import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';
import '../../data/special_day_data.dart';
import '../bouquet/bouquet_builder_screen.dart';
import '../main/special_bouquet_detail_screen.dart';
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
        body: items.isEmpty
            ? const _EmptyCart()
            : Column(children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    itemCount: items.length,
                    itemBuilder: (_, i) => _CartTile(
                      item: items[i],
                      isSpecial: _findSpecialBouquet(items[i]) != null,
                      onAiPreview: () =>
                          _generateAiPreview(context, prov, items[i]),
                      onIncrement: () =>
                          prov.updateCartQty(items[i].id, items[i].qty + 1),
                      onDecrement: () =>
                          prov.updateCartQty(items[i].id, items[i].qty - 1),
                      onRemove: () => prov.removeFromCart(items[i].id),
                      onTap: () {
                        final special = _findSpecialBouquet(items[i]);
                        if (special != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  SpecialBouquetDetailScreen(bouquet: special),
                            ),
                          );
                          return;
                        }

                        prov.loadBouquetForEdit(items[i].bouquet);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                BouquetBuilderScreen(cartItem: items[i]),
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
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
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
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Toplam Tutar',
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppColors.textDark,
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
              onPressed: () => Navigator.pop(context),
              child: const Text('Vazgeç')),
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

  Future<void> _generateAiPreview(
    BuildContext context,
    AppProvider prov,
    CartItem item,
  ) async {
    final style = item.isLego ? AiPreviewStyle.lego : AiPreviewStyle.realistic;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text('${style.shortLabel} hazırlanıyor...',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ]),
      ),
    );
    try {
      await prov.applyAiPreviewToCart(item.id, style);
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('${style.shortLabel} görseli hazır.'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFD32030),
          content: Text('AI görseli üretilemedi: $e'),
        ),
      );
    }
  }
}

