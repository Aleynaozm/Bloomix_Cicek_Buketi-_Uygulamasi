import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/widgets.dart';
import '../../models/models.dart';
import '../../data/flower_data.dart';
import 'bouquet_builder_screen.dart';

enum BouquetStyle { romantic, minimal, scattered, symmetric }

extension _BouquetStyleExt on BouquetStyle {
  String get label {
    switch (this) {
      case BouquetStyle.romantic:
        return 'Romantik';
      case BouquetStyle.minimal:
        return 'Minimal';
      case BouquetStyle.scattered:
        return 'Dağınık';
      case BouquetStyle.symmetric:
        return 'Simetrik';
    }
  }

  IconData get icon {
    switch (this) {
      case BouquetStyle.romantic:
        return Icons.favorite_rounded;
      case BouquetStyle.minimal:
        return Icons.crop_square_rounded;
      case BouquetStyle.scattered:
        return Icons.grain_rounded;
      case BouquetStyle.symmetric:
        return Icons.compare_arrows_rounded;
    }
  }
}

enum FlowerPalette { all, warm, cool, pastel }

extension _PaletteExt on FlowerPalette {
  String get label {
    switch (this) {
      case FlowerPalette.all:
        return 'Tümü';
      case FlowerPalette.warm:
        return 'Sıcak';
      case FlowerPalette.cool:
        return 'Soğuk';
      case FlowerPalette.pastel:
        return 'Pastel';
    }
  }

  /// Çiçeği palete göre filtrele — HSV bazlı.
  bool matches(Flower f) {
    final hsv = HSVColor.fromColor(f.color);
    switch (this) {
      case FlowerPalette.all:
        return true;
      case FlowerPalette.warm:
        return hsv.hue <= 65 || hsv.hue >= 320;
      case FlowerPalette.cool:
        return hsv.hue >= 180 && hsv.hue <= 290;
      case FlowerPalette.pastel:
        return hsv.value > 0.85 || hsv.saturation < 0.4;
    }
  }
}

/// Buket Tasarla — uygulamanın kalbi.
/// • Tap & drag ile canvas'a çiçek ekle
/// • Seçili çiçeği taşı, döndür, büyüt, ön/arka layer
/// • 4 stil + 4 palet + 🔥 otomatik buket
class FreeDesignScreen extends StatefulWidget {
  const FreeDesignScreen({super.key});

  @override
  State<FreeDesignScreen> createState() => _FreeDesignScreenState();
}

class _FreeDesignScreenState extends State<FreeDesignScreen> {
  final List<PlacedFlowerData> _placed = [];
  String? _selectedId;
  BouquetStyle _style = BouquetStyle.romantic;
  FlowerPalette _palette = FlowerPalette.all;
  int _idCounter = 0;

  String _nextId() => 'pf_${_idCounter++}';

  PlacedFlowerData? _findSelected() {
    if (_selectedId == null) return null;
    for (final p in _placed) {
      if (p.id == _selectedId) return p;
    }
    return null;
  }

  // ── Çiçek operasyonları ────────────────────────────────────
  void _addCenter(Flower f) {
    setState(() {
      final id = _nextId();
      _placed.add(PlacedFlowerData(
        id: id,
        flower: f,
        position: const Offset(0.5, 0.45),
      ));
      _selectedId = id;
    });
  }

  void _addAtPosition(Flower f, Offset normalized) {
    setState(() {
      final id = _nextId();
      _placed.add(PlacedFlowerData(
        id: id,
        flower: f,
        position: normalized,
      ));
      _selectedId = id;
    });
  }

  void _select(String? id) => setState(() => _selectedId = id);

  void _move(String id, Offset newNormalized) {
    final i = _placed.indexWhere((p) => p.id == id);
    if (i < 0) return;
    setState(() => _placed[i] = _placed[i].copyWith(
        position: Offset(
          newNormalized.dx.clamp(0.05, 0.95),
          newNormalized.dy.clamp(0.05, 0.95),
        )));
  }

  void _setScale(String id, double s) {
    final i = _placed.indexWhere((p) => p.id == id);
    if (i < 0) return;
    setState(() => _placed[i] = _placed[i].copyWith(scale: s));
  }

  void _setRotation(String id, double r) {
    final i = _placed.indexWhere((p) => p.id == id);
    if (i < 0) return;
    setState(() => _placed[i] = _placed[i].copyWith(rotation: r));
  }

