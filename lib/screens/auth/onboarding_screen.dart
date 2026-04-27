import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onDone;
  const OnboardingScreen({super.key, required this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;

  static const _pages = <_OnboardPage>[
    _OnboardPage(
      emoji: '🌷',
      title: 'İsminden Buket Yarat',
      body: 'Her harf özel bir çiçeğe dönüşür. Sevdiklerinin ismiyle benzersiz buketler tasarla.',
      bg: Color(0xFFFDF0F5),
    ),
    _OnboardPage(
      emoji: '💐',
      title: 'Çiçek Alfabesi',
      body: 'A\'dan Z\'ye 26 farklı çiçek. Her birinin kendine özgü anlamı ve güzelliği var.',
      bg: Color(0xFFF0F5F0),
    ),
    _OnboardPage(
      emoji: '🧱',
      title: 'Lego\'ya Dönüştür',
      body: 'Tasarladığın buketi Lego versiyonuyla sipariş et. Kalıcı, özel ve unutulmaz bir hediye.',
      bg: Color(0xFFFFF8F0),
    ),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 20, 0),
                child: TextButton(
                  onPressed: widget.onDone,
                  child: Text('Atla', style: TextStyle(color: AppColors.textLight, fontSize: 14)),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _ctrl,
                physics: const BouncingScrollPhysics(),
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _pages[i],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _ctrl,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      dotHeight: 8, dotWidth: 8,
                      activeDotColor: AppColors.rose,
                      dotColor: AppColors.border,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      if (_page > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _ctrl.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            ),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(54),
                              side: BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text('Geri'),
                          ),
                        ),
                      if (_page > 0) const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: PrimaryButton(
                          label: _page == _pages.length - 1 ? 'Başla' : 'İleri',
                          onPressed: () {
                            if (_page == _pages.length - 1) {
                              widget.onDone();
                            } else {
                              _ctrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final String emoji;
  final String title;
  final String body;
  final Color bg;

  const _OnboardPage({
    required this.emoji,
    required this.title,
    required this.body,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 72))),
          ),
          const SizedBox(height: 40),
          Text(title, style: Theme.of(context).textTheme.headlineLarge, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(body, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textMid),
            textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
