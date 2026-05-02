import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';
import 'orders_screen.dart';

class OrderSuccessScreen extends StatefulWidget {
  final Order order;
  const OrderSuccessScreen({super.key, required this.order});
  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale, _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _scale = Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const SizedBox(height: 32),
            ScaleTransition(scale: _scale,
              child: FadeTransition(opacity: _fade,
                child: Container(
                  width: 110, height: 110,
                  decoration: BoxDecoration(color: AppColors.greenLight, shape: BoxShape.circle),
                  child: const Center(child: Text('🎉', style: TextStyle(fontSize: 54))),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeTransition(opacity: _fade, child: Column(children: [
              Text('Siparişin Alındı!', style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: AppColors.green)),
              const SizedBox(height: 8),
              Text('Temsili sipariş başarıyla oluşturuldu', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(color: AppColors.rose.withOpacity(0.1), borderRadius: BorderRadius.circular(50)),
                child: Text(o.id, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                  color: AppColors.rose, letterSpacing: 1)),
              ),
            ])),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Sipariş Detayı', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                _InfoRow('Sipariş No', o.id),
                _InfoRow('Ürün',
                    o.items.length == 1
                        ? o.firstBouquet.name
                        : '${o.items.length} farklı buket'),
                _InfoRow('Toplam Adet', '${o.totalQty}'),
                _InfoRow('Toplam Brick', '${o.totalLego}'),
                _InfoRow('Alıcı', o.recipientName),
                _InfoRow('Durum', o.status.label, valueColor: AppColors.green),
                const Divider(height: 20),
                _InfoRow('Toplam', '₺${o.total.toStringAsFixed(0)}', bold: true),
              ]),
            ),
            if (o.giftMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.roseLight.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.rose.withOpacity(0.2)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Hediye Mesajı', style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                  const SizedBox(height: 6),
                  Text('"${o.giftMessage}"', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
                ]),
              ),
            ],
            const SizedBox(height: 32),
            PrimaryButton(label: 'Ana Sayfaya Dön',
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst)),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, height: 54,
              child: OutlinedButton(
                onPressed: () => Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const OrdersScreen())),
                child: const Text('Siparişlerime Git'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final bool bold;
  final Color? valueColor;
  const _InfoRow(this.label, this.value, {this.bold = false, this.valueColor});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textLight)),
      Text(value, style: TextStyle(fontSize: bold ? 16 : 13,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        color: valueColor ?? (bold ? AppColors.rose : AppColors.textDark))),
    ]),
  );
}
