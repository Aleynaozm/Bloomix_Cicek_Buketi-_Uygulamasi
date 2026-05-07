import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'collections_screen.dart';
import '../profile/profile_screen.dart';
import '../shop/cart_screen.dart';

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
      const CollectionsScreen(),
      const CartScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: _BottomNav(index: _index, onTap: _switchTab),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.index, required this.onTap});

  static const _items = [
    (icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Anasayfa'),
    (icon: Icons.search_outlined, activeIcon: Icons.search_rounded, label: 'Keşfet'),
    (icon: Icons.collections_bookmark_outlined, activeIcon: Icons.collections_bookmark_rounded, label: 'Koleksiyon'),
    (icon: Icons.shopping_bag_outlined, activeIcon: Icons.shopping_bag_rounded, label: 'Sepet'),
    (icon: Icons.person_outline, activeIcon: Icons.person_rounded, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<AppProvider>().cartCount;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFEDE0E4), width: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _items.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              final selected = i == index;
              final badge = i == 3 && cartCount > 0 ? cartCount : 0;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFFFF4D7E).withOpacity(0.12)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              selected ? item.activeIcon : item.icon,
                              size: 24,
                              color: selected
                                  ? const Color(0xFFFF4D7E)
                                  : const Color(0xFFBBAFB2),
                            ),
                          ),
                          if (badge > 0)
                            Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 1),
                                constraints: const BoxConstraints(
                                    minWidth: 16, minHeight: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF4D7E),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Colors.white, width: 1.5),
                                ),
                                child: Center(
                                  child: Text(
                                    badge > 99 ? '99+' : '$badge',
                                    style: GoogleFonts.urbanist(
                                        color: Colors.white,
                                        fontSize: 9,
                                        height: 1.1,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: GoogleFonts.urbanist(
                          fontSize: 10.5,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected
                              ? const Color(0xFFFF4D7E)
                              : const Color(0xFFBBAFB2),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
