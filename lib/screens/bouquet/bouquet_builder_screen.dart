import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/widgets.dart';
import 'customize_screen.dart';
import '../shop/checkout_screen.dart';

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
                      child: BouquetPreview(flowers: prov.flowers, wrapper: prov.wrapper),
                    ),
            ),
          ),

          // Flower info strip
          if (prov.flowers.isNotEmpty)
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: prov.flowers.length,
                itemBuilder: (_, i) {
                  final f = prov.flowers[i];
                  return GestureDetector(
                    onTap: () => showFlowerDetail(context, f),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: f.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: f.color.withOpacity(0.3)),
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(f.letter, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: f.color)),
                        const SizedBox(height: 2),
                        Text(f.nameTr, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                      ]),
                    ),
                  );
                },
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
                      ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen()))
                      : null,
                  icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                  label: const Text('Sipariş Ver'),
                ),
              ),
            ]),
          ),
        ]),
      );
    });
  }
}
