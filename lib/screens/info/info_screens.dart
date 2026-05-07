import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/widgets.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Adreslerim
// ══════════════════════════════════════════════════════════════════════════════

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: Text('Adreslerim',
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.rose,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text('Adres Ekle', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        onPressed: () => _showAddressForm(context, null),
      ),
      body: Consumer<AppProvider>(builder: (_, prov, __) {
        final addrs = prov.addresses;
        if (addrs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('🏠', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                Text('Henüz adres eklemedin',
                    style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark)),
                const SizedBox(height: 6),
                Text('Teslimat için kolayca adres ekleyebilirsin.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: AppColors.textMid)),
              ]),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          itemCount: addrs.length,
          itemBuilder: (_, i) => _AddressCard(
            address: addrs[i],
            onEdit: () => _showAddressForm(context, addrs[i]),
            onDelete: () => _confirmDelete(context, prov, addrs[i].id),
          ),
        );
      }),
    );
  }

  void _confirmDelete(BuildContext context, AppProvider prov, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Adresi Sil'),
        content: const Text('Bu adresi silmek istediğinden emin misin?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          TextButton(
            onPressed: () { Navigator.pop(context); prov.removeAddress(id); },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  static void _showAddressForm(BuildContext context, AppAddress? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _AddressFormSheet(existing: existing),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final AppAddress address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _AddressCard({required this.address, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: address.isDefault ? AppColors.rose : AppColors.border,
            width: address.isDefault ? 1.5 : 1),
        boxShadow: [
          BoxShadow(
              color: AppColors.rose.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
                color: AppColors.rose.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.location_on_outlined,
                color: AppColors.rose, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(address.title,
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark)),
                if (address.isDefault) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                        color: AppColors.rose.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(50)),
                    child: Text('Varsayılan',
                        style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.rose)),
                  ),
                ],
              ]),
              const SizedBox(height: 2),
              Text('${address.district}, ${address.city}',
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: AppColors.textMid)),
              Text(address.fullAddress,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: AppColors.textLight)),
            ]),
          ),
          Column(children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              color: AppColors.textMid,
              onPressed: onEdit,
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              color: Colors.red.shade300,
              onPressed: onDelete,
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(),
            ),
          ]),
        ]),
      ),
    );
  }
}

class _AddressFormSheet extends StatefulWidget {
  final AppAddress? existing;
  const _AddressFormSheet({this.existing});

  @override
  State<_AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<_AddressFormSheet> {
  final _form = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.existing?.title ?? '');
  late final _city = TextEditingController(text: widget.existing?.city ?? '');
  late final _district = TextEditingController(text: widget.existing?.district ?? '');
  late final _full = TextEditingController(text: widget.existing?.fullAddress ?? '');
  late bool _isDefault = widget.existing?.isDefault ?? false;

  @override
  void dispose() {
    _title.dispose(); _city.dispose(); _district.dispose(); _full.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    final prov = context.read<AppProvider>();
    final addr = AppAddress(
      id: widget.existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _title.text.trim(),
      city: _city.text.trim(),
      district: _district.text.trim(),
      fullAddress: _full.text.trim(),
      isDefault: _isDefault,
    );
    if (widget.existing == null) {
      prov.addAddress(addr);
    } else {
      prov.updateAddress(addr);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Form(
        key: _form,
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
            child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 20),
          Text(widget.existing == null ? 'Adres Ekle' : 'Adresi Düzenle',
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark)),
          const SizedBox(height: 20),
          TextFormField(
            controller: _title,
            decoration: const InputDecoration(
                labelText: 'Adres Başlığı (Ev, İş...)',
                prefixIcon: Icon(Icons.label_outline, size: 20)),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Başlık gerekli' : null,
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: TextFormField(
                controller: _city,
                decoration: const InputDecoration(
                    labelText: 'Şehir',
                    prefixIcon: Icon(Icons.location_city_outlined, size: 20)),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Şehir gerekli' : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _district,
                decoration: const InputDecoration(
                    labelText: 'İlçe',
                    prefixIcon: Icon(Icons.map_outlined, size: 20)),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'İlçe gerekli' : null,
              ),
            ),
          ]),
          const SizedBox(height: 12),
          TextFormField(
            controller: _full,
            maxLines: 2,
            decoration: const InputDecoration(
                labelText: 'Açık Adres',
                prefixIcon: Icon(Icons.home_outlined, size: 20),
                alignLabelWithHint: true),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Adres gerekli' : null,
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: Text('Varsayılan adres olarak ayarla',
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textDark)),
            value: _isDefault,
            onChanged: (v) => setState(() => _isDefault = v),
            activeColor: AppColors.rose,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          PrimaryButton(
              label: widget.existing == null ? 'Adresi Kaydet' : 'Değişiklikleri Kaydet',
              onPressed: _save),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Bildirimler
