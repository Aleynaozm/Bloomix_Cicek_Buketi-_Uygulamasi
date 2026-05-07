import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/widgets.dart';

class PurchasedBouquetsScreen extends StatelessWidget {
  const PurchasedBouquetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();

    // Her siparişten tüm buketleri çek, sipariş bilgisiyle birlikte
    final items = prov.orders
        .expand((o) => o.items.map((it) => (order: o, item: it)))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F9),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Satın Alınanlar',
            style: GoogleFonts.urbanist(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2D2D2D))),
        centerTitle: true,
      ),
      body: items.isEmpty
          ? Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('🛍️', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 16),
                Text('Henüz satın alınan buket yok',
                    style: GoogleFonts.urbanist(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2D2D2D))),
              ]),
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.78,
              ),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final entry = items[i];
                return _PurchasedBouquetCard(
                  bouquet: entry.item.bouquet,
                  orderId: entry.order.id,
                  orderDate: entry.order.createdAt,
                  isLego: entry.item.isLego,
                );
              },
            ),
    );
  }
}

class _PurchasedBouquetCard extends StatelessWidget {
  final Bouquet bouquet;
  final String orderId;
  final DateTime orderDate;
  final bool isLego;

  const _PurchasedBouquetCard({
    required this.bouquet,
    required this.orderId,
    required this.orderDate,
    required this.isLego,
  });

  static const _months = [
    '', 'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
    'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'
  ];

  String get _dateStr =>
      '${orderDate.day} ${_months[orderDate.month]} ${orderDate.year}';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEDE0E4), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Buket Önizleme ──────────────────────────────────
        Expanded(
          child: Container(
            width: double.infinity,
            color: bouquet.ribbon.color.withOpacity(0.08),
            child: bouquet.previewImageBytes != null
                ? Image.memory(bouquet.previewImageBytes!, fit: BoxFit.contain)
                : FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: BouquetPreview(
                        flowers: bouquet.flowers,
                        placed: bouquet.placedFlowers.isNotEmpty
                            ? bouquet.placedFlowers
                            : null,
                        ribbon: bouquet.ribbon,
                        template: bouquet.template,
                        height: 200,
                      ),
                    ),
                  ),
          ),
        ),

        // ── Bilgi ───────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(
                      bouquet.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.urbanist(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF2D2D2D)),
                    ),
                  ),
                  if (isLego)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3070D0).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('Lego',
                          style: GoogleFonts.urbanist(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF3070D0))),
                    ),
                ]),
                const SizedBox(height: 3),
                Text(
                  '${bouquet.flowers.length} çiçek',
                  style: GoogleFonts.urbanist(
                      fontSize: 11,
                      color: const Color(0xFF9A8A8E)),
                ),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.receipt_long_outlined,
                      size: 11, color: Color(0xFFFF4D7E)),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      _dateStr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.urbanist(
                          fontSize: 10,
                          color: const Color(0xFFFF4D7E),
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ]),
              ]),
        ),
      ]),
    );
  }
}
