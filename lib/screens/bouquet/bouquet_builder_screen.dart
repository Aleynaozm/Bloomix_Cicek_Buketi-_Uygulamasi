import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/widgets.dart';
import 'customize_screen.dart';

class BouquetBuilderScreen extends StatelessWidget {
  const BouquetBuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, prov, _) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            prov.inputName.isEmpty ? 'Buketiniz' : prov.inputName,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              letterSpacing: 4, color: AppColors.rose),
          ),
          actions: [
            IconButton(
              icon: Icon(
                prov.currentBouquet != null && prov.isFavorite(prov.currentBouquet!.id)
                    ? Icons.favorite_rounded : Icons.favorite_outline,
                color: AppColors.rose,
              ),
              onPressed: () {
                if (prov.currentBouquet != null) prov.toggleFavorite(prov.currentBouquet!);
              },
            ),
          ],
        ),
        body: Column(children: [
          // Bouquet canvas
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: prov.flowers.isEmpty
                  ? const Center(child: Text('Çiçek yok', style: TextStyle(color: AppColors.textLight)))
                  : Center(
                      child: BouquetPreview(
                        flowers: prov.flowers,
                        wrapper: prov.wrapper,
                        height: 380,
                      ),
                    ),
            ),
          ),

          // İsim — büyük renkli harflerle altta tam yazılı
          if (prov.flowers.isNotEmpty)
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
                          style: TextStyle(
                            fontFamily: 'DM Serif Display',
                            fontSize: 36,
                            color: f.color,
                            letterSpacing: 6,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

          // Çiçek chip'leri — Wrap ile her zaman tamamı görünür
          if (prov.flowers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 6,
                runSpacing: 6,
                children: prov.flowers.map((f) => GestureDetector(
                  onTap: () => showFlowerDetail(context, f),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: f.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: f.color.withOpacity(0.3)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(f.letter,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: f.color)),
                      const SizedBox(width: 5),
                      Text(f.nameTr,
                        style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                    ]),
                  ),
                )).toList(),
              ),
            ),

          // Fiyat + brick özet barı
          if (prov.hasBouquet && prov.currentBouquet != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.roseLight.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(children: [
                    const Icon(Icons.extension_rounded,
                        size: 18, color: AppColors.rose),
                    const SizedBox(width: 6),
                    Text('${prov.currentBouquet!.legoCount} brick',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark)),
                    Text('  •  ${prov.size.label}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textLight)),
                  ]),
                  Text('₺${prov.currentBouquet!.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.rose)),
                ]),
              ),
            ),

          // Buttons
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).padding.bottom + 12),
            child: Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomizeScreen())),
                  icon: const Icon(Icons.tune_rounded, size: 18),
                  label: const Text('Özelleştir'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: prov.hasBouquet
                      ? () {
                          prov.addToCart(prov.currentBouquet!);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppColors.rose,
                              content: Row(children: [
                                const Icon(Icons.check_circle_outline_rounded,
                                    color: Colors.white),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: Text(
                                        '${prov.currentBouquet!.name} sepete eklendi',
                                        style: const TextStyle(
                                            color: Colors.white))),
                              ]),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                  label: const Text('Sepete Ekle'),
                ),
              ),
            ]),
          ),
        ]),
      );
    });
  }
}