// ══════════════════════════════════════════════════════════════════════════════

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static IconData _icon(String type) {
    switch (type) {
      case 'order': return Icons.receipt_long_outlined;
      case 'campaign': return Icons.local_offer_outlined;
      default: return Icons.notifications_outlined;
    }
  }

  static Color _color(String type) {
    switch (type) {
      case 'order': return AppColors.rose;
      case 'campaign': return const Color(0xFF4CAF50);
      default: return AppColors.roseDark;
    }
  }

  static String _relativeTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
    if (diff.inHours < 24) return '${diff.inHours} sa önce';
    return '${diff.inDays} gün önce';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: Text('Bildirimler',
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        actions: [
          Consumer<AppProvider>(builder: (_, prov, __) {
            if (prov.unreadCount == 0) return const SizedBox.shrink();
            return TextButton(
              onPressed: prov.markAllNotificationsRead,
              child: Text('Tümünü Oku',
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.rose,
                      fontWeight: FontWeight.w600)),
            );
          }),
        ],
      ),
      body: Consumer<AppProvider>(builder: (_, prov, __) {
        final notifs = prov.notifications;
        if (notifs.isEmpty) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('🔔', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 12),
              Text('Henüz bildirim yok',
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark)),
            ]),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          itemCount: notifs.length,
          itemBuilder: (_, i) {
            final n = notifs[i];
            return GestureDetector(
              onTap: () => prov.markNotificationRead(n.id),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: n.isRead ? AppColors.white : AppColors.rose.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: n.isRead ? AppColors.border : AppColors.rose.withValues(alpha: 0.25)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                          color: _color(n.type).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12)),
                      child: Icon(_icon(n.type), color: _color(n.type), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(
                            child: Text(n.title,
                                style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700,
                                    color: AppColors.textDark)),
                          ),
                          if (!n.isRead)
                            Container(
                              width: 8, height: 8,
                              decoration: const BoxDecoration(
                                  color: AppColors.rose, shape: BoxShape.circle),
                            ),
                        ]),
                        const SizedBox(height: 2),
                        Text(n.body,
                            style: GoogleFonts.poppins(
                                fontSize: 11, color: AppColors.textMid)),
                        const SizedBox(height: 4),
                        Text(_relativeTime(n.time),
                            style: GoogleFonts.poppins(
                                fontSize: 10, color: AppColors.textLight)),
                      ]),
                    ),
                  ]),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Ayarlar
