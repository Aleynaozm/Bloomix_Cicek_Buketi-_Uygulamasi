import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

// ── Bloomix Logo ──────────────────────────────────────────
class BloomixLogo extends StatelessWidget {
  final double size;
  final bool dark;
  final Color? color;
  const BloomixLogo({super.key, this.size = 28, this.dark = false, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? (dark ? AppColors.white : AppColors.rose);
    return Text(
      'Bloomix',
      style: GoogleFonts.dmSerifDisplay(
        fontSize: size,
        color: c,
        height: 1.0,
        letterSpacing: 0.5,
      ),
    );
  }
}

// ── Flower SVG Card ────────────────────────────────────────
class FlowerCard extends StatelessWidget {
  final Flower flower;
  final double size;
  final VoidCallback? onTap;

  const FlowerCard({super.key, required this.flower, this.size = 80, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: size, height: size * 1.4,
            decoration: BoxDecoration(
              color: flower.color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: flower.color.withOpacity(0.2)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  flower.assetPath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => _PlaceholderFlower(flower: flower),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(flower.letter, style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700, color: flower.color,
          )),
          Text(
            flower.nameTr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderFlower extends StatelessWidget {
  final Flower flower;
  const _PlaceholderFlower({required this.flower});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: flower.color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(flower.letter, style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700,
              color: flower.color,
            )),
          ),
        ),
        Container(width: 3, height: 30, color: AppColors.green.withOpacity(0.5)),
      ],
    );
  }
}

// ── Bouquet Preview ─────────────────────────────────────────
/// Gerçek buket görseli: pozisyonlu çiçekler → her birinden curve sap →
/// merkezde bind point + kurdele → altta paralel saplar → kanvas dibi.
///
/// `placed` doluysa o pozisyonları kullanır (FreeDesign veya alfabe dome).
/// `flowers` parametresi geriye uyumluluk için tutuldu, kullanılmıyor.
class BouquetPreview extends StatefulWidget {
  final List<Flower> flowers;
  final List<PlacedFlowerData>? placed;
  final RibbonStyle ribbon;
  final double height;

  const BouquetPreview({
    super.key,
    required this.flowers,
    this.placed,
    required this.ribbon,
    this.height = 320,
  });

  @override
  State<BouquetPreview> createState() => _BouquetPreviewState();
}

class _BouquetPreviewState extends State<BouquetPreview> with TickerProviderStateMixin {
  late List<AnimationController> _ctrls;
  late List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didUpdateWidget(BouquetPreview old) {
    super.didUpdateWidget(old);
    if (old.flowers != widget.flowers) {
      for (final c in _ctrls) c.dispose();
      _init();
    }
  }

  void _init() {
    final n = widget.flowers.length;
    _ctrls = List.generate(n, (_) => AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500),
    ));
    _anims = _ctrls.map((c) => CurvedAnimation(parent: c, curve: Curves.easeOutBack)).toList();
    for (int i = 0; i < n; i++) {
      Future.delayed(Duration(milliseconds: 60 * i), () {
        if (mounted) _ctrls[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pozisyon kaynağı: explicit `placed` > flowers'tan otomatik dome.
    final placed = widget.placed != null && widget.placed!.isNotEmpty
        ? widget.placed!
        : _autoDome(widget.flowers);
    if (placed.isEmpty) return SizedBox(height: widget.height);
    final n = placed.length;
    return LayoutBuilder(builder: (ctx, constraints) {
      final w = constraints.maxWidth.isFinite
          ? constraints.maxWidth
          : MediaQuery.of(ctx).size.width;
      final h = widget.height;
      final flowerBase = (h * 0.22).clamp(56.0, 120.0);
      return ClipRect(
        child: SizedBox(
          width: w,
          height: h,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // 1. Buket şablon görseli (sap + yapraklar)
              Positioned.fill(
                child: IgnorePointer(
                  child: Image.asset(
                    'assets/images/bouquet_template.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                  ),
                ),
              ),
              // 2. Çiçekler — pozisyonlarda, scale + rotate ile
              ...placed.asMap().entries.map((entry) {
                final i = entry.key;
                final p = entry.value;
                final size = flowerBase * p.scale;
                final dx = p.position.dx * w - size / 2;
                final dy = p.position.dy * h - size * 0.55;
                return Positioned(
                  left: dx,
                  top: dy,
                  width: size,
                  height: size,
                  child: ScaleTransition(
                    scale: i < _anims.length
                        ? _anims[i]
                        : const AlwaysStoppedAnimation(1.0),
                    alignment: Alignment.center,
                    child: Transform.rotate(
                      angle: p.rotation,
                      child: Image.asset(
                        p.flower.assetPath,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(colors: [
                              p.flower.color,
                              p.flower.color.withOpacity(0.7),
                            ]),
                          ),
                        ),
                      ),
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

  /// `placed` verilmediğinde fallback: şablon buket çiçek bölgesine dome üretir.
  List<PlacedFlowerData> _autoDome(List<Flower> flowers) {
    final n = flowers.length;
    if (n == 0) return [];
    const cx = 0.5;
    const baseY = 0.28;
    final radius = n <= 3 ? 0.10 : (n <= 6 ? 0.14 : 0.18);
    return List.generate(n, (i) {
      final t = (n == 1) ? 0.0 : (i - (n - 1) / 2) / ((n - 1) / 2);
      final angle = t * (math.pi / 2.5);
      return PlacedFlowerData(
        id: 'dome_$i',
        flower: flowers[i],
        position: Offset(
          cx + math.sin(angle) * radius,
          baseY + (1 - math.cos(angle)) * radius * 0.85,
        ),
        scale: 1.0 - t.abs() * 0.12,
        rotation: t * 0.12,
      );
    });
  }

}

// ── Primary Button ─────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  const PrimaryButton({super.key, required this.label, this.onPressed, this.loading = false, this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, height: 54,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(width: 22, height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
            : Row(mainAxisSize: MainAxisSize.min, children: [
                if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
                Text(label),
              ]),
      ),
    );
  }
}

// ── Gradient Button ───────────────────────────────────────────────────────
/// Pembe gradient'li, dolu butonlar (onboarding "Sonraki", welcome "Kayıt Ol" gibi).
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final double height;
  final List<Color>? colors;

  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.icon,
    this.height = 56,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors ??
        [
          AppColors.roseLight, // #FFB8D4
          AppColors.rose,      // #FF74B3
        ];
    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: c,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(height / 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.rose.withOpacity(0.30),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: loading ? null : onPressed,
            borderRadius: BorderRadius.circular(height / 2),
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: 18, color: AppColors.white),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          label,
                          style: GoogleFonts.poppins(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Section Header ─────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(action!, style: TextStyle(
              fontSize: 13, color: AppColors.rose, fontWeight: FontWeight.w600,
            )),
          ),
      ],
    );
  }
}

// ── Flower Detail Sheet ────────────────────────────────────
void showFlowerDetail(BuildContext context, Flower flower) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.cream,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(
            color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          SizedBox(
            height: 160,
            child: Image.asset(flower.assetPath, fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Center(
                child: Text(flower.letter, style: TextStyle(fontSize: 80, color: flower.color)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: flower.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(flower.letter, style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700, color: flower.color)),
          ),
          const SizedBox(height: 10),
          Text(flower.nameTr, style: Theme.of(context).textTheme.headlineMedium),
          Text(flower.nameEn, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          Text(flower.meaning, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontStyle: FontStyle.italic, color: AppColors.textMid)),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