class _CartTile extends StatelessWidget {
  final CartItem item;
  final bool isSpecial;
  final VoidCallback onIncrement, onDecrement, onRemove;
  final VoidCallback onAiPreview;
  final VoidCallback? onTap;
  const _CartTile({
    required this.item,
    required this.isSpecial,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onAiPreview,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final b = item.bouquet;
    final hasAiImage = b.aiImageBase64?.isNotEmpty == true;
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
        child: Column(children: [
          if (hasAiImage) ...[
            _AiHeroPreview(
              item: item,
              onView: () => _showAiPreviewDialog(context, item),
            ),
            const SizedBox(height: 12),
          ],
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Mini buket önizleme
            SizedBox(
              width: hasAiImage ? 0 : 64,
              height: hasAiImage ? 0 : 64,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  color: b.ribbon.color.withOpacity(0.10),
                  child: Stack(children: [
                    Positioned.fill(
                      child: b.aiImageBase64?.isNotEmpty == true
                          ? Image.memory(
                              base64Decode(b.aiImageBase64!),
                              fit: BoxFit.contain,
                            )
                          : b.previewImageBytes != null
                              ? Image.memory(b.previewImageBytes!,
                                  fit: BoxFit.contain)
                              : b.previewAssetPath != null
                                  ? Image.asset(
                                      b.previewAssetPath!,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.local_florist_rounded,
                                        color: AppColors.rose,
                                      ),
                                    )
                                  : FittedBox(
                                      fit: BoxFit.contain,
                                      child: SizedBox(
                                        width: 180,
                                        height: 180,
                                        child: BouquetPreview(
                                          flowers: b.flowers,
                                          placed: b.placedFlowers.isNotEmpty
                                              ? b.placedFlowers
                                              : null,
                                          ribbon: b.ribbon,
                                          template: b.template,
                                          height: 180,
                                        ),
                                      ),
                                    ),
                    ),
                    if (b.aiPreviewStyle != null)
                      Positioned(
                        left: 4,
                        right: 4,
                        bottom: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.textDark.withValues(alpha: 0.72),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            b.aiPreviewStyle!.shortLabel,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white),
                          ),
                        ),
                      ),
                  ]),
                ),
              ),
            ),
            if (!hasAiImage) const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                    if (!isSpecial) ...[
                      const SizedBox(height: 6),
                      _AiPreviewControls(
                        isLego: item.isLego,
                        style: b.aiPreviewStyle,
                        hasImage: b.aiImageBase64?.isNotEmpty == true,
                        onTap: onAiPreview,
                        onView: () => _showAiPreviewDialog(context, item),
                      ),
                    ],
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
                        item.deliveryAddress?.isNotEmpty == true ||
                        item.isNft) ...[
                      const SizedBox(height: 6),
                      _CartExtras(item: item),
                    ],
                    const SizedBox(height: 8),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Qty stepper
                          _QtyStepper(
                              qty: item.qty,
                              onInc: onIncrement,
                              onDec: onDecrement),
                          // Fiyat: buket + ekstra ücretler
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (item.extraFees > 0)
                                  Text(
                                      '+₺${item.extraFees.toStringAsFixed(0)} ek',
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
        ]),
      ),
    );
  }

  void _showAiPreviewDialog(BuildContext context, CartItem item) {
    final imageBase64 = item.bouquet.aiImageBase64;
    if (imageBase64 == null || imageBase64.isEmpty) return;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(18),
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 10, 8),
            child: Row(children: [
              Expanded(
                child: Text(item.bouquet.aiPreviewStyle?.label ?? 'AI Görsel',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark)),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
                color: AppColors.textLight,
              ),
            ]),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4,
                  child: Image.memory(
                    base64Decode(imageBase64),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _AiHeroPreview extends StatelessWidget {
  final CartItem item;
  final VoidCallback onView;

  const _AiHeroPreview({
    required this.item,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final imageBase64 = item.bouquet.aiImageBase64!;
    return SizedBox(
      height: 260,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(children: [
          Positioned.fill(
            child: Container(
              color: item.bouquet.ribbon.color.withValues(alpha: 0.08),
              child: Image.memory(
                base64Decode(imageBase64),
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            left: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.textDark.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                item.bouquet.aiPreviewStyle?.shortLabel ?? 'AI Görsel',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: onView,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.open_in_full_rounded,
                  size: 17,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _AiPreviewControls extends StatelessWidget {
  final bool isLego;
  final AiPreviewStyle? style;
  final bool hasImage;
  final VoidCallback onTap;
  final VoidCallback onView;

  const _AiPreviewControls({
    required this.isLego,
    required this.style,
    required this.hasImage,
    required this.onTap,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final expectedStyle =
        isLego ? AiPreviewStyle.lego : AiPreviewStyle.realistic;
    final selected = style == expectedStyle;
    final color = selected ? const Color(0xFF6B48FF) : AppColors.rose;
    final label = selected
        ? '${expectedStyle.shortLabel} hazır'
        : 'AI Görseline Dönüştür';
    return Wrap(spacing: 6, runSpacing: 6, children: [
      InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: selected ? 0.16 : 0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(
              isLego ? Icons.extension_rounded : Icons.auto_awesome_rounded,
              size: 13,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 10, fontWeight: FontWeight.w700, color: color)),
          ]),
        ),
      ),
      if (hasImage)
        InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onView,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.textDark.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(999),
              border:
                  Border.all(color: AppColors.textDark.withValues(alpha: 0.14)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.open_in_full_rounded,
                  size: 12, color: AppColors.textDark),
              const SizedBox(width: 4),
              Text('Büyük Gör',
                  style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark)),
            ]),
          ),
        ),
    ]);
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
        if (item.deliveryAddress?.isNotEmpty == true)
          _ExtraRow(
            icon: Icons.location_on_outlined,
            label: item.deliveryAddress!.replaceAll('\n', ' '),
            color: const Color(0xFF3070D0),
          ),
        if (item.isNft)
          _ExtraRow(
            icon: Icons.diamond_outlined,
            label: item.nftHash != null ? 'NFT · ${item.nftHash!}' : 'NFT mint',
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
                fontSize: 10, color: color, fontWeight: FontWeight.w500),
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
  const _QtyStepper(
      {required this.qty, required this.onInc, required this.onDec});

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
              child:
                  Icon(Icons.remove_rounded, size: 16, color: AppColors.rose)),
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
              child: Icon(Icons.add_rounded, size: 16, color: AppColors.rose)),
        ),
      ]),
    );
  }
}

SpecialBouquet? _findSpecialBouquet(CartItem item) {
  final explicitId = item.bouquet.specialBouquetId;
  final parsedId = _parseSpecialBouquetId(item.bouquet.id);
  final id = explicitId ?? parsedId;
  if (id == null) return null;
  for (final bouquet in specialBouquets) {
    if (bouquet.id == id) return bouquet;
  }
  return null;
}

String? _parseSpecialBouquetId(String bouquetId) {
  const prefix = 'b_special_';
  if (!bouquetId.startsWith(prefix)) return null;
  final raw = bouquetId.substring(prefix.length);
  final parts = raw.split('_');
  if (parts.length < 2) return null;
  return '${parts[0]}_${parts[1]}';
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
              style:
                  GoogleFonts.poppins(fontSize: 13, color: AppColors.textMid)),
        ]),
      ),
    );
  }
}
