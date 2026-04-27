import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

// ── Bloomix Logo ──────────────────────────────────────────
class BloomixLogo extends StatelessWidget {
  final double size;
  final bool dark;
  const BloomixLogo({super.key, this.size = 28, this.dark = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('✿', style: TextStyle(fontSize: size * 0.9, color: AppColors.rose)),
        const SizedBox(width: 6),
        Text('Bloomix', style: TextStyle(
          fontFamily: 'DM Serif Display',
          fontSize: size,
          color: dark ? AppColors.white : AppColors.textDark,
          fontWeight: FontWeight.w400,
        )),
      ],
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
          Text(flower.nameTr, style: const TextStyle(fontSize: 10, color: AppColors.textLight),
            overflow: TextOverflow.ellipsis),
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

// ── Bouquet Preview (horizontal flower strip + wrapper) ────
class BouquetPreview extends StatefulWidget {
  final List<Flower> flowers;
  final WrapperStyle wrapper;
  final double height;

  const BouquetPreview({super.key, required this.flowers, required this.wrapper, this.height = 280});

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
    final n = widget.flowers.length;
    if (n == 0) return SizedBox(height: widget.height);
    final slotW = (MediaQuery.of(context).size.width - 48) / n;

    return SizedBox(
      height: widget.height,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // wrapper
          Positioned(
            bottom: 0,
            child: CustomPaint(
              size: Size((slotW * n).clamp(100, 300), 80),
              painter: WrapperPainter(color: widget.wrapper.color),
            ),
          ),
          // flowers
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: widget.flowers.asMap().entries.map((e) {
              final i = e.key;
              final f = e.value;
              final sway = (i - (n - 1) / 2) * 0.12;
              final heightFraction = i % 2 == 0 ? 1.0 : 0.88;
              return ScaleTransition(
                scale: i < _anims.length ? _anims[i] : const AlwaysStoppedAnimation(1.0),
                alignment: Alignment.bottomCenter,
                child: Transform.rotate(
                  angle: sway,
                  child: SizedBox(
                    width: slotW.clamp(40, 100),
                    height: widget.height * 0.88 * heightFraction,
                    child: Image.asset(
                      f.assetPath,
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomCenter,
                      errorBuilder: (_, __, ___) => Align(
                        alignment: Alignment.bottomCenter,
                        child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(shape: BoxShape.circle,
                              color: f.color.withOpacity(0.2)),
                            child: Center(child: Text(f.letter, style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700, color: f.color))),
                          ),
                          Container(width: 2.5, height: 70, color: AppColors.green.withOpacity(0.5)),
                        ]),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class WrapperPainter extends CustomPainter {
  final Color color;
  const WrapperPainter({required this.color});

  @override
  void paint(Canvas canvas, Size s) {
    final fill = Paint()..color = color;
    final stroke = Paint()..color = color.withOpacity(0.5)..style = PaintingStyle.stroke..strokeWidth = 0.8;
    final path = Path()
      ..moveTo(0, 22)..quadraticBezierTo(s.width / 2, 0, s.width, 22)
      ..lineTo(s.width - 12, s.height)..lineTo(12, s.height)..close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
    // ribbon
    final rp = Paint()..color = AppColors.roseLight.withOpacity(0.7);
    final lb = Path()
      ..moveTo(s.width / 2, 28)..quadraticBezierTo(s.width / 2 - 26, 6, s.width / 2 - 44, 20)
      ..quadraticBezierTo(s.width / 2 - 24, 32, s.width / 2, 28);
    final rb = Path()
      ..moveTo(s.width / 2, 28)..quadraticBezierTo(s.width / 2 + 26, 6, s.width / 2 + 44, 20)
      ..quadraticBezierTo(s.width / 2 + 24, 32, s.width / 2, 28);
    canvas.drawPath(lb, rp);
    canvas.drawPath(rb, rp);
    canvas.drawCircle(Offset(s.width / 2, 28), 5, Paint()..color = AppColors.rose.withOpacity(0.6));
  }

  @override
  bool shouldRepaint(WrapperPainter old) => old.color != color;
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
