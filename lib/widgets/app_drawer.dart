import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../data/special_day_data.dart';
import '../screens/shop/orders_screen.dart';
import '../screens/info/info_screens.dart';
import '../screens/bouquet/free_design_screen.dart';
import '../screens/bouquet/name_input_screen.dart';
import '../screens/main/special_days_screen.dart';
import '../screens/main/popular_designs_screen.dart';
import '../screens/main/collections_screen.dart';
import '../screens/main/category_detail_screen.dart';

class AppDrawer extends StatefulWidget {
  final VoidCallback? onShowOnboarding;
  const AppDrawer({super.key, this.onShowOnboarding});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _specialExpanded = false;

  void _go(Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.cream,
      child: Consumer<AppProvider>(builder: (ctx, prov, _) {
        final user = prov.user;
        return Column(
          children: [
            // ── Header ────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).padding.top + 20, 20, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.roseLight, AppColors.rose],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.white,
                    child: Text(
                      (user?.name.isNotEmpty == true)
                          ? user!.name[0].toUpperCase()
                          : '🌸',
                      style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.rose),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Misafir',
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white),
                        ),
                        if (user?.email != null)
                          Text(
                            user!.email,
                            style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.white.withOpacity(0.85)),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Menü ─────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  // ── Keşfet ───────────────────────────────────
                  _SectionLabel('Keşfet'),
                  _Tile(
                    icon: Icons.star_rounded,
                    label: 'Popüler Tasarımlar',
                    iconColor: const Color(0xFFCB8C20),
                    onTap: () => _go(const PopularDesignsScreen()),
                  ),

                  // Özel Gün — satıra basınca alt kategoriler açılır
                  _Tile(
                    icon: Icons.card_giftcard_rounded,
                    label: 'Özel Gün Buketleri',
                    iconColor: AppColors.rose,
                    trailing: AnimatedRotation(
                      turns: _specialExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.keyboard_arrow_down_rounded,
                          size: 18, color: AppColors.textLight),
                    ),
                    onTap: () =>
                        setState(() => _specialExpanded = !_specialExpanded),
                  ),

                  // Alt kategoriler — animasyonla açılır/kapanır
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 200),
                    crossFadeState: _specialExpanded
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Container(
                      margin: const EdgeInsets.only(
                          left: 24, right: 8, bottom: 4),
                      decoration: BoxDecoration(
                        color: AppColors.rose.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: SpecialDayCategory.values
                            .map((cat) => ListTile(
                                  dense: true,
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(16, 0, 12, 0),
                                  leading: Text(cat.emoji,
                                      style: const TextStyle(fontSize: 18)),
                                  title: Text(
                                    cat.title,
                                    style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.textDark),
                                  ),
                                  trailing: const Icon(
                                      Icons.chevron_right_rounded,
                                      size: 14,
                                      color: AppColors.textLight),
                                  onTap: () => _go(
                                      CategoryDetailScreen(category: cat)),
                                ))
                            .toList(),
                      ),
                    ),
                    secondChild: const SizedBox.shrink(),
                  ),

                  const Divider(height: 1, indent: 16, endIndent: 16),
                  const SizedBox(height: 8),

                  // ── Tasarla ──────────────────────────────────
                  _SectionLabel('Tasarla'),
                  _Tile(
                    icon: Icons.palette_outlined,
                    label: 'Serbest Tasarım',
                    iconColor: AppColors.rose,
                    onTap: () => _go(const FreeDesignScreen()),
                  ),
                  _Tile(
                    icon: Icons.text_fields_rounded,
                    label: 'Çiçek Alfabesi',
                    iconColor: AppColors.green,
                    onTap: () => _go(const NameInputScreen()),
                  ),

                  const Divider(height: 1, indent: 16, endIndent: 16),
                  const SizedBox(height: 8),

                  // ── Koleksiyonum ─────────────────────────────
                  _SectionLabel('Koleksiyonum'),
                  _Tile(
                    icon: Icons.collections_bookmark_outlined,
                    label: 'Koleksiyonlarım',
                    iconColor: const Color(0xFF3070D0),
                    onTap: () => _go(const CollectionsScreen()),
                  ),
                  _Tile(
                    icon: Icons.shopping_bag_outlined,
                    label: 'Siparişlerim',
                    iconColor: AppColors.textMid,
                    onTap: () => _go(const OrdersScreen()),
                  ),

                  const Divider(height: 1, indent: 16, endIndent: 16),
                  const SizedBox(height: 8),

                  // ── Hesap ────────────────────────────────────
                  _SectionLabel('Hesap'),
                  _Tile(
                    icon: Icons.location_on_outlined,
                    label: 'Adreslerim',
                    onTap: () => _go(const AddressesScreen()),
                  ),
                  _Tile(
                    icon: Icons.notifications_outlined,
                    label: 'Bildirimler',
                    iconColor: AppColors.textMid,
                    badge: prov.unreadCount > 0 ? prov.unreadCount : null,
                    onTap: () => _go(const NotificationsScreen()),
                  ),
                  _Tile(
                    icon: Icons.settings_outlined,
                    label: 'Ayarlar',
                    onTap: () => _go(const SettingsScreen()),
                  ),
                  if (widget.onShowOnboarding != null)
                    _Tile(
                      icon: Icons.auto_awesome_outlined,
                      label: 'Tanıtımı Tekrar İzle',
                      onTap: () {
                        Navigator.pop(context);
                        widget.onShowOnboarding!();
                      },
                    ),

                  const Divider(height: 1, indent: 16, endIndent: 16),
                  const SizedBox(height: 8),

                  // ── Diğer ────────────────────────────────────
                  _SectionLabel('Diğer'),
                  _Tile(
                    icon: Icons.help_outline_rounded,
                    label: 'Yardım & Destek',
                    onTap: () => _go(const HelpScreen()),
                  ),
                  _Tile(
                    icon: Icons.info_outline_rounded,
                    label: 'Hakkında',
                    onTap: () => _go(const AboutScreen()),
                  ),
                ],
              ),
            ),

            // ── Çıkış ────────────────────────────────────────────
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text('Çıkış Yap'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.rose,
                      side:
                          BorderSide(color: AppColors.rose.withOpacity(0.4)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      await prov.logout();
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          color: AppColors.textLight,
        ),
      ),
    );
  }
}

// ── Normal Tile ───────────────────────────────────────────────────────────────
class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final int? badge;
  final VoidCallback onTap;
  final Color? iconColor;
  final Widget? trailing;

  const _Tile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
    this.iconColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.textMid).withOpacity(0.10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.textMid, size: 18),
      ),
      title: Text(
        label,
        style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark),
      ),
      trailing: trailing ??
          (badge != null
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
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
              : const Icon(Icons.chevron_right_rounded,
                  size: 16, color: AppColors.textLight)),
      onTap: onTap,
    );
  }
}
