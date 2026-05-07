import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/widgets.dart';
import '../shop/orders_screen.dart';
import '../bouquet/alphabet_screen.dart';
import '../bouquet/free_design_screen.dart';
import '../info/info_screens.dart';

const _kBg = Color(0xFFFFF8F9);
const _kPink = Color(0xFFFF85A1);

TextStyle _urban(double size, {FontWeight w = FontWeight.w400, Color? color}) =>
    GoogleFonts.urbanist(fontSize: size, fontWeight: w, color: color);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _picker = ImagePicker();

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined, color: _kPink),
            title: Text('Kamera', style: _urban(15, w: FontWeight.w600)),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined, color: _kPink),
            title: Text('Galeri', style: _urban(15, w: FontWeight.w600)),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
    if (source == null || !mounted) return;
    final file = await _picker.pickImage(source: source, imageQuality: 80);
    if (file != null && mounted) {
      context.read<AppProvider>().setLocalPhotoPath(file.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, prov, _) {
      final user = prov.user;
      final initials = user?.name
              .trim()
              .split(' ')
              .map((w) => w.isNotEmpty ? w[0] : '')
              .take(2)
              .join()
              .toUpperCase() ??
          '?';
      final hasPhoto = prov.localPhotoPath != null;

      return Scaffold(
        backgroundColor: _kBg,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: _kBg,
              expandedHeight: 260,
              pinned: true,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: Text('Profilim',
                  style: _urban(18, w: FontWeight.w800, color: AppColors.textDark)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: _kPink),
                  onPressed: () => _showEditProfile(ctx, prov),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: _ProfileHeader(
                  initials: initials,
                  user: user,
                  hasPhoto: hasPhoto,
                  localPhotoPath: prov.localPhotoPath,
                  onPickPhoto: _pickPhoto,
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Column(children: [
                  _StatsCard(prov: prov),
                  const SizedBox(height: 20),

                  _MenuGroup(title: 'Hesabım', items: [
                    _Item(Icons.receipt_long_outlined, 'Siparişlerim',
                        () => _push(ctx, const OrdersScreen())),
                    _Item(Icons.favorite_outline_rounded, 'Favorilerim',
                        () => _push(ctx, const _FavoritesScreen())),
                    _Item(Icons.local_florist_outlined, 'Çiçek Alfabesi',
                        () => _push(ctx, const AlphabetScreen())),
                  ]),
                  const SizedBox(height: 14),

                  _MenuGroup(title: 'Uygulama', items: [
                    _Item(Icons.location_on_outlined, 'Adreslerim',
                        () => _push(ctx, const AddressesScreen())),
                    _Item(Icons.notifications_outlined, 'Bildirimler',
                        () => _push(ctx, const NotificationsScreen()),
                        badge: prov.unreadCount),
                    _Item(Icons.settings_outlined, 'Ayarlar',
                        () => _push(ctx, const SettingsScreen())),
                  ]),
                  const SizedBox(height: 14),

                  _MenuGroup(title: 'Destek', items: [
                    _Item(Icons.help_outline_rounded, 'Yardım & Destek',
                        () => _push(ctx, const HelpScreen())),
                    _Item(Icons.logout_rounded, 'Çıkış Yap',
                        () => _confirmLogout(ctx, prov),
                        color: Colors.red.shade400),
                  ]),

                  const SizedBox(height: 28),
                  Text('Bloomix v1.0.0',
                      style: _urban(11, color: AppColors.textLight)),
                ]),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _push(BuildContext ctx, Widget screen) =>
      Navigator.push(ctx, MaterialPageRoute(builder: (_) => screen));

  void _showEditProfile(BuildContext context, AppProvider prov) {
    final ctrl = TextEditingController(text: prov.user?.name ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 32),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text('Profili Düzenle',
                  style: _urban(18, w: FontWeight.w800, color: AppColors.textDark)),
              const SizedBox(height: 20),
              TextField(
                controller: ctrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                    labelText: 'Ad Soyad',
                    prefixIcon: Icon(Icons.person_outline, size: 20)),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                  label: 'Kaydet',
                  onPressed: () {
                    prov.updateProfile(ctrl.text.trim());
                    Navigator.pop(context);
                  }),
            ]),
      ),
    );
  }

  void _confirmLogout(BuildContext context, AppProvider prov) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Çıkış Yap', style: _urban(17, w: FontWeight.w700)),
        content: Text('Hesabından çıkmak istediğinden emin misin?',
            style: _urban(14, color: AppColors.textMid)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  Text('İptal', style: _urban(14, color: AppColors.textMid))),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                prov.logout();
              },
              child: Text('Çıkış Yap',
                  style:
                      _urban(14, w: FontWeight.w700, color: Colors.red))),
        ],
      ),
    );
  }
}

