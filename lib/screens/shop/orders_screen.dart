import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';
import '../bouquet/free_design_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          backgroundColor: AppColors.cream,
          elevation: 0,
          title: Text('Siparişlerim',
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          bottom: TabBar(
            indicatorColor: AppColors.rose,
            indicatorWeight: 2.5,
            labelColor: AppColors.rose,
            unselectedLabelColor: AppColors.textLight,
            labelStyle:
                GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
            unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13),
            tabs: const [Tab(text: 'Aktif'), Tab(text: 'Geçmiş')],
          ),
        ),
        body: Consumer<AppProvider>(builder: (_, prov, __) {
          return TabBarView(children: [
            _OrderList(
              orders: prov.activeOrders,
              emptyIcon: '📦',
              emptyTitle: 'Aktif siparişin yok',
              emptyBody: 'Sepetinden ilk siparişini oluştur.',
            ),
            _OrderList(
              orders: prov.pastOrders,
              emptyIcon: '🌸',
              emptyTitle: 'Henüz tamamlanan sipariş yok',
              emptyBody: 'Geçmiş siparişlerin burada görünecek.',
            ),
          ]);
        }),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<Order> orders;
  final String emptyIcon, emptyTitle, emptyBody;
  const _OrderList({
    required this.orders,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptyBody,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(emptyIcon, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(emptyTitle,
                style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            const SizedBox(height: 6),
            Text(emptyBody,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 13, color: AppColors.textMid)),
            const SizedBox(height: 24),
            GradientButton(
              label: 'Hemen Tasarlamaya Başla',
              icon: Icons.local_florist_outlined,
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const FreeDesignScreen())),
            ),
          ]),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      itemCount: orders.length,
      itemBuilder: (_, i) => _OrderCard(order: orders[i]),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});

  static String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  @override
  Widget build(BuildContext context) {
    final b = order.firstBouquet;
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.cream,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        builder: (_) => _OrderDetailSheet(order: order),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
                color: AppColors.rose.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 60, height: 60,
                color: b.ribbon.color.withValues(alpha: 0.10),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: 150, height: 150,
                    child: BouquetPreview(
                      flowers: b.flowers,
                      placed: b.placedFlowers.isNotEmpty ? b.placedFlowers : null,
                      ribbon: b.ribbon,
                      template: b.template,
                      height: 150,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(order.id,
                      style: GoogleFonts.poppins(
                          fontSize: 11, fontWeight: FontWeight.w700,
                          color: AppColors.rose, letterSpacing: 0.4)),
                  _StatusBadge(status: order.status),
                ]),
                const SizedBox(height: 4),
                Text(
                  order.items.length == 1 ? b.name : '${b.name} +${order.items.length - 1} ürün',
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: AppColors.textDark),
                ),
                const SizedBox(height: 2),
                Text(_fmtDate(order.createdAt),
                    style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textLight)),
                const SizedBox(height: 6),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(order.recipientName,
                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMid)),
                  Text('₺${order.total.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w700,
                          color: AppColors.rose)),
                ]),
              ]),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AppColors.textLight),
          ]),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: status.color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(status.label,
            style: GoogleFonts.poppins(
                fontSize: 10, fontWeight: FontWeight.w700, color: status.color)),
      );
}

class _OrderDetailSheet extends StatelessWidget {
  final Order order;
  const _OrderDetailSheet({required this.order});

  static String _fmtFull(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year} '
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (_, ctrl) => ListView(
        controller: ctrl,
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Sipariş Detayı',
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.w800,
                      color: AppColors.textDark)),
              Text(order.id,
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: AppColors.rose,
                      fontWeight: FontWeight.w600)),
            ]),
            _StatusBadge(status: order.status),
          ]),
          const SizedBox(height: 20),
          _SectionTitle('Ürünler'),
          ...order.items.map((it) => _ItemRow(item: it)),
          const SizedBox(height: 16),
          _SectionTitle('Teslimat Bilgileri'),
          _InfoRow(Icons.person_outline_rounded, 'Alıcı', order.recipientName),
          _InfoRow(Icons.location_on_outlined, 'Adres', order.address),
          _InfoRow(Icons.phone_outlined, 'Telefon', order.phone),
          _InfoRow(Icons.calendar_today_outlined, 'Sipariş Tarihi', _fmtFull(order.createdAt)),
          if (order.giftMessage?.isNotEmpty == true)
            _InfoRow(Icons.mail_outline_rounded, 'Hediye Notu', order.giftMessage!),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.rose.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Toplam Tutar',
                  style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      color: AppColors.textDark)),
              Text('₺${order.total.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                      fontSize: 20, fontWeight: FontWeight.w800,
                      color: AppColors.rose)),
            ]),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text,
            style: GoogleFonts.poppins(
                fontSize: 12, fontWeight: FontWeight.w700,
                color: AppColors.textMid, letterSpacing: 0.5)),
      );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 16, color: AppColors.rose),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textLight)),
              Text(value,
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: AppColors.textDark,
                      fontWeight: FontWeight.w500)),
            ]),
          ),
        ]),
      );
}

class _ItemRow extends StatelessWidget {
  final CartItem item;
  const _ItemRow({required this.item});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.bouquet.name,
                    style: GoogleFonts.poppins(
                        fontSize: 13, fontWeight: FontWeight.w700,
                        color: AppColors.textDark)),
                Text(
                    '${item.isLego ? "🧱 LEGO" : "🌸 Normal"} · '
                    '${item.bouquet.size.label} · ${item.bouquet.ribbon.label}',
                    style: GoogleFonts.poppins(
                        fontSize: 10, color: AppColors.textLight)),
              ]),
            ),
            Text('x${item.qty}',
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMid)),
            const SizedBox(width: 12),
            Text('₺${item.lineTotal.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.rose)),
          ],
        ),
      );
}
