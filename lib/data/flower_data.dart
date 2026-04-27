import 'package:flutter/material.dart';
import '../models/models.dart';

const Map<String, Flower> flowerAlphabet = {
  'A': Flower(letter:'A', nameTr:'Krizantem',    nameEn:'Chrysanthemum',     meaning:'Uzun ömür ve mutluluk',        assetPath:'assets/flowers/a_chrysanthemum.svg', color:Color(0xFFE05B8A)),
  'B': Flower(letter:'B', nameTr:'Çan Çiçeği',   nameEn:'Bluebell',          meaning:'Sürekli sevgi ve sadakat',     assetPath:'assets/flowers/b_bluebell.svg',      color:Color(0xFF6080E0)),
  'C': Flower(letter:'C', nameTr:'Karanfil',      nameEn:'Carnation',         meaning:'Sevgi ve hayranlık',           assetPath:'assets/flowers/c_carnation.svg',     color:Color(0xFFF07090)),
  'D': Flower(letter:'D', nameTr:'Papatya',       nameEn:'Daisy',             meaning:'Saflık ve masumiyet',          assetPath:'assets/flowers/d_daisy.svg',         color:Color(0xFFF5C842)),
  'E': Flower(letter:'E', nameTr:'Lisyantus',     nameEn:'Eustoma',           meaning:'Değer ve zarafet',             assetPath:'assets/flowers/e_eustoma.svg',       color:Color(0xFF9060D0)),
  'F': Flower(letter:'F', nameTr:'Frezya',        nameEn:'Freesia',           meaning:'Dostluk ve güven',             assetPath:'assets/flowers/f_freesia.svg',       color:Color(0xFFF0C030)),
  'G': Flower(letter:'G', nameTr:'Gardenia',      nameEn:'Gardenia',          meaning:'Gizli aşk ve saflık',         assetPath:'assets/flowers/g_gardenia.svg',      color:Color(0xFFF0EDE0)),
  'H': Flower(letter:'H', nameTr:'Sümbül',        nameEn:'Hyacinth',          meaning:'Oyun ve neşe',                 assetPath:'assets/flowers/h_hyacinth.svg',      color:Color(0xFF5080E8)),
  'I': Flower(letter:'I', nameTr:'İris',          nameEn:'Iris',              meaning:'Bilgelik ve umut',             assetPath:'assets/flowers/i_iris.svg',          color:Color(0xFF6050D0)),
  'J': Flower(letter:'J', nameTr:'Yasemin',       nameEn:'Jasmine',           meaning:'Sevgi ve zarafet',             assetPath:'assets/flowers/j_jasmine.svg',       color:Color(0xFFFFF5B8)),
  'K': Flower(letter:'K', nameTr:'Kerria',        nameEn:'Kerria',            meaning:'Neşe ve zenginlik',            assetPath:'assets/flowers/k_kerria.svg',        color:Color(0xFFF0C030)),
  'L': Flower(letter:'L', nameTr:'Lavanta',       nameEn:'Lavender',          meaning:'Sessizlik ve huzur',           assetPath:'assets/flowers/l_lavender.svg',      color:Color(0xFFB090E0)),
  'M': Flower(letter:'M', nameTr:'Manolya',       nameEn:'Magnolia',          meaning:'Asalet ve onur',               assetPath:'assets/flowers/m_magnolia.svg',      color:Color(0xFFF0D0E0)),
  'N': Flower(letter:'N', nameTr:'Nergis',        nameEn:'Narcissus',         meaning:'Yenilik ve taze başlangıç',   assetPath:'assets/flowers/n_narcissus.svg',     color:Color(0xFFFFE566)),
  'O': Flower(letter:'O', nameTr:'Orkide',        nameEn:'Orchid',            meaning:'Lüks ve güç',                  assetPath:'assets/flowers/o_orchid.svg',        color:Color(0xFFE090D0)),
  'P': Flower(letter:'P', nameTr:'Şakayık',       nameEn:'Peony',             meaning:'Romantizm ve refah',           assetPath:'assets/flowers/p_peony.svg',         color:Color(0xFFF090B0)),
  'Q': Flower(letter:'Q', nameTr:'Dere Otu',      nameEn:'Queen Anne\'s Lace',meaning:'Zarafet ve incelik',           assetPath:'assets/flowers/q_queenanneslace.svg',color:Color(0xFFF0EDE8)),
  'R': Flower(letter:'R', nameTr:'Gül',           nameEn:'Rose',              meaning:'Derin aşk ve tutku',           assetPath:'assets/flowers/r_rose.svg',          color:Color(0xFFE8213A)),
  'S': Flower(letter:'S', nameTr:'Ayçiçeği',      nameEn:'Sunflower',         meaning:'Sadakat ve neşe',              assetPath:'assets/flowers/s_sunflower.svg',     color:Color(0xFFF5A623)),
  'T': Flower(letter:'T', nameTr:'Lale',          nameEn:'Tulip',             meaning:'Mükemmel aşk',                 assetPath:'assets/flowers/t_tulip.svg',         color:Color(0xFFE8907A)),
  'U': Flower(letter:'U', nameTr:'Ursinia',       nameEn:'Ursinia',           meaning:'Neşe ve canlılık',             assetPath:'assets/flowers/u_ursinia.svg',       color:Color(0xFFF0A030)),
  'V': Flower(letter:'V', nameTr:'Menekşe',       nameEn:'Violet',            meaning:'Tevazu ve sadakat',            assetPath:'assets/flowers/v_violet.svg',        color:Color(0xFF9060C0)),
  'W': Flower(letter:'W', nameTr:'Salkım',        nameEn:'Wisteria',          meaning:'Uzun ömür ve şans',            assetPath:'assets/flowers/w_wisteria.svg',      color:Color(0xFFC090E0)),
  'X': Flower(letter:'X', nameTr:'Kuru Çiçek',    nameEn:'Xeranthemum',       meaning:'Ebediyet ve anı',              assetPath:'assets/flowers/x_xeranthemum.svg',   color:Color(0xFFD080C0)),
  'Y': Flower(letter:'Y', nameTr:'Civanperçemi',  nameEn:'Yarrow',            meaning:'Şifa ve bereket',              assetPath:'assets/flowers/y_yarrow.svg',        color:Color(0xFFF0E060)),
  'Z': Flower(letter:'Z', nameTr:'Zinnya',        nameEn:'Zinnia',            meaning:'Hatıra ve dostluk',            assetPath:'assets/flowers/z_zinnia.svg',        color:Color(0xFFF06050)),
};

List<Flower> getFlowersForName(String name) {
  final seen = <String>{};
  return name.toUpperCase()
      .replaceAll(RegExp(r'[^A-Z]'), '')
      .split('')
      .where((l) => seen.add(l) && flowerAlphabet.containsKey(l))
      .map((l) => flowerAlphabet[l]!)
      .toList();
}
