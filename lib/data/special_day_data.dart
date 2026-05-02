import 'package:flutter/material.dart';
import '../models/models.dart';
import 'flower_data.dart';

/// Özel Gün kategorileri.
enum SpecialDayCategory {
  birthday,
  valentine,
  mother,
  anniversary,
  graduation,
  romantic,
  congrats,
  getWell,
}

extension SpecialDayCategoryExt on SpecialDayCategory {
  String get title {
    switch (this) {
      case SpecialDayCategory.birthday:
        return 'Doğum Günü';
      case SpecialDayCategory.valentine:
        return 'Sevgililer Günü';
      case SpecialDayCategory.mother:
        return 'Anneler Günü';
      case SpecialDayCategory.anniversary:
        return 'Yıldönümü';
      case SpecialDayCategory.graduation:
        return 'Mezuniyet';
      case SpecialDayCategory.romantic:
        return 'Sevgiliye';
      case SpecialDayCategory.congrats:
        return 'Tebrik';
      case SpecialDayCategory.getWell:
        return 'Geçmiş Olsun';
    }
  }

  String get emoji {
    switch (this) {
      case SpecialDayCategory.birthday:
        return '🎂';
      case SpecialDayCategory.valentine:
        return '❤️';
      case SpecialDayCategory.mother:
        return '🌷';
      case SpecialDayCategory.anniversary:
        return '💍';
      case SpecialDayCategory.graduation:
        return '🎓';
      case SpecialDayCategory.romantic:
        return '💐';
      case SpecialDayCategory.congrats:
        return '🎉';
      case SpecialDayCategory.getWell:
        return '🌼';
    }
  }

  /// Kategori karakteristik açık + koyu renk (gradient için).
  List<Color> get colors {
    switch (this) {
      case SpecialDayCategory.birthday:
        return const [Color(0xFFFFB8D4), Color(0xFFFF74B3)];
      case SpecialDayCategory.valentine:
        return const [Color(0xFFFFC2C2), Color(0xFFD32030)];
      case SpecialDayCategory.mother:
        return const [Color(0xFFE8C8E0), Color(0xFFB060B0)];
      case SpecialDayCategory.anniversary:
        return const [Color(0xFFEBD9A8), Color(0xFFB58A2A)];
      case SpecialDayCategory.graduation:
        return const [Color(0xFFC5D9F0), Color(0xFF3070D0)];
      case SpecialDayCategory.romantic:
        return const [Color(0xFFFFD9C5), Color(0xFFE05050)];
      case SpecialDayCategory.congrats:
        return const [Color(0xFFD9E8C5), Color(0xFF4A8B40)];
      case SpecialDayCategory.getWell:
        return const [Color(0xFFFCE5B0), Color(0xFFCB8C20)];
    }
  }

  /// Kategori asset key (dosya adı için).
  String get key {
    switch (this) {
      case SpecialDayCategory.birthday:
        return 'birthday';
      case SpecialDayCategory.valentine:
        return 'valentine';
      case SpecialDayCategory.mother:
        return 'mother';
      case SpecialDayCategory.anniversary:
        return 'anniversary';
      case SpecialDayCategory.graduation:
        return 'graduation';
      case SpecialDayCategory.romantic:
        return 'romantic';
      case SpecialDayCategory.congrats:
        return 'congrats';
      case SpecialDayCategory.getWell:
        return 'getwell';
    }
  }
}

/// Özel gün için hazır konsept buket.
/// `assetPath` kullanıcının yükleyeceği Canva görseli.
class SpecialBouquet {
  final String id;
  final String title;
  final String description;
  final String assetPath;
  final SpecialDayCategory category;
  /// Lego buket için çiçek listesi — sepete eklendiğinde kullanılır.
  final List<Flower> flowers;
  final RibbonStyle ribbon;
  final BouquetSize size;

  const SpecialBouquet({
    required this.id,
    required this.title,
    required this.description,
    required this.assetPath,
    required this.category,
    required this.flowers,
    this.ribbon = RibbonStyle.red,
    this.size = BouquetSize.medium,
  });
}

// ── Çiçek seçim yardımcısı ─────────────────────────────────
List<Flower> _pick(List<String> letters) =>
    letters.map((l) => flowerAlphabet[l]!).toList();

