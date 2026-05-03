import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/widgets.dart';
import '../../widgets/save_to_collection_sheet.dart';
import '../../widgets/share_sheet.dart';
import 'customize_screen.dart';

/// Buket Önizleme — bir önceki ekrandaki tasarımı kullanır.
/// AppBar: ❤ Favori · 💾 Kaydet (koleksiyon) · 📤 Paylaş (screenshot)
class BouquetBuilderScreen extends StatefulWidget {
  const BouquetBuilderScreen({super.key});

  @override
  State<BouquetBuilderScreen> createState() => _BouquetBuilderScreenState();
}

class _BouquetBuilderScreenState extends State<BouquetBuilderScreen> {
  /// RepaintBoundary key — paylaş butonu bu sahneyi PNG'e çevirir.
  final GlobalKey _previewKey = GlobalKey();

  /// Paylaşım sheet'ini açar — kullanıcı PNG İndir / Hikaye / Hızlı Paylaş seçer.
  /// PNG render + watermark ekleme + galeriye kayıt veya share, sheet içinde.
  void _share(Bouquet b) {
    ShareSheet.show(context, previewKey: _previewKey, bouquet: b);
  }

  void _toast(String msg, {Color? bg}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: bg ?? AppColors.rose,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        content: Row(children: [
          const Icon(Icons.check_circle_outline_rounded,
              color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
              child: Text(msg,
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontWeight: FontWeight.w600))),
        ]),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, prov, _) {
      final isFreeDesign = prov.isFreeDesign;
      final placed = prov.placedFlowers;
      final bouquet = prov.currentBouquet;
      final isFavorite =
          bouquet != null && prov.isFavorite(bouquet.id);

      return Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          backgroundColor: AppColors.cream,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            isFreeDesign
                ? 'Tasarımım'
                : (prov.inputName.isEmpty ? 'Buketim' : prov.inputName),
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 28,
              color: AppColors.rose,
              letterSpacing: isFreeDesign ? 0.5 : 4,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: isFavorite ? 'Favorilerden çıkar' : 'Favorile',
              icon: Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_outline_rounded,
                color: AppColors.rose,
              ),
              onPressed: bouquet == null
                  ? null
                  : () {
                      prov.toggleFavorite(bouquet);
                      _toast(isFavorite
                          ? 'Favorilerden çıkarıldı'
                          : 'Favorilere eklendi 💖');
                    },
            ),
            IconButton(
              tooltip: 'Kaydet',
              icon: const Icon(Icons.bookmark_outline_rounded,
                  color: AppColors.rose),
              onPressed: bouquet == null
                  ? null
                  : () => SaveToCollectionSheet.show(context, bouquet),
            ),
            IconButton(
              tooltip: 'Paylaş',
              icon: const Icon(Icons.ios_share_rounded,
                  color: AppColors.rose),
              onPressed: bouquet == null ? null : () => _share(bouquet),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Column(children: [
            // ── Buket önizleme — RepaintBoundary ile paylaşılabilir ──
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: placed.isEmpty
                    ? const Center(
                        child: Text('Çiçek yok',
                            style:
                                TextStyle(color: AppColors.textLight)),
                      )
                    : Center(
                        child: RepaintBoundary(
                          key: _previewKey,
                          child: Container(
                            color: AppColors.cream,
                            padding: const EdgeInsets.all(16),
                            child: BouquetPreview(
                              flowers: prov.flowers,
                              placed: placed,
                              ribbon: prov.ribbon,
                              height: 380,
                            ),
                          ),
                        ),
                      ),
              ),
            ),

            // ── Alfabe akışında: harf adı + chip listesi ───────────
            if (!isFreeDesign && prov.flowers.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        for (final f in prov.flowers)
                          TextSpan(
                            text: f.letter,
                            style: GoogleFonts.dmSerifDisplay(
                              fontSize: 32,
                              color: f.color,
                              letterSpacing: 6,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6,
                  runSpacing: 6,
                  children: prov.flowers
                      .map((f) => GestureDetector(
                            onTap: () => showFlowerDetail(context, f),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: f.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                    color: f.color.withOpacity(0.3)),
                              ),
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(f.letter,
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: f.color)),
                                    const SizedBox(width: 5),
                                    Text(f.nameTr,
                                        style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            color:
                                                AppColors.textLight)),
                                  ]),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],

            // ── Free design'da kompakt bilgi şeridi ────────────────
            if (isFreeDesign && placed.isNotEmpty) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Text(
                  '${placed.length} çiçek · ${prov.ribbon.label} kurdele',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textMid,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 6),
            ],

            // ── Fiyat + brick özet barı ────────────────────────────
            if (bouquet != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.roseLight.withOpacity(0.4),
                        AppColors.roseLight.withOpacity(0.2),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.rose.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                                Icons.extension_rounded,
                                size: 16,
                                color: AppColors.rose),
                          ),
                          const SizedBox(width: 10),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${bouquet.legoCount} brick',
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textDark)),
                                Text(prov.size.label,
                                    style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: AppColors.textLight)),
                              ]),
                        ]),
                        Text('₺${bouquet.price.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.rose)),
                      ]),
                ),
              ),

            // ── Eylemler: Özelleştir + Sepete Ekle ────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                  16, 6, 16, MediaQuery.of(context).padding.bottom + 12),
              child: Row(children: [
                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CustomizeScreen())),
                      icon: const Icon(Icons.tune_rounded, size: 18),
                      label: Text('Özelleştir',
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: AppColors.rose.withOpacity(0.5),
                            width: 1.5),
                        foregroundColor: AppColors.rose,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: GradientButton(
                    label: 'Sepete Ekle',
                    icon: Icons.add_shopping_cart_rounded,
                    onPressed: bouquet == null
                        ? null
                        : () {
                            prov.addToCart(bouquet);
                            _toast('${bouquet.name} sepete eklendi');
                          },
                  ),
                ),
              ]),
            ),
          ]),
        ),
      );
    });
  }
}
