import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../screens/shop/orders_screen.dart';
import '../screens/info/info_screens.dart';
import '../screens/bouquet/free_design_screen.dart';
import '../screens/bouquet/name_input_screen.dart';
import '../screens/main/special_days_screen.dart';
import '../screens/main/popular_designs_screen.dart';
import '../screens/main/collections_screen.dart';

/// Sol kenardan açılan ana menü.
/// Üstte profil header, altında navigasyon link'leri ve çıkış.
class AppDrawer extends StatelessWidget {
  /// Onboarding'i tekrar göstermek için (Home'dan paslanır).
  final VoidCallback? onShowOnboarding;
  const AppDrawer({super.key, this.onShowOnboarding});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.cream,
      child: Consumer<AppProvider>(builder: (ctx, prov, _) {
        final user = prov.user;
        return SafeArea(
          child: Column(children: [
            // ── Header ─────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.roseLight, AppColors.rose],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.white,
                    child: Text(
                      (user?.name.isNotEmpty == true)
                          ? user!.name[0].toUpperCase()
                          : '🌸',
                      style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.rose),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? 'Misafir',
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white),
                  ),
                  if (user?.email != null)
                    Text(
                      user!.email,
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.white.withOpacity(0.85)),
                    ),
                ],
              ),
            ),

            // ── Menü öğeleri ───────────────────────────────────────
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // ── Ana kategoriler ──────────────────────────────
                  _SectionLabel('Tasarla'),
                  _Tile(
                    icon: Icons.palette_outlined,
                    label: 'Buket Tasarla',
                    iconColor: AppColors.rose,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const FreeDesignScreen()));
                    },
                  ),
                  _Tile(
                    icon: Icons.text_fields_rounded,
                    label: 'Çiçek Alfabesi',
                    iconColor: AppColors.green,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const NameInputScreen()));
                    },
                  ),
                  _Tile(
                    icon: Icons.card_giftcard_rounded,
                    label: 'Özel Gün Buketleri',
                    iconColor: AppColors.rose,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SpecialDaysScreen()));
                    },
                  ),
                  _Tile(
                    icon: Icons.star_rounded,
                    label: 'Popüler Tasarımlar',
                    iconColor: const Color(0xFFCB8C20),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PopularDesignsScreen()));
                    },
                  ),
                  _Tile(
                    icon: Icons.inventory_2_rounded,
                    label: 'Koleksiyonum',
                    iconColor: const Color(0xFF3070D0),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CollectionsScreen()));
                    },
                  ),

                  const Divider(height: 24, indent: 16, endIndent: 16),
                  _SectionLabel('Hesap'),
                  _Tile(
                    icon: Icons.shopping_bag_outlined,
                    label: 'Siparişlerim',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const OrdersScreen()));
                    },
                  ),
                  _Tile(
                    icon: Icons.location_on_outlined,
                    label: 'Adreslerim',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AddressesScreen()));
                    },
                  ),
                  _Tile(
                    icon: Icons.notifications_outlined,
                    label: 'Bildirimler',
                    badge: prov.unreadCount > 0 ? prov.unreadCount : null,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const NotificationsScreen()));
                    },
                  ),
                  if (onShowOnboarding != null)
                    _Tile(
                      icon: Icons.auto_awesome_outlined,
                      label: 'Tanıtımı Tekrar İzle',
                      onTap: () {
                        Navigator.pop(context);
                        onShowOnboarding!();
                      },
                    ),
                  const Divider(height: 24, indent: 16, endIndent: 16),
                  _SectionLabel('Diğer'),
                  _Tile(
                    icon: Icons.help_outline_rounded,
                    label: 'Yardım & Destek',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const HelpScreen()));
                    },
                  ),
                  _Tile(
                    icon: Icons.info_outline_rounded,
                    label: 'Hakkında',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AboutScreen()));
                    },
                  ),
                  _Tile(
                    icon: Icons.settings_outlined,
                    label: 'Ayarlar',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SettingsScreen()));
                    },
                  ),
                ],
              ),
            ),

            // ── Çıkış ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text('Çıkış Yap'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.rose,
                    side: BorderSide(color: AppColors.rose.withOpacity(0.4)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    await prov.logout();
                  },
                ),
              ),
            ),
          ]),
        );
      }),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.3,
          color: AppColors.textLight,
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final int? badge;
  final VoidCallback onTap;
  final Color? iconColor;
  const _Tile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: iconColor ?? AppColors.textMid, size: 22),
      title: Text(
        label,
        style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark),
      ),
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.rose,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('$badge',
                  style: GoogleFonts.poppins(
                      color: AppColors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            )
          : Icon(Icons.chevron_right_rounded,
              size: 18, color: AppColors.textLight),
      onTap: onTap,
    );
  }
}
