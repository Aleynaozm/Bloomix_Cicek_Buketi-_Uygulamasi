import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../data/flower_data.dart';

/// Sepet, kaydedilenler ve koleksiyonları cihaza kaydeder.
/// Tüm anahtarlar userId ile prefikslendiğinden farklı hesaplar karışmaz.
class LocalStorage {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ── Anahtarlar ────────────────────────────────────────────
  static String _kSaved(String uid) => 'saved_$uid';
  static String _kCollections(String uid) => 'collections_$uid';
  static String _kCart(String uid) => 'cart_$uid';

  // ── Bouquet serialize/deserialize ─────────────────────────
  static Map<String, dynamic> _bouquetToJson(Bouquet b) => {
        'id': b.id,
        'name': b.name,
        'flowers': b.flowers.map((f) => f.letter).toList(),
        'ribbon': b.ribbon.index,
        'size': b.size.index,
        'giftMessage': b.giftMessage,
      };

  static Bouquet? _bouquetFromJson(Map<String, dynamic> j) {
    try {
      final flowers = (j['flowers'] as List)
          .map((l) => flowerAlphabet[l])
          .whereType<Flower>()
          .toList();
      return Bouquet(
        id: j['id'] as String,
        name: j['name'] as String,
        flowers: flowers,
        ribbon: RibbonStyle.values[j['ribbon'] as int],
        size: BouquetSize.values[j['size'] as int],
        giftMessage: j['giftMessage'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  // ── SavedBouquet ──────────────────────────────────────────
  static Future<void> saveSaved(
      String userId, List<SavedBouquet> saved) async {
    await init();
    final list = saved
        .map((s) => {
              'id': s.id,
              'bouquet': _bouquetToJson(s.bouquet),
              'savedAt': s.savedAt.toIso8601String(),
            })
        .toList();
    await _prefs!.setString(_kSaved(userId), jsonEncode(list));
  }

  static Future<List<SavedBouquet>> loadSaved(String userId) async {
    await init();
    final raw = _prefs!.getString(_kSaved(userId));
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((j) {
            final b = _bouquetFromJson(j['bouquet'] as Map<String, dynamic>);
            if (b == null) return null;
            return SavedBouquet(
              id: j['id'] as String,
              bouquet: b,
              savedAt: DateTime.parse(j['savedAt'] as String),
            );
          })
          .whereType<SavedBouquet>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Collections ───────────────────────────────────────────
  static Future<void> saveCollections(
      String userId, List<BouquetCollection> cols) async {
    await init();
    final list = cols
        .map((c) => {
              'id': c.id,
              'name': c.name,
              'emoji': c.emoji,
              'description': c.description,
              'createdAt': c.createdAt.toIso8601String(),
              'isSystem': c.isSystem,
              'savedBouquetIds': c.savedBouquetIds,
            })
        .toList();
    await _prefs!.setString(_kCollections(userId), jsonEncode(list));
  }

  static Future<List<BouquetCollection>> loadCollections(
      String userId) async {
    await init();
    final raw = _prefs!.getString(_kCollections(userId));
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((j) => BouquetCollection(
                id: j['id'] as String,
                name: j['name'] as String,
                emoji: j['emoji'] as String,
                description: j['description'] as String?,
                createdAt: DateTime.parse(j['createdAt'] as String),
                isSystem: j['isSystem'] as bool,
                savedBouquetIds:
                    List<String>.from(j['savedBouquetIds'] as List),
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Cart ──────────────────────────────────────────────────
  static Future<void> saveCart(
      String userId, List<CartItem> cart) async {
    await init();
    final list = cart
        .map((it) => {
              'id': it.id,
              'bouquet': _bouquetToJson(it.bouquet),
              'qty': it.qty,
              'addedAt': it.addedAt.toIso8601String(),
            })
        .toList();
    await _prefs!.setString(_kCart(userId), jsonEncode(list));
  }

  static Future<List<CartItem>> loadCart(String userId) async {
    await init();
    final raw = _prefs!.getString(_kCart(userId));
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((j) {
            final b = _bouquetFromJson(j['bouquet'] as Map<String, dynamic>);
            if (b == null) return null;
            return CartItem(
              id: j['id'] as String,
              bouquet: b,
              qty: j['qty'] as int,
              addedAt: DateTime.parse(j['addedAt'] as String),
            );
          })
          .whereType<CartItem>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Temizle (logout) ──────────────────────────────────────
  static Future<void> clear(String userId) async {
    await init();
    await _prefs!.remove(_kSaved(userId));
    await _prefs!.remove(_kCollections(userId));
    await _prefs!.remove(_kCart(userId));
  }
}