/// Tüm kategoriler için hazır buket listesi.
/// Her kategori altında 3 buket. Asset path: assets/special_days/{key}_{N}.png
/// Kullanıcı bu yola Canva görsellerini ekledikçe gerçek görsel görünür;
/// görsel olmadığında gradient + emoji fallback.
final List<SpecialBouquet> specialBouquets = [
  // ── Doğum Günü ───────────────────────────────────────────
  SpecialBouquet(
    id: 'birthday_1',
    title: 'Doğum Günü Renk Şöleni',
    description: 'Canlı renklerle dolu, kutlamalık karışık buket',
    assetPath: 'assets/special_days/birthday_1.png',
    category: SpecialDayCategory.birthday,
    flowers: _pick(['E', 'F', 'G', 'R', 'M', 'U', 'L', 'A', 'P']),
    ribbon: RibbonStyle.pink,
    size: BouquetSize.medium,
  ),
  SpecialBouquet(
    id: 'birthday_2',
    title: 'Pembe Doğum Günü',
    description: 'Soft pembe tonlarda zarif kutlama buketi',
    assetPath: 'assets/special_days/birthday_2.png',
    category: SpecialDayCategory.birthday,
    flowers: _pick(['B', 'D', 'F', 'N', 'U', 'A', 'G']),
    ribbon: RibbonStyle.pink,
    size: BouquetSize.medium,
  ),
  SpecialBouquet(
    id: 'birthday_3',
    title: 'Premium Doğum Günü',
    description: 'Büyük boy karışık çiçek buketi',
    assetPath: 'assets/special_days/birthday_3.png',
    category: SpecialDayCategory.birthday,
    flowers: _pick(['R', 'L', 'Z', 'A', 'B', 'F', 'M', 'H', 'V', 'D', 'E', 'P', 'G', 'U', 'N']),
    ribbon: RibbonStyle.gold,
    size: BouquetSize.large,
  ),

  // ── Sevgililer Günü ──────────────────────────────────────
  SpecialBouquet(
    id: 'valentine_1',
    title: 'Klasik Kırmızı Güller',
    description: 'Aşkın simgesi, 9 kırmızı gül',
    assetPath: 'assets/special_days/valentine_1.png',
    category: SpecialDayCategory.valentine,
    flowers: _pick(['R', 'R', 'R', 'R', 'R', 'L', 'L', 'Z', 'A']),
    ribbon: RibbonStyle.red,
    size: BouquetSize.medium,
  ),
  SpecialBouquet(
    id: 'valentine_2',
    title: 'Kırmızı & Pembe Tutku',
    description: 'Kırmızı ve pembe karışım, romantik tasarım',
    assetPath: 'assets/special_days/valentine_2.png',
    category: SpecialDayCategory.valentine,
    flowers: _pick(['R', 'L', 'B', 'N', 'F', 'D', 'U']),
    ribbon: RibbonStyle.red,
    size: BouquetSize.medium,
  ),
  SpecialBouquet(
    id: 'valentine_3',
    title: 'Lüks Aşk Buketi',
    description: 'Premium, sıkı kırmızı dome',
    assetPath: 'assets/special_days/valentine_3.png',
    category: SpecialDayCategory.valentine,
    flowers: _pick(['R', 'R', 'R', 'L', 'L', 'L', 'Z', 'Z', 'A', 'A', 'B', 'F', 'N', 'D', 'G']),
    ribbon: RibbonStyle.red,
    size: BouquetSize.large,
  ),

  // ── Anneler Günü ─────────────────────────────────────────
  SpecialBouquet(
    id: 'mother_1',
    title: 'Anneye Şefkat',
    description: 'Pembe ve mor tonlarda yumuşak buket',
    assetPath: 'assets/special_days/mother_1.png',
    category: SpecialDayCategory.mother,
    flowers: _pick(['B', 'D', 'F', 'H', 'V', 'Ş', 'N']),
    ribbon: RibbonStyle.purple,
    size: BouquetSize.medium,
  ),
  SpecialBouquet(
    id: 'mother_2',
    title: 'Beyaz & Pembe Sevgi',
    description: 'Saflık ve sevginin birleşimi',
    assetPath: 'assets/special_days/mother_2.png',
    category: SpecialDayCategory.mother,
    flowers: _pick(['A', 'Ç', 'S', 'B', 'F', 'N', 'D', 'J', 'U']),
    ribbon: RibbonStyle.pink,
    size: BouquetSize.medium,
  ),
  SpecialBouquet(
    id: 'mother_3',
    title: 'Premium Anne Buketi',
    description: 'Büyük boy, zengin renk paleti',
    assetPath: 'assets/special_days/mother_3.png',
    category: SpecialDayCategory.mother,
    flowers: _pick(['B', 'D', 'F', 'N', 'U', 'A', 'Ç', 'S', 'H', 'V', 'Ş', 'J', 'G', 'P', 'M']),
    ribbon: RibbonStyle.purple,
    size: BouquetSize.large,
  ),

  // ── Yıldönümü ────────────────────────────────────────────
  SpecialBouquet(
    id: 'anniversary_1',
    title: 'Klasik Yıldönümü',
    description: 'Beyaz ve kırmızı tonlarda, zaman geçirmez',
    assetPath: 'assets/special_days/anniversary_1.png',
    category: SpecialDayCategory.anniversary,
    flowers: _pick(['R', 'A', 'S', 'L', 'Ç', 'J', 'Z']),
    ribbon: RibbonStyle.gold,
    size: BouquetSize.medium,
  ),
  SpecialBouquet(
    id: 'anniversary_2',
    title: 'Altın Yıldönümü',
    description: 'Sarı ve altın tonlu görkemli buket',
    assetPath: 'assets/special_days/anniversary_2.png',
    category: SpecialDayCategory.anniversary,
    flowers: _pick(['E', 'K', 'T', 'Ü', 'P', 'Ö', 'A']),
    ribbon: RibbonStyle.gold,
    size: BouquetSize.medium,
  ),
  SpecialBouquet(
    id: 'anniversary_3',
    title: 'Sonsuz Aşk',
    description: 'Premium karışık, büyük boy',
    assetPath: 'assets/special_days/anniversary_3.png',
    category: SpecialDayCategory.anniversary,
    flowers: _pick(['R', 'A', 'S', 'L', 'Ç', 'J', 'B', 'F', 'N', 'D', 'H', 'V', 'E', 'K', 'Z']),
    ribbon: RibbonStyle.red,
    size: BouquetSize.large,
  ),

  // ── Mezuniyet ────────────────────────────────────────────
  SpecialBouquet(
    id: 'graduation_1',
    title: 'Mezuniyet Tebriği',
    description: 'Sarı ve beyaz neşeli karışım',
    assetPath: 'assets/special_days/graduation_1.png',
    category: SpecialDayCategory.graduation,
    flowers: _pick(['E', 'Ö', 'Ü', 'A', 'Ç', 'P', 'T']),
    ribbon: RibbonStyle.blue,
    size: BouquetSize.medium,
  ),
  SpecialBouquet(
    id: 'graduation_2',
    title: 'Akademik Başarı',
    description: 'Mavi ve mor akademi tonları',
    assetPath: 'assets/special_days/graduation_2.png',
    category: SpecialDayCategory.graduation,
    flowers: _pick(['M', 'H', 'V', 'O', 'Ş', 'I', 'J']),
    ribbon: RibbonStyle.blue,
    size: BouquetSize.medium,
  ),
  SpecialBouquet(
    id: 'graduation_3',
    title: 'Premium Mezuniyet',
    description: 'Büyük boy, neşeli renkler',
    assetPath: 'assets/special_days/graduation_3.png',
    category: SpecialDayCategory.graduation,
    flowers: _pick(['E', 'Ö', 'Ü', 'A', 'Ç', 'P', 'T', 'M', 'H', 'V', 'O', 'Ş', 'I', 'J', 'K']),
    ribbon: RibbonStyle.gold,
    size: BouquetSize.large,
  ),

  // ── Sevgiliye ────────────────────────────────────────────
  SpecialBouquet(
    id: 'romantic_1',
    title: 'Romantik Karışım',
    description: 'Pembe ve kırmızı sevgili buketi',
    assetPath: 'assets/special_days/romantic_1.png',
    category: SpecialDayCategory.romantic,
    flowers: _pick(['R', 'L', 'B', 'N', 'F', 'D', 'A']),
    ribbon: RibbonStyle.pink,
    size: BouquetSize.medium,
  ),
  SpecialBouquet(
    id: 'romantic_2',
    title: 'Pastel Aşk',
    description: 'Soft renklerde romantik tasarım',
    assetPath: 'assets/special_days/romantic_2.png',
    category: SpecialDayCategory.romantic,
    flowers: _pick(['B', 'D', 'F', 'U', 'A', 'C', 'N', 'G']),
    ribbon: RibbonStyle.pink,
    size: BouquetSize.medium,
  ),
  SpecialBouquet(
    id: 'romantic_3',
    title: 'Lüks Romantizm',
    description: 'Premium karışım, büyük boy',
    assetPath: 'assets/special_days/romantic_3.png',
    category: SpecialDayCategory.romantic,
    flowers: _pick(['R', 'L', 'B', 'N', 'F', 'D', 'A', 'Z', 'P', 'U', 'H', 'V', 'Ş', 'G', 'M']),
    ribbon: RibbonStyle.red,
    size: BouquetSize.large,
  ),

  // ── Tebrik ───────────────────────────────────────────────
  SpecialBouquet(
    id: 'congrats_1',
    title: 'Tebrik Buketi',
    description: 'Neşeli renklerde kutlama buketi',
    assetPath: 'assets/special_days/congrats_1.png',
    category: SpecialDayCategory.congrats,
    flowers: _pick(['E', 'F', 'G', 'P', 'T', 'A', 'U']),
    ribbon: RibbonStyle.gold,
    size: BouquetSize.medium,
  ),
  SpecialBouquet(
    id: 'congrats_2',
    title: 'Başarı Buketi',
    description: 'Yeşil ve sarı, taze tasarım',
    assetPath: 'assets/special_days/congrats_2.png',
    category: SpecialDayCategory.congrats,
    flowers: _pick(['Ö', 'Ü', 'E', 'T', 'P', 'K', 'A']),
    ribbon: RibbonStyle.gold,
    size: BouquetSize.medium,
  ),
  SpecialBouquet(
    id: 'congrats_3',
    title: 'Premium Tebrik',
    description: 'Lüks, büyük boy karışık',
    assetPath: 'assets/special_days/congrats_3.png',
    category: SpecialDayCategory.congrats,
    flowers: _pick(['E', 'F', 'G', 'P', 'T', 'A', 'U', 'B', 'D', 'H', 'V', 'N', 'M', 'R', 'L']),
    ribbon: RibbonStyle.gold,
    size: BouquetSize.large,
  ),

  // ── Geçmiş Olsun ─────────────────────────────────────────
  SpecialBouquet(
    id: 'getwell_1',
    title: 'Geçmiş Olsun',
    description: 'Sarı papatya ve canlı renkler',
    assetPath: 'assets/special_days/getwell_1.png',
    category: SpecialDayCategory.getWell,
    flowers: _pick(['Ö', 'Ü', 'E', 'P', 'T', 'A', 'C']),
    ribbon: RibbonStyle.gold,
    size: BouquetSize.medium,
  ),
  SpecialBouquet(
    id: 'getwell_2',
    title: 'Şifa Buketi',
    description: 'Sakinleştirici lavanta ve papatya',
    assetPath: 'assets/special_days/getwell_2.png',
    category: SpecialDayCategory.getWell,
    flowers: _pick(['Ş', 'Ö', 'A', 'Ç', 'J', 'U']),
    ribbon: RibbonStyle.purple,
    size: BouquetSize.small,
  ),
  SpecialBouquet(
    id: 'getwell_3',
    title: 'Mutluluk Buketi',
    description: 'Renkli, neşeli premium',
    assetPath: 'assets/special_days/getwell_3.png',
    category: SpecialDayCategory.getWell,
    flowers: _pick(['Ö', 'Ü', 'E', 'P', 'T', 'A', 'C', 'F', 'G', 'D', 'B', 'U', 'M', 'V', 'K']),
    ribbon: RibbonStyle.pink,
    size: BouquetSize.large,
  ),
];

/// Bir kategoriye ait buketleri filtrele.
List<SpecialBouquet> bouquetsForCategory(SpecialDayCategory cat) =>
    specialBouquets.where((b) => b.category == cat).toList();
