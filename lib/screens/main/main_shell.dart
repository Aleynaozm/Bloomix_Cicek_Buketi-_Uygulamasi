import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'favorites_screen.dart';
import '../profile/profile_screen.dart';
import '../shop/cart_screen.dart';

/// Ana iskelet — 5 sekmeli alt navigasyon.
/// Sepet ikonunda kırmızı badge cart count'unu gösterir.
class MainShell extends StatefulWidget {
  final VoidCallback? onShowOnboarding;
  const MainShell({super.key, this.onShowOnboarding});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _switchTab(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      HomeScreen(
        onShowOnboarding: widget.onShowOnboarding,
        onGoCart: () => _switchTab(3),
        onGoExplore: () => _switchTab(1),
      ),
      const ExploreScreen(),
      const FavoritesScreen(),
      const CartScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: _BottomNav(
        index: _index,
        onTap: _switchTab,
      ),
    );
  }
}

/// Beyaz, ince border'lı, 5 ikon, Sepet'te badge.
class _BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, prov, _) {
      final cartCount = prov.cartCount;
      final items = <_NavSpec>[
        const _NavSpec(Icons.home_outlined, Icons.home_rounded, 'Anasayfa'),
        const _NavSpec(Icons.search_outlined, Icons.search_rounded, 'Keşfet'),
        const _NavSpec(Icons.favorite_outline, Icons.favorite_rounded, 'Favoriler'),
        _NavSpec(Icons.shopping_bag_outlined, Icons.shopping_bag_rounded,
            'Sepet', badge: cartCount > 0 ? cartCount : null),
        const _NavSpec(Icons.person_outline, Icons.person_rounded, 'Profil'),
      ];

      return Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(
              top: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: items.asMap().entries.map((e) {
                return _NavTile(
                  spec: e.value,
                  selected: e.key == index,
                  onTap: () => onTap(e.key),
                );
              }).toList(),
            ),
          ),
        ),
      );
    });
  }
}

class _NavSpec {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int? badge;
  const _NavSpec(this.icon, this.activeIcon, this.label, {this.badge});
}

class _NavTile extends StatelessWidget {
  final _NavSpec spec;
  final bool selected;
  final VoidCallback onTap;
  const _NavTile(
      {required this.spec, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.rose : AppColors.textLight;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(selected ? spec.activeIcon : spec.icon,
                    color: color, size: 24),
                if (spec.badge != null)
                  Positioned(
                    right: -8,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      constraints:
                          const BoxConstraints(minWidth: 16, minHeight: 16),
                      decoration: BoxDecoration(
                        color: AppColors.rose,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.white, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          spec.badge! > 99 ? '99+' : '${spec.badge}',
                          style: GoogleFonts.poppins(
                              color: AppColors.white,
                              fontSize: 9,
                              height: 1.1,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              spec.label,
              style: GoogleFonts.poppins(
                fontSize: 10.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
