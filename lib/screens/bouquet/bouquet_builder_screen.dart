import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/widgets.dart';
import '../../widgets/save_to_collection_sheet.dart';
import '../../widgets/share_sheet.dart';
import 'customize_screen.dart';

/// Buket Önizleme — bir önceki ekrandaki tasarımı kullanır.
/// AppBar: ❤ Favori · 💾 Kaydet (koleksiyon) · 📤 Paylaş (screenshot)
class BouquetBuilderScreen extends StatefulWidget {
  const BouquetBuilderScreen({super.key});

  @override
  State<BouquetBuilderScreen> createState() => _BouquetBuilderScreenState();
}

class _BouquetBuilderScreenState extends State<BouquetBuilderScreen> {
  /// RepaintBoundary key — paylaş butonu bu sahneyi PNG'e çevirir.
  final GlobalKey _previewKey = GlobalKey();

  List<PlacedFlowerData> _editablePlaced = [];
  bool _initialized = false;
  String? _selectedId;
  bool _layerPanelOpen = false;

  void _share(Bouquet b) {
    ShareSheet.show(context, previewKey: _previewKey, bouquet: b);
  }

  void _toast(String msg, {Color? bg}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: bg ?? AppColors.rose,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(children: [
          const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
              child: Text(msg,
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontWeight: FontWeight.w600))),
        ]),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showCartToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.rose,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(children: [
          const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
              child: Text(msg,
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontWeight: FontWeight.w600))),
        ]),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAddToCartSheet(Bouquet bouquet, AppProvider prov) {
    if (bouquet.flowers.length < 5) {
      final remaining = 5 - bouquet.flowers.length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFE08020),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          content: Row(children: [
            const Icon(Icons.info_outline_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'En az 5 çiçek gerekli. $remaining çiçek daha ekle.',
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ]),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TypeSelectionSheet(
        bouquet: bouquet,
        onSelect: (isLego) {
          Navigator.pop(context);
          prov.addToCart(bouquet, isLego: isLego);
          _showCartToast('${bouquet.name} sepete eklendi');
        },
      ),
    );
  }

  void _select(String? id) => setState(() => _selectedId = id);

  void _moveFlower(String id, Offset newPos) {
    final i = _editablePlaced.indexWhere((p) => p.id == id);
    if (i < 0) return;
    setState(() {
      _editablePlaced[i] = _editablePlaced[i].copyWith(
        position: Offset(
          newPos.dx.clamp(0.05, 0.95),
          newPos.dy.clamp(0.05, 0.75),
        ),
      );
    });
  }

  void _setScale(String id, double s) {
    final i = _editablePlaced.indexWhere((p) => p.id == id);
    if (i < 0) return;
    setState(() => _editablePlaced[i] = _editablePlaced[i].copyWith(scale: s));
  }

  void _setRotation(String id, double r) {
    final i = _editablePlaced.indexWhere((p) => p.id == id);
    if (i < 0) return;
    setState(() => _editablePlaced[i] = _editablePlaced[i].copyWith(rotation: r));
  }

  void _bringForward(String id) {
    final i = _editablePlaced.indexWhere((p) => p.id == id);
    if (i < 0 || i == _editablePlaced.length - 1) return;
    setState(() {
      final item = _editablePlaced.removeAt(i);
      _editablePlaced.insert(i + 1, item);
    });
  }

  void _sendBackward(String id) {
    final i = _editablePlaced.indexWhere((p) => p.id == id);
    if (i <= 0) return;
    setState(() {
      final item = _editablePlaced.removeAt(i);
      _editablePlaced.insert(i - 1, item);
    });
  }

  void _deleteFlower(String id) {
    setState(() {
      _editablePlaced.removeWhere((p) => p.id == id);
      if (_selectedId == id) _selectedId = null;
    });
  }

  PlacedFlowerData? get _selectedFlower {
    if (_selectedId == null) return null;
    try {
      return _editablePlaced.firstWhere((p) => p.id == _selectedId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, prov, _) {
      final isFreeDesign = prov.isFreeDesign;
      final placed = prov.placedFlowers;

      // Provider'dan gelen listeyi lokal state'e ilk seferinde kopyala
      if (!_initialized && placed.isNotEmpty) {
        _editablePlaced = List.from(placed);
        _initialized = true;
      }
      final bouquet = prov.currentBouquet;
      final isFavorite =
          bouquet != null && prov.isFavorite(bouquet.id);

      return Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          backgroundColor: AppColors.cream,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            isFreeDesign
                ? 'Tasarımım'
                : (prov.inputName.isEmpty ? 'Buketim' : prov.inputName),
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 28,
              color: AppColors.rose,
              letterSpacing: isFreeDesign ? 0.5 : 4,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: isFavorite ? 'Favorilerden çıkar' : 'Favorile',
              icon: Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_outline_rounded,
                color: AppColors.rose,
              ),
              onPressed: bouquet == null
                  ? null
                  : () {
                      prov.toggleFavorite(bouquet);
                      _toast(isFavorite
                          ? 'Favorilerden çıkarıldı'
                          : 'Favorilere eklendi 💖');
                    },
            ),
            IconButton(
              tooltip: 'Kaydet',
              icon: const Icon(Icons.bookmark_outline_rounded,
                  color: AppColors.rose),
              onPressed: bouquet == null
                  ? null
                  : () => SaveToCollectionSheet.show(context, bouquet),
            ),
            IconButton(
              tooltip: 'Paylaş',
              icon: const Icon(Icons.ios_share_rounded,
                  color: AppColors.rose),
              onPressed: bouquet == null ? null : () => _share(bouquet),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Column(children: [
            // ── Buket canvas — sürüklenebilir + RepaintBoundary ──
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _editablePlaced.isEmpty
                    ? const Center(
                        child: Text('Çiçek yok',
                            style: TextStyle(color: AppColors.textLight)),
                      )
                    : Stack(children: [
                        RepaintBoundary(
                          key: _previewKey,
                          child: Container(
                            color: AppColors.cream,
                            child: _DraggableBouquetCanvas(
                              placed: _editablePlaced,
                              selectedId: _selectedId,
                              onSelect: _select,
                              onMove: _moveFlower,
                              onTapEmpty: () {
                                _select(null);
                                if (_layerPanelOpen) {
                                  setState(() => _layerPanelOpen = false);
                                }
                              },
                              template: prov.template,
                            ),
                          ),
                        ),
                        // ── Katman paneli ──────────────────────────
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: _LayerPanel(
                            placed: _editablePlaced,
                            selectedId: _selectedId,
                            isOpen: _layerPanelOpen,
                            onToggle: () => setState(
                                () => _layerPanelOpen = !_layerPanelOpen),
                            onSelect: (id) => setState(() {
                              _selectedId = id;
                              _layerPanelOpen = false;
                            }),
                          ),
                        ),
                      ]),
              ),
            ),

            // ── Seçili çiçek kontrol paneli ───────────────────────
            if (_selectedFlower != null)
              _FlowerControls(
                placed: _selectedFlower!,
                onScale: (s) => _setScale(_selectedFlower!.id, s),
                onRotate: (r) => _setRotation(_selectedFlower!.id, r),
                onForward: () => _bringForward(_selectedFlower!.id),
                onBackward: () => _sendBackward(_selectedFlower!.id),
                onDelete: () => _deleteFlower(_selectedFlower!.id),
              ),

            // ── Alfabe akışında: harf adı + chip listesi ───────────
            if (!isFreeDesign && prov.flowers.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        for (final f in prov.flowers)
                          TextSpan(
                            text: f.letter,
                            style: GoogleFonts.dmSerifDisplay(
                              fontSize: 32,
                              color: f.color,
                              letterSpacing: 6,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6,
                  runSpacing: 6,
                  children: prov.flowers
                      .map((f) => GestureDetector(
                            onTap: () => showFlowerDetail(context, f),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: f.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                    color: f.color.withOpacity(0.3)),
                              ),
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(f.letter,
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: f.color)),
                                    const SizedBox(width: 5),
                                    Text(f.nameTr,
                                        style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            color:
                                                AppColors.textLight)),
                                  ]),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],

            // ── Free design'da kompakt bilgi şeridi ────────────────
            if (isFreeDesign && placed.isNotEmpty) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Text(
                  '${placed.length} çiçek · ${prov.ribbon.label} kurdele',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textMid,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 6),
            ],

            // ── Fiyat karşılaştırma barı ────────────────────────────
            if (bouquet != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(children: [
                    // Normal buket fiyatı
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🌸 Normal Buket',
                                style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: AppColors.textLight)),
                            Text('₺${bouquet.normalPrice.toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.rose)),
                          ]),
                    ),
                    Container(
                        width: 1, height: 36, color: AppColors.border),
                    const SizedBox(width: 12),
                    // LEGO buket fiyatı
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🧱 LEGO · ${bouquet.legoCount} brick',
                                style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: AppColors.textLight)),
                            Text('₺${bouquet.price.toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF3070D0))),
                          ]),
                    ),
                  ]),
                ),
              ),

            // ── Eylemler: Özelleştir + Sepete Ekle ────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                  16, 6, 16, MediaQuery.of(context).padding.bottom + 12),
              child: Row(children: [
                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CustomizeScreen())),
                      icon: const Icon(Icons.tune_rounded, size: 18),
                      label: Text('Özelleştir',
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: AppColors.rose.withOpacity(0.5),
                            width: 1.5),
                        foregroundColor: AppColors.rose,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: GradientButton(
                    label: 'Sepete Ekle',
                    icon: Icons.add_shopping_cart_rounded,
                    onPressed: bouquet == null
                        ? null
                        : () => _showAddToCartSheet(bouquet, prov),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      );
    });
  }
}

