import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../data/special_day_data.dart';
import 'category_detail_screen.dart';

/// Özel Gün Buketleri kataloğu — kategori grid'i.
/// Tap → CategoryDetailScreen (o kategoriye ait buketler).
class SpecialDaysScreen extends StatelessWidget {
  const SpecialDaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('Özel Gün Buketleri')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text(
            'Hangi özel gün için?',
            style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark),
          ),
          const SizedBox(height: 4),
          Text(
            'Sana özel hazırlanmış konsept Lego buketleri',
            style: GoogleFonts.poppins(
                fontSize: 13, color: AppColors.textMid, height: 1.5),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.95,
            children: SpecialDayCategory.values
                .map((c) => _CategoryCard(
                      category: c,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  CategoryDetailScreen(category: c))),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final SpecialDayCategory category;
  final VoidCallback onTap;
  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = category.colors;
    final count = bouquetsForCategory(category).length;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.first.withOpacity(0.55), colors.first],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.last.withOpacity(0.18)),
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(category.emoji,
                    style: const TextStyle(fontSize: 36)),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colors.last.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('$count buket',
                      style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: colors.last)),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.title,
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: colors.last)),
                const SizedBox(height: 2),
                Row(children: [
                  Text('İncele',
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: colors.last.withOpacity(0.75))),
                  Icon(Icons.arrow_forward_rounded,
                      size: 14,
                      color: colors.last.withOpacity(0.75)),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
