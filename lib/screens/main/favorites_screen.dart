import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../bouquet/bouquet_builder_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, prov, _) {
      final favs = prov.favorites;
      return Scaffold(
        appBar: AppBar(title: const Text('Favorilerim')),
        body: favs.isEmpty
            ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('🌱', style: const TextStyle(fontSize: 56)),
                const SizedBox(height: 16),
                Text('Henüz favori buketin yok', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Buket tasarlarken ❤ ile kaydedebilirsin', style: Theme.of(context).textTheme.bodyMedium),
              ]))
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: favs.length,
                itemBuilder: (_, i) {
                  final b = favs[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(b.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          letterSpacing: 2, color: AppColors.rose)),
                        const SizedBox(height: 4),
                        Text('${b.flowers.length} çiçek türü • ${b.size.label}',
                          style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 8),
                        Wrap(spacing: 6, children: b.flowers.take(5).map((f) =>
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: f.color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(f.nameTr, style: TextStyle(fontSize: 10, color: f.color, fontWeight: FontWeight.w600)),
                          )
                        ).toList()),
                      ])),
                      Column(children: [
                        IconButton(
                          icon: const Icon(Icons.favorite, color: AppColors.rose),
                          onPressed: () => prov.toggleFavorite(b),
                        ),
                        TextButton(
                          onPressed: () {
                            prov.generateBouquet(b.name);
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const BouquetBuilderScreen()));
                          },
                          child: const Text('Görüntüle', style: TextStyle(fontSize: 12)),
                        ),
                      ]),
                    ]),
                  );
                },
              ),
      );
    });
  }
}
