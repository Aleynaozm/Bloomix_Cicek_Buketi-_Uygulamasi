import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/widgets.dart';
import '../../widgets/app_drawer.dart';
import '../bouquet/name_input_screen.dart';
import '../bouquet/free_design_screen.dart';
import '../info/info_screens.dart';
import '../shop/orders_screen.dart';
import 'special_days_screen.dart';
import 'popular_designs_screen.dart';

class HomeScreen extends StatefulWidget {
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
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
            begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Günaydın';
    if (h < 18) return 'İyi günler';
    return 'İyi akşamlar';
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final firstName = prov.user?.name.split(' ').first ?? 'Misafir';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F9),
      drawer: AppDrawer(onShowOnboarding: widget.onShowOnboarding),
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── AppBar ──────────────────────────────────────────
              SliverAppBar(
                floating: true,
                backgroundColor: const Color(0xFFFFF8F9),
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: Builder(
                  builder: (c) => IconButton(
                    icon: const Icon(Icons.menu_rounded,
                        color: Color(0xFF2D2D2D)),
                    onPressed: () => Scaffold.of(c).openDrawer(),
                  ),
                ),
                title: const BloomixLogo(size: 24),
                centerTitle: true,
                actions: [
                  Stack(children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined,
                          color: Color(0xFF2D2D2D)),
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const NotificationsScreen())),
                    ),
                    if (prov.unreadCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: Color(0xFFFF4D6D),
                              shape: BoxShape.circle),
                        ),
                      ),
                  ]),
                  const SizedBox(width: 4),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Karşılama ─────────────────────────────────
                      Text(
                        '${_greeting()}, $firstName 🌸',
                        style: GoogleFonts.urbanist(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bugün hangi buketi tasarlayalım?',
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          color: const Color(0xFF9A8A8E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Lottie Hero ───────────────────────────────
                      _LottieHero(),
                      const SizedBox(height: 20),

                      // ── Hızlı Erişim ──────────────────────────────
                      _QuickActions(),
                      const SizedBox(height: 20),

                      // ── Aktif Sipariş Banner ───────────────────────
                      if (prov.activeOrders.isNotEmpty) ...[
                        _ActiveOrderBanner(
                            count: prov.activeOrders.length),
                        const SizedBox(height: 16),
                      ],

                      // ── Ana CTA ───────────────────────────────────
                      _HeroCTA(),
                      const SizedBox(height: 16),

                      // ── 2-Kolon Kartlar ───────────────────────────
                      Row(children: [
                        Expanded(
                          child: _FeatureCard(
                            title: 'Çiçek Alfabesi',
                            subtitle: 'İsimden buket yap',
                            icon: Icons.text_fields_rounded,
                            bg: const Color(0xFFEAF6EA),
                            fg: const Color(0xFF3A7D44),
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const NameInputScreen())),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _FeatureCard(
                            title: 'Özel Gün',
                            subtitle: 'Hazır şablonlar',
                            icon: Icons.card_giftcard_rounded,
                            bg: const Color(0xFFFFF0F3),
                            fg: const Color(0xFFE85D8A),
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const SpecialDaysScreen())),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 12),

                      // ── Geniş Kart ────────────────────────────────
                      _WideCard(
                        title: 'Popüler Tasarımlar',
                        subtitle: 'En çok beğenilen buketler',
                        icon: Icons.star_rounded,
                        bg: const Color(0xFFFFF8E7),
                        fg: const Color(0xFFB07D00),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const PopularDesignsScreen())),
                      ),
                      const SizedBox(height: 20),

                      // ── İstatistik Şeridi ─────────────────────────
                      _StatsStrip(prov: prov),
                      const SizedBox(height: 20),

                      // ── Lego Banner ───────────────────────────────
                      _LegoBanner(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Lottie Hero ──────────────────────────────────────────────────────────────
class _LottieHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE4EE), Color(0xFFFFC8DC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF85A1).withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Lottie.asset(
            'assets/animations/flower_shop.json',
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            repeat: true,
            errorBuilder: (_, __, ___) => Lottie.asset(
              'assets/animations/flower_shop.lottie',
              fit: BoxFit.cover,
              repeat: true,
              errorBuilder: (_, __, ___) => const Center(
                child: Text('🌷', style: TextStyle(fontSize: 80)),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.88),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Text('🌸', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 5),
                Text(
                  'Bloomix',
                  style: GoogleFonts.urbanist(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFFF4D7E),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hızlı Erişim ─────────────────────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  static const _items = [
    (icon: Icons.palette_rounded, label: 'Serbest\nTasarım', color: Color(0xFFFF4D7E)),
    (icon: Icons.text_fields_rounded, label: 'Çiçek\nAlfabesi', color: Color(0xFF4CAF50)),
    (icon: Icons.card_giftcard_rounded, label: 'Özel\nGün', color: Color(0xFFE040FB)),
    (icon: Icons.star_rounded, label: 'Popüler', color: Color(0xFFFFC107)),
    (icon: Icons.local_shipping_outlined, label: 'Siparişler', color: Color(0xFF2196F3)),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final item = _items[i];
          return GestureDetector(
            onTap: () => _onTap(context, i),
            child: Container(
              width: 72,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: item.color.withOpacity(0.2), width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.icon, color: item.color, size: 26),
                  const SizedBox(height: 5),
                  Text(
                    item.label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.urbanist(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D2D2D),
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _onTap(BuildContext context, int i) {
    switch (i) {
      case 0:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const FreeDesignScreen()));
        break;
      case 1:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const NameInputScreen()));
        break;
      case 2:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SpecialDaysScreen()));
        break;
      case 3:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PopularDesignsScreen()));
        break;
      case 4:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const OrdersScreen()));
        break;
    }
  }
}

