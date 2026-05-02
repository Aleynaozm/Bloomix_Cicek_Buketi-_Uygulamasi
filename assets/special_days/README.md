# Özel Gün Buketleri — Görsel Yükleme Klasörü

Bu klasöre Canva'dan tasarladığın **PNG** görselleri yükle. Her buket için belirli bir dosya adı gerekiyor — `lib/data/special_day_data.dart` içindeki `assetPath` alanlarıyla eşleşmeli.

## Dosya Adlandırma

Format: `{kategori_anahtarı}_{numara}.png`

### Doğum Günü
- `birthday_1.png` — Doğum Günü Renk Şöleni
- `birthday_2.png` — Pembe Doğum Günü
- `birthday_3.png` — Premium Doğum Günü

### Sevgililer Günü
- `valentine_1.png` — Klasik Kırmızı Güller
- `valentine_2.png` — Kırmızı & Pembe Tutku
- `valentine_3.png` — Lüks Aşk Buketi

### Anneler Günü
- `mother_1.png` — Anneye Şefkat
- `mother_2.png` — Beyaz & Pembe Sevgi
- `mother_3.png` — Premium Anne Buketi

### Yıldönümü
- `anniversary_1.png` — Klasik Yıldönümü
- `anniversary_2.png` — Altın Yıldönümü
- `anniversary_3.png` — Sonsuz Aşk

### Mezuniyet
- `graduation_1.png` — Mezuniyet Tebriği
- `graduation_2.png` — Akademik Başarı
- `graduation_3.png` — Premium Mezuniyet

### Sevgiliye
- `romantic_1.png` — Romantik Karışım
- `romantic_2.png` — Pastel Aşk
- `romantic_3.png` — Lüks Romantizm

### Tebrik
- `congrats_1.png` — Tebrik Buketi
- `congrats_2.png` — Başarı Buketi
- `congrats_3.png` — Premium Tebrik

### Geçmiş Olsun
- `getwell_1.png` — Geçmiş Olsun
- `getwell_2.png` — Şifa Buketi
- `getwell_3.png` — Mutluluk Buketi

## Önerilen Boyut

- **En:** 800-1200 px
- **Boy:** 1000-1500 px
- **Format:** PNG (şeffaf zemin tercih edilir)
- **Oran:** ~3:4 (dikey kart formatı için ideal)

## Görsel Eksikse

Bir görsel yüklenmemişse uygulamada otomatik olarak gradient arka plan + kategori emojisi gösterilir. İstediğin anda yükleyebilirsin, hot restart sonrası görünür.

## Yeni Buket Eklemek

`lib/data/special_day_data.dart` içindeki `specialBouquets` listesine yeni `SpecialBouquet(...)` ekle. `assetPath` için yeni bir dosya adı ver, görseli buraya yükle.
