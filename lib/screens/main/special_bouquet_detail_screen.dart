import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/widgets.dart';
import '../../data/special_day_data.dart';

class SpecialBouquetDetailScreen extends StatefulWidget {
  final SpecialBouquet bouquet;
  const SpecialBouquetDetailScreen({super.key, required this.bouquet});

  @override
  State<SpecialBouquetDetailScreen> createState() =>
      _SpecialBouquetDetailScreenState();
}

class _SpecialBouquetDetailScreenState
    extends State<SpecialBouquetDetailScreen> {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  List<String> get _images {
    final list = <String>[];
    if (widget.bouquet.normalAssetPath.isNotEmpty) {
      list.add(widget.bouquet.normalAssetPath);
    }
    list.add(widget.bouquet.assetPath);
    return list;
  }

  void _showAddToCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _AddToCartSheet(bouquet: widget.bouquet),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.bouquet.category.colors;
    final images = _images;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(children: [
        // ── Görsel alanı ─────────────────────────────────────────
        SizedBox(
          height: 340,
          child: Stack(children: [
            // Görseller
            PageView.builder(
              controller: _pageCtrl,
              itemCount: images.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (_, i) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors.first.withOpacity(0.35),
                      colors.first,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Image.asset(
                  images[i],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) => Center(
                    child: Text(widget.bouquet.category.emoji,
                        style: const TextStyle(fontSize: 100)),
                  ),
                ),
              ),
            ),
            // Geri butonu
            Positioned(
              top: topPad + 8,
              left: 8,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black26,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            // Tür etiketi
            if (images.length > 1)
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      _currentPage == 0 ? 'Gerçek Çiçek' : 'LEGO',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            // Dot göstergesi
            if (images.length > 1)
              Positioned(
                bottom: 14,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    images.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == i ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == i
                            ? AppColors.rose
                            : Colors.white.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
          ]),
        ),

        // ── Kaydırılabilir içerik ────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kategori chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colors.first.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(widget.bouquet.category.emoji,
                          style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 6),
                      Text(widget.bouquet.category.title,
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: colors.last)),
                    ]),
                  ),
                  const SizedBox(height: 14),

                  Text(widget.bouquet.title,
                      style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                          height: 1.2)),
                  const SizedBox(height: 6),
                  Text(widget.bouquet.description,
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textMid,
                          height: 1.55)),
                  const SizedBox(height: 20),

                  Row(children: [
                    _StatPill(
                      icon: Icons.extension_rounded,
                      label: '${widget.bouquet.legoCount} brick',
                    ),
                    const SizedBox(width: 8),
                    _StatPill(
                      icon: Icons.local_florist_rounded,
                      label: '${widget.bouquet.flowers.length} çiçek',
                    ),
                    const SizedBox(width: 8),
                    _StatPill(
                      icon: Icons.straighten_rounded,
                      label: widget.bouquet.size.label,
                    ),
                  ]),
                  const SizedBox(height: 20),

                  Text('İçindeki Çiçekler',
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: widget.bouquet.flowers
                        .toSet()
                        .map((f) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: f.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                    color: f.color.withOpacity(0.3)),
                              ),
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                          color: f.color,
                                          shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(f.nameTr,
                                        style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textDark)),
                                  ]),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ]),
          ),
        ),
      ]),

      // ── Alt bar ──────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
            16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          border:
              Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: Row(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Toplam',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: AppColors.textLight)),
              Text('₺${widget.bouquet.price.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.rose)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GradientButton(
              label: 'Sepete Ekle',
              icon: Icons.add_shopping_cart_rounded,
              onPressed: _showAddToCartSheet,
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Sepete Ekle alt sayfası ──────────────────────────────────────
class _AddToCartSheet extends StatefulWidget {
  final SpecialBouquet bouquet;
  const _AddToCartSheet({required this.bouquet});

  @override
  State<_AddToCartSheet> createState() => _AddToCartSheetState();
}

class _AddToCartSheetState extends State<_AddToCartSheet> {
  bool _isLego = true;
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  void _addToCart() {
    final prov = context.read<AppProvider>();
    final suffix = _isLego ? ' (LEGO)' : ' (Gerçek Çiçek)';
    final b = Bouquet(
      id: 'b_special_${widget.bouquet.id}_${DateTime.now().millisecondsSinceEpoch}',
      name: '${widget.bouquet.title}$suffix',
      flowers: widget.bouquet.flowers,
      ribbon: widget.bouquet.ribbon,
      size: widget.bouquet.size,
    );
    prov.addToCart(b);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.rose,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        content: Row(children: [
          const Icon(Icons.check_circle_outline_rounded,
              color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
              child: Text('${widget.bouquet.title} sepete eklendi',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600))),
        ]),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 24, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2)),
        ),
        Text('Tür Seçin',
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark)),
        const SizedBox(height: 6),
        Text('Buketinizi nasıl almak istersiniz?',
            style: GoogleFonts.poppins(
                fontSize: 13, color: AppColors.textMid)),
        const SizedBox(height: 20),

        Row(children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isLego = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  color: _isLego
                      ? AppColors.rose.withOpacity(0.08)
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isLego ? AppColors.rose : AppColors.border,
                    width: _isLego ? 2 : 1,
                  ),
                ),
                child: Column(children: [
                  const Text('🧱', style: TextStyle(fontSize: 28)),
                  const SizedBox(height: 8),
                  Text('LEGO',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _isLego
                              ? AppColors.rose
                              : AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text('Sonsuz ömür',
                      style: GoogleFonts.poppins(
                          fontSize: 10, color: AppColors.textLight)),
                ]),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isLego = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  color: !_isLego
                      ? AppColors.rose.withOpacity(0.08)
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: !_isLego ? AppColors.rose : AppColors.border,
                    width: !_isLego ? 2 : 1,
                  ),
                ),
                child: Column(children: [
                  const Text('🌸', style: TextStyle(fontSize: 28)),
                  const SizedBox(height: 8),
                  Text('Gerçek Çiçek',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: !_isLego
                              ? AppColors.rose
                              : AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text('Taze buket',
                      style: GoogleFonts.poppins(
                          fontSize: 10, color: AppColors.textLight)),
                ]),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 20),

        TextField(
          controller: _noteCtrl,
          maxLines: 3,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Sipariş notu (opsiyonel)',
            hintStyle: GoogleFonts.poppins(
                fontSize: 13, color: AppColors.textLight),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.rose, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 20),

        GradientButton(
          label: 'Sepete Ekle',
          icon: Icons.add_shopping_cart_rounded,
          onPressed: _addToCart,
        ),
      ]),
    );
  }
}

// ── Yardımcı widget ──────────────────────────────────────────────
class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(children: [
          Icon(icon, size: 18, color: AppColors.rose),
          const SizedBox(height: 4),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
        ]),
      ),
    );
  }
}