// ── Aktif Sipariş Banner ──────────────────────────────────────────────────────
class _ActiveOrderBanner extends StatelessWidget {
  final int count;
  const _ActiveOrderBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const OrdersScreen())),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2196F3).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.local_shipping_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                '$count aktif siparişin var',
                style: GoogleFonts.urbanist(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
              Text(
                'Durumu takip et',
                style: GoogleFonts.urbanist(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8)),
              ),
            ]),
          ),
          const Icon(Icons.arrow_forward_ios_rounded,
              color: Colors.white, size: 16),
        ]),
      ),
    );
  }
}

// ── Ana CTA ───────────────────────────────────────────────────────────────────
class _HeroCTA extends StatefulWidget {
  @override
  State<_HeroCTA> createState() => _HeroCTAState();
}

class _HeroCTAState extends State<_HeroCTA>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120),
        lowerBound: 0.96, upperBound: 1.0, value: 1.0);
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const FreeDesignScreen()));
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          height: 110,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF4D7E), Color(0xFFFF85A1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF4D7E).withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -16,
                bottom: -16,
                child: Icon(
                  Icons.local_florist_rounded,
                  size: 110,
                  color: Colors.white.withOpacity(0.14),
                ),
              ),
              Positioned(
                right: 80,
                top: -20,
                child: Icon(
                  Icons.spa_rounded,
                  size: 70,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Buket Tasarla',
                            style: GoogleFonts.urbanist(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Serbest tasarımla kendi buketi yarat',
                            style: GoogleFonts.urbanist(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 22),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 2-Kolon Feature Kartı ─────────────────────────────────────────────────────
class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color bg;
  final Color fg;
  final VoidCallback? onTap;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.bg,
    required this.fg,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 115,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: fg.withOpacity(0.15), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: fg.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: fg, size: 20),
            ),
            const Spacer(),
            Text(
              title,
              style: GoogleFonts.urbanist(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.urbanist(
                fontSize: 11,
                color: const Color(0xFF9A8A8E),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Geniş Kart ────────────────────────────────────────────────────────────────
class _WideCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color bg;
  final Color fg;
  final VoidCallback? onTap;

  const _WideCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.bg,
    required this.fg,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: fg.withOpacity(0.2), width: 1.5),
        ),
        child: Row(children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: fg.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: fg, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.urbanist(
                    fontSize: 12,
                    color: const Color(0xFF9A8A8E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, color: fg, size: 16),
        ]),
      ),
    );
  }
}

// ── İstatistik Şeridi ─────────────────────────────────────────────────────────
class _StatsStrip extends StatelessWidget {
  final AppProvider prov;
  const _StatsStrip({required this.prov});

  @override
  Widget build(BuildContext context) {
    final items = [
      (label: 'Tasarım', value: prov.saved.length, emoji: '🎨'),
      (label: 'Favori', value: prov.saved.length, emoji: '❤️'),
      (label: 'Sipariş', value: prov.orders.length, emoji: '📦'),
      (label: 'Koleksiyon', value: prov.collections.length, emoji: '🗂️'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEDE0E4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: items.asMap().entries.map((e) {
          final last = e.key == items.length - 1;
          return Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: last
                    ? null
                    : const Border(
                        right: BorderSide(
                            color: Color(0xFFEDE0E4), width: 1)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Column(children: [
                Text(e.value.emoji,
                    style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 6),
                Text(
                  '${e.value.value}',
                  style: GoogleFonts.urbanist(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  e.value.label,
                  style: GoogleFonts.urbanist(
                    fontSize: 11,
                    color: const Color(0xFF9A8A8E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ]),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Lego Banner ───────────────────────────────────────────────────────────────
class _LegoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFFF4D7E).withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.extension_rounded,
              color: Color(0xFFFF85A1), size: 26),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              'Hiç solmayan Lego buketler',
              style: GoogleFonts.urbanist(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tasarladığın buket gerçek Lego olarak hediyene dönüşür.',
              style: GoogleFonts.urbanist(
                fontSize: 12,
                color: Colors.white.withOpacity(0.6),
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
