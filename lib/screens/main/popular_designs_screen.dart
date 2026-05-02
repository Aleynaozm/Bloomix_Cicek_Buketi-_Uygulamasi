import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

/// Popüler Tasarımlar — kullanıcıların en çok beğendiği buket önizlemeleri.
/// Tur 2'de gerçek beğeni verileriyle dinamikleşecek.
class PopularDesignsScreen extends StatelessWidget {
  const PopularDesignsScreen({super.key});

  static const _items = <_PopularItem>[
    _PopularItem('Klasik Kırmızı Güller', '36 brick', '₺2.880', '💐',
        Color(0xFFFFC2C2)),
    _PopularItem(
        'Pastel Lilac Karışım', '24 brick', '₺2.880', '🌷', Color(0xFFE8C8E0)),
    _PopularItem('Sarı Papatya Buketi', '18 brick', '₺1.440', '🌼',
        Color(0xFFFCE5B0)),
    _PopularItem('Romantik Lale', '20 brick', '₺2.880', '🌷', Color(0xFFFFD9C5)),
    _PopularItem('Lavanta Demet', '15 brick', '₺1.440', '💜', Color(0xFFD8C5EC)),
    _PopularItem(
        'Beyaz Şakayık', '24 brick', '₺2.880', '🤍', Color(0xFFF5E6E8)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('Popüler Tasarımlar')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text('Topluluğun favorileri',
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark)),
          const SizedBox(height: 4),
          Text('En çok beğenilen ve sipariş edilen Lego buket tasarımları',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: AppColors.textMid, height: 1.5)),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.72,
            children: _items
                .map((it) => _PopularCard(
                      item: it,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  '${it.title} detay sayfası yakında 🌸')),
                        );
                      },
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _PopularItem {
  final String title, brick, price, emoji;
  final Color color;
  const _PopularItem(
      this.title, this.brick, this.price, this.emoji, this.color);
}

class _PopularCard extends StatelessWidget {
  final _PopularItem item;
  final VoidCallback onTap;
  const _PopularCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Görsel placeholder (gradient + emoji)
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    item.color.withOpacity(0.4),
                    item.color.withOpacity(0.85)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                  child: Text(item.emoji,
                      style: const TextStyle(fontSize: 56))),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                  const SizedBox(height: 4),
                  Text(item.brick,
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: AppColors.textLight)),
                  const SizedBox(height: 6),
                  Text(item.price,
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.rose)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
