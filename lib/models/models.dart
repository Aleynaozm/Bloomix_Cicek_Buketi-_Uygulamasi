import 'package:flutter/material.dart';

// ── Flower ──────────────────────────────────────────────
class Flower {
  final String letter;
  final String nameTr;
  final String nameEn;
  final String meaning;
  final String assetPath;
  final Color color;

  const Flower({
    required this.letter,
    required this.nameTr,
    required this.nameEn,
    required this.meaning,
    required this.assetPath,
    required this.color,
  });
}

// ── Wrapper ──────────────────────────────────────────────
enum WrapperStyle { pastelPink, pastelBlue, pastelLilac, pastelGreen, pastelYellow }

extension WrapperStyleExt on WrapperStyle {
  String get label {
    switch (this) {
      case WrapperStyle.pastelPink:
        return 'Pastel Pembe';
      case WrapperStyle.pastelBlue:
        return 'Pastel Mavi';
      case WrapperStyle.pastelLilac:
        return 'Pastel Lila';
      case WrapperStyle.pastelGreen:
        return 'Pastel Yeşil';
      case WrapperStyle.pastelYellow:
        return 'Pastel Sarı';
    }
  }

  Color get color {
    switch (this) {
      case WrapperStyle.pastelPink:
        return const Color(0xFFF8CDD8);
      case WrapperStyle.pastelBlue:
        return const Color(0xFFBDDDF0);
      case WrapperStyle.pastelLilac:
        return const Color(0xFFD8C5EC);
      case WrapperStyle.pastelGreen:
        return const Color(0xFFC8E2C5);
      case WrapperStyle.pastelYellow:
        return const Color(0xFFF8E8B8);
    }
  }
}

// ── Pricing (lego brick bazlı) ───────────────────────────
/// Birim brick fiyatı (TL). Buket fiyatı = legoCount × pricePerLego.
/// Tek noktadan değiştirilebilir; kampanya/indirim uygulamak için ideal yer.
const double pricePerLego = 12.0;

// ── Size ─────────────────────────────────────────────────
enum BouquetSize { small, medium, large }

extension BouquetSizeExt on BouquetSize {
  String get label {
    switch (this) {
      case BouquetSize.small:
        return 'Küçük';
      case BouquetSize.medium:
        return 'Orta';
      case BouquetSize.large:
        return 'Büyük';
    }
  }

  /// Buketteki çiçek sayısı (görsel düzen için).
  int get count {
    switch (this) {
      case BouquetSize.small:
        return 5;
      case BouquetSize.medium:
        return 9;
      case BouquetSize.large:
        return 15;
    }
  }

  /// Buketin toplam Lego brick adedi (gerçek Lego Botanical setlerine yakın).
  int get legoCount {
    switch (this) {
      case BouquetSize.small:
        return 120;
      case BouquetSize.medium:
        return 240;
      case BouquetSize.large:
        return 400;
    }
  }

  /// Brick × birim fiyat → buket fiyatı.
  double get price => legoCount * pricePerLego;
}

// ── Bouquet ───────────────────────────────────────────────
class Bouquet {
  final String id;
  final String name;
  final List<Flower> flowers;
  final WrapperStyle wrapper;
  final BouquetSize size;
  final String? giftMessage;
  final bool isFavorite;

  const Bouquet({
    required this.id,
    required this.name,
    required this.flowers,
    this.wrapper = WrapperStyle.pastelPink,
    this.size = BouquetSize.medium,
    this.giftMessage,
    this.isFavorite = false,
  });

  /// Buketteki toplam lego brick adedi.
  int get legoCount => size.legoCount;

  /// Buketin TL fiyatı (legoCount × pricePerLego).
  double get price => size.price;

  Bouquet copyWith({
    String? name,
    List<Flower>? flowers,
    WrapperStyle? wrapper,
    BouquetSize? size,
    String? giftMessage,
    bool? isFavorite,
  }) =>
      Bouquet(
        id: id,
        name: name ?? this.name,
        flowers: flowers ?? this.flowers,
        wrapper: wrapper ?? this.wrapper,
        size: size ?? this.size,
        giftMessage: giftMessage ?? this.giftMessage,
        isFavorite: isFavorite ?? this.isFavorite,
      );
}

// ── CartItem ──────────────────────────────────────────────
class CartItem {
  final String id;
  final Bouquet bouquet;
  final int qty;
  final DateTime addedAt;

  const CartItem({
    required this.id,
    required this.bouquet,
    required this.qty,
    required this.addedAt,
  });

  double get lineTotal => bouquet.price * qty;
  int get lineLegoCount => bouquet.legoCount * qty;

  CartItem copyWith({int? qty}) => CartItem(
        id: id,
        bouquet: bouquet,
        qty: qty ?? this.qty,
        addedAt: addedAt,
      );
}

// ── Order ─────────────────────────────────────────────────
enum OrderStatus { confirmed, preparing, shipped, delivered }

extension OrderStatusExt on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.confirmed:
        return 'Onaylandı';
      case OrderStatus.preparing:
        return 'Hazırlanıyor';
      case OrderStatus.shipped:
        return 'Kargoda';
      case OrderStatus.delivered:
        return 'Teslim Edildi';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.confirmed:
        return const Color(0xFF378ADD);
      case OrderStatus.preparing:
        return const Color(0xFFBA7517);
      case OrderStatus.shipped:
        return const Color(0xFF9060D0);
      case OrderStatus.delivered:
        return const Color(0xFF3B6D11);
    }
  }
}

class Order {
  final String id;
  /// Sipariş anında dondurulmuş cart snapshot'ı.
  final List<CartItem> items;
  final String recipientName;
  final String address;
  final String phone;
  final String email;
  final String? giftMessage;
  final OrderStatus status;
  final DateTime createdAt;
  final double total;

  Order({
    required this.id,
    required this.items,
    required this.recipientName,
    required this.address,
    required this.phone,
    required this.email,
    this.giftMessage,
    this.status = OrderStatus.confirmed,
    required this.createdAt,
    required this.total,
  });

  /// İlk buket — eski tek-buket ekranlarıyla uyum için kısa yol.
  Bouquet get firstBouquet => items.first.bouquet;
  int get totalQty => items.fold(0, (s, it) => s + it.qty);
  int get totalLego => items.fold(0, (s, it) => s + it.lineLegoCount);
}

// ── User ──────────────────────────────────────────────────
class AppUser {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
  });

  AppUser copyWith({String? name, String? email, String? photoUrl}) =>
      AppUser(id: id, name: name ?? this.name, email: email ?? this.email, photoUrl: photoUrl ?? this.photoUrl);
}
