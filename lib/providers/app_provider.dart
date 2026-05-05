import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../models/models.dart';
import '../data/flower_data.dart';
import '../services/supabase_service.dart';
import '../services/local_storage.dart';

class AppProvider extends ChangeNotifier {
  AppProvider() {
    _initAuth();
  }

  // ── Auth (Supabase tarafından yönetiliyor) ────────────────────────────────
  AppUser? _user;
  StreamSubscription<sb.AuthState>? _authSub;

  AppUser? get user => _user;
  bool get isLoggedIn => SupabaseService.isLoggedIn;

  // Hangi kullanıcı için veri yüklendiğini takip eder — tekrar yüklemeyi önler.
  String? _loadedForUserId;

  /// Mevcut session'dan AppUser üretir + auth değişikliklerini dinler.
  void _initAuth() {
    _hydrateUserFromSession();
    _maybeLoadUserData();
    _authSub = SupabaseService.onAuthStateChange.listen((event) {
      _hydrateUserFromSession();
      _maybeLoadUserData();
      notifyListeners();
    });
  }

  /// Yüklü kullanıcı farklıysa veriyi yükler (tekrar yüklemeyi önler).
  void _maybeLoadUserData() {
    final uid = _user?.id;
    if (uid != null && uid != _loadedForUserId) {
      _loadedForUserId = uid;
      _loadUserData();
    } else if (uid == null) {
      _loadedForUserId = null;
    }
  }

  Future<void> _loadUserData() async {
    final uid = _user?.id ?? SupabaseService.currentUser?.id;
    if (uid == null) return;
    final saved = await LocalStorage.loadSaved(uid);
    final cols = await LocalStorage.loadCollections(uid);
    final cart = await LocalStorage.loadCart(uid);

    _saved
      ..clear()
      ..addAll(saved);

    if (cols.isEmpty) {
      // İlk giriş — sadece Favoriler koleksiyonu zaten var
    } else {
      _collections
        ..clear()
        ..addAll(cols);
      // sys_favorites yoksa ekle
      if (!_collections.any((c) => c.id == 'sys_favorites')) {
        _collections.insert(
          0,
          BouquetCollection(
            id: 'sys_favorites',
            name: 'Favoriler',
            emoji: '❤️',
            isSystem: true,
            createdAt: DateTime(2024, 1, 1),
          ),
        );
      }
    }

    _cart
      ..clear()
      ..addAll(cart);

    notifyListeners();
  }

  void _persist() {
    final uid = _user?.id;
    if (uid == null) return;
    Future.wait([
      LocalStorage.saveSaved(uid, List.from(_saved)),
      LocalStorage.saveCollections(uid, List.from(_collections)),
      LocalStorage.saveCart(uid, List.from(_cart)),
    ]).catchError((_) {});
  }

  void _hydrateUserFromSession() {
    final sbUser = SupabaseService.currentUser;
    if (sbUser == null) {
      _user = null;
      return;
    }
    final meta = sbUser.userMetadata ?? const {};
    final fullName = (meta['full_name'] as String?) ??
        (meta['name'] as String?) ??
        sbUser.email?.split('@').first ??
        'Kullanıcı';
    _user = AppUser(
      id: sbUser.id,
      name: fullName,
      email: sbUser.email ?? '',
      photoUrl: meta['avatar_url'] as String?,
    );
  }

  /// İsim değişikliği — Supabase profiles tablosuna yansıt.
  Future<void> updateProfile(String name) async {
    if (_user == null) return;
    _user = _user!.copyWith(name: name);
    notifyListeners();
    try {
      await SupabaseService.updateProfile(fullName: name);
    } catch (_) {
      // Hata olursa lokal state'i geri almıyoruz; sonraki refresh düzeltir.
    }
  }

