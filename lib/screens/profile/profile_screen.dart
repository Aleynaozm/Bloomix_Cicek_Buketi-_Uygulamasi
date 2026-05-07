import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../bouquet/alphabet_screen.dart';
import '../bouquet/free_design_screen.dart';
import '../shop/orders_screen.dart';
import '../info/info_screens.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _picker = ImagePicker();

  Future<void> _pickPhoto(AppProvider prov) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: const Color(0xFFEDE0E4),
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F3),
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.camera_alt_rounded,
                  color: Color(0xFFFF4D7E), size: 20),
            ),
            title: Text('Kamerayı Aç',
                style: GoogleFonts.urbanist(
                    fontWeight: FontWeight.w700, fontSize: 15)),
            onTap: () async {
              Navigator.pop(context);
              final f = await _picker.pickImage(
                  source: ImageSource.camera, imageQuality: 80);
              if (f != null) prov.setLocalPhotoPath(f.path);
            },
          ),
          ListTile(
            leading: Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F3),
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.photo_library_rounded,
                  color: Color(0xFFFF4D7E), size: 20),
            ),
            title: Text('Galeriden Seç',
                style: GoogleFonts.urbanist(
                    fontWeight: FontWeight.w700, fontSize: 15)),
            onTap: () async {
              Navigator.pop(context);
              final f = await _picker.pickImage(
                  source: ImageSource.gallery, imageQuality: 80);
              if (f != null) prov.setLocalPhotoPath(f.path);
            },
          ),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }

  void _showEditProfile(AppProvider prov) {
    final ctrl = TextEditingController(text: prov.user?.name ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 32),
        child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFFEDE0E4),
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text('Profili Düzenle',
              style: GoogleFonts.urbanist(
                  fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          TextField(
            controller: ctrl,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Ad Soyad',
              prefixIcon: const Icon(Icons.person_outline, size: 20),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4D7E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                prov.updateProfile(ctrl.text.trim());
                Navigator.pop(context);
              },
              child: Text('Kaydet',
                  style: GoogleFonts.urbanist(
                      fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ]),
      ),
    );
  }

  void _logout(AppProvider prov) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Çıkış Yap',
            style: GoogleFonts.urbanist(fontWeight: FontWeight.w800)),
        content: Text('Hesabından çıkmak istediğinden emin misin?',
            style: GoogleFonts.urbanist()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal',
                style: GoogleFonts.urbanist(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () { Navigator.pop(context); prov.logout(); },
            child: Text('Çıkış Yap',
                style: GoogleFonts.urbanist(
                    color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final user = prov.user;
    final initials = user?.name.trim().split(' ')
            .map((w) => w.isNotEmpty ? w[0] : '')
            .take(2)
            .join()
            .toUpperCase() ??
        '?';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F9),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── AppBar ──────────────────────────────────────────
          SliverAppBar(
            backgroundColor: const Color(0xFFFFF8F9),
            elevation: 0,
            scrolledUnderElevation: 0,
            floating: true,
            title: Text('Profilim',
                style: GoogleFonts.urbanist(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2D2D2D))),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: Color(0xFF2D2D2D)),
                onPressed: () => _showEditProfile(prov),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(children: [
              // ── Header ─────────────────────────────────────
              _ProfileHeader(
                initials: initials,
                name: user?.name ?? 'Kullanıcı',
                email: user?.email ?? '',
                localPhotoPath: prov.localPhotoPath,
                onPickPhoto: () => _pickPhoto(prov),
              ),
              const SizedBox(height: 16),

              // ── Stats ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _StatsCard(prov: prov),
              ),
              const SizedBox(height: 24),

              // ── HESABIM ─────────────────────────────────────
              _MenuGroup(
                label: 'HESABIM',
                items: [
                  _Item(
                    icon: Icons.receipt_long_outlined,
                    label: 'Siparişlerim',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const OrdersScreen())),
                  ),
                  _Item(
                    icon: Icons.favorite_outline_rounded,
                    label: 'Favorilerim',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const _FavoritesScreen())),
                  ),
                ],
              ),

              // ── UYGULAMA ────────────────────────────────────
              _MenuGroup(
                label: 'UYGULAMA',
                items: [
                  _Item(
                    icon: Icons.location_on_outlined,
                    label: 'Adreslerim',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const AddressesScreen())),
                  ),
                  _Item(
                    icon: Icons.notifications_outlined,
                    label: 'Bildirimler',
                    badge: prov.unreadCount,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const NotificationsScreen())),
                  ),
                  _Item(
                    icon: Icons.settings_outlined,
                    label: 'Ayarlar',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const SettingsScreen())),
                  ),
                ],
              ),

              // ── DESTEK ──────────────────────────────────────
              _MenuGroup(
                label: 'DESTEK',
                items: [
                  _Item(
                    icon: Icons.help_outline_rounded,
                    label: 'Yardım & Destek',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const HelpScreen())),
                  ),
                  _Item(
                    icon: Icons.logout_rounded,
                    label: 'Çıkış Yap',
                    danger: true,
                    onTap: () => _logout(prov),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Text(
                'Bloomix v1.0.0',
                style: GoogleFonts.urbanist(
                    fontSize: 12,
                    color: const Color(0xFFBBAFB2),
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 40),
            ]),
          ),
        ],
      ),
    );
  }
}

