import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/widgets.dart';

class CustomizeScreen extends StatelessWidget {
  const CustomizeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, prov, _) {
      return Scaffold(
        appBar: AppBar(title: const Text('Özelleştir')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Preview mini
            Container(
              height: 200,
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border)),
              child: BouquetPreview(
                flowers: prov.flowers,
                placed: prov.placedFlowers,
                ribbon: prov.ribbon,
                height: 200,
              ),
            ),
            const SizedBox(height: 28),

            // Ribbon (kurdele)
            Text('Kurdele Rengi', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(spacing: 10, runSpacing: 10,
              children: RibbonStyle.values.map((r) {
                final sel = prov.ribbon == r;
                return GestureDetector(
                  onTap: () => prov.setRibbon(r),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.rose : AppColors.white,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: sel ? AppColors.rose : AppColors.border, width: sel ? 2 : 1),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(width: 14, height: 14, margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(color: r.color, shape: BoxShape.circle,
                          border: Border.all(color: Colors.black12))),
                      Text(r.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                        color: sel ? AppColors.white : AppColors.textDark)),
                    ]),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // Size
            Text('Buket Boyutu', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...BouquetSize.values.map((s) {
              final sel = prov.size == s;
              return GestureDetector(
                onTap: () => prov.setSize(s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.rose.withOpacity(0.06) : AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: sel ? AppColors.rose : AppColors.border, width: sel ? 1.5 : 1),
                  ),
                  child: Row(children: [
                    AnimatedContainer(duration: const Duration(milliseconds: 200),
                      width: 20, height: 20,
                      decoration: BoxDecoration(shape: BoxShape.circle,
                        border: Border.all(color: sel ? AppColors.rose : AppColors.textLight, width: sel ? 5 : 1.5))),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(s.label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                        color: sel ? AppColors.rose : AppColors.textDark)),
                      Text('${s.legoCount} brick', style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                    ])),
                    Text('₺${s.price.toStringAsFixed(0)}', style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700,
                      color: sel ? AppColors.rose : AppColors.textMid)),
                  ]),
                ),
              );
            }),
            const SizedBox(height: 28),
            PrimaryButton(label: 'Tamam', onPressed: () => Navigator.pop(context)),
          ]),
        ),
      );
    });
  }
}