  Future<void> logout() async {
    _loadedForUserId = null;
    await SupabaseService.signOut();
    _currentBouquet = null;
    _flowers = [];
    _placedFlowers = [];
    _isFreeDesign = false;
    _inputName = '';
    _saved.clear();
    _cart.clear();
    _collections.removeWhere((c) => !c.isSystem);
    final favIdx = _collections.indexWhere((c) => c.id == 'sys_favorites');
    if (favIdx >= 0) {
      _collections[favIdx] = _collections[favIdx].copyWith(savedBouquetIds: []);
    }
    // Lokal veriyi silme — kullanıcı tekrar girince geri yüklensin
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  // ── Bouquet Builder ───────────────────────────────────────────────────────
  String _inputName = '';
  List<Flower> _flowers = [];
  /// Kullanıcı tasarladıysa bunlar dolu. Alfabe akışında otomatik dome pozisyonu üretilir.
  /// BouquetPreview hep buradan render eder.
  List<PlacedFlowerData> _placedFlowers = [];
  RibbonStyle _ribbon = RibbonStyle.red;
  BouquetSize _size = BouquetSize.medium;
  Bouquet? _currentBouquet;
  /// True = serbest tasarla akışından geldi, False = alfabe akışı.
  bool _isFreeDesign = false;

  String get inputName => _inputName;
  List<Flower> get flowers => _flowers;
  List<PlacedFlowerData> get placedFlowers =>
      List.unmodifiable(_placedFlowers);
  RibbonStyle get ribbon => _ribbon;
  BouquetSize get size => _size;
  Bouquet? get currentBouquet => _currentBouquet;
  bool get hasBouquet => _flowers.isNotEmpty;
  bool get isFreeDesign => _isFreeDesign;

  /// Alfabe akışı: isimden çiçekler + dome pozisyonları üretir.
  void generateBouquet(String name) {
    _inputName = turkishUpperCase(name)
        .split('')
        .where((c) => flowerAlphabet.containsKey(c))
        .join('');
    _flowers = getFlowersForName(name);
    _isFreeDesign = false;
    _placedFlowers = _generateDomePositions(_flowers);
    _currentBouquet = _flowers.isEmpty
        ? null
        : Bouquet(
            id: 'b_${DateTime.now().millisecondsSinceEpoch}',
            name: _inputName,
            flowers: _flowers,
            ribbon: _ribbon,
            size: _size,
          );
    notifyListeners();
  }

  /// Serbest tasarla akışı: kullanıcının placed flower verilerini direkt kullan.
  void setPlacedFlowers(List<PlacedFlowerData> placed,
      {String name = 'Tasarımım'}) {
    _placedFlowers = List.from(placed);
    _flowers = placed.map((p) => p.flower).toList();
    _inputName = name;
    _isFreeDesign = true;
    _rebuildBouquet();
  }

  /// Özel Gün şablon buketini editöre yükler (Kişiselleştir akışı).
  /// Çiçek listesinden otomatik dome pozisyonu üretilir; kullanıcı
  /// BouquetBuilder + Customize'da kurdele/boyut değiştirebilir.
  void loadTemplateBouquet({
    required String name,
    required List<Flower> flowers,
    required RibbonStyle ribbon,
    required BouquetSize size,
  }) {
    _flowers = List.from(flowers);
    _ribbon = ribbon;
    _size = size;
    _inputName = name;
    _isFreeDesign = false;
    _placedFlowers = _generateDomePositions(_flowers);
    _currentBouquet = _flowers.isEmpty
        ? null
        : Bouquet(
            id: 'b_${DateTime.now().millisecondsSinceEpoch}',
            name: name,
            flowers: _flowers,
            ribbon: _ribbon,
            size: _size,
          );
    notifyListeners();
  }

  void setRibbon(RibbonStyle r) {
    _ribbon = r;
    _rebuildBouquet();
  }

  void setSize(BouquetSize s) {
    _size = s;
    _rebuildBouquet();
  }

  /// İsimsel buket için pozisyon üretici — sıkı dome.
  List<PlacedFlowerData> _generateDomePositions(List<Flower> flowers) {
    final n = flowers.length;
    if (n == 0) return [];
    const cx = 0.5;
    const baseY = 0.40;
    final radius = n <= 3 ? 0.10 : (n <= 6 ? 0.14 : 0.18);
    return List.generate(n, (i) {
      final t = (n == 1) ? 0.0 : (i - (n - 1) / 2) / ((n - 1) / 2);
      final angle = t * pi / 2.5;
      final x = cx + sin(angle) * radius;
      final y = baseY + (1 - cos(angle)) * radius * 0.85;
      return PlacedFlowerData(
        id: 'dome_$i',
        flower: flowers[i],
        position: Offset(x, y),
        scale: 1.0 - t.abs() * 0.12,
        rotation: t * 0.12,
      );
    });
  }

  void _rebuildBouquet() {
    if (_flowers.isNotEmpty) {
      _currentBouquet = Bouquet(
        id: _currentBouquet?.id ?? 'b_${DateTime.now().millisecondsSinceEpoch}',
        name: _inputName,
        flowers: _flowers,
        ribbon: _ribbon,
        size: _size,
      );
    }
    notifyListeners();
  }

  // ── Saved + Collections ─────────────────────────────────────────────────
  /// Kullanıcının kütüphaneye kaydettiği buketler.
  final List<SavedBouquet> _saved = [];
  List<SavedBouquet> get saved => List.unmodifiable(_saved);

  /// Sistem + kullanıcı koleksiyonları. İlk eleman daima Favoriler (sistem).
  final List<BouquetCollection> _collections = [
    BouquetCollection(
      id: 'sys_favorites',
      name: 'Favoriler',
      emoji: '❤️',
      isSystem: true,
      createdAt: DateTime(2024, 1, 1),
    ),
  ];
  List<BouquetCollection> get collections => List.unmodifiable(_collections);

  /// Sistem favorisi koleksiyonu — kısa yol.
  BouquetCollection get _favoritesCollection =>
      _collections.firstWhere((c) => c.id == 'sys_favorites');

  /// Bir koleksiyonun saved buket içeriklerini sırayla döndürür.
  List<SavedBouquet> bouquetsInCollection(String collectionId) {
    final c = _collections.firstWhere(
      (c) => c.id == collectionId,
      orElse: () => _collections.first,
    );
    return c.savedBouquetIds
        .map((id) {
          for (final s in _saved) {
            if (s.id == id) return s;
          }
          return null;
        })
        .whereType<SavedBouquet>()
        .toList();
  }

  /// Bir bouquet ID'si saved listesinde var mı?
  SavedBouquet? findSavedByBouquetId(String bouquetId) {
    for (final s in _saved) {
      if (s.bouquet.id == bouquetId) return s;
    }
    return null;
  }

  /// ── Save / Unsave ──────────────────────────────────────
  /// Buketi kütüphaneye kaydeder. Zaten varsa mevcut id döner.
  String saveBouquet(Bouquet b) {
    final existing = findSavedByBouquetId(b.id);
    if (existing != null) return existing.id;
    final saved = SavedBouquet(
      id: 's_${DateTime.now().millisecondsSinceEpoch}',
      bouquet: b,
      savedAt: DateTime.now(),
    );
    _saved.add(saved);
    notifyListeners();
    _persist();
    return saved.id;
  }

  void unsaveBouquet(String savedId) {
    _saved.removeWhere((s) => s.id == savedId);
    for (int i = 0; i < _collections.length; i++) {
      final c = _collections[i];
      if (c.savedBouquetIds.contains(savedId)) {
        _collections[i] = c.copyWith(
          savedBouquetIds:
              c.savedBouquetIds.where((id) => id != savedId).toList(),
        );
      }
    }
    notifyListeners();
    _persist();
  }

  /// ── Collection CRUD ────────────────────────────────────
  String createCollection({
    required String name,
    String emoji = '📁',
    String? description,
  }) {
    final c = BouquetCollection(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      emoji: emoji,
      description: description,
      createdAt: DateTime.now(),
    );
    _collections.add(c);
    notifyListeners();
    _persist();
    return c.id;
  }

  void renameCollection(String collectionId,
      {String? name, String? emoji, String? description}) {
    final i = _collections.indexWhere((c) => c.id == collectionId);
    if (i < 0 || _collections[i].isSystem) return;
    _collections[i] = _collections[i].copyWith(
      name: name,
      emoji: emoji,
      description: description,
    );
    notifyListeners();
    _persist();
  }

  void deleteCollection(String collectionId) {
    final i = _collections.indexWhere((c) => c.id == collectionId);
    if (i < 0 || _collections[i].isSystem) return;
    _collections.removeAt(i);
    notifyListeners();
    _persist();
  }

  /// ── Membership ────────────────────────────────────────
  bool isInCollection(String savedId, String collectionId) {
    final c = _collections.firstWhere(
      (c) => c.id == collectionId,
      orElse: () => _favoritesCollection,
    );
    return c.savedBouquetIds.contains(savedId);
  }

  void addToCollection(String savedId, String collectionId) {
    final i = _collections.indexWhere((c) => c.id == collectionId);
    if (i < 0) return;
    final c = _collections[i];
    if (c.savedBouquetIds.contains(savedId)) return;
    _collections[i] = c.copyWith(
      savedBouquetIds: [...c.savedBouquetIds, savedId],
    );
    notifyListeners();
    _persist();
  }

  void removeFromCollection(String savedId, String collectionId) {
    final i = _collections.indexWhere((c) => c.id == collectionId);
    if (i < 0) return;
    final c = _collections[i];
    if (!c.savedBouquetIds.contains(savedId)) return;
    _collections[i] = c.copyWith(
      savedBouquetIds:
          c.savedBouquetIds.where((id) => id != savedId).toList(),
    );
    notifyListeners();
    _persist();
  }

  /// ── Favorites compatibility ────────────────────────────
  /// Bouquet bazlı API — eski koddan değişmemesi için korunuyor.
  List<Bouquet> get favorites =>
      bouquetsInCollection('sys_favorites').map((s) => s.bouquet).toList();

  bool isFavorite(String bouquetId) {
    final saved = findSavedByBouquetId(bouquetId);
    if (saved == null) return false;
    return _favoritesCollection.savedBouquetIds.contains(saved.id);
  }

  /// Bouquet'i favorilere ekle/çıkar — gerekirse otomatik save eder.
  void toggleFavorite(Bouquet bouquet) {
    final saved = findSavedByBouquetId(bouquet.id);
    if (saved == null) {
      // İlk kez: önce kaydet, sonra Favoriler'e ekle
      final newId = saveBouquet(bouquet);
      addToCollection(newId, 'sys_favorites');
    } else {
      // Zaten kayıtlı — Favoriler durumunu toggle et
      if (_favoritesCollection.savedBouquetIds.contains(saved.id)) {
        removeFromCollection(saved.id, 'sys_favorites');
      } else {
        addToCollection(saved.id, 'sys_favorites');
      }
    }
  }

  // ── Cart ─────────────────────────────────────────────────────────────────
  final List<CartItem> _cart = [];
  List<CartItem> get cart => List.unmodifiable(_cart);

  /// Sepetteki toplam adet (her line item'ın qty toplamı).
  int get cartCount => _cart.fold(0, (s, it) => s + it.qty);

  /// Sepetin toplam fiyatı (TL).
  double get cartTotal => _cart.fold(0.0, (s, it) => s + it.lineTotal);

  /// Sepetteki toplam lego brick adedi.
  int get cartLegoCount => _cart.fold(0, (s, it) => s + it.lineLegoCount);

  /// Aynı bouquet ID zaten varsa adet artar; yoksa yeni satır.
  void addToCart(Bouquet b, {int qty = 1}) {
    final idx = _cart.indexWhere((it) => it.bouquet.id == b.id);
    if (idx >= 0) {
      _cart[idx] = _cart[idx].copyWith(qty: _cart[idx].qty + qty);
    } else {
      _cart.add(CartItem(
        id: 'c_${DateTime.now().millisecondsSinceEpoch}',
        bouquet: b,
        qty: qty,
        addedAt: DateTime.now(),
      ));
    }
    notifyListeners();
    _persist();
  }

  void removeFromCart(String cartItemId) {
    _cart.removeWhere((it) => it.id == cartItemId);
    notifyListeners();
    _persist();
  }

  void updateCartQty(String cartItemId, int qty) {
    final idx = _cart.indexWhere((it) => it.id == cartItemId);
    if (idx < 0) return;
    if (qty <= 0) {
      _cart.removeAt(idx);
    } else {
      _cart[idx] = _cart[idx].copyWith(qty: qty);
    }
    notifyListeners();
    _persist();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
    _persist();
  }

  // ── Notifications ─────────────────────────────────────────────────────────
  final List<AppNotification> _notifications = [
    AppNotification(
      title: 'Bloomix\'e Hoş Geldin!',
      body: 'İsminden ilk buketini oluştur.',
      time: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    AppNotification(
      title: 'Yeni Çiçek Eklendi',
      body: 'Krizantem koleksiyona katıldı!',
      time: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AppNotification(
      title: 'Kampanya',
      body: 'Bu hafta büyük buketlerde %10 indirim!',
      time: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.length;

  // ── Orders ────────────────────────────────────────────────────────────────
  final List<Order> _orders = [];
  List<Order> get orders => List.unmodifiable(_orders.reversed.toList());

  /// Sepetteki tüm buketleri tek bir order'a çevirir.
  /// Cart boşsa null döner. Order başarılı olunca cart temizlenir.
  Order? placeOrder({
    required String recipientName,
    required String address,
    required String phone,
    required String email,
    String? giftMessage,
  }) {
    if (_cart.isEmpty) return null;
    final snapshot = List<CartItem>.from(_cart);
    final order = Order(
      id: 'BLX-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
      items: snapshot,
      recipientName: recipientName,
      address: address,
      phone: phone,
      email: email,
      giftMessage: giftMessage,
      createdAt: DateTime.now(),
      total: snapshot.fold(0.0, (s, it) => s + it.lineTotal),
    );
    _orders.add(order);
    _cart.clear();
    _notifications.insert(
      0,
      AppNotification(
        title: 'Siparişin Alındı!',
        body: '${order.id} numaralı siparişin onaylandı.',
        time: DateTime.now(),
      ),
    );
    notifyListeners();
    return order;
  }
}

class AppNotification {
  final String title;
  final String body;
  final DateTime time;
  AppNotification({required this.title, required this.body, required this.time});
}