// ── Katman Paneli ────────────────────────────────────────────────────────────
class _LayerPanel extends StatelessWidget {
  final List<PlacedFlowerData> placed;
  final String? selectedId;
  final bool isOpen;
  final VoidCallback onToggle;
  final ValueChanged<String> onSelect;

  const _LayerPanel({
    required this.placed,
    required this.selectedId,
    required this.isOpen,
    required this.onToggle,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Liste paneli ──────────────────────────
        AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          width: isOpen ? 62 : 0,
          child: ClipRect(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: isOpen ? 1.0 : 0.0,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 12,
                      offset: const Offset(4, 0),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 6),
                      child: Text(
                        'Katmanlar',
                        style: GoogleFonts.poppins(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textLight,
                            letterSpacing: 0.5),
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          children: placed.reversed.map((p) {
                            final selected = p.id == selectedId;
                            return GestureDetector(
                              onTap: () => onSelect(p.id),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 3),
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.rose.withOpacity(0.12)
                                      : AppColors.cream,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.rose
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Image.asset(
                                        p.flower.assetPath,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) =>
                                            Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: p.flower.color
                                                .withOpacity(0.6),
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (selected)
                                      Positioned(
                                        right: 2,
                                        top: 2,
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: const BoxDecoration(
                                            color: AppColors.rose,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.check_rounded,
                                            size: 7,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Toggle butonu ─────────────────────────
        GestureDetector(
          onTap: onToggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            width: 24,
            height: 72,
            decoration: BoxDecoration(
              color: isOpen ? AppColors.rose : Colors.white.withOpacity(0.92),
              borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(3, 0),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isOpen
                      ? Icons.chevron_left_rounded
                      : Icons.layers_rounded,
                  size: 16,
                  color: isOpen ? Colors.white : AppColors.rose,
                ),
                if (!isOpen) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${placed.length}',
                    style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.rose),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Tür Seçim Sayfası ────────────────────────────────────────────────────────
class _TypeSelectionSheet extends StatelessWidget {
  final Bouquet bouquet;
  final void Function(bool isLego) onSelect;

  const _TypeSelectionSheet({required this.bouquet, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text('Buket Tipi Seç',
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark)),
          const SizedBox(height: 6),
          Text('Hangi versiyonu sepete eklemek istiyorsun?',
              style: GoogleFonts.poppins(
                  fontSize: 12, color: AppColors.textLight)),
          const SizedBox(height: 20),
          _TypeCard(
            emoji: '🌸',
            title: 'Normal Buket',
            subtitle: 'Gerçek çiçeklerle hazırlanır, kapınıza teslim',
            price: '₺${bouquet.normalPrice.toStringAsFixed(0)}',
            accentColor: AppColors.rose,
            onTap: () => onSelect(false),
          ),
          const SizedBox(height: 12),
          _TypeCard(
            emoji: '🧱',
            title: 'LEGO Buket',
            subtitle: '${bouquet.legoCount} brick · Kalıcı hatıra',
            price: '₺${bouquet.price.toStringAsFixed(0)}',
            accentColor: const Color(0xFF3070D0),
            onTap: () => onSelect(true),
          ),
        ],
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String price;
  final Color accentColor;
  final VoidCallback onTap;

  const _TypeCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accentColor.withOpacity(0.3), width: 1.5),
        ),
        child: Row(children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                  Text(subtitle,
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: AppColors.textLight)),
                ]),
          ),
          Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(price,
                    style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: accentColor)),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('Ekle',
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ]),
        ]),
      ),
    );
  }
}

