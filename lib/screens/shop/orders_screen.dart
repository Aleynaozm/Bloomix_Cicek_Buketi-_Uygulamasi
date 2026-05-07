import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../bouquet/free_design_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<AppProvider>().orders;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F9),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Siparişlerim',
            style: GoogleFonts.urbanist(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2D2D2D))),
        centerTitle: true,
      ),
      body: orders.isEmpty
          ? _EmptyState()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (_, i) => _OrderCard(
                order: orders[i],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => OrderDetailScreen(order: orders[i])),
                ),
              ),
            ),
    );
  }
}

// ── Boş Durum ─────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('📦', style: TextStyle(fontSize: 56)),
        const SizedBox(height: 16),
        Text('Henüz siparişin yok',
            style: GoogleFonts.urbanist(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2D2D2D))),
        const SizedBox(height: 8),
        Text('İlk buketini tasarla ve sipariş ver!',
            style: GoogleFonts.urbanist(
                fontSize: 14, color: const Color(0xFF9A8A8E))),
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF4D7E),
            foregroundColor: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const FreeDesignScreen())),
          child: Text('Hemen Tasarla',
              style: GoogleFonts.urbanist(fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }
}

// ── Sipariş Kart (liste) ──────────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;
  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ID + Durum
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(order.id,
                          style: GoogleFonts.urbanist(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFFF4D7E),
                              letterSpacing: 0.5)),
                      _StatusBadge(status: order.status),
                    ]),
                const SizedBox(height: 12),

                // Buket adı
                Text(
                  order.items.length == 1
                      ? order.firstBouquet.name
                      : '${order.firstBouquet.name} +${order.items.length - 1} ürün',
                  style: GoogleFonts.urbanist(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2D2D2D)),
                ),
                const SizedBox(height: 4),
                Text(
                  '${order.totalQty} ürün  •  ${_formatDate(order.createdAt)}',
                  style: GoogleFonts.urbanist(
                      fontSize: 12, color: const Color(0xFF9A8A8E)),
                ),
                const SizedBox(height: 14),

                const Divider(height: 0, color: Color(0xFFEDE0E4)),
                const SizedBox(height: 12),

                // Alt satır
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        const Icon(Icons.person_outline,
                            size: 14, color: Color(0xFF9A8A8E)),
                        const SizedBox(width: 4),
                        Text(order.recipientName,
                            style: GoogleFonts.urbanist(
                                fontSize: 13,
                                color: const Color(0xFF9A8A8E))),
                      ]),
                      Row(children: [
                        Text(
                          '₺${order.total.toStringAsFixed(0)}',
                          style: GoogleFonts.urbanist(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFFF4D7E)),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            size: 13, color: Color(0xFFBBAFB2)),
                      ]),
                    ]),
              ]),
        ),
      ),
    );
  }
}

