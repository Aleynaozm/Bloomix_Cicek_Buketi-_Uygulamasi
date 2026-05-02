import 'package:flutter/material.dart';

// ── PlacedFlowerData ─────────────────────────────────────
/// Tasarım canvas'ında konumlandırılmış bir çiçek.
/// Pozisyon (0..1, 0..1) normalize. Scale 0.5..2.0. Rotation radyan.
/// FreeDesign + AlphabetDome ortak render formatı.
class PlacedFlowerData {
  final String id;
  final Flower flower;
  final Offset position;
  final double scale;
  final double rotation;

  const PlacedFlowerData({
    required this.id,
    required this.flower,
    required this.position,
    this.scale = 1.0,
    this.rotation = 0.0,
  });

  PlacedFlowerData copyWith({
    Flower? flower,
    Offset? position,
    double? scale,
    double? rotation,
  }) =>
      PlacedFlowerData(
        id: id,
        flower: flower ?? this.flower,
        position: position ?? this.position,
        scale: scale ?? this.scale,
        rotation: rotation ?? this.rotation,
      );
}

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

// ── Ribbon (kurdele) ─────────────────────────────────────
/// Buketin sapını saran kurdele. Lego konsepti gereği kağıt sargı yok;
/// saplar Lego yeşili, sadece kurdele renk olarak değişiyor.
enum RibbonStyle { red, pink, gold, purple, blue }

extension RibbonStyleExt on RibbonStyle {
  String get label {
    switch (this) {
      case RibbonStyle.red:
        return 'Kırmızı';
      case RibbonStyle.pink:
        return 'Pembe';
      case RibbonStyle.gold:
        return 'Altın';
      case RibbonStyle.purple:
        return 'Mor';
      case RibbonStyle.blue:
        return 'Mavi';
    }
  }

  Color get color {
    switch (this) {
      case RibbonStyle.red:
        return const Color(0xFFD32030);
      case RibbonStyle.pink:
        return const Color(0xFFFF74B3);
      case RibbonStyle.gold:
        return const Color(0xFFE0B040);
      case RibbonStyle.purple:
        return const Color(0xFF8848B8);
      case RibbonStyle.blue:
        return const Color(0xFF3070D0);
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
  final RibbonStyle ribbon;
  final BouquetSize size;
  final String? giftMessage;
  final bool isFavorite;

  const Bouquet({
    required this.id,
    required this.name,
    required this.flowers,
    this.ribbon = RibbonStyle.red,
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
    RibbonStyle? ribbon,
    BouquetSize? size,
    String? giftMessage,
    bool? isFavorite,
  }) =>
      Bouquet(
        id: id,
        name: name ?? this.name,
        flowers: flowers ?? this.flowers,
        ribbon: ribbon ?? this.ribbon,
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

// ── Saved Bouquet ─────────────────────────────────────────
/// Kullanıcının kütüphanesine kaydettiği buket.
/// İmmutable — koleksiyon üyeliği BouquetCollection.savedBouquetIds'ten okunur.
class SavedBouquet {
  final String id;
  final Bouquet bouquet;
  final DateTime savedAt;

  const SavedBouquet({
    required this.id,
    required this.bouquet,
    required this.savedAt,
  });

  SavedBouquet copyWith({Bouquet? bouquet}) => SavedBouquet(
        id: id,
        bouquet: bouquet ?? this.bouquet,
        savedAt: savedAt,
      );
}

// ── Bouquet Collection ────────────────────────────────────
/// Kullanıcının oluşturduğu (veya sistem) buket koleksiyonu.
/// `isSystem=true` → silinemez/yeniden adlandırılamaz (ör. Favoriler).
class BouquetCollection {
  final String id;
  final String name;
  final String emoji;
  final String? description;
  final DateTime createdAt;
  final bool isSystem;
  final List<String> savedBouquetIds;

  const BouquetCollection({
    required this.id,
    required this.name,
    required this.emoji,
    this.description,
    required this.createdAt,
    this.isSystem = false,
    this.savedBouquetIds = const [],
  });

  BouquetCollection copyWith({
    String? name,
    String? emoji,
    String? description,
    List<String>? savedBouquetIds,
  }) =>
      BouquetCollection(
        id: id,
        name: name ?? this.name,
        emoji: emoji ?? this.emoji,
        description: description ?? this.description,
        createdAt: createdAt,
        isSystem: isSystem,
        savedBouquetIds: savedBouquetIds ?? this.savedBouquetIds,
      );

  int get count => savedBouquetIds.length;
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