  void _bringForward(String id) {
    final i = _placed.indexWhere((p) => p.id == id);
    if (i < 0 || i == _placed.length - 1) return;
    setState(() {
      final item = _placed.removeAt(i);
      _placed.insert(i + 1, item);
    });
  }

  void _sendBackward(String id) {
    final i = _placed.indexWhere((p) => p.id == id);
    if (i <= 0) return;
    setState(() {
      final item = _placed.removeAt(i);
      _placed.insert(i - 1, item);
    });
  }

  void _delete(String id) {
    setState(() {
      _placed.removeWhere((p) => p.id == id);
      if (_selectedId == id) _selectedId = null;
    });
  }

  void _clearAll() {
    if (_placed.isEmpty) return;
    setState(() {
      _placed.clear();
      _selectedId = null;
    });
  }

  // ── Otomatik buket üretici ────────────────────────────────
  void _autoGenerate() {
    final pool = flowerAlphabet.values.where(_palette.matches).toList();
    if (pool.isEmpty) return;
    final rng = Random();
    setState(() {
      _placed.clear();
      _selectedId = null;
      switch (_style) {
        case BouquetStyle.romantic:
          _genRomantic(pool, rng);
          break;
        case BouquetStyle.minimal:
          _genMinimal(pool, rng);
          break;
        case BouquetStyle.scattered:
          _genScattered(pool, rng);
          break;
        case BouquetStyle.symmetric:
          _genSymmetric(pool, rng);
          break;
      }
    });
  }

  void _genRomantic(List<Flower> pool, Random rng) {
    const n = 9;
    const cx = 0.5;
    const cy = 0.42;
    const radius = 0.18;
    for (int i = 0; i < n; i++) {
      final t = (i - (n - 1) / 2) / ((n - 1) / 2);
      final angle = t * pi / 2.5; // -72°..72°
      final x = cx + sin(angle) * radius;
      final y = cy + (1 - cos(angle)) * radius * 0.85;
      _placed.add(PlacedFlowerData(
        id: _nextId(),
        flower: pool[rng.nextInt(pool.length)],
        position: Offset(x, y),
        scale: 1.0 - t.abs() * 0.15,
        rotation: t * 0.18,
      ));
    }
  }

  void _genMinimal(List<Flower> pool, Random rng) {
    const n = 4;
    const cy = 0.46;
    for (int i = 0; i < n; i++) {
      final t = (n == 1) ? 0.0 : (i - (n - 1) / 2) / ((n - 1) / 2);
      final x = 0.5 + t * 0.18;
      final y = cy + (i.isEven ? -0.04 : 0.04);
      _placed.add(PlacedFlowerData(
        id: _nextId(),
        flower: pool[rng.nextInt(pool.length)],
        position: Offset(x, y),
        scale: 1.15,
      ));
    }
  }

  void _genScattered(List<Flower> pool, Random rng) {
    const n = 11;
    for (int i = 0; i < n; i++) {
      _placed.add(PlacedFlowerData(
        id: _nextId(),
        flower: pool[rng.nextInt(pool.length)],
        position: Offset(
          0.18 + rng.nextDouble() * 0.64,
          0.20 + rng.nextDouble() * 0.55,
        ),
        scale: 0.75 + rng.nextDouble() * 0.5,
        rotation: (rng.nextDouble() - 0.5) * 0.7,
      ));
    }
  }

  void _genSymmetric(List<Flower> pool, Random rng) {
    // 3x3 grid + ortada büyük 1 = 10 çiçek
    const cols = 3;
    const rows = 3;
    final gridFlowers = List.generate(rows * cols, (i) {
      final row = i ~/ cols;
      final col = i % cols;
      final x = 0.32 + col * 0.18;
      final y = 0.26 + row * 0.16;
      return PlacedFlowerData(
        id: _nextId(),
        flower: pool[i % pool.length],
        position: Offset(x, y),
        scale: 0.95,
      );
    });
    _placed.addAll(gridFlowers);
    // Merkez büyük çiçek
    _placed.add(PlacedFlowerData(
      id: _nextId(),
      flower: pool[rng.nextInt(pool.length)],
      position: const Offset(0.5, 0.42),
      scale: 1.4,
    ));
  }