// ── Sipariş Detay Ekranı ──────────────────────────────────────────────────────
class OrderDetailScreen extends StatelessWidget {
  final Order order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F9),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Sipariş Detayı',
            style: GoogleFonts.urbanist(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2D2D2D))),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Sipariş No & Tarih ────────────────────────────
          _SectionCard(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sipariş No',
                            style: GoogleFonts.urbanist(
                                fontSize: 11,
                                color: const Color(0xFF9A8A8E),
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 3),
                        Text(order.id,
                            style: GoogleFonts.urbanist(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFFF4D7E))),
                      ]),
                  Column(crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Tarih',
                            style: GoogleFonts.urbanist(
                                fontSize: 11,
                                color: const Color(0xFF9A8A8E),
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 3),
                        Text(_formatDate(order.createdAt),
                            style: GoogleFonts.urbanist(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2D2D2D))),
                      ]),
                ]),
          ),
          const SizedBox(height: 14),

          // ── Durum İzleme ──────────────────────────────────
          _SectionCard(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sipariş Durumu',
                      style: GoogleFonts.urbanist(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2D2D2D))),
                  const SizedBox(height: 16),
                  _StatusTracker(status: order.status),
                ]),
          ),
          const SizedBox(height: 14),

          // ── Ürünler ───────────────────────────────────────
          _SectionTitle('Ürünler'),
          const SizedBox(height: 8),
          ...order.items.map((item) => _ItemRow(item: item)),
          const SizedBox(height: 14),

          // ── Teslimat Bilgileri ────────────────────────────
          _SectionTitle('Teslimat Bilgileri'),
          const SizedBox(height: 8),
          _SectionCard(
            child: Column(children: [
              _InfoRow(
                icon: Icons.person_outline,
                label: 'Alıcı',
                value: order.recipientName,
              ),
              _Divider(),
              _InfoRow(
                icon: Icons.location_on_outlined,
                label: 'Adres',
                value: order.address,
              ),
              _Divider(),
              _InfoRow(
                icon: Icons.phone_outlined,
                label: 'Telefon',
                value: order.phone,
              ),
              _Divider(),
              _InfoRow(
                icon: Icons.email_outlined,
                label: 'E-posta',
                value: order.email,
              ),
              if (_earliestDelivery(order) != null) ...[
                _Divider(),
                _InfoRow(
                  icon: Icons.calendar_month_outlined,
                  label: 'Teslimat Tarihi',
                  value: _formatDate(_earliestDelivery(order)!),
                ),
              ],
              if (order.giftMessage != null && order.giftMessage!.isNotEmpty)
                ...[
                _Divider(),
                _InfoRow(
                  icon: Icons.note_outlined,
                  label: 'Sipariş Notu',
                  value: order.giftMessage!,
                ),
              ],
            ]),
          ),
          const SizedBox(height: 14),

          // ── Ödeme Özeti ───────────────────────────────────
          _SectionTitle('Ödeme Özeti'),
          const SizedBox(height: 8),
          _SectionCard(
            child: _PaymentSummary(order: order),
          ),
          const SizedBox(height: 24),

          // ── Yardım Notu ───────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F8FF),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: const Color(0xFFB3D4F0), width: 1.5),
            ),
            child: Row(children: [
              const Icon(Icons.info_outline_rounded,
                  color: Color(0xFF2196F3), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Siparişinle ilgili bir sorun mu var? Yardım & Destek sayfasından bize ulaşabilirsin.',
                  style: GoogleFonts.urbanist(
                      fontSize: 12,
                      color: const Color(0xFF1565C0),
                      height: 1.5),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ── Durum Badge ───────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final OrderStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status.label,
          style: GoogleFonts.urbanist(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: status.color)),
    );
  }
}

// ── Durum İzleyici ────────────────────────────────────────────────────────────
class _StatusTracker extends StatelessWidget {
  final OrderStatus status;
  const _StatusTracker({required this.status});

  static const _steps = [
    (icon: Icons.check_circle_outline, label: 'Onaylandı'),
    (icon: Icons.handyman_outlined, label: 'Hazırlanıyor'),
    (icon: Icons.local_shipping_outlined, label: 'Kargoda'),
    (icon: Icons.home_outlined, label: 'Teslim Edildi'),
  ];

  @override
  Widget build(BuildContext context) {
    final activeIdx = status.index;
    return Row(
      children: _steps.asMap().entries.map((e) {
        final i = e.key;
        final step = e.value;
        final done = i <= activeIdx;
        final active = i == activeIdx;

        return Expanded(
          child: Row(children: [
            Expanded(
              child: Column(children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: done
                        ? (active
                            ? status.color
                            : status.color.withOpacity(0.15))
                        : const Color(0xFFF0F0F0),
                    shape: BoxShape.circle,
                    border: active
                        ? Border.all(color: status.color, width: 2)
                        : null,
                  ),
                  child: Icon(
                    step.icon,
                    size: 18,
                    color: done
                        ? (active ? Colors.white : status.color)
                        : const Color(0xFFBBAFB2),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  step.label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.urbanist(
                    fontSize: 9.5,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: done
                        ? status.color
                        : const Color(0xFFBBAFB2),
                  ),
                ),
              ]),
            ),
            if (i < _steps.length - 1)
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.only(bottom: 22),
                  color: i < activeIdx
                      ? status.color.withOpacity(0.4)
                      : const Color(0xFFEDE0E4),
                ),
              ),
          ]),
        );
      }).toList(),
    );
  }
}

