import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/widgets.dart';
import '../../models/models.dart';
import '../../data/flower_data.dart';
import 'bouquet_builder_screen.dart';

// Sol panel aktif sekmesi
enum _PanelTab { layers, templates }

/// Buket Tasarla — uygulamanın kalbi.
/// • Sol panel: Katmanlar sekmesi + Şablonlar sekmesi
/// • Tap & drag ile canvas'a çiçek ekle
/// • Seçili çiçeği taşı, döndür, büyüt, ön/arka layer
/// • 🔥 otomatik buket
class FreeDesignScreen extends StatefulWidget {
  /// Düzenleme modunda önceki çiçekler ile açılır.
  final List<PlacedFlowerData>? initialPlaced;
  final bool preserveName;
  final bool keepAlphabetFlow;
  const FreeDesignScreen({
    super.key,
    this.initialPlaced,
    this.preserveName = false,
    this.keepAlphabetFlow = false,
  });

  @override
  State<FreeDesignScreen> createState() => _FreeDesignScreenState();
}

class _FreeDesignScreenState extends State<FreeDesignScreen> {
  final List<PlacedFlowerData> _placed = [];
  final GlobalKey _canvasKey = GlobalKey();
  String? _selectedId;
  bool _panelOpen = false;
  _PanelTab _activeTab = _PanelTab.layers;
  int _idCounter = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialPlaced != null && widget.initialPlaced!.isNotEmpty) {
      _placed.addAll(widget.initialPlaced!);
      _idCounter = _placed.length;
    }
  }

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
        position: const Offset(0.5, 0.32),
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
          newNormalized.dx.clamp(0.08, 0.92),
          newNormalized.dy.clamp(0.05, 0.70),
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

  // ── Otomatik buket (romantik dome, tüm çiçekler) ──────────
  void _autoGenerate() {
    final pool = flowerAlphabet.values.toList();
    final rng = Random();
    const n = 9;
    const cx = 0.5;
    const cy = 0.30;
    const radius = 0.16;
    setState(() {
      _placed.clear();
      _selectedId = null;
      for (int i = 0; i < n; i++) {
        final t = (i - (n - 1) / 2) / ((n - 1) / 2);
        final angle = t * pi / 2.5;
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
    });
  }

  // ── Panel toggle ───────────────────────────────────────────
  void _togglePanel(_PanelTab tab) {
    setState(() {
      if (_panelOpen && _activeTab == tab) {
        _panelOpen = false;
      } else {
        _panelOpen = true;
        _activeTab = tab;
      }
    });
  }

  // ── Tamamla → BouquetBuilder ──────────────────────────────
  Future<void> _confirm() async {
    if (_placed.isEmpty) return;
    if (!widget.keepAlphabetFlow && _placed.length < 5) {
      _toast('Serbest tasarım için en az 5 çiçek seçmelisin.');
      return;
    }
    if (widget.keepAlphabetFlow && _placed.length < 3) {
      _toast('Çiçek alfabesi için en az 3 çiçek olmalı.');
      return;
    }

    // Seçimi kaldır, bir frame bekle, sonra canvas'ı yakala
    setState(() => _selectedId = null);
    await Future.microtask(() {});
    if (!mounted) return;

    final prov = context.read<AppProvider>();

    try {
      final boundary = _canvasKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 2.0);
        final byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          prov.setDesignPreviewImage(byteData.buffer.asUint8List());
        }
      }
    } catch (_) {
      prov.setDesignPreviewImage(null);
    }

    final name = widget.preserveName && prov.inputName.trim().isNotEmpty
        ? prov.inputName
        : 'Tasarımım';
    prov.setPlacedFlowers(
      _placed,
      name: name,
      isFreeDesign: !widget.keepAlphabetFlow,
    );
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const BouquetBuilderScreen()),
      );
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFFE08020),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      content: Text(msg,
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.w600)),
    ));
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
              tooltip: 'Temizle',
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
      body: Consumer<AppProvider>(
        builder: (_, prov, __) => Column(children: [
          // ── Canvas + Sol Panel ────────────────────────────────
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Sol panel ─────────────────────────────────
                _LeftPanel(
                  panelOpen: _panelOpen,
                  activeTab: _activeTab,
                  placed: _placed,
                  selectedId: _selectedId,
                  currentTemplate: prov.template,
                  onToggle: _togglePanel,
                  onSelectLayer: (id) => setState(() {
                    _selectedId = id;
                    _panelOpen = false;
                  }),
                  onTemplateChanged: (t) {
                    prov.setTemplate(t);
                    setState(() => _panelOpen = false);
                  },
                ),

                // ── Tasarım alanı ──────────────────────────────
                Expanded(
                  child: _DesignCanvas(
                    placed: _placed,
                    selectedId: _selectedId,
                    template: prov.template,
                    repaintKey: _canvasKey,
                    onSelect: (id) {
                      _select(id);
                      if (_panelOpen) setState(() => _panelOpen = false);
                    },
                    onMove: _move,
                    onTapEmpty: () {
                      _select(null);
                      if (_panelOpen) setState(() => _panelOpen = false);
                    },
                    onAcceptDrop: (f, normalized) =>
                        _addAtPosition(f, normalized),
                  ),
                ),
              ],
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
          _FlowerPaletteStrip(onTap: _addCenter),

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
      ),
    );
  }
}