  // ── Tamamla → BouquetBuilder ──────────────────────────────
  void _confirm() {
    if (_placed.isEmpty) return;
    // Pozisyonları + scale + rotation ile birlikte provider'a yolla.
    context.read<AppProvider>().setPlacedFlowers(_placed, name: 'Tasarımım');
    // PUSH (replace değil!) — geri tuşu FreeDesign'a state korunarak döner.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BouquetBuilderScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = _findSelected();

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Buket Tasarla'),
        actions: [
          if (_placed.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Sil',
              onPressed: _clearAll,
            ),
          IconButton(
            icon: const Icon(Icons.local_fire_department_rounded,
                color: Color(0xFFFF6B35)),
            tooltip: 'Otomatik Buket',
            onPressed: _autoGenerate,
          ),
        ],
      ),
      body: Column(children: [
        // ── Stil + Palet seçimi (kompakt) ─────────────────────
        _StyleAndPaletteRow(
          style: _style,
          palette: _palette,
          onStyleChanged: (s) => setState(() => _style = s),
          onPaletteChanged: (p) => setState(() => _palette = p),
        ),

        // ── Canvas ────────────────────────────────────────────
        Expanded(
          child: _DesignCanvas(
            placed: _placed,
            selectedId: _selectedId,
            onSelect: _select,
            onMove: _move,
            onTapEmpty: () => _select(null),
            onAcceptDrop: (f, normalized) =>
                _addAtPosition(f, normalized),
          ),
        ),

        // ── Seçili çiçek kontrol paneli ───────────────────────
        if (selected != null)
          _SelectedControls(
            placed: selected,
            onScale: (s) => _setScale(selected.id, s),
            onRotate: (r) => _setRotation(selected.id, r),
            onForward: () => _bringForward(selected.id),
            onBackward: () => _sendBackward(selected.id),
            onDelete: () => _delete(selected.id),
          ),

        // ── Çiçek paleti (alt strip) ──────────────────────────
        _FlowerPaletteStrip(
          palette: _palette,
          onTap: _addCenter,
        ),

        // ── Tamamla butonu ────────────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(
              16, 8, 16, MediaQuery.of(context).padding.bottom + 12),
          child: GradientButton(
            label: _placed.isEmpty
                ? 'Önce çiçek ekle'
                : 'Tasarımı Tamamla (${_placed.length})',
            icon: _placed.isEmpty ? null : Icons.check_rounded,
            onPressed: _placed.isEmpty ? null : _confirm,
          ),
        ),
      ]),
    );
  }
}

// ── Stil + palet kompakt seçim çubuğu ──────────────────────
class _StyleAndPaletteRow extends StatelessWidget {
  final BouquetStyle style;
  final FlowerPalette palette;
  final ValueChanged<BouquetStyle> onStyleChanged;
  final ValueChanged<FlowerPalette> onPaletteChanged;
  const _StyleAndPaletteRow({
    required this.style,
    required this.palette,
    required this.onStyleChanged,
    required this.onPaletteChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
            bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(children: [
        // Stil dropdown
        Expanded(
          child: _PickerChip(
            icon: style.icon,
            label: 'Stil: ${style.label}',
            onTap: () async {
              final v = await showModalBottomSheet<BouquetStyle>(
                context: context,
                builder: (_) => _StylePickerSheet(current: style),
              );
              if (v != null) onStyleChanged(v);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PickerChip(
            icon: Icons.palette_outlined,
            label: 'Palet: ${palette.label}',
            onTap: () async {
              final v = await showModalBottomSheet<FlowerPalette>(
                context: context,
                builder: (_) => _PalettePickerSheet(current: palette),
              );
              if (v != null) onPaletteChanged(v);
            },
          ),
        ),
      ]),
    );
  }
}

class _PickerChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PickerChip(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: AppColors.rose),
          const SizedBox(width: 6),
          Expanded(
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark)),
          ),
          const Icon(Icons.unfold_more_rounded,
              size: 14, color: AppColors.textLight),
        ]),
      ),
    );
  }
}