// ── Ürün Satırı ───────────────────────────────────────────────────────────────
class _ItemRow extends StatelessWidget {
  final CartItem item;
  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDE0E4), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.local_florist_rounded,
                color: Color(0xFFFF4D7E), size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.bouquet.name,
                      style: GoogleFonts.urbanist(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2D2D2D))),
                  const SizedBox(height: 3),
                  Wrap(spacing: 6, children: [
                    _Tag('${item.bouquet.flowers.length} çiçek'),
                    if (item.isLego) _Tag('Lego', accent: true),
                    if (item.isNft) _Tag('NFT', accent: true),
                  ]),
                  if (item.giftNote != null && item.giftNote!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '📝 ${item.giftNote}',
                      style: GoogleFonts.urbanist(
                          fontSize: 11,
                          color: const Color(0xFF9A8A8E),
                          fontStyle: FontStyle.italic),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ]),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(
              '₺${item.lineTotal.toStringAsFixed(0)}',
              style: GoogleFonts.urbanist(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFFF4D7E)),
            ),
            const SizedBox(height: 2),
            Text('x${item.qty}',
                style: GoogleFonts.urbanist(
                    fontSize: 12, color: const Color(0xFF9A8A8E))),
          ]),
        ]),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final bool accent;
  const _Tag(this.label, {this.accent = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: accent
            ? const Color(0xFFFF4D7E).withOpacity(0.1)
            : const Color(0xFFF5F0F2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: GoogleFonts.urbanist(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: accent
                  ? const Color(0xFFFF4D7E)
                  : const Color(0xFF9A8A8E))),
    );
  }
}

// ── Yardımcı Widgetlar ────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: GoogleFonts.urbanist(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2D2D2D)));
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDE0E4), width: 1.5),
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0F3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFFFF4D7E)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.urbanist(
                        fontSize: 11,
                        color: const Color(0xFF9A8A8E),
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value,
                    style: GoogleFonts.urbanist(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D2D2D))),
              ]),
        ),
      ]),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final bool accent;
  const _PriceRow(
      {required this.label,
      required this.value,
      this.bold = false,
      this.accent = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: GoogleFonts.urbanist(
                    fontSize: bold ? 15 : 13,
                    fontWeight:
                        bold ? FontWeight.w800 : FontWeight.w500,
                    color: const Color(0xFF2D2D2D))),
            Text(value,
                style: GoogleFonts.urbanist(
                    fontSize: bold ? 18 : 14,
                    fontWeight:
                        bold ? FontWeight.w900 : FontWeight.w600,
                    color: accent
                        ? const Color(0xFFFF4D7E)
                        : const Color(0xFF2D2D2D))),
          ]),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 0, color: Color(0xFFEDE0E4));
}

// ── Ödeme Özeti ───────────────────────────────────────────────────────────────
class _PaymentSummary extends StatelessWidget {
  final Order order;
  const _PaymentSummary({required this.order});

  static const _deliveryFee = 150.0;

  @override
  Widget build(BuildContext context) {
    final subtotal = order.items
        .fold(0.0, (s, it) => s + it.bouquet.normalPrice * it.qty);
    final legoFee = order.items.fold(0.0, (s, it) => s + it.nftMintFee);
    final giftFee = order.items.fold(0.0, (s, it) => s + it.giftNoteFee);
    final grandTotal = subtotal + legoFee + giftFee + _deliveryFee;

    return Column(children: [
      _PriceRow(label: 'Ara Toplam', value: '₺${subtotal.toStringAsFixed(0)}'),
      if (legoFee > 0) ...[
        _Divider(),
        _PriceRow(
            label: 'Lego Üretim',
            value: '₺${legoFee.toStringAsFixed(0)}',
            accent: true),
      ],
      if (giftFee > 0) ...[
        _Divider(),
        _PriceRow(
            label: 'Sipariş Notu',
            value: '₺${giftFee.toStringAsFixed(0)}'),
      ],
      _Divider(),
      _PriceRow(label: 'Teslimat Ücreti', value: '₺${_deliveryFee.toStringAsFixed(0)}'),
      const SizedBox(height: 8),
      Container(height: 1.5, color: const Color(0xFFEDE0E4)),
      const SizedBox(height: 8),
      _PriceRow(
          label: 'Toplam',
          value: '₺${grandTotal.toStringAsFixed(0)}',
          bold: true,
          accent: true),
    ]);
  }
}

// ── Yardımcı Fonksiyon ────────────────────────────────────────────────────────
DateTime? _earliestDelivery(Order order) {
  final dates = order.items
      .map((it) => it.deliveryDate)
      .whereType<DateTime>()
      .toList();
  if (dates.isEmpty) return null;
  dates.sort();
  return dates.first;
}

String _formatDate(DateTime dt) {
  const months = [
    '', 'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
    'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'
  ];
  return '${dt.day} ${months[dt.month]} ${dt.year}';
}
