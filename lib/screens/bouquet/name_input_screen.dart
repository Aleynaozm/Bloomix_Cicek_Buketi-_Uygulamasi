import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/widgets.dart';
import '../../data/flower_data.dart';
import '../../models/models.dart';
import 'bouquet_builder_screen.dart';

/// Çiçek Alfabesi — isim girme ekranı.
/// [editMode] = true → provider'daki mevcut isimle açılır (düzenleme akışı).
class NameInputScreen extends StatefulWidget {
  final bool editMode;
  const NameInputScreen({super.key, this.editMode = false});

  @override
  State<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> {
  final _ctrl = TextEditingController();
  List<Flower> _preview = [];

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onChanged);
    if (widget.editMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final name = context.read<AppProvider>().inputName;
        if (name.isNotEmpty) {
          _ctrl.text = name;
          _ctrl.selection = TextSelection.collapsed(offset: name.length);
        }
      });
    }
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onChanged);
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged() {
    setState(() => _preview = getFlowersForName(_ctrl.text));
  }

  void _go() {
    final cleaned = _ctrl.text.trim();
    if (cleaned.isEmpty) return;
    if (getFlowersForName(cleaned).length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFE08020),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Text('Çiçek alfabesi için en az 3 çiçek oluşmalı.',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ));
      return;
    }
    context.read<AppProvider>().generateBouquet(cleaned);
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const BouquetBuilderScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _ctrl.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: Text('Çiçek Alfabesi',
            style: GoogleFonts.dmSerifDisplay(
                fontSize: 22, color: AppColors.rose)),
        centerTitle: true,
      ),
      body: Stack(children: [
        // ── Pastel arka plan deseni ────────────────────────
        const Positioned.fill(child: _FloralBackground()),

        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 8),

            // ── Açıklama kartı ───────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.rose.withValues(alpha: 0.15)),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('🌸', style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('Bir İsim Yaz',
                        style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark)),
                    const SizedBox(height: 4),
                    Text(
                      'Her harf benzersiz bir çiçeğe dönüşür.\nDoğum günü, sevgililer günü ya da sürpriz için ideal.',
                      style: GoogleFonts.poppins(
                          fontSize: 12, height: 1.55, color: AppColors.textMid),
                    ),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 20),

            // ── TextField ───────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.rose.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _ctrl,
                textCapitalization: TextCapitalization.characters,
                style: GoogleFonts.dmSerifDisplay(
                    letterSpacing: 6,
                    fontWeight: FontWeight.w700,
                    fontSize: 26,
                    color: AppColors.rose),
                decoration: InputDecoration(
                  hintText: 'Buraya isim giriniz...',
                  hintStyle: GoogleFonts.poppins(
                      color: AppColors.textLight.withValues(alpha: 0.5),
                      letterSpacing: 1.0,
                      fontSize: 16),
                  prefixIcon:
                      const Icon(Icons.text_fields_rounded, color: AppColors.rose),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                ),
                onSubmitted: (_) => _go(),
              ),
            ),
            const SizedBox(height: 16),

            // ── Animasyonlu çiçek önizleme ─────────────
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              child: _preview.isEmpty
                  ? const SizedBox.shrink()
                  : _FlowerPreviewRow(flowers: _preview),
            ),
            if (_preview.isNotEmpty) const SizedBox(height: 16),

            // ── Buketi Oluştur butonu ─────────────────
            GradientButton(
              label: 'Buketi Oluştur',
              icon: Icons.auto_awesome_rounded,
              onPressed: hasText ? _go : null,
            ),
            const SizedBox(height: 32),

            // ── Alfabe ızgarası ──────────────────────
            Text('Türk Çiçek Alfabesi',
                style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            const SizedBox(height: 4),
            Text('29 harf — her biri bir çiçek',
                style: GoogleFonts.poppins(
                    fontSize: 11, color: AppColors.textLight)),
            const SizedBox(height: 14),
            _AlphabetGrid(),
          ]),
        ),
      ]),
    );
  }
}

