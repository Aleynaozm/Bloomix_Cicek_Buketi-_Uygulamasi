import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';
import '../bouquet/bouquet_builder_screen.dart';
import 'checkout_screen.dart';

/// Sepet — eklenen tüm buketleri listeler, adet/silme ile düzenler,
/// alta sticky toplam + "Siparişi Tamamla" butonu yerleştirir.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, prov, _) {
      final items = prov.cart;
      final total = prov.cartTotal;
      final brickTotal = prov.cartLegoCount;

      return Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          title: const Text('Sepetim'),
          actions: [
            if (items.isNotEmpty)
              TextButton(
                onPressed: () => _confirmClear(context, prov),
                child: Text('Boşalt',
                    style: GoogleFonts.poppins(
                        color: AppColors.rose,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
          ],
        ),
        body: items.isEmpty ? const _EmptyCart() : Column(children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              itemCount: items.length,
              itemBuilder: (_, i) => _CartTile(
                item: items[i],
                onIncrement: () =>
                    prov.updateCartQty(items[i].id, items[i].qty + 1),
                onDecrement: () =>
                    prov.updateCartQty(items[i].id, items[i].qty - 1),
                onRemove: () => prov.removeFromCart(items[i].id),
                onTap: () {
                  prov.loadBouquetForEdit(items[i].bouquet);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BouquetBuilderScreen(cartItem: items[i]),
                    ),
                  );
                },
              ),
            ),
          ),

          // Bottom toplam + checkout
          Container(
            padding: EdgeInsets.fromLTRB(
                20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border(
                  top: BorderSide(color: AppColors.border, width: 0.5)),
            ),
            child: Column(children: [
              // Brick toplamı sadece LEGO ürünler varsa göster
              if (brickTotal > 0) ...[
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Toplam Brick',
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: AppColors.textLight)),
                  Text('$brickTotal adet',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF3070D0),
                          fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: 6),
              ],
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Toplam Tutar',
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: AppColors.textDark,
                        fontWeight: FontWeight.w600)),
                Text('₺${total.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                        fontSize: 22,
                        color: AppColors.rose,
                        fontWeight: FontWeight.w800)),
              ]),
              const SizedBox(height: 14),
              GradientButton(
                label: 'Siparişi Tamamla',
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const CheckoutScreen()));
                },
              ),
            ]),
          ),
        ]),
      );
    });
  }

  void _confirmClear(BuildContext context, AppProvider prov) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sepeti boşalt?'),
        content: const Text('Sepetindeki tüm buketler silinecek.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('Vazgeç')),
          TextButton(
            onPressed: () {
              prov.clearCart();
              Navigator.pop(context);
            },
            child: Text('Boşalt',
                style: GoogleFonts.poppins(
                    color: AppColors.rose, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _CartTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrement, onDecrement, onRemove;
  final VoidCallback? onTap;
  const _CartTile({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final b = item.bouquet;
    return GestureDetector(
      onTap: onTap,
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Mini buket önizleme
        SizedBox(
          width: 64,
          height: 64,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              color: b.ribbon.color.withOpacity(0.10),
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: 180,
                  height: 180,
                  child: BouquetPreview(
                    flowers: b.flowers,
                    placed: b.placedFlowers.isNotEmpty ? b.placedFlowers : null,
                    ribbon: b.ribbon,
                    template: b.template,
                    height: 180,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Text(b.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                        letterSpacing: 1.2)),
              ),
              GestureDetector(
                onTap: onRemove,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.close_rounded,
                      size: 18, color: AppColors.textLight),
                ),
              ),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: (item.isLego
                          ? const Color(0xFF3070D0)
                          : AppColors.rose)
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(item.isLego ? '🧱 LEGO' : '🌸 Normal',
                    style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: item.isLego
                            ? const Color(0xFF3070D0)
                            : AppColors.rose)),
              ),
            ]),
            if (item.isLego) ...[
              const SizedBox(height: 2),
              Text('${b.legoCount} brick',
                  style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFF3070D0),
                      fontWeight: FontWeight.w600)),
            ],
            // ── Ek hizmetler (not / tarih / NFT) ─────────────
            if (item.giftNote?.isNotEmpty == true ||
                item.deliveryDate != null ||
                item.isNft) ...[
              const SizedBox(height: 6),
              _CartExtras(item: item),
            ],
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              // Qty stepper
              _QtyStepper(
                  qty: item.qty,
                  onInc: onIncrement,
                  onDec: onDecrement),
              // Fiyat: buket + ekstra ücretler
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                if (item.extraFees > 0)
                  Text('+₺${item.extraFees.toStringAsFixed(0)} ek',
                      style: GoogleFonts.poppins(
                          fontSize: 9,
                          color: AppColors.rose,
                          fontWeight: FontWeight.w600)),
                Text('₺${item.lineTotal.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark)),
              ]),
            ]),
          ]),
        ),
      ]),
    ),
    );
  }
}

// ── Sepet kartı ek hizmet satırları ───────────────────────────
class _CartExtras extends StatelessWidget {
  final CartItem item;
  const _CartExtras({required this.item});

  static String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.rose.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.rose.withValues(alpha: 0.15)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (item.giftNote?.isNotEmpty == true)
          _ExtraRow(
            icon: Icons.mail_outline_rounded,
            label: '"${item.giftNote!}"',
            badge: item.giftNoteFee > 0
                ? '+₺${item.giftNoteFee.toStringAsFixed(0)}'
                : null,
          ),
        if (item.deliveryDate != null)
          _ExtraRow(
            icon: Icons.calendar_month_rounded,
            label: 'Teslimat: ${_fmtDate(item.deliveryDate!)}',
            color: const Color(0xFF3070D0),
          ),
        if (item.isNft)
          _ExtraRow(
            icon: Icons.diamond_outlined,
            label: item.nftHash != null
                ? 'NFT · ${item.nftHash!}'
                : 'NFT mint',
            badge: item.nftMintFee > 0
                ? '+₺${item.nftMintFee.toStringAsFixed(0)}'
                : null,
            color: const Color(0xFF6B48FF),
          ),
      ]),
    );
  }
}

class _ExtraRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final Color color;
  const _ExtraRow({
    required this.icon,
    required this.label,
    this.badge,
    this.color = AppColors.rose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w500),
          ),
        ),
        if (badge != null) ...[
          const SizedBox(width: 4),
          Text(badge!,
              style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: AppColors.rose,
                  fontWeight: FontWeight.w700)),
        ],
      ]),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  final int qty;
  final VoidCallback onInc, onDec;
  const _QtyStepper({required this.qty, required this.onInc, required this.onDec});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onDec,
          child: const SizedBox(
              width: 32,
              height: 32,
              child: Icon(Icons.remove_rounded,
                  size: 16, color: AppColors.rose)),
        ),
        SizedBox(
          width: 24,
          child: Text('$qty',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w700)),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onInc,
          child: const SizedBox(
              width: 32,
              height: 32,
              child: Icon(Icons.add_rounded,
                  size: 16, color: AppColors.rose)),
        ),
      ]),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: AppColors.roseLight.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: const Center(
                child: Icon(Icons.shopping_bag_outlined,
                    size: 54, color: AppColors.rose)),
          ),
          const SizedBox(height: 20),
          Text('Sepetin boş',
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark)),
          const SizedBox(height: 6),
          Text('Tasarladığın buketler burada görünür.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 13, color: AppColors.textMid)),
        ]),
      ),
    );
  }
}
