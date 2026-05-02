import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, prov, _) {
      final orders = prov.orders;
      return Scaffold(
        appBar: AppBar(title: const Text('Siparişlerim')),
        body: orders.isEmpty
            ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('📦', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 16),
                Text('Henüz siparişin yok', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('İlk buketini oluştur!', style: Theme.of(context).textTheme.bodyMedium),
              ]))
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: orders.length,
                itemBuilder: (_, i) {
                  final o = orders[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(o.id, style: TextStyle(fontSize: 12, color: AppColors.rose, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: o.status.color.withOpacity(0.1), borderRadius: BorderRadius.circular(50)),
                          child: Text(o.status.label, style: TextStyle(fontSize: 11, color: o.status.color, fontWeight: FontWeight.w600)),
                        ),
                      ]),
                      const SizedBox(height: 10),
                      Text(
                        o.items.length == 1
                            ? o.firstBouquet.name
                            : '${o.firstBouquet.name} +${o.items.length - 1} daha',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 22, letterSpacing: 3, color: AppColors.rose),
                      ),
                      const SizedBox(height: 4),
                      Text('${o.totalQty} ürün • ${o.totalLego} brick',
                        style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 10),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(o.recipientName, style: const TextStyle(fontSize: 13, color: AppColors.textMid)),
                        Text('₺${o.total.toStringAsFixed(0)}', style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.rose)),
                      ]),
                    ]),
                  );
                },
              ),
      );
    });
  }
}
