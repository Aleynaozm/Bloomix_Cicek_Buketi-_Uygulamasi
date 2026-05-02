import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Splash — Bloomix.png logosu + animasyonlu "Bloomix" yazısı.
/// Beyaz arkaplan, sade ve şık.
class SplashScreen extends StatefulWidget {
  final VoidCallback onDone;
  const SplashScreen({super.key, required this.onDone});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final AnimationController _textCtrl;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _logoCtrl.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _textCtrl.forward();
    });

    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: widget.onDone,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Logo ──────────────────────────────────────────────
              AnimatedBuilder(
                animation: _logoCtrl,
                builder: (_, __) {
                  final t = Curves.elasticOut
                      .transform(_logoCtrl.value.clamp(0.0, 1.0));
                  return Opacity(
                    opacity: _logoCtrl.value.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: 0.6 + 0.4 * t,
                      child: Image.asset(
                        'assets/images/Bloomix.png',
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Text(
                          'B',
                          style: TextStyle(
                            fontFamily: 'DM Serif Display',
                            fontSize: 180,
                            color: AppColors.textDark,
                            height: 0.95,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // ── "Bloomix" yazısı ──────────────────────────────────
              AnimatedBuilder(
                animation: _textCtrl,
                builder: (_, __) =>
                    _AnimatedBloomixText(progress: _textCtrl.value),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedBloomixText extends StatelessWidget {
  final double progress;
  const _AnimatedBloomixText({required this.progress});

  static const _text = 'Bloomix';

  @override
  Widget build(BuildContext context) {
    final letters = _text.split('');
    final perLetter = 0.7 / letters.length;
    return Wrap(
      alignment: WrapAlignment.center,
      children: List.generate(letters.length, (i) {
        final start = i * perLetter;
        final t = ((progress - start) / (perLetter * 1.6)).clamp(0.0, 1.0);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 14),
            child: Text(
              letters[i],
              style: TextStyle(
                fontFamily: 'DM Serif Display',
                fontSize: 44,
                color: AppColors.rose,
                letterSpacing: 1.5,
              ),
            ),
          ),
        );
      }),
    );
  }
}