// ── Pastel arka plan deseni ────────────────────────────────────
class _FloralBackground extends StatelessWidget {
  const _FloralBackground();

  @override
  Widget build(BuildContext context) {
    const emojis = ['🌸', '🌷', '🌼', '💐', '🌺', '🌹'];
    return IgnorePointer(
      child: CustomPaint(
        painter: _FloralPatternPainter(emojis),
      ),
    );
  }
}

class _FloralPatternPainter extends CustomPainter {
  final List<String> emojis;
  const _FloralPatternPainter(this.emojis);

  @override
  void paint(Canvas canvas, Size size) {
    final positions = [
      const Offset(0.05, 0.04),
      const Offset(0.90, 0.08),
      const Offset(0.02, 0.35),
      const Offset(0.93, 0.28),
      const Offset(0.08, 0.65),
      const Offset(0.88, 0.55),
      const Offset(0.04, 0.88),
      const Offset(0.92, 0.82),
      const Offset(0.50, 0.02),
    ];
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < positions.length; i++) {
      final emoji = emojis[i % emojis.length];
      tp.text = TextSpan(
        text: emoji,
        style: TextStyle(
          fontSize: 22,
          color: const Color(0xFFFFB8D4).withValues(alpha: 0.25),
        ),
      );
      tp.layout();
      tp.paint(
        canvas,
        Offset(
          positions[i].dx * size.width - tp.width / 2,
          positions[i].dy * size.height - tp.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Animasyonlu çiçek önizleme satırı ─────────────────────────
class _FlowerPreviewRow extends StatelessWidget {
  final List<Flower> flowers;
  const _FlowerPreviewRow({required this.flowers});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Buketindeki çiçekler',
          style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMid)),
      const SizedBox(height: 8),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < flowers.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              _AnimatedFlowerChip(
                key: ValueKey('${flowers[i].letter}_$i'),
                flower: flowers[i],
              ),
            ],
          ],
        ),
      ),
    ]);
  }
}

class _AnimatedFlowerChip extends StatefulWidget {
  final Flower flower;
  const _AnimatedFlowerChip({super.key, required this.flower});

  @override
  State<_AnimatedFlowerChip> createState() => _AnimatedFlowerChipState();
}

class _AnimatedFlowerChipState extends State<_AnimatedFlowerChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _scale =
        Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _ctrl,
      curve: Curves.elasticOut,
    ));
    _fade = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.flower;
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: GestureDetector(
          onTap: () => showFlowerDetail(context, f),
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 14, 8),
            decoration: BoxDecoration(
              color: f.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: f.color.withValues(alpha: 0.35)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(
                width: 28,
                height: 28,
                child: Image.asset(f.assetPath,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: f.color.withValues(alpha: 0.3)),
                          child: Center(
                              child: Text(f.letter,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: f.color))),
                        )),
              ),
              const SizedBox(width: 6),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(f.letter,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: f.color)),
                Text(f.nameTr,
                    style: GoogleFonts.poppins(
                        fontSize: 9, color: AppColors.textLight)),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}

// ── Alfabe ızgarası ────────────────────────────────────────────
class _AlphabetGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final entries = flowerAlphabet.entries.toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.78,
      ),
      itemCount: entries.length,
      itemBuilder: (_, i) {
        final f = entries[i].value;
        return GestureDetector(
          onTap: () => showFlowerDetail(context, f),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: f.color.withValues(alpha: 0.25)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 44,
                  child: Image.asset(f.assetPath,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: f.color.withValues(alpha: 0.2)),
                            width: 36,
                            height: 36,
                            child: Center(
                                child: Text(f.letter,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: f.color))),
                          )),
                ),
                const SizedBox(height: 4),
                Text(f.letter,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: f.color)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(f.nameTr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          fontSize: 7.5, color: AppColors.textLight)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