class _DraggableBouquetCanvas extends StatelessWidget {
  final List<PlacedFlowerData> placed;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final void Function(String id, Offset newNormalized) onMove;
  final VoidCallback onTapEmpty;
  final BouquetTemplate template;

  const _DraggableBouquetCanvas({
    required this.placed,
    required this.selectedId,
    required this.onSelect,
    required this.onMove,
    required this.onTapEmpty,
    required this.template,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;
      return GestureDetector(
        onTap: onTapEmpty,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: w,
          height: h,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // Şablon (sap + yapraklar)
              Positioned.fill(
                child: Image.asset(
                  template.assetPath,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/images/bouquet_template.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                  ),
                ),
              ),
              ...placed.map((p) {
                final selected = p.id == selectedId;
                const base = 70.0;
                final size = base * p.scale;
                return Positioned(
                  left: p.position.dx * w - size / 2,
                  top: p.position.dy * h - size / 2,
                  width: size,
                  height: size,
                  child: GestureDetector(
                    onTap: () => onSelect(p.id),
                    onPanStart: (_) => onSelect(p.id),
                    onPanUpdate: (d) {
                      final nx = (p.position.dx * w + d.delta.dx) / w;
                      final ny = (p.position.dy * h + d.delta.dy) / h;
                      onMove(p.id, Offset(nx, ny));
                    },
                    child: Transform.rotate(
                      angle: p.rotation,
                      child: Stack(children: [
                        Image.asset(
                          p.flower.assetPath,
                          width: size,
                          height: size,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: p.flower.color.withOpacity(0.7),
                            ),
                          ),
                        ),
                        if (selected)
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.rose, width: 2.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.rose.withOpacity(0.35),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ]),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      );
    });
  }
}

class _FlowerControls extends StatelessWidget {
  final PlacedFlowerData placed;
  final ValueChanged<double> onScale;
  final ValueChanged<double> onRotate;
  final VoidCallback onForward;
  final VoidCallback onBackward;
  final VoidCallback onDelete;

