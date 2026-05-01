import 'dart:async';
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
  WrapperStyle _wrapper = WrapperStyle.pastelPink;
  BouquetSize _size = BouquetSize.medium;
  Bouquet? _currentBouquet;

  String get inputName => _inputName;
  List<Flower> get flowers => _flowers;
  WrapperStyle get wrapper => _wrapper;
  BouquetSize get size => _size;
  Bouquet? get currentBouquet => _currentBouquet;
  bool get hasBouquet => _flowers.isNotEmpty;

  void generateBouquet(String name) {
    _inputName = turkishUpperCase(name)
        .split('')
        .where((c) => flowerAlphabet.containsKey(c))
        .join('');
    _flowers = getFlowersForName(name);
    _currentBouquet = _flowers.isEmpty
        ? null
        : Bouquet(
            id: 'b_${DateTime.now().millisecondsSinceEpoch}',
            name: _inputName,
            flowers: _flowers,
            wrapper: _wrapper,
            size: _size,
          );
    notifyListeners();
  }

  void setWrapper(WrapperStyle w) {
    _wrapper = w;
    _rebuildBouquet();
  }

  void setSize(BouquetSize s) {
    _size = s;
    _rebuildBouquet();
  }

  void _rebuildBouquet() {
    if (_flowers.isNotEmpty) {
      _currentBouquet = Bouquet(
        id: _currentBouquet?.id ?? 'b_${DateTime.now().millisecondsSinceEpoch}',
        name: _inputName,
        flowers: _flowers,
        wrapper: _wrapper,
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

  Order placeOrder({
    required String recipientName,
    required String address,
    required String phone,
    required String email,
    String? giftMessage,
  }) {
    final order = Order(
      id: 'BLX-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
      bouquet: _currentBouquet!,
      recipientName: recipientName,
      address: address,
      phone: phone,
      email: email,
      giftMessage: giftMessage,
      createdAt: DateTime.now(),
      total: _currentBouquet!.price,
    );
    _orders.add(order);
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
