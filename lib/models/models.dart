import 'dart:typed_data';
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

// ── Bouquet Template ─────────────────────────────────────
enum BouquetTemplate { classic, modern, minimal, luxury }

extension BouquetTemplateExt on BouquetTemplate {
  String get label {
    switch (this) {
      case BouquetTemplate.classic:
        return 'Klasik';
      case BouquetTemplate.modern:
        return 'Modern';
      case BouquetTemplate.minimal:
        return 'Minimal';
      case BouquetTemplate.luxury:
        return 'Lüks';
    }
  }

  String get emoji {
    switch (this) {
      case BouquetTemplate.classic:
        return '🌿';
      case BouquetTemplate.modern:
        return '✨';
      case BouquetTemplate.minimal:
        return '🤍';
      case BouquetTemplate.luxury:
        return '👑';
    }
  }

  String get assetPath {
    switch (this) {
      case BouquetTemplate.classic:
        return 'assets/images/bouquet_template.png';
      case BouquetTemplate.modern:
        return 'assets/images/bouquet_template_modern.png';
      case BouquetTemplate.minimal:
        return 'assets/images/bouquet_template_minimal.png';
      case BouquetTemplate.luxury:
        return 'assets/images/bouquet_template_luxury.png';
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

  /// Buketteki referans çiçek sayısı (görsel düzen için).
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
}

enum AiPreviewStyle { realistic, lego }

extension AiPreviewStyleExt on AiPreviewStyle {
  String get label {
    switch (this) {
      case AiPreviewStyle.realistic:
        return 'AI Gerçek Buket';
      case AiPreviewStyle.lego:
        return 'AI LEGO Buket';
    }
  }

  String get shortLabel {
    switch (this) {
      case AiPreviewStyle.realistic:
        return 'AI Gerçek';
      case AiPreviewStyle.lego:
        return 'AI LEGO';
    }
  }
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
  final BouquetTemplate template;

  /// Canvas'taki çiçek konumları — kaydedilip geri yüklenebilir.
  final List<PlacedFlowerData> placedFlowers;

  /// Tasarım ekranından alınan PNG önizleme görüntüsü (bellekte, serialize edilmez).
  final Uint8List? previewImageBytes;
  final String? previewAssetPath;
  final String? specialBouquetId;
  final AiPreviewStyle? aiPreviewStyle;
  final String? aiPrompt;
  final String? aiImageBase64;

  const Bouquet({
    required this.id,
    required this.name,
    required this.flowers,
    this.ribbon = RibbonStyle.red,
    this.size = BouquetSize.medium,
    this.giftMessage,
    this.isFavorite = false,
    this.template = BouquetTemplate.classic,
    this.placedFlowers = const [],
    this.previewImageBytes,
    this.previewAssetPath,
    this.specialBouquetId,
    this.aiPreviewStyle,
    this.aiPrompt,
    this.aiImageBase64,
  });

  /// Çiçek sayısına göre LEGO brick adedi (~65 brick/çiçek).
  int get legoCount => flowers.length * 65;

  /// LEGO buket fiyatı: ₺300 baz + çiçek başı ₺360.
  double get price => 300 + (flowers.length * 360);

  /// Normal buket fiyatı: ₺180 baz + çiçek başı ₺140.
  double get normalPrice => 180 + (flowers.length * 140);

  Bouquet copyWith({
    String? name,
    List<Flower>? flowers,
    RibbonStyle? ribbon,
    BouquetSize? size,
    String? giftMessage,
    bool? isFavorite,
    BouquetTemplate? template,
    List<PlacedFlowerData>? placedFlowers,
    Uint8List? previewImageBytes,
    String? previewAssetPath,
    String? specialBouquetId,
    AiPreviewStyle? aiPreviewStyle,
    String? aiPrompt,
    String? aiImageBase64,
  }) =>
      Bouquet(
        id: id,
        name: name ?? this.name,
        flowers: flowers ?? this.flowers,
        ribbon: ribbon ?? this.ribbon,
        size: size ?? this.size,
        giftMessage: giftMessage ?? this.giftMessage,
        isFavorite: isFavorite ?? this.isFavorite,
        template: template ?? this.template,
        placedFlowers: placedFlowers ?? this.placedFlowers,
        previewImageBytes: previewImageBytes ?? this.previewImageBytes,
        previewAssetPath: previewAssetPath ?? this.previewAssetPath,
        specialBouquetId: specialBouquetId ?? this.specialBouquetId,
        aiPreviewStyle: aiPreviewStyle ?? this.aiPreviewStyle,
        aiPrompt: aiPrompt ?? this.aiPrompt,
        aiImageBase64: aiImageBase64 ?? this.aiImageBase64,
      );
}

// ── CartItem ──────────────────────────────────────────────
class CartItem {
  final String id;
  final Bouquet bouquet;
  final int qty;
  final DateTime addedAt;

  /// true → LEGO buket, false → gerçek çiçek buketi.
  final bool isLego;

  // ── Upsell alanları ──────────────────────────────────────
  /// Hediye notu metni (boşsa ücret sıfır).
  final String? giftNote;

  /// Kullanıcının seçtiği teslimat tarihi.
  final DateTime? deliveryDate;

  /// Kullanıcının seçtiği teslimat adresi.
  final String? deliveryAddress;

  /// true → NFT olarak mint edildi.
  final bool isNft;

  /// Hediye notu ek ücreti (₺).
  final double giftNoteFee;

  /// NFT minting ücreti (₺).
  final double nftMintFee;

  /// Mock blockchain hash (isNft=true olduğunda set edilir).
  final String? nftHash;

  const CartItem({
    required this.id,
    required this.bouquet,
    required this.qty,
    required this.addedAt,
    this.isLego = false,
    this.giftNote,
    this.deliveryDate,
    this.deliveryAddress,
    this.isNft = false,
    this.giftNoteFee = 0.0,
    this.nftMintFee = 0.0,
    this.nftHash,
  });

  /// Toplam ek ücret (not + NFT).
  double get extraFees => giftNoteFee + nftMintFee;

  /// Birim fiyat = buket fiyatı + ek ücretler.
  double get unitPrice =>
      (isLego ? bouquet.price : bouquet.normalPrice) + extraFees;

  double get lineTotal => unitPrice * qty;
  int get lineLegoCount => isLego ? bouquet.legoCount * qty : 0;

  CartItem copyWith({
    Bouquet? bouquet,
    int? qty,
    String? giftNote,
    DateTime? deliveryDate,
    String? deliveryAddress,
    bool? isNft,
    double? giftNoteFee,
    double? nftMintFee,
    String? nftHash,
  }) =>
      CartItem(
        id: id,
        bouquet: bouquet ?? this.bouquet,
        qty: qty ?? this.qty,
        addedAt: addedAt,
        isLego: isLego,
        giftNote: giftNote ?? this.giftNote,
        deliveryDate: deliveryDate ?? this.deliveryDate,
        deliveryAddress: deliveryAddress ?? this.deliveryAddress,
        isNft: isNft ?? this.isNft,
        giftNoteFee: giftNoteFee ?? this.giftNoteFee,
        nftMintFee: nftMintFee ?? this.nftMintFee,
        nftHash: nftHash ?? this.nftHash,
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
  final DateTime? deliveryDate;
  final OrderStatus status;
  final DateTime createdAt;
  final double total;

  /// true → LEGO brick buket, false → gerçek/normal buket.
  final bool isLego;

  Order({
    required this.id,
    required this.items,
    required this.recipientName,
    required this.address,
    required this.phone,
    required this.email,
    this.giftMessage,
    this.deliveryDate,
    this.status = OrderStatus.confirmed,
    required this.createdAt,
    required this.total,
    this.isLego = false,
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

  AppUser copyWith({String? name, String? email, String? photoUrl}) => AppUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl);
}
