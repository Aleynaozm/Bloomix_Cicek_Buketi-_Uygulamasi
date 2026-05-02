import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../models/models.dart';
import '../data/flower_data.dart';
import '../services/supabase_service.dart';

class AppProvider extends ChangeNotifier {
  AppProvider() {
    _initAuth();
  }

  // ── Auth (Supabase tarafından yönetiliyor) ────────────────────────────────
  AppUser? _user;
  StreamSubscription<sb.AuthState>? _authSub;

  AppUser? get user => _user;
  bool get isLoggedIn => SupabaseService.isLoggedIn;

  /// Mevcut session'dan AppUser üretir + auth değişikliklerini dinler.
  void _initAuth() {
    _hydrateUserFromSession();
    _authSub = SupabaseService.onAuthStateChange.listen((event) {
      _hydrateUserFromSession();
      notifyListeners();
    });
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
    await SupabaseService.signOut();
    // Bouquet/sipariş gibi geçici state'leri temizle:
    _currentBouquet = null;
    _flowers = [];
    _placedFlowers = [];
    _isFreeDesign = false;
    _inputName = '';
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

  // ── Favorites ─────────────────────────────────────────────────────────────
  final List<Bouquet> _favorites = [];
  List<Bouquet> get favorites => List.unmodifiable(_favorites);

  bool isFavorite(String id) => _favorites.any((b) => b.id == id);

  void toggleFavorite(Bouquet bouquet) {
    final idx = _favorites.indexWhere((b) => b.id == bouquet.id);
    if (idx >= 0) {
      _favorites.removeAt(idx);
    } else {
      _favorites.add(bouquet);
    }
    notifyListeners();
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
  }

  void removeFromCart(String cartItemId) {
    _cart.removeWhere((it) => it.id == cartItemId);
    notifyListeners();
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
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
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
