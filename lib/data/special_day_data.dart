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
  final String normalAssetPath;
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
    this.normalAssetPath = '',
    required this.category,
    required this.flowers,
    this.ribbon = RibbonStyle.red,
    this.size = BouquetSize.medium,
  });

  int get legoCount => flowers.length * 65;
  double get price => 300 + (flowers.length * 360);
  double get normalPrice => 180 + (flowers.length * 140);
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
    title: 'Pembe Lale Neşesi',
    description: 'Pembe lalelerden oluşan zarif doğum günü buketi',
    assetPath: 'assets/special_days/birthday_1.png',
    normalAssetPath: 'assets/special_days/birthday_1_normal.png',
    category: SpecialDayCategory.birthday,
    flowers: _pick(['Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y']),
    ribbon: RibbonStyle.pink,
    size: BouquetSize.medium,
  ),
  SpecialBouquet(
    id: 'birthday_2',
    title: 'Pembe Kasımpatı Zarafeti',
    description: 'Soft pembe kasımpatılarla hazırlanmış taze buket',
    assetPath: 'assets/special_days/birthday_2.png',
    normalAssetPath: 'assets/special_days/birthday_2_normal.png',
    category: SpecialDayCategory.birthday,
    flowers: _pick(['F', 'F', 'F', 'F', 'F', 'F', 'F', 'F', 'F']),
    ribbon: RibbonStyle.pink,
    size: BouquetSize.medium,
  ),
  SpecialBouquet(
    id: 'birthday_3',
    title: 'Mavi Bahar Şöleni',
    description: 'Mavi, pembe, beyaz ve sarı tonlarda premium karışık buket',
    assetPath: 'assets/special_days/birthday_3.png',
    normalAssetPath: 'assets/special_days/birthday_3_normal.png',
    category: SpecialDayCategory.birthday,
    flowers: _pick([
      'M',
      'M',
      'M',
      'M',
      'D',
      'D',
      'D',
      'A',
      'A',
      'A',
      'R',
      'R',
      'E',
      'Ü',
      'Ü'
    ]),
    ribbon: RibbonStyle.gold,
    size: BouquetSize.large,
  ),

  // ── Sevgililer Günü ──────────────────────────────────────
  SpecialBouquet(
    id: 'valentine_1',
    title: 'Pembe Gül Romantizmi',
    description: 'Pembe ve kırmızı güllerden romantik sevgili buketi',
    assetPath: 'assets/special_days/valentine_1.png',
    normalAssetPath: 'assets/special_days/valentine_1_normal.png',
    category: SpecialDayCategory.valentine,
    flowers: _pick([
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N'
    ]),
    ribbon: RibbonStyle.red,
    size: BouquetSize.medium,
  ),
  SpecialBouquet(
    id: 'valentine_2',
    title: 'Kırmızı Gül Tutkusu',
    description: 'Yoğun kırmızı güllerden tutkulu sevgili buketi',
    assetPath: 'assets/special_days/valentine_2.png',
    normalAssetPath: 'assets/special_days/valentine_2_normal.png',
    category: SpecialDayCategory.valentine,
    flowers: _pick([
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R'
    ]),
    ribbon: RibbonStyle.red,
    size: BouquetSize.medium,
  ),
  SpecialBouquet(
    id: 'valentine_3',
    title: 'Pembe Aşk Bahçesi',
    description: 'Pembe güllerden oluşan zarif aşk buketi',
    assetPath: 'assets/special_days/valentine_3.png',
    normalAssetPath: 'assets/special_days/valentine_3_normal.png',
    category: SpecialDayCategory.valentine,
    flowers: _pick([
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N'
    ]),
    ribbon: RibbonStyle.red,
    size: BouquetSize.large,
  ),

  // ── Anneler Günü ─────────────────────────────────────────
  SpecialBouquet(
    id: 'mother_1',
    title: 'Anneye Bahar Şefkati',
    description: 'Pembe ve mor tonlarda yumuşak buket',
    assetPath: 'assets/special_days/mother_1.png',
    normalAssetPath: 'assets/special_days/mother_1_normal.png',
    category: SpecialDayCategory.mother,
    flowers: _pick(
        ['N', 'N', 'N', 'U', 'U', 'Ö', 'Ö', 'Ü', 'Ü', 'Ş', 'Ş', 'D', 'D', 'B']),
    ribbon: RibbonStyle.purple,
    size: BouquetSize.medium,
  ),
  SpecialBouquet(
    id: 'mother_2',
    title: 'Pembe Gül Sevgisi',
    description: 'Pembe güllerden oluşan yumuşak sevgi buketi',
    assetPath: 'assets/special_days/mother_2.png',
    normalAssetPath: 'assets/special_days/mother_2_normal.png',
    category: SpecialDayCategory.mother,
    flowers: _pick([
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N'
    ]),
    ribbon: RibbonStyle.pink,
    size: BouquetSize.medium,
  ),
  SpecialBouquet(
    id: 'mother_3',
    title: 'Premium Anne Zarafeti',
    description: 'Pembe gül, lale ve papatyalarla zarif premium buket',
    assetPath: 'assets/special_days/mother_3.png',
    normalAssetPath: 'assets/special_days/mother_3_normal.png',
    category: SpecialDayCategory.mother,
    flowers: _pick(
        ['N', 'N', 'N', 'Y', 'Ö', 'Ö', 'Ö', 'Ö', 'J', 'J', 'J', 'J', 'A']),
    ribbon: RibbonStyle.purple,
    size: BouquetSize.large,
  ),

  // ── Yıldönümü ────────────────────────────────────────────
  SpecialBouquet(
    id: 'anniversary_1',
    title: 'Mavi Hatıra Buketi',
    description: 'Mavi, kırmızı ve sarı tonlarda hatıra buketi',
    assetPath: 'assets/special_days/anniversary_1.png',
    normalAssetPath: 'assets/special_days/anniversary_1_normal.png',
    category: SpecialDayCategory.anniversary,
    flowers: _pick(
        ['M', 'M', 'M', 'M', 'R', 'R', 'R', 'Ü', 'Ü', 'Ü', 'Ç', 'Ç', 'E', 'A']),
    ribbon: RibbonStyle.gold,
    size: BouquetSize.medium,
  ),
  SpecialBouquet(
    id: 'anniversary_2',
    title: 'Altın Bahar Kutlaması',
    description: 'Pembe, sarı ve mor tonlarda kutlama buketi',
    assetPath: 'assets/special_days/anniversary_2.png',
    normalAssetPath: 'assets/special_days/anniversary_2_normal.png',
    category: SpecialDayCategory.anniversary,
    flowers: _pick(
        ['N', 'N', 'N', 'D', 'D', 'D', 'Ö', 'Ö', 'Ö', 'Ü', 'Ü', 'Ş', 'Ş', 'A']),
    ribbon: RibbonStyle.gold,
    size: BouquetSize.medium,
  ),
  SpecialBouquet(
    id: 'anniversary_3',
    title: 'Sonsuz Kırmızı Güller',
    description: 'Yoğun kırmızı güllerden klasik yıldönümü buketi',
    assetPath: 'assets/special_days/anniversary_3.png',
    normalAssetPath: 'assets/special_days/anniversary_3_normal.png',
    category: SpecialDayCategory.anniversary,
    flowers: _pick([
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R'
    ]),
    ribbon: RibbonStyle.red,
    size: BouquetSize.large,
  ),

  // ── Mezuniyet ────────────────────────────────────────────
  SpecialBouquet(
    id: 'graduation_1',
    title: 'Renkli Mezuniyet Tebriği',
    description: 'Mavi ve canlı tonlarda mezuniyet kutlama buketi',
    assetPath: 'assets/special_days/graduation_1.png',
    normalAssetPath: 'assets/special_days/graduation_1_normal.png',
    category: SpecialDayCategory.graduation,
    flowers: _pick([
      'M',
      'M',
      'M',
      'M',
      'D',
      'D',
      'D',
      'A',
      'A',
      'A',
      'R',
      'R',
      'E',
      'Ü',
      'Ü'
    ]),
    ribbon: RibbonStyle.blue,
    size: BouquetSize.medium,
  ),
  SpecialBouquet(
    id: 'graduation_2',
    title: 'Akademik Bahar Buketi',
    description: 'Pembe, sarı ve mor tonlarda akademik başarı buketi',
    assetPath: 'assets/special_days/graduation_2.png',
    normalAssetPath: 'assets/special_days/graduation_2_normal.png',
    category: SpecialDayCategory.graduation,
    flowers: _pick(
        ['N', 'N', 'N', 'U', 'U', 'Ö', 'Ö', 'Ü', 'Ü', 'Ş', 'Ş', 'D', 'D', 'B']),
    ribbon: RibbonStyle.blue,
    size: BouquetSize.medium,
  ),
  SpecialBouquet(
    id: 'graduation_3',
    title: 'Premium Mezuniyet Kutlaması',
    description: 'Sarı güller, papatyalar ve beyaz dokularla premium buket',
    assetPath: 'assets/special_days/graduation_3.png',
    normalAssetPath: 'assets/special_days/graduation_3_normal.png',
    category: SpecialDayCategory.graduation,
    flowers: _pick(
        ['E', 'E', 'E', 'Ö', 'Ö', 'Ö', 'J', 'J', 'J', 'J', 'O', 'O', 'O']),
    ribbon: RibbonStyle.gold,
    size: BouquetSize.large,
  ),

  // ── Sevgiliye ────────────────────────────────────────────
  SpecialBouquet(
    id: 'romantic_1',
    title: 'Pembe Gül Bahçesi',
    description: 'Pembe güllerden oluşan romantik sevgili buketi',
    assetPath: 'assets/special_days/romantic_1.png',
    normalAssetPath: 'assets/special_days/romantic_1_normal.png',
    category: SpecialDayCategory.romantic,
    flowers: _pick([
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N'
    ]),
    ribbon: RibbonStyle.pink,
    size: BouquetSize.medium,
  ),
  SpecialBouquet(
    id: 'romantic_2',
    title: 'Kırmızı Aşk Buketi',
    description: 'Yoğun kırmızı güllerden iddialı aşk buketi',
    assetPath: 'assets/special_days/romantic_2.png',
    normalAssetPath: 'assets/special_days/romantic_2_normal.png',
    category: SpecialDayCategory.romantic,
    flowers: _pick([
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R'
    ]),
    ribbon: RibbonStyle.pink,
    size: BouquetSize.medium,
  ),
  SpecialBouquet(
    id: 'romantic_3',
    title: 'Romantik Bahar Buketi',
    description: 'Pembe, sarı ve mor tonlarda romantik bahar buketi',
    assetPath: 'assets/special_days/romantic_3.png',
    normalAssetPath: 'assets/special_days/romantic_3_normal.png',
    category: SpecialDayCategory.romantic,
    flowers: _pick(
        ['N', 'N', 'N', 'D', 'D', 'D', 'Ö', 'Ö', 'Ö', 'Ü', 'Ü', 'Ş', 'Ş', 'A']),
    ribbon: RibbonStyle.red,
    size: BouquetSize.large,
  ),

  // ── Tebrik ───────────────────────────────────────────────
  SpecialBouquet(
    id: 'congrats_1',
    title: 'Zarif Tebrik Buketi',
    description: 'Pembe güllerden oluşan zarif tebrik buketi',
    assetPath: 'assets/special_days/congrats_1.png',
    normalAssetPath: 'assets/special_days/congrats_1_normal.png',
    category: SpecialDayCategory.congrats,
    flowers:
        _pick(['N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N']),
    ribbon: RibbonStyle.gold,
    size: BouquetSize.medium,
  ),
  SpecialBouquet(
    id: 'congrats_2',
    title: 'Başarı Gül Buketi',
    description: 'Pembe ve kırmızı güllerden başarı buketi',
    assetPath: 'assets/special_days/congrats_2.png',
    normalAssetPath: 'assets/special_days/congrats_2_normal.png',
    category: SpecialDayCategory.congrats,
    flowers: _pick([
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'R',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N',
      'N'
    ]),
    ribbon: RibbonStyle.gold,
    size: BouquetSize.medium,
  ),
  SpecialBouquet(
    id: 'congrats_3',
    title: 'Kutlama Neşesi',
    description: 'Pembe, mavi ve beyaz tonlarda neşeli kutlama buketi',
    assetPath: 'assets/special_days/congrats_3.png',
    normalAssetPath: 'assets/special_days/congrats_3_normal.png',
    category: SpecialDayCategory.congrats,
    flowers: _pick([
      'N',
      'N',
      'N',
      'N',
      'N',
      'M',
      'M',
      'Ö',
      'Ö',
      'Ö',
      'U',
      'U',
      'U',
      'U',
      'U',
      'Ü',
      'Ü'
    ]),
    ribbon: RibbonStyle.gold,
    size: BouquetSize.large,
  ),

  // ── Geçmiş Olsun ─────────────────────────────────────────
  SpecialBouquet(
    id: 'getwell_1',
    title: 'Moral Bahçesi',
    description: 'Mavi, pembe ve sarı tonlarda moral veren buket',
    assetPath: 'assets/special_days/getwell_1.png',
    normalAssetPath: 'assets/special_days/getwell_1_normal.png',
    category: SpecialDayCategory.getWell,
    flowers: _pick([
      'M',
      'M',
      'M',
      'Y',
      'Y',
      'E',
      'D',
      'D',
      'Ö',
      'Ü',
      'Ş',
      'Ş',
      'R',
      'N',
      'U'
    ]),
    ribbon: RibbonStyle.gold,
    size: BouquetSize.medium,
  ),
  SpecialBouquet(
    id: 'getwell_2',
    title: 'Şifa Çiçekleri',
    description: 'Pembe, mor ve papatya tonlarında şifa buketi',
    assetPath: 'assets/special_days/getwell_2.png',
    normalAssetPath: 'assets/special_days/getwell_2_normal.png',
    category: SpecialDayCategory.getWell,
    flowers: _pick(
        ['N', 'N', 'N', 'D', 'D', 'Ö', 'Ö', 'Ü', 'Ü', 'Ş', 'Ş', 'A', 'U', 'B']),
    ribbon: RibbonStyle.purple,
    size: BouquetSize.small,
  ),
  SpecialBouquet(
    id: 'getwell_3',
    title: 'Güneşli Mutluluk Buketi',
    description: 'Sarı ve beyaz papatyalarla güneşli moral buketi',
    assetPath: 'assets/special_days/getwell_3.png',
    normalAssetPath: 'assets/special_days/getwell_3_normal.png',
    category: SpecialDayCategory.getWell,
    flowers: _pick([
      'Ü',
      'Ü',
      'Ö',
      'Ö',
      'Ö',
      'U',
      'U',
      'U',
      'U',
      'U',
      'J',
      'J',
      'J',
      'J',
      'P',
      'P'
    ]),
    ribbon: RibbonStyle.pink,
    size: BouquetSize.large,
  ),
];

/// Bir kategoriye ait buketleri filtrele.
List<SpecialBouquet> bouquetsForCategory(SpecialDayCategory cat) =>
    specialBouquets.where((b) => b.category == cat).toList();
