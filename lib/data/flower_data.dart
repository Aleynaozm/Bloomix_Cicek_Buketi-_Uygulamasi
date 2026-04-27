import 'package:flutter/material.dart';
import '../models/models.dart';

/// Türk alfabesi (29 harf) — her harf bir çiçeğe karşılık geliyor.
const Map<String, Flower> flowerAlphabet = {
  'A': Flower(letter: 'A', nameTr: 'Beyaz Şakayık',          nameEn: 'White Peony',         meaning: 'Saflık ve mutluluk',          assetPath: 'assets/flowers/a.png',  color: Color(0xFFF5E6E8)),
  'B': Flower(letter: 'B', nameTr: 'Pembe Şakayık',          nameEn: 'Pink Peony',          meaning: 'Romantizm ve aşk',            assetPath: 'assets/flowers/b.png',  color: Color(0xFFE8A0B8)),
  'C': Flower(letter: 'C', nameTr: 'Şakayık Tipi Lale',      nameEn: 'Peony Tulip',         meaning: 'Zarafet ve yenilenme',        assetPath: 'assets/flowers/c.png',  color: Color(0xFFE8907A)),
  'Ç': Flower(letter: 'Ç', nameTr: 'Beyaz Zambak',           nameEn: 'White Lily',          meaning: 'Saflık ve masumiyet',         assetPath: 'assets/flowers/ç.png',  color: Color(0xFFF5F5EE)),
  'D': Flower(letter: 'D', nameTr: 'Pembe Zambak',           nameEn: 'Pink Lily',           meaning: 'Hayranlık ve şefkat',         assetPath: 'assets/flowers/d.png',  color: Color(0xFFF0B8C8)),
  'E': Flower(letter: 'E', nameTr: 'Sarı Lale',              nameEn: 'Yellow Tulip',        meaning: 'Neşe ve umut',                assetPath: 'assets/flowers/e.png',  color: Color(0xFFF5C842)),
  'F': Flower(letter: 'F', nameTr: 'Pembe Kasımpatı',        nameEn: 'Pink Chrysanthemum',  meaning: 'Sevgi ve dostluk',            assetPath: 'assets/flowers/f.png',  color: Color(0xFFE890B0)),
  'G': Flower(letter: 'G', nameTr: 'Pembe Yıldız Çiçeği',    nameEn: 'Pink Aster',          meaning: 'İncelik ve sevgi',            assetPath: 'assets/flowers/g.png',  color: Color(0xFFEFA8C0)),
  'Ğ': Flower(letter: 'Ğ', nameTr: 'Antoryum',               nameEn: 'Anthurium',           meaning: 'Konukseverlik ve sıcaklık',   assetPath: 'assets/flowers/ğ.png',  color: Color(0xFFE05050)),
  'H': Flower(letter: 'H', nameTr: 'Mor Orkide',             nameEn: 'Purple Orchid',       meaning: 'Asalet ve hayranlık',         assetPath: 'assets/flowers/h.png',  color: Color(0xFF9050C0)),
  'I': Flower(letter: 'I', nameTr: 'Phalaenopsis Orkide',    nameEn: 'Phalaenopsis',        meaning: 'Zarafet ve güzellik',         assetPath: 'assets/flowers/ı.png',  color: Color(0xFFE8C8E0)),
  'İ': Flower(letter: 'İ', nameTr: 'Beyaz Şakayık',          nameEn: 'White Peony',         meaning: 'Saflık ve yeni başlangıç',    assetPath: 'assets/flowers/ii.png', color: Color(0xFFF8F0F0)),
  'J': Flower(letter: 'J', nameTr: 'Cipso (Çöven)',          nameEn: 'Baby\'s Breath',      meaning: 'Sonsuz aşk ve saflık',        assetPath: 'assets/flowers/j.png',  color: Color(0xFFF5F5F5)),
  'K': Flower(letter: 'K', nameTr: 'Zambak',                 nameEn: 'Lily',                meaning: 'Asalet ve onur',              assetPath: 'assets/flowers/k.png',  color: Color(0xFFFFF5DD)),
  'L': Flower(letter: 'L', nameTr: 'Kırmızı Yıldız Çiçeği',  nameEn: 'Red Aster',           meaning: 'Sadakat ve aşk',              assetPath: 'assets/flowers/l.png',  color: Color(0xFFE8213A)),
  'M': Flower(letter: 'M', nameTr: 'Mavi Çan Çiçeği',        nameEn: 'Blue Bluebell',       meaning: 'Sürekli sevgi ve sadakat',    assetPath: 'assets/flowers/m.png',  color: Color(0xFF6080E0)),
  'N': Flower(letter: 'N', nameTr: 'Pembe Gül',              nameEn: 'Pink Rose',           meaning: 'Zarafet ve teşekkür',         assetPath: 'assets/flowers/n.png',  color: Color(0xFFE890A8)),
  'O': Flower(letter: 'O', nameTr: 'Mor Menekşe',            nameEn: 'Purple Violet',       meaning: 'Sadakat ve düşünce',          assetPath: 'assets/flowers/o.png',  color: Color(0xFF9060C0)),
  'Ö': Flower(letter: 'Ö', nameTr: 'Papatya',                nameEn: 'Daisy',               meaning: 'Saflık ve masumiyet',         assetPath: 'assets/flowers/ö.png',  color: Color(0xFFF5C842)),
  'P': Flower(letter: 'P', nameTr: 'Sarı Menekşe',           nameEn: 'Yellow Pansy',        meaning: 'Mütevazı sevinç',             assetPath: 'assets/flowers/p.png',  color: Color(0xFFF0C030)),
  'R': Flower(letter: 'R', nameTr: 'Kırmızı Gül',            nameEn: 'Red Rose',            meaning: 'Tutkulu aşk',                 assetPath: 'assets/flowers/r.png',  color: Color(0xFFE8213A)),
  'S': Flower(letter: 'S', nameTr: 'Beyaz Gül',              nameEn: 'White Rose',          meaning: 'Saflık ve yeni başlangıç',    assetPath: 'assets/flowers/s.png',  color: Color(0xFFF5F0EE)),
  'Ş': Flower(letter: 'Ş', nameTr: 'Lavanta',                nameEn: 'Lavender',            meaning: 'Huzur ve sadakat',            assetPath: 'assets/flowers/ş.png',  color: Color(0xFFB090E0)),
  'T': Flower(letter: 'T', nameTr: 'Nergis',                 nameEn: 'Narcissus',           meaning: 'Yeni başlangıç ve umut',      assetPath: 'assets/flowers/t.png',  color: Color(0xFFFFE566)),
  'U': Flower(letter: 'U', nameTr: 'Pembe Papatya',          nameEn: 'Pink Daisy',          meaning: 'Şefkatli sevgi',              assetPath: 'assets/flowers/u.png',  color: Color(0xFFEFAEC0)),
  'Ü': Flower(letter: 'Ü', nameTr: 'Sarı Papatya',           nameEn: 'Yellow Daisy',        meaning: 'Dostluk ve neşe',             assetPath: 'assets/flowers/ü.png',  color: Color(0xFFF5D848)),
  'V': Flower(letter: 'V', nameTr: 'Mor Kasımpatı',          nameEn: 'Purple Chrysanthemum',meaning: 'Sadakat ve uzun ömür',        assetPath: 'assets/flowers/v.png',  color: Color(0xFFA060C0)),
  'Y': Flower(letter: 'Y', nameTr: 'Lale',                   nameEn: 'Tulip',               meaning: 'Mükemmel aşk',                assetPath: 'assets/flowers/y.png',  color: Color(0xFFE8907A)),
  'Z': Flower(letter: 'Z', nameTr: 'Kırmızı Şakayık',        nameEn: 'Red Peony',           meaning: 'Tutku ve onur',               assetPath: 'assets/flowers/z.png',  color: Color(0xFFE03050)),
};

/// Türkçe duyarlı upper-case (Dart'ın varsayılanı i→İ ve ı→I yapmaz).
String turkishUpperCase(String s) {
  return s
      .replaceAll('i', 'İ')
      .replaceAll('ı', 'I')
      .replaceAll('ş', 'Ş')
      .replaceAll('ç', 'Ç')
      .replaceAll('ğ', 'Ğ')
      .replaceAll('ö', 'Ö')
      .replaceAll('ü', 'Ü')
      .toUpperCase();
}

List<Flower> getFlowersForName(String name) {
  final upper = turkishUpperCase(name);
  // Sadece harfleri al (Türkçe dahil), boşluk ve sayıları çıkar
  final letters = upper.split('').where((c) => flowerAlphabet.containsKey(c)).toList();
  // Tekrar eden harfleri tek seferde göster
  final seen = <String>{};
  return letters
      .where((l) => seen.add(l))
      .map((l) => flowerAlphabet[l]!)
      .toList();
}
