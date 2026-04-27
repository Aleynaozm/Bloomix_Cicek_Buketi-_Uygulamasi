import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/widgets.dart';
import '../shop/orders_screen.dart';
import '../bouquet/alphabet_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, prov, _) {
      final user = prov.user;
      final initials = user?.name.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase() ?? '?';

      return Scaffold(
        appBar: AppBar(title: const Text('Profilim'), actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditProfile(context, prov),
          ),
        ]),
        body: SingleChildScrollView(
          child: Column(children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              color: AppColors.surface,
              child: Column(children: [
                Container(
                  width: 84, height: 84,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.rose, AppColors.roseDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: Text(initials, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.white))),
                ),
                const SizedBox(height: 14),
                Text(user?.name ?? 'Kullanıcı', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 4),
                Text(user?.email ?? '', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _StatChip('${prov.orders.length}', 'Sipariş'),
                  const SizedBox(width: 16),
                  _StatChip('${prov.favorites.length}', 'Favori'),
                  const SizedBox(width: 16),
                  _StatChip('26', 'Çiçek'),
                ]),
              ]),
            ),

            const SizedBox(height: 8),

            // Menu
            _MenuSection(title: 'Hesabım', items: [
              _MenuItem(Icons.receipt_long_outlined, 'Siparişlerim', () =>
                Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()))),
              _MenuItem(Icons.favorite_outline_rounded, 'Favorilerim', () {}),
              _MenuItem(Icons.local_florist_outlined, 'Çiçek Alfabesi', () =>
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AlphabetScreen()))),
            ]),

            _MenuSection(title: 'Uygulama', items: [
              _MenuItem(Icons.notifications_outlined, 'Bildirimler', () => _showNotifSettings(context)),
              _MenuItem(Icons.info_outline_rounded, 'Hakkında', () => _showAbout(context)),
              _MenuItem(Icons.help_outline_rounded, 'Yardım', () {}),
            ]),

            _MenuSection(title: '', items: [
              _MenuItem(Icons.logout_rounded, 'Çıkış Yap', () => _logout(context, prov), color: Colors.red),
            ]),

            const SizedBox(height: 32),
            Text('Bloomix v1.0.0 • Okul Projesi', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textLight.withOpacity(0.5))),
            const SizedBox(height: 24),
          ]),
        ),
      );
    });
  }

  void _showEditProfile(BuildContext context, AppProvider prov) {
    final ctrl = TextEditingController(text: prov.user?.name ?? '');
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 32),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Text('Profili Düzenle', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 20),
          TextField(controller: ctrl, textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Ad Soyad', prefixIcon: Icon(Icons.person_outline, size: 20))),
          const SizedBox(height: 20),
          PrimaryButton(label: 'Kaydet', onPressed: () {
            prov.updateProfile(ctrl.text.trim());
            Navigator.pop(context);
          }),
        ]),
      ),
    );
  }

  void _showNotifSettings(BuildContext context) {
    showModalBottomSheet(
      context: context, backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Text('Bildirim Ayarları', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          ...[('Sipariş güncellemeleri', true), ('Kampanyalar', false), ('Yeni çiçekler', true)].map((item) =>
            SwitchListTile(
              title: Text(item.$1, style: const TextStyle(fontSize: 14)),
              value: item.$2,
              onChanged: (_) {},
              activeColor: AppColors.rose,
              contentPadding: EdgeInsets.zero,
            )
          ),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Bloomix',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2025 Bloomix — Okul Projesi\nİsminden çiçek buketi tasarım platformu.',
    );
  }

  void _logout(BuildContext context, AppProvider prov) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Çıkış Yap'),
        content: const Text('Hesabından çıkmak istediğinden emin misin?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          TextButton(onPressed: () { Navigator.pop(context); prov.logout(); },
            child: const Text('Çıkış Yap', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value, label;
  const _StatChip(this.value, this.label);
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textDark)),
    Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
  ]);
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;
  const _MenuSection({required this.title, required this.items});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (title.isNotEmpty) ...[
          Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textLight, letterSpacing: 0.5)),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border)),
          child: Column(
            children: items.asMap().entries.map((e) {
              final i = e.key; final item = e.value;
              return Column(children: [
                ListTile(
                  leading: Icon(item.icon, size: 22, color: item.color ?? AppColors.textMid),
                  title: Text(item.label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: item.color ?? AppColors.textDark)),
                  trailing: item.color == null ? const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textLight) : null,
                  onTap: item.onTap,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                if (i < items.length - 1) Divider(height: 0.5, indent: 56, color: AppColors.border),
              ]);
            }).toList(),
          ),
        ),
      ]),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _MenuItem(this.icon, this.label, this.onTap, {this.color});
}
