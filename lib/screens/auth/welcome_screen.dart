import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

/// Welcome — onboarding sonrası karşılama ekranı (Figma).
/// Üstte "Bloomix" pembe serif, ardından başlık + açıklama,
/// ortada flower shop görseli, altta iki gradient buton.
class WelcomeScreen extends StatelessWidget {
  /// Onboarding'e geri dönüş callback'i (kullanılmıyor — Figma'da geri yok).
  final VoidCallback? onBack;

  const WelcomeScreen({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // ── "Bloomix" başlık (DM Serif Display, pembe) ────────
              const BloomixLogo(size: 38),

              const SizedBox(height: 22),

              // ── Slogan başlık ────────────────────────────────────
              Text(
                'Lego Çiçek Buketini\nTasarla',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                  height: 1.2,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 14),

              // ── Açıklama ─────────────────────────────────────────
              Text(
                'Hayalindeki buketi oluştur ve koleksiyonuna ekle',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMid,
                  height: 1.55,
                ),
              ),

              const SizedBox(height: 24),

              // ── Flower shop görseli (orta blok) ─────────────────
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 260,
                      maxWidth: 280,
                    ),
                    child: Image.asset(
                      'assets/images/flower_shop.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDF0F5),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: const Center(
                          child:
                              Text('🌸', style: TextStyle(fontSize: 72)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Butonlar ─────────────────────────────────────────
              GradientButton(
                label: 'Kayıt Ol',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const SignupScreen()),
                  );
                },
              ),
              const SizedBox(height: 14),
              GradientButton(
                label: 'Giriş Yap',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const LoginScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