// ══════════════════════════════════════════════════════════════════════════════

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (_, prov, __) {
      return Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          backgroundColor: AppColors.cream,
          elevation: 0,
          title: Text('Ayarlar',
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            // Profile Section
            _SectionHeader('Profil'),
            _SettingsCard(children: [
              _ProfileTile(prov: prov),
            ]),

            const SizedBox(height: 16),
            _SectionHeader('Bildirimler'),
            _SettingsCard(children: [
              _SwitchTile(
                icon: Icons.receipt_long_outlined,
                label: 'Sipariş Güncellemeleri',
                value: prov.notifOrders,
                onChanged: prov.setNotifOrders,
              ),
              _SwitchTile(
                icon: Icons.local_offer_outlined,
                label: 'Kampanyalar',
                value: prov.notifCampaigns,
                onChanged: prov.setNotifCampaigns,
              ),
            ]),

            const SizedBox(height: 16),
            _SectionHeader('Uygulama'),
            _SettingsCard(children: [
              _NavTile(
                icon: Icons.info_outline_rounded,
                label: 'Hakkında',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AboutScreen())),
              ),
              _NavTile(
                icon: Icons.privacy_tip_outlined,
                label: 'Gizlilik Politikası',
                onTap: () => launchUrl(Uri.parse('https://bloomix.app/privacy')),
              ),
            ]),

            const SizedBox(height: 16),
            _SettingsCard(children: [
              _NavTile(
                icon: Icons.logout_rounded,
                label: 'Çıkış Yap',
                color: Colors.red,
                onTap: () => _confirmLogout(context, prov),
              ),
            ]),

            const SizedBox(height: 24),
            Center(
              child: Text('Bloomix v1.0.0',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: AppColors.textLight)),
            ),
          ],
        ),
      );
    });
  }

  void _confirmLogout(BuildContext context, AppProvider prov) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Çıkış Yap'),
        content: const Text('Hesabından çıkmak istediğinden emin misin?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              prov.logout();
              Navigator.of(context).popUntil((r) => r.isFirst);
            },
            child: const Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 2),
        child: Text(text,
            style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textLight,
                letterSpacing: 0.5)),
      );
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border)),
        child: Column(
          children: children.asMap().entries.map((e) {
            return Column(children: [
              e.value,
              if (e.key < children.length - 1)
                Divider(height: 0.5, indent: 52, color: AppColors.border),
            ]);
          }).toList(),
        ),
      );
}

class _ProfileTile extends StatelessWidget {
  final AppProvider prov;
  const _ProfileTile({required this.prov});

  @override
  Widget build(BuildContext context) {
    final user = prov.user;
    final initials = user?.name.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase() ?? '?';
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [AppColors.rose, AppColors.roseDark],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
            shape: BoxShape.circle),
        child: Center(child: Text(initials,
            style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w700, fontSize: 15))),
      ),
      title: Text(user?.name ?? 'Kullanıcı',
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
      subtitle: Text(user?.email ?? '',
          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textLight)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textLight),
      onTap: () => _showEditProfile(context, prov),
    );
  }

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
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Text('Profili Düzenle',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          const SizedBox(height: 20),
          TextField(
            controller: ctrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
                labelText: 'Ad Soyad', prefixIcon: Icon(Icons.person_outline, size: 20)),
          ),
          const SizedBox(height: 20),
          PrimaryButton(label: 'Kaydet', onPressed: () {
            prov.updateProfile(ctrl.text.trim());
            Navigator.pop(context);
          }),
        ]),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTile({required this.icon, required this.label, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        secondary: Icon(icon, size: 22, color: AppColors.textMid),
        title: Text(label,
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.rose,
      );
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _NavTile({required this.icon, required this.label, required this.onTap, this.color});
  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Icon(icon, size: 22, color: color ?? AppColors.textMid),
        title: Text(label,
            style: GoogleFonts.poppins(
                fontSize: 14, fontWeight: FontWeight.w500, color: color ?? AppColors.textDark)),
        trailing: color == null
            ? const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textLight)
            : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      );
}