// ── Sol Panel ───────────────────────────────────────────────
/// Row tabanlı açılır/kapanır panel.
/// Sol taraf: AnimatedContainer (içerik).
/// Sağ taraf: İki toggle butonu (Katmanlar + Şablonlar).
class _LeftPanel extends StatelessWidget {
  final bool panelOpen;
  final _PanelTab activeTab;
  final List<PlacedFlowerData> placed;
  final String? selectedId;
  final BouquetTemplate currentTemplate;
  final void Function(_PanelTab) onToggle;
  final ValueChanged<String> onSelectLayer;
  final ValueChanged<BouquetTemplate> onTemplateChanged;

  const _LeftPanel({
    required this.panelOpen,
    required this.activeTab,
    required this.placed,
    required this.selectedId,
    required this.currentTemplate,
    required this.onToggle,
    required this.onSelectLayer,
    required this.onTemplateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Panel içerik alanı ─────────────────────────────
        AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          width: panelOpen ? 156 : 0,
          child: ClipRect(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: panelOpen ? 1.0 : 0.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.97),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 12,
                      offset: const Offset(4, 0),
                    ),
                  ],
                ),
                child: panelOpen
                    ? (activeTab == _PanelTab.layers
                        ? _LayersContent(
                            placed: placed,
                            selectedId: selectedId,
                            onSelect: onSelectLayer,
                          )
                        : _TemplatesContent(
                            currentTemplate: currentTemplate,
                            onChanged: onTemplateChanged,
                          ))
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ),

        // ── İki toggle butonu (dikey sütun) ────────────────
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            // Şablonlar butonu
            _PanelTabButton(
              icon: Icons.auto_awesome_mosaic_outlined,
              label: 'Şablon',
              active: panelOpen && activeTab == _PanelTab.templates,
              onTap: () => onToggle(_PanelTab.templates),
            ),
            const SizedBox(height: 6),
            // Katmanlar butonu
            _PanelTabButton(
              icon: Icons.layers_rounded,
              label: 'Katman',
              badge: placed.isNotEmpty ? '${placed.length}' : null,
              active: panelOpen && activeTab == _PanelTab.layers,
              onTap: () => onToggle(_PanelTab.layers),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Panel Tab Butonu ────────────────────────────────────────
class _PanelTabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final bool active;
  final VoidCallback onTap;

  const _PanelTabButton({
    required this.icon,
    required this.label,
    this.badge,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 28,
        height: 64,
        decoration: BoxDecoration(
          color: active ? AppColors.rose : Colors.white.withOpacity(0.92),
          borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 8,
              offset: const Offset(3, 0),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              active ? Icons.chevron_left_rounded : icon,
              size: 15,
              color: active ? Colors.white : AppColors.rose,
            ),
            if (!active) ...[
              const SizedBox(height: 2),
              if (badge != null)
                Text(badge!,
                    style: GoogleFonts.poppins(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: AppColors.rose))
              else
                Text(label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontSize: 7,
                        fontWeight: FontWeight.w700,
                        color: AppColors.rose,
                        letterSpacing: 0.2)),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Katmanlar İçerik ────────────────────────────────────────
/// Placed çiçek listesi — tersine sıralanmış (en üst katman önce).
/// Z-order, _placed listesinin sırasıyla senkronize (son index = en üstte).
class _LayersContent extends StatelessWidget {
  final List<PlacedFlowerData> placed;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  const _LayersContent({
    required this.placed,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 6),
          child: Row(children: [
            const Icon(Icons.layers_rounded, size: 13, color: AppColors.rose),
            const SizedBox(width: 5),
            Text('Katmanlar',
                style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
          ]),
        ),
        if (placed.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
            child: Text('Henüz çiçek\neklenmedi',
                style: GoogleFonts.poppins(
                    fontSize: 10, color: AppColors.textLight)),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
              // Tersine — en üst katman (son index) listenin başında
              itemCount: placed.length,
              itemBuilder: (_, i) {
                final p = placed[placed.length - 1 - i];
                final sel = p.id == selectedId;
                return GestureDetector(
                  onTap: () => onSelect(p.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel
                          ? AppColors.rose.withOpacity(0.10)
                          : AppColors.cream,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: sel ? AppColors.rose : Colors.transparent,
                        width: sel ? 1.5 : 1,
                      ),
                    ),
                    child: Row(children: [
                      // Çiçek küçük resmi
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.asset(
                            p.flower.assetPath,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Container(
                              decoration: BoxDecoration(
                                color: p.flower.color.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(p.flower.letter,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: p.flower.color)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(p.flower.nameTr,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                                fontSize: 9,
                                fontWeight: sel
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: sel
                                    ? AppColors.rose
                                    : AppColors.textDark)),
                      ),
                      if (sel)
                        const Icon(Icons.check_circle_rounded,
                            size: 12, color: AppColors.rose),
                    ]),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

// ── Şablonlar İçerik ────────────────────────────────────────
/// 4 şablon kartı. PNG eklenince otomatik görünür,
/// yoksa emoji + isim ile placeholder gösterir.
class _TemplatesContent extends StatelessWidget {
  final BouquetTemplate currentTemplate;
  final ValueChanged<BouquetTemplate> onChanged;

  const _TemplatesContent({
    required this.currentTemplate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 6),
          child: Row(children: [
            const Icon(Icons.auto_awesome_mosaic_outlined,
                size: 13, color: AppColors.rose),
            const SizedBox(width: 5),
            Text('Şablonlar',
                style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
            itemCount: BouquetTemplate.values.length,
            itemBuilder: (_, i) {
              final t = BouquetTemplate.values[i];
              final sel = currentTemplate == t;
              return GestureDetector(
                onTap: () => onChanged(t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: sel
                        ? AppColors.rose.withOpacity(0.08)
                        : AppColors.cream,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: sel ? AppColors.rose : AppColors.border,
                      width: sel ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Şablon önizleme görseli
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(10)),
                        child: SizedBox(
                          height: 72,
                          width: double.infinity,
                          child: Image.asset(
                            t.assetPath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.cream,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(t.emoji,
                                      style:
                                          const TextStyle(fontSize: 28)),
                                  Text('PNG ekle',
                                      style: GoogleFonts.poppins(
                                          fontSize: 8,
                                          color: AppColors.textLight)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // İsim + seçim göstergesi
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        child: Row(children: [
                          Expanded(
                            child: Text(t.label,
                                style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: sel
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: sel
                                        ? AppColors.rose
                                        : AppColors.textDark)),
                          ),
                          if (sel)
                            const Icon(Icons.check_circle_rounded,
                                size: 13, color: AppColors.rose),
                        ]),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
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
  final BouquetTemplate template;
  final GlobalKey? repaintKey;

  const _DesignCanvas({
    required this.placed,
    required this.selectedId,
    required this.onSelect,
    required this.onMove,
    required this.onTapEmpty,
    required this.onAcceptDrop,
    required this.template,
    this.repaintKey,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;
      return DragTarget<Flower>(
        onAccept: (f) => onAcceptDrop(f, const Offset(0.5, 0.30)),
        builder: (_, __, ___) => GestureDetector(
          onTap: onTapEmpty,
          behavior: HitTestBehavior.opaque,
          child: RepaintBoundary(
            key: repaintKey,
            child: SizedBox(
              width: w,
              height: h,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  // ── Şablon arka planı ──────────────────────
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

                  // ── Boş ipucu ──────────────────────────────
                  if (placed.isEmpty) _CanvasEmptyHint(),

                  // ── Yerleştirilmiş çiçekler ─────────────────
                  // Sıralama: placed[0] altta, placed.last üstte (Katman z-order)
                  ...placed.map((p) {
                    final sel = p.id == selectedId;
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
                            selected: sel,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
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
    return Positioned(
      top: 12,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.82),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            'Aşağıdan çiçek ekle veya 🔥 ile otomatik doldur',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textMid,
            ),
          ),
        ),
      ),
    );
  }
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
    return Stack(
      children: [
        Image.asset(
          flower.assetPath,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                flower.color,
                flower.color.withOpacity(0.7),
              ]),
            ),
          ),
        ),
        if (selected)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.rose, width: 2.5),
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
      ],
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
        border:
            Border(top: BorderSide(color: AppColors.border, width: 0.5)),
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
            constraints:
                const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          IconButton(
            tooltip: 'Öne getir',
            icon: const Icon(Icons.flip_to_front_rounded, size: 20),
            color: AppColors.textMid,
            onPressed: onForward,
            padding: EdgeInsets.zero,
            constraints:
                const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          IconButton(
            tooltip: 'Sil',
            icon: const Icon(Icons.delete_outline_rounded, size: 20),
            color: AppColors.rose,
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints:
                const BoxConstraints(minWidth: 32, minHeight: 32),
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
/// Tüm çiçekleri gösterir — palet filtresi kaldırıldı.
class _FlowerPaletteStrip extends StatelessWidget {
  final ValueChanged<Flower> onTap;
  const _FlowerPaletteStrip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final flowers = flowerAlphabet.values.toList();
    return Container(
      height: 118,
      decoration: BoxDecoration(
        color: AppColors.white,
        border:
            Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Çiçekler (${flowers.length})',
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
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
            itemCount: flowers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final f = flowers[i];
              return _PaletteFlowerThumb(
                  flower: f, onTap: () => onTap(f));
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
  const _PaletteFlowerThumb(
      {required this.flower, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final thumb = Container(
      width: 62,
      height: 62,
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
            child: Text(flower.letter,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: flower.color)),
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
            child: SizedBox(width: 68, height: 68, child: thumb),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.4, child: thumb),
        child: thumb,
      ),
    );
  }
}
