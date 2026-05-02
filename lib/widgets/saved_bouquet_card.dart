import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import 'widgets.dart';

/// Saved buket için kart — küçük preview + bilgi.
/// Koleksiyon listesinde ve "Tüm Tasarımlarım" gridinde kullanılır.
class SavedBouquetCard extends StatelessWidget {
  final SavedBouquet saved;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  /// Sağ üstte favori kalp göstergesi.
  final bool showFavorite;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const SavedBouquetCard({
    super.key,
    required this.saved,
    this.onTap,
    this.onLongPress,
    this.showFavorite = false,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final b = saved.bouquet;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            flex: 6,
            child: Stack(children: [
              // Kompakt buket preview — kart kapağı
              Container(
                width: double.infinity,
                color: b.ribbon.color.withOpacity(0.08),
                child: BouquetPreview(
                  flowers: b.flowers,
                  ribbon: b.ribbon,
                  height: 180,
                ),
              ),
              if (showFavorite)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Material(
                    color: AppColors.white.withOpacity(0.85),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onFavoriteToggle,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_outline_rounded,
                          size: 18,
                          color: AppColors.rose,
                        ),
                      ),
                    ),
                  ),
                ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text('${b.legoCount} brick · ${b.size.label}',
                      style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: AppColors.textLight)),
                  const SizedBox(height: 4),
                  Text('₺${b.price.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.rose)),
                ]),
          ),
        ]),
      ),
    );
  }
}
