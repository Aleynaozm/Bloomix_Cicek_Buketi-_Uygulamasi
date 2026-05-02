import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../theme/app_theme.dart';

/// Onboarding — Figma tasarımına göre 3 sayfa:
/// 1) Çiçek Buketini Tasarla (renkli buket görseli)
/// 2) Lego Dünyasına Dönüştür (lego dönüşüm görseli)
/// 3) Koleksiyonuna Ekle ve Sahip Ol (buket görseli)
///
/// Sağ üstte "Atla", altta dot indicator + pembe "Sonraki" butonu.
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onDone;
  const OnboardingScreen({super.key, required this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;

  static const _pages = <_OnboardData>[
    _OnboardData(
      image: 'assets/images/onboarding_1.png',
      fallbackEmoji: '💐',
      title: 'Çiçek Buketini Tasarla',
      body:
          'Onlarca farklı parça arasından dilediğini seç ve koleksiyonun için eşsiz bir aranjman oluştur.',
    ),
    _OnboardData(
      image: 'assets/images/onboarding_2.png',
      fallbackEmoji: '🧱',
      title: 'Lego Dünyasına Dönüştür',
      body:
          'Tasarladığın buketi tek tıkla ikonik Lego parçalarına dönüştür ve dijital bahçeni inşa etmeye başla.',
    ),
    _OnboardData(
      image: 'assets/images/onboarding_3.png',
      fallbackEmoji: '🌸',
      title: 'Koleksiyonuna Ekle ve Sahip Ol',
      body:
          'Hiç solmayan bu özel tasarımı dijital galerinde sergile veya gerçek hayatta sahip olmak için hemen sipariş ver.',
    ),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _pages.length - 1;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Sağ üst: "Atla" → son sayfada "Başla" ──────────────────
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 20, 0),
                child: TextButton(
                  onPressed: widget.onDone,
                  style: TextButton.styleFrom(
                    foregroundColor:
                        isLast ? AppColors.rose : AppColors.textLight,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    minimumSize: const Size(0, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    isLast ? 'Başla' : 'Atla',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: isLast ? FontWeight.w700 : FontWeight.w600,
                      color: isLast ? AppColors.rose : AppColors.textLight,
                    ),
                  ),
                ),
              ),
            ),

            // ── Sayfalar (yatay swipe ile gezinme) ───────────────────
            Expanded(
              child: PageView.builder(
                controller: _ctrl,
                physics: const BouncingScrollPhysics(),
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _OnboardPageView(data: _pages[i]),
              ),
            ),

            // ── Yalnız indicator (buton yok) ─────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 12, 28, 36),
              child: SmoothPageIndicator(
                controller: _ctrl,
                count: _pages.length,
                effect: ScaleEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  activeDotColor: AppColors.rose,
                  dotColor: AppColors.roseLight,
                  scale: 1.6,
                  spacing: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tek bir onboarding sayfası ─────────────────────────────────────────────

class _OnboardData {
  final String image;
  final String fallbackEmoji;
  final String title;
  final String body;
  const _OnboardData({
    required this.image,
    required this.fallbackEmoji,
    required this.title,
    required this.body,
  });
}

class _OnboardPageView extends StatelessWidget {
  final _OnboardData data;
  const _OnboardPageView({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 16),
      child: Column(
        children: [
          // Görsel
          Expanded(
            flex: 5,
            child: Center(
              child: Image.asset(
                data.image,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF0F5),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      data.fallbackEmoji,
                      style: const TextStyle(fontSize: 96),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Başlık
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              height: 1.25,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),
          // Açıklama
          Text(
            data.body,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textMid,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
