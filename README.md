<<<<<<< HEAD
# Bloomix
=======
# Bloomix — Kurulum Rehberi

## Adım 1 — Flutter projesi oluştur
```bash
flutter create bloomix
cd bloomix
```

## Adım 2 — ZIP'i aç ve kopyala
ZIP içindeki lib/, assets/, pubspec.yaml dosyalarını
flutter create'in oluşturduğu bloomix/ klasörüne kopyala.
"Üzerine yaz" sorusuna evet de.

## Adım 3 — Paketleri yükle
```bash
flutter pub get
```

## Adım 4 — Çalıştır
```bash
flutter run
```

---

## Ekranlar
- Onboarding (3 sayfa swipe)
- Giriş / Kayıt / Şifremi Unuttum
- Ana Sayfa (isim girişi, öne çıkan çiçekler)
- Buket Tasarımcı (SVG çiçekler, animasyonlu)
- Özelleştir (ambalaj rengi, buket boyutu)
- Çiçek Alfabesi (A-Z, arama)
- Keşfet (tüm çiçekler, trend isimler)
- Favoriler
- Sipariş (3 adım: Teslimat > Ödeme > Onay)
- Sipariş Başarılı
- Profil (düzenleme, bildirim ayarları)
- Siparişlerim

## Çiçek SVG'leri nasıl eklersin?
assets/flowers/ klasöründe her harf için placeholder SVG var.
Canva'dan indirdiğin SVG'yi aynı isimle üzerine kaydet.

Dosya isimleri: a_chrysanthemum.svg, b_bluebell.svg, c_carnation.svg,
d_daisy.svg, e_eustoma.svg, f_freesia.svg, g_gardenia.svg, h_hyacinth.svg,
i_iris.svg, j_jasmine.svg, k_kerria.svg, l_lavender.svg, m_magnolia.svg,
n_narcissus.svg, o_orchid.svg, p_peony.svg, q_queenanneslace.svg, r_rose.svg,
s_sunflower.svg, t_tulip.svg, u_ursinia.svg, v_violet.svg, w_wisteria.svg,
x_xeranthemum.svg, y_yarrow.svg, z_zinnia.svg
>>>>>>> 6ce6c16 (first commit)