class _StylePickerSheet extends StatelessWidget {
  final BouquetStyle current;
  const _StylePickerSheet({required this.current});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 18),
          Text('Buket Stili',
              style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark)),
          const SizedBox(height: 14),
          ...BouquetStyle.values.map((s) {
            final sel = s == current;
            return ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    sel ? AppColors.rose : AppColors.rose.withOpacity(0.12),
                child: Icon(s.icon,
                    size: 18,
                    color: sel ? AppColors.white : AppColors.rose),
              ),
              title: Text(s.label,
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
                      color: sel ? AppColors.rose : AppColors.textDark)),
              subtitle: Text(_descFor(s),
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: AppColors.textLight)),
              trailing: sel
                  ? const Icon(Icons.check_circle, color: AppColors.rose)
                  : null,
              onTap: () => Navigator.pop(context, s),
            );
          }),
        ]),
      ),
    );
  }

  String _descFor(BouquetStyle s) {
    switch (s) {
      case BouquetStyle.romantic:
        return 'Klasik dome, sıkı kümelenmiş, simetrik';
      case BouquetStyle.minimal:
        return 'Az çiçek, geniş aralıklı, sade';
      case BouquetStyle.scattered:
        return 'Doğal dağılım, rastgele döndürülmüş';
      case BouquetStyle.symmetric:
        return 'Mükemmel simetri, grid yerleşim';
    }
  }
}

class _PalettePickerSheet extends StatelessWidget {
  final FlowerPalette current;
  const _PalettePickerSheet({required this.current});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 18),
          Text('Renk Paleti',
              style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark)),
          const SizedBox(height: 14),
          ...FlowerPalette.values.map((p) {
            final sel = p == current;
            return ListTile(
              leading: _PaletteSwatch(palette: p, selected: sel),
              title: Text(p.label,
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
                      color: sel ? AppColors.rose : AppColors.textDark)),
              subtitle: Text(_descFor(p),
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: AppColors.textLight)),
              trailing: sel
                  ? const Icon(Icons.check_circle, color: AppColors.rose)
                  : null,
              onTap: () => Navigator.pop(context, p),
            );
          }),
        ]),
      ),
    );
  }

  String _descFor(FlowerPalette p) {
    switch (p) {
      case FlowerPalette.all:
        return '29 çiçek — tüm renkler';
      case FlowerPalette.warm:
        return 'Kırmızı, turuncu, sarı, pembe';
      case FlowerPalette.cool:
        return 'Mavi, mor, beyaz';
      case FlowerPalette.pastel:
        return 'Yumuşak, açık tonlar';
    }
  }
}

class _PaletteSwatch extends StatelessWidget {
  final FlowerPalette palette;
  final bool selected;
  const _PaletteSwatch({required this.palette, required this.selected});

  @override
  Widget build(BuildContext context) {
    final colors = _swatchColors(palette);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        border: Border.all(
            color: selected ? AppColors.rose : AppColors.border, width: 2),
      ),
    );
  }

  List<Color> _swatchColors(FlowerPalette p) {
    switch (p) {
      case FlowerPalette.all:
        return [
          const Color(0xFFE8213A),
          const Color(0xFF9050C0),
          const Color(0xFFF5C842),
        ];
      case FlowerPalette.warm:
        return [
          const Color(0xFFE8213A),
          const Color(0xFFFF74B3),
          const Color(0xFFF5C842),
        ];
      case FlowerPalette.cool:
        return [
          const Color(0xFF6080E0),
          const Color(0xFF9050C0),
          const Color(0xFFE8E8FF),
        ];
      case FlowerPalette.pastel:
        return [
          const Color(0xFFFFC2DC),
          const Color(0xFFE8C8E0),
          const Color(0xFFC8E2C5),
        ];
    }
  }
}

// ── Canvas ─────────────────────────────────────────────────
class _DesignCanvas extends StatelessWidget {
  final List<PlacedFlowerData> placed;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final void Function(String, Offset) onMove;
  final VoidCallback onTapEmpty;
  final void Function(Flower, Offset) onAcceptDrop;

