import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/widgets.dart';
import '../../widgets/app_drawer.dart';
import '../bouquet/name_input_screen.dart';
import '../bouquet/free_design_screen.dart';
import 'special_days_screen.dart';
import 'popular_designs_screen.dart';
import 'collections_screen.dart';

/// Anasayfa = Hub.
/// Üstte Lottie hero animasyonu + 5 ana kategori kartı:
/// 🎨 Buket Tasarla (büyük ana CTA)
/// 🔤 Çiçek Alfabesi
/// 🎁 Özel Gün Buketleri
/// ⭐ Popüler Tasarımlar
/// 📦 Koleksiyonum
class HomeScreen extends StatelessWidget {
  final VoidCallback? onShowOnboarding;
  final VoidCallback? onGoCart;
  final VoidCallback? onGoExplore;

  const HomeScreen({
    super.key,
    this.onShowOnboarding,
    this.onGoCart,
    this.onGoExplore,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, prov, _) {
      final user = prov.user;
      final firstName = user?.name.split(' ').first ?? 'Misafir';
      return Scaffold(
        backgroundColor: AppColors.cream,
        drawer: AppDrawer(onShowOnboarding: onShowOnboarding),
        body: CustomScrollView(slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.cream,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: Builder(
              builder: (c) => IconButton(
                icon: const Icon(Icons.menu_rounded),
                tooltip: 'Menü',
                onPressed: () => Scaffold.of(c).openDrawer(),
              ),
            ),
            title: const BloomixLogo(size: 24),
            centerTitle: true,
            actions: [
              Stack(children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => _showNotifications(context, prov),
                ),
                if (prov.unreadCount > 0)
                  Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: AppColors.rose, shape: BoxShape.circle),
                      )),
              ]),
              const SizedBox(width: 4),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Karşılama ────────────────────────────────────
                  Text('Merhaba, $firstName 🌸',
                      style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark)),
                  const SizedBox(height: 4),
                  Text('Hangi buketi oluşturalım?',
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textMid,
                          height: 1.5)),
                  const SizedBox(height: 16),

                  // ── Lottie hero animasyonu ───────────────────────
                  _LottieHero(),
                  const SizedBox(height: 22),

                  // ── 1. ANA CTA: Buket Tasarla ────────────────────
                  _BigFeatureCard(
                    title: 'Buket Tasarla',
                    subtitle: 'Çiçekleri seç, kendi Lego buketini kur',
                    badge: '🎨 Yeni',
                    icon: Icons.palette_rounded,
                    gradient: [AppColors.rose, AppColors.roseDark],
                    tall: true,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const FreeDesignScreen())),
                  ),
                  const SizedBox(height: 14),

                  // ── 2 + 3: Çiçek Alfabesi & Özel Gün ─────────────
                  Row(children: [
                    Expanded(
                      child: _BigFeatureCard(
                        title: 'Çiçek\nAlfabesi',
                        subtitle: 'İsmini gir, harfler buket olsun',
                        icon: Icons.text_fields_rounded,
                        gradient: const [
                          Color(0xFFE5F4E5),
                          Color(0xFFC8E2C5),
                        ],
                        textDark: true,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const NameInputScreen())),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _BigFeatureCard(
                        title: 'Özel Gün\nBuketleri',
                        subtitle: 'Doğum günü, sevgililer...',
                        icon: Icons.card_giftcard_rounded,
                        gradient: const [
                          Color(0xFFFFE3EF),
                          Color(0xFFFFC2DC),
                        ],
                        textDark: true,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SpecialDaysScreen())),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 14),

                  // ── 4 + 5: Popüler & Koleksiyonum ────────────────
                  Row(children: [
                    Expanded(
                      child: _BigFeatureCard(
                        title: 'Popüler\nTasarımlar',
                        subtitle: 'En çok beğenilen buketler',
                        icon: Icons.star_rounded,
                        gradient: const [
                          Color(0xFFFCE5B0),
                          Color(0xFFEBD9A8),
                        ],
                        textDark: true,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const PopularDesignsScreen())),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _BigFeatureCard(
                        title: 'Koleksiyo-\nnum',
                        subtitle: 'Favori buketlerin',
                        icon: Icons.inventory_2_rounded,
                        gradient: const [
                          Color(0xFFC5D9F0),
                          Color(0xFFA8C5E8),
                        ],
                        textDark: true,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CollectionsScreen())),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 28),

                  // ── Bilgi şeridi ─────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.rose.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.extension_rounded,
                            color: AppColors.rose),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Hiç solmayan Lego buketler',
                                  style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark)),
                              const SizedBox(height: 2),
                              Text(
                                  'Tasarladığın buket gerçek Lego brick olarak hediyene dönüşür.',
                                  style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      height: 1.4,
                                      color: AppColors.textMid)),
                            ]),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ]),
      );
    });
  }

  void _showNotifications(BuildContext context, AppProvider prov) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Bildirimler',
                      style: GoogleFonts.poppins(
                          fontSize: 17, fontWeight: FontWeight.w700)),
                  Text('${prov.unreadCount} yeni',
                      style: GoogleFonts.poppins(
                          color: AppColors.rose, fontSize: 13)),
                ]),
          ),
          const SizedBox(height: 12),
          ...prov.notifications.take(5).map((n) => ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: AppColors.roseLight.withOpacity(0.3),
                      shape: BoxShape.circle),
                  child: const Center(
                      child: Text('🌸', style: TextStyle(fontSize: 18))),
                ),
                title: Text(n.title,
                    style: GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: Text(n.body,
                    style: GoogleFonts.poppins(fontSize: 12)),
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Anasayfa hero — flower_shop Lottie animasyonu, yumuşak pembe arka plan.
class _LottieHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.roseLight.withOpacity(0.35),
            AppColors.rose.withOpacity(0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Lottie.asset(
        'assets/animations/flower_shop.json',
        fit: BoxFit.contain,
        repeat: true,
        errorBuilder: (_, __, ___) => Lottie.asset(
          'assets/animations/flower_shop.lottie',
          fit: BoxFit.contain,
          repeat: true,
          errorBuilder: (_, __, ___) => const Center(
            child: Text('🌷', style: TextStyle(fontSize: 80)),
          ),
        ),
      ),
    );
  }
}

/// Geniş, gradient'li, ikon + başlık + alt başlık içeren feature kartı.
class _BigFeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? badge;
  final List<Color> gradient;
  final IconData icon;
  final VoidCallback? onTap;
  final bool tall;
  final bool textDark;

  const _BigFeatureCard({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.icon,
    this.onTap,
    this.badge,
    this.tall = false,
    this.textDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final fg = textDark ? AppColors.textDark : AppColors.white;
    final fgSub =
        textDark ? AppColors.textMid : AppColors.white.withOpacity(0.85);
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        height: tall ? 160 : 140,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradient.last.withOpacity(0.25),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(icon,
                size: tall ? 100 : 76,
                color: fg.withOpacity(textDark ? 0.18 : 0.22)),
          ),
          if (badge != null)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: fg.withOpacity(textDark ? 0.1 : 0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(badge!,
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: fg)),
              ),
            ),
          Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        fontSize: tall ? 22 : 16,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        color: fg)),
                const SizedBox(height: 6),
                Text(subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                        fontSize: tall ? 13 : 11,
                        height: 1.4,
                        color: fgSub)),
              ]),
        ]),
      ),
    );
  }
}
