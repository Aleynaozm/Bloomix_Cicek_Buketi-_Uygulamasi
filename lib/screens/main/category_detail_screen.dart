import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../data/special_day_data.dart';
import 'special_bouquet_detail_screen.dart';

/// Bir özel gün kategorisinin altındaki buket grid'i.
/// Tap → SpecialBouquetDetailScreen.
class CategoryDetailScreen extends StatelessWidget {
  final SpecialDayCategory category;
  const CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final bouquets = bouquetsForCategory(category);
    final colors = category.colors;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: Text('${category.emoji}  ${category.title}'),
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 32), children: [
        // ── Kategori hero başlık ─────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors.first.withOpacity(0.45), colors.first],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(children: [
            Text(category.emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${bouquets.length} hazır tasarım',
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: colors.last)),
                const SizedBox(height: 2),
                Text(
                    'Tek tıkla sepete ekle veya kişiselleştir.',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: colors.last.withOpacity(0.75))),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 20),

        // ── Buket grid'i ─────────────────────────────────────────
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.68,
          children: bouquets
              .map((b) => _BouquetCard(
                    bouquet: b,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                SpecialBouquetDetailScreen(bouquet: b))),
                  ))
              .toList(),
        ),
      ]),
    );
  }
}

class _BouquetCard extends StatelessWidget {
  final SpecialBouquet bouquet;
  final VoidCallback onTap;
  const _BouquetCard({required this.bouquet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = bouquet.category.colors;
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Görsel — Canva yüklenecek alan
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.first.withOpacity(0.4),
                    colors.first.withOpacity(0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Image.asset(
                bouquet.assetPath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Text(bouquet.category.emoji,
                      style: const TextStyle(fontSize: 56)),
                ),
              ),
            ),
          ),
          // Bilgi
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(bouquet.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                              height: 1.2)),
                      const SizedBox(height: 4),
                      Text('${bouquet.size.legoCount} brick',
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.textLight)),
                    ]),
                    Text('₺${bouquet.size.price.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.rose)),
                  ]),
            ),
          ),
        ]),
      ),
    );
  }
}
