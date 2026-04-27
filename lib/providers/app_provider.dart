import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../data/flower_data.dart';

class AppProvider extends ChangeNotifier {
  AppProvider() {
    _loadUsers();
  }

  // ── Auth ──────────────────────────────────────────────
  AppUser? _user;
  bool _isLoggedIn = false;
  // Kayıtlı kullanıcı listesi: key = lowercase email
  final Map<String, _RegisteredUser> _registered = {};
  bool _usersLoaded = false;

  AppUser? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  bool get usersLoaded => _usersLoaded;

  Future<void> _loadUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('bloomix_users');
      if (raw != null) {
        final list = jsonDecode(raw) as List;
        for (final m in list) {
          final u = _RegisteredUser.fromJson(m as Map<String, dynamic>);
          _registered[u.email.toLowerCase()] = u;
        }
      }
    } catch (_) {
      // bozuk veri varsa sıfırla
    }
    _usersLoaded = true;
    notifyListeners();
  }

  Future<void> _saveUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _registered.values.map((u) => u.toJson()).toList();
      await prefs.setString('bloomix_users', jsonEncode(list));
    } catch (_) {}
  }

  /// null = başarılı; string = hata mesajı
  Future<String?> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final key = email.trim().toLowerCase();
    if (key.isEmpty) return 'E-posta gerekli.';
    if (password.isEmpty) return 'Şifre gerekli.';
    final found = _registered[key];
    if (found == null) {
      return 'Bu e-posta ile kayıtlı kullanıcı yok. Önce kayıt ol.';
    }
    if (found.password != password) {
      return 'Şifre hatalı.';
    }
    _user = AppUser(id: found.id, name: found.name, email: found.email);
    _isLoggedIn = true;
    notifyListeners();
    return null;
  }

  /// null = başarılı; string = hata mesajı
  Future<String?> register(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final cleanName = name.trim();
    final cleanEmail = email.trim();
    final key = cleanEmail.toLowerCase();
    if (cleanName.isEmpty) return 'Ad soyad gerekli.';
    if (!cleanEmail.contains('@') || !cleanEmail.contains('.')) {
      return 'Geçerli bir e-posta adresi gir.';
    }
    if (password.length < 6) return 'Şifre en az 6 karakter olmalı.';
    if (_registered.containsKey(key)) {
      return 'Bu e-posta zaten kayıtlı. Giriş yap.';
    }
    final id = 'usr_${DateTime.now().millisecondsSinceEpoch}';
    _registered[key] = _RegisteredUser(
      id: id,
      name: cleanName,
      email: cleanEmail,
      password: password,
    );
    await _saveUsers();
    _user = AppUser(id: id, name: cleanName, email: cleanEmail);
    _isLoggedIn = true;
    notifyListeners();
    return null;
  }

  void logout() {
    _user = null;
    _isLoggedIn = false;
    _currentBouquet = null;
    _inputName = '';
    notifyListeners();
  }

  void updateProfile(String name) {
    if (_user != null) {
      _user = _user!.copyWith(name: name);
      // kayıtlı kullanıcı listesinde de güncelle
      final key = _user!.email.toLowerCase();
      final existing = _registered[key];
      if (existing != null) {
        _registered[key] = _RegisteredUser(
          id: existing.id,
          name: name,
          email: existing.email,
          password: existing.password,
        );
        _saveUsers();
      }
      notifyListeners();
    }
  }

  // ── Bouquet Builder ───────────────────────────────────
  String _inputName = '';
  List<Flower> _flowers = [];
  WrapperStyle _wrapper = WrapperStyle.white;
  BouquetSize _size = BouquetSize.medium;
  Bouquet? _currentBouquet;

  String get inputName => _inputName;
  List<Flower> get flowers => _flowers;
  WrapperStyle get wrapper => _wrapper;
  BouquetSize get size => _size;
  Bouquet? get currentBouquet => _currentBouquet;
  bool get hasBouquet => _flowers.isNotEmpty;

  void generateBouquet(String name) {
    _inputName = name.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    _flowers = getFlowersForName(_inputName);
    _currentBouquet = _flowers.isEmpty ? null : Bouquet(
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

  // ── Favorites ─────────────────────────────────────────
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

  // ── Notifications ─────────────────────────────────────
  final List<AppNotification> _notifications = [
    AppNotification(title: 'Bloomix\'e Hoş Geldin!', body: 'İsminden ilk buketini oluştur.', time: DateTime.now().subtract(const Duration(minutes: 5))),
    AppNotification(title: 'Yeni Çiçek Eklendi', body: 'Krizantem koleksiyona katıldı!', time: DateTime.now().subtract(const Duration(hours: 2))),
    AppNotification(title: 'Kampanya', body: 'Bu hafta büyük buketlerde %10 indirim!', time: DateTime.now().subtract(const Duration(days: 1))),
  ];
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.length;

  // ── Orders ────────────────────────────────────────────
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
    _notifications.insert(0, AppNotification(
      title: 'Siparişin Alındı!',
      body: '${order.id} numaralı siparişin onaylandı.',
      time: DateTime.now(),
    ));
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

/// Sadece local auth için. Şifre düz metin tutuluyor — bu okul projesi.
/// Gerçek bir uygulamada asla böyle yapma; backend + hash kullan.
class _RegisteredUser {
  final String id;
  final String name;
  final String email;
  final String password;

  _RegisteredUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'password': password,
      };

  factory _RegisteredUser.fromJson(Map<String, dynamic> j) => _RegisteredUser(
        id: j['id'] as String,
        name: j['name'] as String,
        email: j['email'] as String,
        password: j['password'] as String,
      );
}
