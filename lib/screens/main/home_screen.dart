import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/widgets.dart';
import '../../widgets/app_drawer.dart';
import '../../data/flower_data.dart';
import '../bouquet/bouquet_builder_screen.dart';
import '../bouquet/alphabet_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onShowOnboarding;
  /// Sepet sekmesine geçiş — MainShell paslar.
  final VoidCallback? onGoCart;
  const HomeScreen({super.key, this.onShowOnboarding, this.onGoCart});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, prov, _) {
      final user = prov.user;
      return Scaffold(
        drawer: AppDrawer(onShowOnboarding: onShowOnboarding),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: AppColors.cream,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  tooltip: 'Menü',
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
              title: const BloomixLogo(size: 24),
              centerTitle: true,
              actions: [
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () => _showNotifications(context, prov),
                    ),
                    if (prov.unreadCount > 0)
                      Positioned(right: 8, top: 8, child: Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(color: AppColors.rose, shape: BoxShape.circle),
                      )),
                  ],
                ),
                const SizedBox(width: 4),
              ],
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting
                    Text('Merhaba, ${user?.name.split(' ').first ?? 'Misafir'} 🌸',
                      style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: 4),
                    Text('İsminden buket oluşturmaya hazır mısın?',
                      style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 16),

                    // Lottie hero animation
                    _HeroAnimation(),
                    const SizedBox(height: 16),

                    // Name input card
                    _NameInputCard(),
                    const SizedBox(height: 28),

                    // Quick actions
                    SectionHeader(title: 'Keşfet', action: 'Tümünü Gör',
                      onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AlphabetScreen()))),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 160,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 6,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, i) {
                          final entries = flowerAlphabet.entries.toList();
                          final f = entries[i * 4].value;
                          return SizedBox(
                            width: 80,
                            child: GestureDetector(
                              onTap: () => showFlowerDetail(context, f),
                              child: FlowerCard(flower: f, size: 72),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Feature cards
                    SectionHeader(title: 'Ne Yapmak İstersin?'),
                    const SizedBox(height: 14),
                    _FeatureGrid(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showNotifications(BuildContext context, AppProvider prov) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Bildirimler', style: Theme.of(context).textTheme.titleLarge),
              Text('${prov.unreadCount} yeni', style: TextStyle(color: AppColors.rose, fontSize: 13)),
            ]),
          ),
          const SizedBox(height: 12),
          ...prov.notifications.take(5).map((n) => ListTile(
            leading: Container(width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.roseLight.withOpacity(0.3), shape: BoxShape.circle),
              child: const Center(child: Text('🌸', style: TextStyle(fontSize: 18)))),
            title: Text(n.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: Text(n.body, style: const TextStyle(fontSize: 12)),
          )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _NameInputCard extends StatelessWidget {
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.rose,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bir İsim Gir', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.white)),
          const SizedBox(height: 4),
          Text('Her harf bir çiçeğe dönüşür', style: TextStyle(color: AppColors.white.withOpacity(0.8), fontSize: 13)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(letterSpacing: 3, fontWeight: FontWeight.w600, color: AppColors.textDark),
                  decoration: InputDecoration(
                    hintText: '...',
                    hintStyle: TextStyle(color: AppColors.textLight.withOpacity(0.5), letterSpacing: 1, fontSize: 13),
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onSubmitted: (v) => _go(context, v),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _go(context, _ctrl.text),
                child: Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: AppColors.roseDark, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.arrow_forward_rounded, color: AppColors.white, size: 22),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _go(BuildContext context, String val) {
    final cleaned = val.trim();
    if (cleaned.isEmpty) return;
    context.read<AppProvider>().generateBouquet(cleaned);
    Navigator.push(context, MaterialPageRoute(builder: (_) => const BouquetBuilderScreen()));
  }
}

class _FeatureGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      _FeatureItem('🔤', 'Çiçek Alfabesi', 'A\'dan Z\'ye tüm çiçekler', AppColors.greenLight,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AlphabetScreen()))),
      _FeatureItem('💐', 'Buket Tasarla', 'İsmini gir, buket hazır', const Color(0xFFFDF0F5),
          () {
            context.read<AppProvider>().generateBouquet('GÜL');
            Navigator.push(context, MaterialPageRoute(builder: (_) => const BouquetBuilderScreen()));
          }),
    ];

    return Column(
      children: items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: item.onTap,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Text(item.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 16),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 3),
                    Text(item.subtitle, style: Theme.of(context).textTheme.bodySmall),
                  ],
                )),
                const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textLight),
              ],
            ),
          ),
        ),
      )).toList(),
    );
  }
}

class _FeatureItem {
  final String emoji, title, subtitle;
  final Color color;
  final VoidCallback onTap;
  _FeatureItem(this.emoji, this.title, this.subtitle, this.color, this.onTap);
}

class _HeroAnimation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFFFDF0F5),
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