  const _DesignCanvas({
    required this.placed,
    required this.selectedId,
    required this.onSelect,
    required this.onMove,
    required this.onTapEmpty,
    required this.onAcceptDrop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;
      return DragTarget<Flower>(
        onAccept: (f) {
          // Drop = canvas merkezine ekle. Konum için sonra sürükler.
          onAcceptDrop(f, const Offset(0.5, 0.45));
        },
        builder: (_, __, ___) => GestureDetector(
          onTap: onTapEmpty,
          behavior: HitTestBehavior.opaque,
          child: CustomPaint(
            painter: _DotGridPainter(),
            child: SizedBox(
              width: w,
              height: h,
              child: placed.isEmpty
                  ? _CanvasEmptyHint()
                  : Stack(
                      clipBehavior: Clip.hardEdge,
                      children: placed.map((p) {
                        final selected = p.id == selectedId;
                        const flowerBase = 70.0;
                        final size = flowerBase * p.scale;
                        return Positioned(
                          left: p.position.dx * w - size / 2,
                          top: p.position.dy * h - size / 2,
                          width: size,
                          height: size,
                          child: GestureDetector(
                            onTap: () => onSelect(p.id),
                            onPanStart: (_) => onSelect(p.id),
                            onPanUpdate: (d) {
                              final newDx =
                                  (p.position.dx * w + d.delta.dx) / w;
                              final newDy =
                                  (p.position.dy * h + d.delta.dy) / h;
                              onMove(p.id, Offset(newDx, newDy));
                            },
                            child: Transform.rotate(
                              angle: p.rotation,
                              child: _FlowerImage(
                                flower: p.flower,
                                size: size,
                                selected: selected,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ),
        ),
      );
    });
  }
}

class _CanvasEmptyHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
                color: AppColors.roseLight.withOpacity(0.4),
                shape: BoxShape.circle),
            child: const Center(
                child: Icon(Icons.local_florist_rounded,
                    size: 46, color: AppColors.rose)),
          ),
          const SizedBox(height: 14),
          Text('Boş tuval',
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark)),
          const SizedBox(height: 4),
          Text('Aşağıdaki paletten çiçek dokun veya sürükle.\nOtomatik için 🔥 butonuna bas.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textMid,
                  height: 1.5)),
        ]),
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = AppColors.border.withOpacity(0.5);
    const spacing = 24.0;
    for (double x = 0; x < s.width; x += spacing) {
      for (double y = 0; y < s.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.7, p);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter old) => false;
}

class _FlowerImage extends StatelessWidget {
  final Flower flower;
  final double size;
  final bool selected;
  const _FlowerImage({
    required this.flower,
    required this.size,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: selected
          ? BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.rose, width: 2.5),
              boxShadow: [
                BoxShadow(
                    color: AppColors.rose.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 1),
              ],
            )
          : null,
      child: ClipOval(
        child: Image.asset(
          flower.assetPath,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                flower.color,
                flower.color.withOpacity(0.7),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Seçili çiçek kontrol paneli ─────────────────────────────
class _SelectedControls extends StatelessWidget {
  final PlacedFlowerData placed;
  final ValueChanged<double> onScale;
  final ValueChanged<double> onRotate;
  final VoidCallback onForward;
  final VoidCallback onBackward;
  final VoidCallback onDelete;

  const _SelectedControls({
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
        // Header
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

        // Scale & rotate sliders
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
              value: placed.rotation.clamp(-pi, pi),
              min: -pi,
              max: pi,
              activeColor: AppColors.rose,
              onChanged: onRotate,
            ),
          ),
          SizedBox(
            width: 36,
            child: Text('${(placed.rotation * 180 / pi).toInt()}°',
                style: GoogleFonts.poppins(
                    fontSize: 11, color: AppColors.textMid)),
          ),
        ]),
      ]),
    );
  }
}

// ── Çiçek paleti (alt strip) ────────────────────────────────
class _FlowerPaletteStrip extends StatelessWidget {
  final FlowerPalette palette;
  final ValueChanged<Flower> onTap;
  const _FlowerPaletteStrip({required this.palette, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final filtered =
        flowerAlphabet.values.where(palette.matches).toList();
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Çiçekler (${filtered.length})',
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark)),
                Text('Dokun veya sürükle',
                    style: GoogleFonts.poppins(
                        fontSize: 10, color: AppColors.textLight)),
              ]),
        ),
        Expanded(
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final f = filtered[i];
              return _PaletteFlowerThumb(flower: f, onTap: () => onTap(f));
            },
          ),
        ),
      ]),
    );
  }
}

class _PaletteFlowerThumb extends StatelessWidget {
  final Flower flower;
  final VoidCallback onTap;
  const _PaletteFlowerThumb({required this.flower, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final thumb = Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: flower.color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: flower.color.withOpacity(0.4)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Image.asset(
          flower.assetPath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Center(
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: flower.color.withOpacity(0.6),
              ),
            ),
          ),
        ),
      ),
    );
    return GestureDetector(
      onTap: onTap,
      child: LongPressDraggable<Flower>(
        data: flower,
        delay: const Duration(milliseconds: 180),
        feedback: Material(
          color: Colors.transparent,
          child: Transform.scale(
            scale: 1.1,
            child: SizedBox(width: 70, height: 70, child: thumb),
          ),
        ),
        childWhenDragging:
            Opacity(opacity: 0.4, child: thumb),
        child: thumb,
      ),
    );
  }
}
