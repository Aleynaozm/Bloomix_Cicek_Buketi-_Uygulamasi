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
                    : RepaintBoundary(
                        key: _previewKey,
                        child: Container(
                          color: AppColors.cream,
                          child: _DraggableBouquetCanvas(
                            placed: _editablePlaced,
                            selectedId: _selectedId,
                            onSelect: _select,
                            onMove: _moveFlower,
                            onTapEmpty: () => _select(null),
                          ),
                        ),
                      ),
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

            // ── Fiyat + brick özet barı ────────────────────────────
            if (bouquet != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.roseLight.withOpacity(0.4),
                        AppColors.roseLight.withOpacity(0.2),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.rose.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                                Icons.extension_rounded,
                                size: 16,
                                color: AppColors.rose),
                          ),
                          const SizedBox(width: 10),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${bouquet.legoCount} brick',
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textDark)),
                                Text(prov.size.label,
                                    style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: AppColors.textLight)),
                              ]),
                        ]),
                        Text('₺${bouquet.price.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.rose)),
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
                        : () {
                            prov.addToCart(bouquet);
                            _toast('${bouquet.name} sepete eklendi');
                          },
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

class _DraggableBouquetCanvas extends StatelessWidget {
  final List<PlacedFlowerData> placed;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final void Function(String id, Offset newNormalized) onMove;
  final VoidCallback onTapEmpty;

  const _DraggableBouquetCanvas({
    required this.placed,
    required this.selectedId,
    required this.onSelect,
    required this.onMove,
    required this.onTapEmpty,
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
                  'assets/images/bouquet_template.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
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
