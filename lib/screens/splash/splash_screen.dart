import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onDone;
  const SplashScreen({super.key, required this.onDone});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final AnimationController _textCtrl;
  late final AnimationController _bgCtrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _bgFade;

  static const _welcome = "Bloomix'e Hoşgeldiniz";

  @override
  void initState() {
    super.initState();

    _bgCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();
    _bgFade = CurvedAnimation(parent: _bgCtrl, curve: Curves.easeOut);

    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );
    _logoFade = CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.0, 0.4, curve: Curves.easeIn));

    _textCtrl = AnimationController(vsync: this, duration: Duration(milliseconds: 60 * _welcome.length + 600));

    _logoCtrl.forward();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _textCtrl.forward();
    });

    // 3.5 saniye sonra otomatik geçiş
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _bgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: widget.onDone, // dokununca atla
        child: AnimatedBuilder(
          animation: _bgFade,
          builder: (_, child) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.lerp(AppColors.cream, const Color(0xFFFDF0F5), _bgFade.value)!,
                  Color.lerp(AppColors.cream, const Color(0xFFFFF8F0), _bgFade.value)!,
                ],
              ),
            ),
            child: child,
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Logo (Bloomix.png) — fade + scale
                AnimatedBuilder(
                  animation: _logoCtrl,
                  builder: (_, __) => Opacity(
                    opacity: _logoFade.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: _LogoWithFallback(),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Animasyonlu "Bloomix'e Hoşgeldiniz" yazısı (harf harf)
                AnimatedBuilder(
                  animation: _textCtrl,
                  builder: (_, __) => _AnimatedWelcomeText(
                    text: _welcome,
                    progress: _textCtrl.value,
                  ),
                ),

                const SizedBox(height: 16),

                // Alt yazı
                AnimatedBuilder(
                  animation: _textCtrl,
                  builder: (_, __) {
                    final t = ((_textCtrl.value - 0.7) / 0.3).clamp(0.0, 1.0);
                    return Opacity(
                      opacity: t,
                      child: Transform.translate(
                        offset: Offset(0, (1 - t) * 12),
                        child: Text(
                          'İsminden bir buket yarat 🌸',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textMid,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const Spacer(flex: 3),

                // Loading dots
                AnimatedBuilder(
                  animation: _textCtrl,
                  builder: (_, __) => Opacity(
                    opacity: ((_textCtrl.value - 0.6) / 0.4).clamp(0.0, 1.0),
                    child: const _LoadingDots(),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoWithFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.rose.withOpacity(0.18),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Image.asset(
          'assets/images/Bloomix.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Center(
            child: Text('✿',
                style: TextStyle(
                  fontSize: 80,
                  color: AppColors.rose,
                )),
          ),
        ),
      ),
    );
  }
}

class _AnimatedWelcomeText extends StatelessWidget {
  final String text;
  final double progress; // 0..1
  const _AnimatedWelcomeText({required this.text, required this.progress});

  @override
  Widget build(BuildContext context) {
    final letters = text.split('');
    // Her harfin görünme aralığı: ilk %75'lik dilim içinde
    final perLetter = 0.75 / letters.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Wrap(
        alignment: WrapAlignment.center,
        children: List.generate(letters.length, (i) {
          final start = i * perLetter;
          final t = ((progress - start) / (perLetter * 1.4)).clamp(0.0, 1.0);
          return Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(0, (1 - t) * 16),
              child: Text(
                letters[i],
                style: TextStyle(
                  fontFamily: 'DM Serif Display',
                  fontSize: 32,
                  color: AppColors.rose,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          final phase = (_c.value - i * 0.15) % 1.0;
          final scale = 0.6 + 0.4 * (1 - (phase - 0.5).abs() * 2).clamp(0.0, 1.0);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.rose,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