// ══════════════════════════════════════════════════════════════════════════════
// Yardım & Destek
// ══════════════════════════════════════════════════════════════════════════════

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _faqs = [
    (
      'Buket nasıl tasarlarım?',
      'Ana ekrandan "Tasarla" butonuna basarak Serbest Tasarım ya da Çiçek Alfabesi moduna geçebilirsin. Dilediğin çiçekleri ve şablonları seçerek kendi buketini oluşturabilirsin.'
    ),
    (
      'Sipariş verdikten sonra değişiklik yapabilir miyim?',
      'Sipariş onaylandıktan sonra değişiklik yapmak için destek ekibimizle iletişime geçmen gerekiyor. Hazırlık başlamadan önce genellikle yardımcı olabiliyoruz.'
    ),
    (
      'Teslimat ne kadar sürer?',
      'Standart teslimat 2-3 iş günüdür. Ekspres teslimat seçeneği ile aynı gün veya ertesi gün teslimat da mümkündür.'
    ),
    (
      'Hediye notu ekleyebilir miyim?',
      'Evet! Sipariş aşamasında kişiye özel hediye notu ekleyebilirsin. Not, zarif bir kartla birlikte teslim edilir.'
    ),
    (
      'Faturamı nerede görebilirim?',
      'Siparişlerim ekranında ilgili siparişe tıklayarak sipariş detayını ve fatura bilgilerini görebilirsin.'
    ),
    (
      'Ödeme yöntemleri nelerdir?',
      'Kredi kartı, banka kartı ve havale/EFT ile ödeme yapabilirsin. Tüm ödemeler 256-bit SSL ile güvenli şekilde işlenir.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: Text('Yardım & Destek',
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          // Contact cards
          Row(children: [
            Expanded(child: _ContactCard(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'WhatsApp',
              color: const Color(0xFF25D366),
              onTap: () => launchUrl(Uri.parse('https://wa.me/905XXXXXXXXX')),
            )),
            const SizedBox(width: 12),
            Expanded(child: _ContactCard(
              icon: Icons.email_outlined,
              label: 'E-posta',
              color: AppColors.rose,
              onTap: () => launchUrl(Uri.parse('mailto:destek@bloomix.app')),
            )),
          ]),
          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 2),
            child: Text('Sık Sorulan Sorular',
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
          ),

          Container(
            decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border)),
            child: Column(
              children: _faqs.asMap().entries.map((e) {
                final i = e.key; final faq = e.value;
                return Column(children: [
                  Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                      iconColor: AppColors.rose,
                      collapsedIconColor: AppColors.textLight,
                      title: Text(faq.$1,
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark)),
                      children: [
                        Text(faq.$2,
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: AppColors.textMid, height: 1.55)),
                      ],
                    ),
                  ),
                  if (i < _faqs.length - 1)
                    Divider(height: 0.5, indent: 16, color: AppColors.border),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ContactCard({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border)),
          child: Column(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark)),
          ]),
        ),
      );
}

// ══════════════════════════════════════════════════════════════════════════════
// Hakkında
// ══════════════════════════════════════════════════════════════════════════════

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: Text('Hakkında',
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Container(
              width: 96, height: 96,
              decoration: BoxDecoration(
                  color: AppColors.rose.withValues(alpha: 0.12),
                  shape: BoxShape.circle),
              child: const Center(child: Text('🌸', style: TextStyle(fontSize: 48))),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text('Bloomix',
                style: GoogleFonts.dmSerifDisplay(fontSize: 32, color: AppColors.rose)),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text('v1.0.0 — Beta',
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textLight)),
          ),
          const SizedBox(height: 28),
          Text(
            'İsmin harflerinden ve Lego brick\'lerinden ilham alan, hiç solmayan dijital çiçek buketleri tasarlama uygulaması.',
            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textMid, height: 1.6),
          ),
          const SizedBox(height: 24),
          _AboutRow(Icons.code_rounded, 'Geliştirici', 'Bloomix Team'),
          _AboutRow(Icons.flutter_dash, 'Platform', 'Flutter 3.x'),
          _AboutRow(Icons.copyright_rounded, 'Lisans', '© 2025 Bloomix'),
        ],
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _AboutRow(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          Icon(icon, size: 18, color: AppColors.rose),
          const SizedBox(width: 10),
          Text('$label: ', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textLight)),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        ]),
      );
}