// ── Profile Header ─────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final String initials;
  final dynamic user;
  final bool hasPhoto;
  final String? localPhotoPath;
  final VoidCallback onPickPhoto;

  const _ProfileHeader({
    required this.initials,
    required this.user,
    required this.hasPhoto,
    required this.localPhotoPath,
    required this.onPickPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFE4EE), _kBg],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 64),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                        color: _kPink.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: _kPink.withValues(alpha: 0.12),
                  backgroundImage:
                      hasPhoto ? FileImage(File(localPhotoPath!)) : null,
                  child: !hasPhoto
                      ? Text(initials,
                          style: _urban(30, w: FontWeight.w800, color: _kPink))
                      : null,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: onPickPhoto,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: _kPink.withValues(alpha: 0.4), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6)
                      ],
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        size: 15, color: _kPink),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(user?.name ?? 'Kullanıcı',
              style: _urban(20, w: FontWeight.w800, color: AppColors.textDark)),
          const SizedBox(height: 4),
          Text(user?.email ?? '',
              style: _urban(12, color: AppColors.textLight)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ── Stats Card ─────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  final AppProvider prov;
  const _StatsCard({required this.prov});

  @override
  Widget build(BuildContext context) {
    final favCol = prov.collections.firstWhere(
        (c) => c.id == 'sys_favorites',
        orElse: () => prov.collections.first);
    final favCount = prov.bouquetsInCollection(favCol.id).length;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: _kPink.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(children: [
        _StatTile(Icons.receipt_long_rounded, '${prov.orders.length}', 'Sipariş'),
        Container(height: 44, width: 1, color: AppColors.border),
        _StatTile(Icons.favorite_rounded, '$favCount', 'Favori'),
        Container(height: 44, width: 1, color: AppColors.border),
        _StatTile(Icons.collections_bookmark_outlined, '${prov.collections.length}', 'Koleksiyon'),
      ]),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatTile(this.icon, this.value, this.label);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(children: [
          Icon(icon, color: _kPink, size: 22),
          const SizedBox(height: 6),
          Text(value,
              style: _urban(22, w: FontWeight.w800, color: AppColors.textDark)),
          const SizedBox(height: 2),
          Text(label, style: _urban(11, color: AppColors.textLight)),
        ]),
      );
}

// ── Menu Group ─────────────────────────────────────────────────────────────

class _MenuGroup extends StatelessWidget {
  final String title;
  final List<_Item> items;
  const _MenuGroup({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(title.toUpperCase(),
            style: _urban(10,
                w: FontWeight.w700,
                color: AppColors.textLight)),
      ),
      Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
                color: _kPink.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          children: items.asMap().entries.map((e) {
            final i = e.key;
            final item = e.value;
            return Column(children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: item.onTap,
                  borderRadius: BorderRadius.vertical(
                    top: i == 0 ? const Radius.circular(20) : Radius.zero,
                    bottom: i == items.length - 1
                        ? const Radius.circular(20)
                        : Radius.zero,
                  ),
                  splashColor: _kPink.withValues(alpha: 0.08),
                  highlightColor: _kPink.withValues(alpha: 0.04),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    child: Row(children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: (item.color ?? _kPink).withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(item.icon,
                            size: 19, color: item.color ?? _kPink),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(item.label,
                            style: _urban(14,
                                w: FontWeight.w600,
                                color: item.color ?? AppColors.textDark)),
                      ),
                      if (item.badge > 0)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                              color: _kPink,
                              borderRadius: BorderRadius.circular(50)),
                          child: Text('${item.badge}',
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 13,
                          color: item.color != null
                              ? item.color!.withValues(alpha: 0.5)
                              : AppColors.textLight),
                    ]),
                  ),
                ),
              ),
              if (i < items.length - 1)
                Divider(height: 0.5, indent: 68, color: AppColors.border),
            ]);
          }).toList(),
        ),
      ),
    ]);
  }
}

class _Item {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final int badge;
  const _Item(this.icon, this.label, this.onTap,
      {this.color, this.badge = 0});
}

// ── Favoriler Ekranı ───────────────────────────────────────────────────────

class _FavoritesScreen extends StatelessWidget {
  const _FavoritesScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        title: Text('Favorilerim',
            style: _urban(18, w: FontWeight.w700, color: AppColors.textDark)),
      ),
      body: Consumer<AppProvider>(builder: (_, prov, __) {
        final favCol = prov.collections.firstWhere(
            (c) => c.id == 'sys_favorites',
            orElse: () => prov.collections.first);
        final favs = prov.bouquetsInCollection(favCol.id);

        if (favs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('🌸', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                Text('Henüz favori buketin yok',
                    style:
                        _urban(17, w: FontWeight.w700, color: AppColors.textDark)),
                const SizedBox(height: 6),
                Text('Tasarladığın buketleri favorilere ekleyebilirsin.',
                    textAlign: TextAlign.center,
                    style: _urban(13, color: AppColors.textMid)),
                const SizedBox(height: 24),
                GradientButton(
                  label: 'Hemen Tasarlamaya Başla',
                  icon: Icons.local_florist_outlined,
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const FreeDesignScreen())),
                ),
              ]),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          itemCount: favs.length,
          itemBuilder: (_, i) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border)),
            child: Row(children: [
              const Text('💐', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(favs[i].bouquet.name,
                    style: _urban(14,
                        w: FontWeight.w700, color: AppColors.textDark)),
              ),
            ]),
          ),
        );
      }),
    );
  }
}
