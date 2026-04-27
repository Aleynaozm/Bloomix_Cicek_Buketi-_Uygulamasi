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
enum WrapperStyle { white, kraft, black, pink, sage }

extension WrapperStyleExt on WrapperStyle {
  String get label {
    switch (this) {
      case WrapperStyle.white:
        return 'Beyaz Kraft';
      case WrapperStyle.kraft:
        return 'Naturel Kraft';
      case WrapperStyle.black:
        return 'Siyah';
      case WrapperStyle.pink:
        return 'Pembe';
      case WrapperStyle.sage:
        return 'Adaçayı Yeşili';
    }
  }

  Color get color {
    switch (this) {
      case WrapperStyle.white:
        return const Color(0xFFF5F0E8);
      case WrapperStyle.kraft:
        return const Color(0xFFC8A882);
      case WrapperStyle.black:
        return const Color(0xFF2C2C2C);
      case WrapperStyle.pink:
        return const Color(0xFFF4C0D1);
      case WrapperStyle.sage:
        return const Color(0xFF8FAF8A);
    }
  }
}

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

  double get price {
    switch (this) {
      case BouquetSize.small:
        return 750;
      case BouquetSize.medium:
        return 1250;
      case BouquetSize.large:
        return 1950;
    }
  }
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
    this.wrapper = WrapperStyle.white,
    this.size = BouquetSize.medium,
    this.giftMessage,
    this.isFavorite = false,
  });

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
  final Bouquet bouquet;
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
    required this.bouquet,
    required this.recipientName,
    required this.address,
    required this.phone,
    required this.email,
    this.giftMessage,
    this.status = OrderStatus.confirmed,
    required this.createdAt,
    required this.total,
  });
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
