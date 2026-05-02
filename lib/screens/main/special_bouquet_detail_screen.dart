import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/widgets.dart';
import '../../data/special_day_data.dart';
import '../bouquet/bouquet_builder_screen.dart';

/// Özel Gün buket detay sayfası.
/// Büyük görsel + bilgi + 2 ana eylem:
///   • Sepete Ekle (tek tık seç)
///   • Kişiselleştir (BouquetBuilder editöründe açılır)
class SpecialBouquetDetailScreen extends StatelessWidget {
  final SpecialBouquet bouquet;
  const SpecialBouquetDetailScreen({super.key, required this.bouquet});

  void _addToCart(BuildContext context) {
    final prov = context.read<AppProvider>();
    final b = Bouquet(
      id: 'b_special_${bouquet.id}_${DateTime.now().millisecondsSinceEpoch}',
      name: bouquet.title,
      flowers: bouquet.flowers,
      ribbon: bouquet.ribbon,
      size: bouquet.size,
    );
    prov.addToCart(b);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.rose,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        content: Row(children: [
          const Icon(Icons.check_circle_outline_rounded,
              color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
              child: Text('${bouquet.title} sepete eklendi',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600))),
        ]),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _personalize(BuildContext context) {
    final prov = context.read<AppProvider>();
    prov.loadTemplateBouquet(
      name: bouquet.title,
      flowers: bouquet.flowers,
      ribbon: bouquet.ribbon,
      size: bouquet.size,
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BouquetBuilderScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = bouquet.category.colors;
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: CustomScrollView(slivers: [
        // ── Hero görsel app bar ───────────────────────────────
        SliverAppBar(
          expandedHeight: 360,
          pinned: true,
          backgroundColor: colors.first,
          foregroundColor: AppColors.textDark,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.first.withOpacity(0.4),
                    colors.first.withOpacity(0.95),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Image.asset(
                bouquet.assetPath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Text(bouquet.category.emoji,
                      style: const TextStyle(fontSize: 120)),
                ),
              ),
            ),
          ),
        ),

        // ── İçerik ────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kategori chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colors.first.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(bouquet.category.emoji,
                          style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 6),
                      Text(bouquet.category.title,
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: colors.last)),
                    ]),
                  ),
                  const SizedBox(height: 14),

                  // Başlık
                  Text(bouquet.title,
                      style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                          height: 1.2)),
                  const SizedBox(height: 6),
                  Text(bouquet.description,
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textMid,
                          height: 1.55)),
                  const SizedBox(height: 20),

                  // Detay grid
                  Row(children: [
                    _StatPill(
                      icon: Icons.extension_rounded,
                      label: '${bouquet.size.legoCount} brick',
                    ),
                    const SizedBox(width: 8),
                    _StatPill(
                      icon: Icons.local_florist_rounded,
                      label: '${bouquet.flowers.length} çiçek',
                    ),
                    const SizedBox(width: 8),
                    _StatPill(
                      icon: Icons.straighten_rounded,
                      label: bouquet.size.label,
                    ),
                  ]),
                  const SizedBox(height: 14),

                  // Kurdele rengi
                  Row(children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: bouquet.ribbon.color,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('Kurdele: ${bouquet.ribbon.label}',
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: AppColors.textMid)),
                  ]),
                  const SizedBox(height: 20),

                  // Çiçek listesi
                  Text('İçindeki Çiçekler',
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: bouquet.flowers
                        .toSet()
                        .map((f) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: f.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(50),
                                border:
                                    Border.all(color: f.color.withOpacity(0.3)),
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                      color: f.color, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 6),
                                Text(f.nameTr,
                                    style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textDark)),
                              ]),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 100), // alt buton boşluğu
                ]),
          ),
        ),
      ]),

      // ── Sticky alt bar: fiyat + butonlar ────────────────────
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
            16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(
              top: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Toplam',
                            style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.textLight)),
                        Text('₺${bouquet.size.price.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.rose)),
                      ]),
                  // Kişiselleştir (outlined)
                  SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => _personalize(context),
                      icon: const Icon(Icons.tune_rounded, size: 18),
                      label: Text('Kişiselleştir',
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: AppColors.rose.withOpacity(0.5),
                            width: 1.5),
                        foregroundColor: AppColors.rose,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                ]),
            const SizedBox(height: 10),
            // Sepete Ekle (büyük gradient)
            GradientButton(
              label: 'Sepete Ekle',
              icon: Icons.add_shopping_cart_rounded,
              onPressed: () => _addToCart(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(children: [
          Icon(icon, size: 18, color: AppColors.rose),
          const SizedBox(height: 4),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
        ]),
      ),
    );
  }
}