  const _FlowerControls({
    required this.placed,
    required this.onScale,
    required this.onRotate,
    required this.onForward,
    required this.onBackward,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Column(children: [
        Row(children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
                color: placed.flower.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(placed.flower.nameTr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w700)),
          ),
          IconButton(
            tooltip: 'Geri katmana',
            icon: const Icon(Icons.flip_to_back_rounded, size: 20),
            color: AppColors.textMid,
            onPressed: onBackward,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          IconButton(
            tooltip: 'Öne getir',
            icon: const Icon(Icons.flip_to_front_rounded, size: 20),
            color: AppColors.textMid,
            onPressed: onForward,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          IconButton(
            tooltip: 'Sil',
            icon: const Icon(Icons.delete_outline_rounded, size: 20),
            color: AppColors.rose,
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ]),
        Row(children: [
          const Icon(Icons.zoom_out_map_rounded,
              size: 16, color: AppColors.textLight),
          Expanded(
            child: Slider(
              value: placed.scale.clamp(0.5, 2.0),
              min: 0.5,
              max: 2.0,
              activeColor: AppColors.rose,
              onChanged: onScale,
            ),
          ),
          SizedBox(
            width: 36,
            child: Text('${(placed.scale * 100).toInt()}%',
                style: GoogleFonts.poppins(
                    fontSize: 11, color: AppColors.textMid)),
          ),
        ]),
        Row(children: [
          const Icon(Icons.rotate_right_rounded,
              size: 16, color: AppColors.textLight),
          Expanded(
            child: Slider(
              value: placed.rotation.clamp(-3.14159, 3.14159),
              min: -3.14159,
              max: 3.14159,
              activeColor: AppColors.rose,
              onChanged: onRotate,
            ),
          ),
          SizedBox(
            width: 36,
            child: Text('${(placed.rotation * 180 / 3.14159).toInt()}°',
                style: GoogleFonts.poppins(
                    fontSize: 11, color: AppColors.textMid)),
          ),
        ]),
      ]),
    );
  }
}