// ── Profil Header ─────────────────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final String initials;
  final String name;
  final String email;
  final String? localPhotoPath;
  final VoidCallback onPickPhoto;

  const _ProfileHeader({
    required this.initials,
    required this.name,
    required this.email,
    required this.localPhotoPath,
    required this.onPickPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF4D7E), Color(0xFFFF85A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF4D7E).withOpacity(0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: Colors.white.withOpacity(0.25),
              backgroundImage: localPhotoPath != null
                  ? FileImage(File(localPhotoPath!))
                  : null,
              child: localPhotoPath == null
                  ? Text(initials,
                      style: GoogleFonts.urbanist(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white))
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: onPickPhoto,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 6)
                    ],
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      size: 16, color: Color(0xFFFF4D7E)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(name,
            style: GoogleFonts.urbanist(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white)),
        const SizedBox(height: 4),
        Text(email,
            style: GoogleFonts.urbanist(
                fontSize: 13,
                color: Colors.white.withOpacity(0.85),
                fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

// ── Stats Kartı ───────────────────────────────────────────────────────────────
class _StatsCard extends StatelessWidget {
  final AppProvider prov;
  const _StatsCard({required this.prov});

  @override
  Widget build(BuildContext context) {
    final stats = [
      (value: '${prov.orders.length}', label: 'Sipariş', emoji: '📦'),
      (value: '${prov.favorites.length}', label: 'Favori', emoji: '❤️'),
      (value: '${prov.collections.length}', label: 'Koleksiyon', emoji: '🗂️'),
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
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: stats.asMap().entries.map((e) {
          final last = e.key == stats.length - 1;
          return Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: last
                    ? null
                    : const Border(
                        right: BorderSide(
                            color: Color(0xFFEDE0E4), width: 1)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(children: [
                Text(e.value.emoji,
                    style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 6),
                Text(e.value.value,
                    style: GoogleFonts.urbanist(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF2D2D2D))),
                const SizedBox(height: 2),
                Text(e.value.label,
                    style: GoogleFonts.urbanist(
                        fontSize: 11,
                        color: const Color(0xFF9A8A8E),
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Menü Grubu ────────────────────────────────────────────────────────────────
class _MenuGroup extends StatelessWidget {
  final String label;
  final List<_Item> items;
  const _MenuGroup({required this.label, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: GoogleFonts.urbanist(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFBBAFB2),
                letterSpacing: 1.2)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFEDE0E4), width: 1.5),
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              final item = e.value;
              final last = e.key == items.length - 1;
              return Column(children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.vertical(
                      top: e.key == 0
                          ? const Radius.circular(20)
                          : Radius.zero,
                      bottom: last
                          ? const Radius.circular(20)
                          : Radius.zero,
                    ),
                    onTap: item.onTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: item.danger
                                ? Colors.red.withOpacity(0.08)
                                : const Color(0xFFFFF0F3),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Icon(item.icon,
                              size: 18,
                              color: item.danger
                                  ? Colors.red
                                  : const Color(0xFFFF4D7E)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(item.label,
                              style: GoogleFonts.urbanist(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: item.danger
                                      ? Colors.red
                                      : const Color(0xFF2D2D2D))),
                        ),
                        if (!item.danger) ...[
                          if (item.badge > 0)
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF4D7E),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('${item.badge}',
                                  style: GoogleFonts.urbanist(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                            ),
                          const Icon(Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: Color(0xFFBBAFB2)),
                        ],
                      ]),
                    ),
                  ),
                ),
                if (!last)
                  const Divider(
                      height: 0,
                      indent: 68,
                      endIndent: 0,
                      color: Color(0xFFEDE0E4)),
              ]);
            }).toList(),
          ),
        ),
      ]),
    );
  }
}

class _Item {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final int badge;
  final bool danger;
  const _Item({
    required this.icon,
    required this.label,
    this.onTap,
    this.badge = 0,
    this.danger = false,
  });
}

// ── Favoriler Sayfası ─────────────────────────────────────────────────────────
class _FavoritesScreen extends StatelessWidget {
  const _FavoritesScreen();

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final favs = prov.favorites;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F9),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Favorilerim',
            style: GoogleFonts.urbanist(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2D2D2D))),
        centerTitle: true,
      ),
      body: favs.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🌸', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 16),
                  Text('Henüz favori buketin yok',
                      style: GoogleFonts.urbanist(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2D2D2D))),
                  const SizedBox(height: 8),
                  Text('İlk buketi tasarlamaya başla!',
                      style: GoogleFonts.urbanist(
                          fontSize: 13,
                          color: const Color(0xFF9A8A8E))),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4D7E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const FreeDesignScreen())),
                    child: Text('Hemen Tasarla',
                        style: GoogleFonts.urbanist(
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: favs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final b = favs[i];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: const Color(0xFFEDE0E4), width: 1.5),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0F3),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.local_florist_rounded,
                          color: Color(0xFFFF4D7E)),
                    ),
                    title: Text(b.name,
                        style: GoogleFonts.urbanist(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2D2D2D))),
                    subtitle: Text('${b.flowers.length} çiçek',
                        style: GoogleFonts.urbanist(
                            fontSize: 12,
                            color: const Color(0xFF9A8A8E))),
                  ),
                );
              },
            ),
    );
  }
}
