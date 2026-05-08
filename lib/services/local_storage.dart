import 'dart:convert';
import 'package:flutter/painting.dart';
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
  static String _kOrders(String uid) => 'orders_$uid';
  static String _kAddresses(String uid) => 'addresses_$uid';

  // ── Bouquet serialize/deserialize ─────────────────────────
  static Map<String, dynamic> _bouquetToJson(Bouquet b) => {
        'id': b.id,
        'name': b.name,
        'flowers': b.flowers.map((f) => f.letter).toList(),
        'ribbon': b.ribbon.index,
        'size': b.size.index,
        'giftMessage': b.giftMessage,
        'template': b.template.index,
        'previewAssetPath': b.previewAssetPath,
        'specialBouquetId': b.specialBouquetId,
        'placedFlowers': b.placedFlowers
            .map((p) => {
                  'id': p.id,
                  'letter': p.flower.letter,
                  'x': p.position.dx,
                  'y': p.position.dy,
                  'scale': p.scale,
                  'rotation': p.rotation,
                })
            .toList(),
      };

  static Bouquet? _bouquetFromJson(Map<String, dynamic> j) {
    try {
      final flowers = (j['flowers'] as List)
          .map((l) => flowerAlphabet[l])
          .whereType<Flower>()
          .toList();
      final templateIdx = (j['template'] as int?) ?? 0;
      final placedJson = (j['placedFlowers'] as List?) ?? [];
      final placed = placedJson
          .map((pj) {
            final flower = flowerAlphabet[pj['letter'] as String];
            if (flower == null) return null;
            return PlacedFlowerData(
              id: pj['id'] as String? ?? 'pf_0',
              flower: flower,
              position: Offset(
                (pj['x'] as num).toDouble(),
                (pj['y'] as num).toDouble(),
              ),
              scale: (pj['scale'] as num).toDouble(),
              rotation: (pj['rotation'] as num).toDouble(),
            );
          })
          .whereType<PlacedFlowerData>()
          .toList();
      return Bouquet(
        id: j['id'] as String,
        name: j['name'] as String,
        flowers: flowers,
        ribbon: RibbonStyle.values[j['ribbon'] as int],
        size: BouquetSize.values[j['size'] as int],
        giftMessage: j['giftMessage'] as String?,
        template: BouquetTemplate
            .values[templateIdx.clamp(0, BouquetTemplate.values.length - 1)],
        placedFlowers: placed,
        previewAssetPath: j['previewAssetPath'] as String?,
        specialBouquetId: j['specialBouquetId'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  // ── SavedBouquet ──────────────────────────────────────────
  static Future<void> saveSaved(String userId, List<SavedBouquet> saved) async {
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

  static Future<List<BouquetCollection>> loadCollections(String userId) async {
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
  static Future<void> saveCart(String userId, List<CartItem> cart) async {
    await init();
    final list = cart
        .map((it) => {
              'id': it.id,
              'bouquet': _bouquetToJson(it.bouquet),
              'qty': it.qty,
              'addedAt': it.addedAt.toIso8601String(),
              'isLego': it.isLego,
              'giftNote': it.giftNote,
              'deliveryDate': it.deliveryDate?.toIso8601String(),
              'deliveryAddress': it.deliveryAddress,
              'isNft': it.isNft,
              'giftNoteFee': it.giftNoteFee,
              'nftMintFee': it.nftMintFee,
              'nftHash': it.nftHash,
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
            final deliveryRaw = j['deliveryDate'] as String?;
            return CartItem(
              id: j['id'] as String,
              bouquet: b,
              qty: j['qty'] as int,
              addedAt: DateTime.parse(j['addedAt'] as String),
              isLego: j['isLego'] as bool? ?? false,
              giftNote: j['giftNote'] as String?,
              deliveryDate:
                  deliveryRaw != null ? DateTime.parse(deliveryRaw) : null,
              deliveryAddress: j['deliveryAddress'] as String?,
              isNft: j['isNft'] as bool? ?? false,
              giftNoteFee: (j['giftNoteFee'] as num?)?.toDouble() ?? 0.0,
              nftMintFee: (j['nftMintFee'] as num?)?.toDouble() ?? 0.0,
              nftHash: j['nftHash'] as String?,
            );
          })
          .whereType<CartItem>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Orders ────────────────────────────────────────────────
  static Future<void> saveOrders(String userId, List<Order> orders) async {
    await init();
    final list = orders
        .map((o) => {
              'id': o.id,
              'items': o.items
                  .map((it) => {
                        'id': it.id,
                        'bouquet': _bouquetToJson(it.bouquet),
                        'qty': it.qty,
                        'addedAt': it.addedAt.toIso8601String(),
                        'isLego': it.isLego,
                        'giftNote': it.giftNote,
                        'deliveryDate': it.deliveryDate?.toIso8601String(),
                        'deliveryAddress': it.deliveryAddress,
                        'isNft': it.isNft,
                        'giftNoteFee': it.giftNoteFee,
                        'nftMintFee': it.nftMintFee,
                        'nftHash': it.nftHash,
                      })
                  .toList(),
              'recipientName': o.recipientName,
              'address': o.address,
              'phone': o.phone,
              'email': o.email,
              'giftMessage': o.giftMessage,
              'status': o.status.index,
              'createdAt': o.createdAt.toIso8601String(),
              'total': o.total,
            })
        .toList();
    await _prefs!.setString(_kOrders(userId), jsonEncode(list));
  }

  static Future<List<Order>> loadOrders(String userId) async {
    await init();
    final raw = _prefs!.getString(_kOrders(userId));
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((j) {
            final itemsJson = j['items'] as List;
            final items = itemsJson
                .map((it) {
                  final b =
                      _bouquetFromJson(it['bouquet'] as Map<String, dynamic>);
                  if (b == null) return null;
                  final deliveryRaw = it['deliveryDate'] as String?;
                  return CartItem(
                    id: it['id'] as String,
                    bouquet: b,
                    qty: it['qty'] as int,
                    addedAt: DateTime.parse(it['addedAt'] as String),
                    isLego: it['isLego'] as bool? ?? false,
                    giftNote: it['giftNote'] as String?,
                    deliveryDate: deliveryRaw != null
                        ? DateTime.parse(deliveryRaw)
                        : null,
                    deliveryAddress: it['deliveryAddress'] as String?,
                    isNft: it['isNft'] as bool? ?? false,
                    giftNoteFee: (it['giftNoteFee'] as num?)?.toDouble() ?? 0.0,
                    nftMintFee: (it['nftMintFee'] as num?)?.toDouble() ?? 0.0,
                    nftHash: it['nftHash'] as String?,
                  );
                })
                .whereType<CartItem>()
                .toList();
            if (items.isEmpty) return null;
            return Order(
              id: j['id'] as String,
              items: items,
              recipientName: j['recipientName'] as String,
              address: j['address'] as String,
              phone: j['phone'] as String,
              email: j['email'] as String,
              giftMessage: j['giftMessage'] as String?,
              status: OrderStatus.values[j['status'] as int? ?? 0],
              createdAt: DateTime.parse(j['createdAt'] as String),
              total: (j['total'] as num).toDouble(),
            );
          })
          .whereType<Order>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Addresses ─────────────────────────────────────────────
  static Future<void> saveAddresses(
      String userId, List<dynamic> addresses) async {
    await init();
    final list = addresses
        .map((a) => {
              'id': a.id,
              'title': a.title,
              'city': a.city,
              'district': a.district,
              'fullAddress': a.fullAddress,
              'isDefault': a.isDefault,
            })
        .toList();
    await _prefs!.setString(_kAddresses(userId), jsonEncode(list));
  }

  static Future<List<_AddressData>> loadAddresses(String userId) async {
    await init();
    final raw = _prefs!.getString(_kAddresses(userId));
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((j) => _AddressData(
                id: j['id'] as String,
                title: j['title'] as String,
                city: j['city'] as String,
                district: j['district'] as String,
                fullAddress: j['fullAddress'] as String,
                isDefault: j['isDefault'] as bool? ?? false,
              ))
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
    await _prefs!.remove(_kOrders(userId));
    await _prefs!.remove(_kAddresses(userId));
  }
}

class _AddressData {
  final String id, title, city, district, fullAddress;
  final bool isDefault;
  const _AddressData({
    required this.id,
    required this.title,
    required this.city,
    required this.district,
    required this.fullAddress,
    required this.isDefault,
  });
}
