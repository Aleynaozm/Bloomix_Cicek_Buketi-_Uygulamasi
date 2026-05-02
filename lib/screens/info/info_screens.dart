import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

/// Drawer üzerinden açılan basit bilgi/ayar ekranları için ortak iskelet.
/// İlerde her biri kendi ekranına ayrılır; şimdilik içerik stub.
class _StubScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final String subtitle;
  final Widget? body;
  const _StubScreen({
    required this.title,
    required this.icon,
    required this.subtitle,
    this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: Text(title)),
      body: body ??
          Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.roseLight.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 44, color: AppColors.rose),
                ),
                const SizedBox(height: 20),
                Text(title,
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark)),
                const SizedBox(height: 8),
                Text(subtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: AppColors.textMid, height: 1.55)),
                const SizedBox(height: 12),
                Text('Yakında eklenecek 🌸',
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textLight,
                        fontStyle: FontStyle.italic)),
              ]),
            ),
          ),
    );
  }
}

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});
  @override
  Widget build(BuildContext context) => const _StubScreen(
        title: 'Adreslerim',
        icon: Icons.location_on_outlined,
        subtitle:
            'Teslimat adreslerini buradan ekleyip yönetebileceksin. Birden fazla adres tanımlayıp varsayılan seçebilirsin.',
      );
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});
  @override
  Widget build(BuildContext context) => const _StubScreen(
        title: 'Yardım & Destek',
        icon: Icons.help_outline_rounded,
        subtitle:
            'Sıkça sorulan sorular, sipariş takibi yardımı ve canlı destek burada olacak.',
      );
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('Hakkında')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.roseLight.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: const Center(
                  child: Text('🌸', style: TextStyle(fontSize: 48))),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text('Bloomix',
                style: GoogleFonts.dmSerifDisplay(
                    fontSize: 32, color: AppColors.rose)),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text('v0.1.0 — Beta',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: AppColors.textLight)),
          ),
          const SizedBox(height: 24),
          Text(
            'İsmin harflerinden ve Lego brick’lerinden ilham alan, hiç solmayan dijital çiçek buketleri tasarlama uygulaması. Tasarladığın buketleri Lego setine dönüştürüp koleksiyonuna ekle.',
            style: GoogleFonts.poppins(
                fontSize: 14, color: AppColors.textMid, height: 1.6),
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => const _StubScreen(
        title: 'Ayarlar',
        icon: Icons.settings_outlined,
        subtitle:
            'Bildirim tercihleri, dil, tema ve gizlilik ayarları burada toplanacak.',
      );
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) => const _StubScreen(
        title: 'Bildirimler',
        icon: Icons.notifications_outlined,
        subtitle:
            'Sipariş güncellemeleri, kampanyalar ve yeni çiçek bildirimleri burada listelenecek.',
      );
}
