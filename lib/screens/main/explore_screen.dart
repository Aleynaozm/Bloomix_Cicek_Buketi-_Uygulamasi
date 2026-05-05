import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../data/flower_data.dart';
import '../../data/special_day_data.dart';
import '../../widgets/widgets.dart';
import '../bouquet/free_design_screen.dart';
import '../bouquet/name_input_screen.dart';
import 'category_detail_screen.dart';
import 'special_days_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final filtered = flowerAlphabet.entries
        .where((e) =>
            _search.isEmpty ||
            e.key.contains(_search.toUpperCase()) ||
            e.value.nameTr.toLowerCase().contains(_search.toLowerCase()) ||
            e.value.nameEn.toLowerCase().contains(_search.toLowerCase()) ||
            e.value.meaning.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Keşfet')),
      body: CustomScrollView(
        slivers: [
          // ── Arama ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                decoration: InputDecoration(
                  hintText: 'Çiçek veya anlam ara...',
                  prefixIcon: const Icon(Icons.search,
                      size: 20, color: AppColors.textLight),
                  suffixIcon: _search.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => setState(() => _search = ''))
                      : null,
                ),
              ),
            ),
          ),

          // Arama aktifken sadece sonuçları göster
          if (_search.isNotEmpty) ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              sliver: SliverToBoxAdapter(
                child: Text(
                  '${filtered.length} çiçek bulundu',
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    if (i >= filtered.length) return null;
                    return _FlowerGridCard(flower: filtered[i].value,
                        onTap: () => showFlowerDetail(context, filtered[i].value));
                  },
                  childCount: filtered.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
              ),
            ),
          ],

          // Arama yokken ana içerik
          if (_search.isEmpty) ...[
            // ── Özel Gün Kategorileri ─────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Özel Gün Buketleri',
                        style: Theme.of(context).textTheme.titleLarge),
                    GestureDetector(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const SpecialDaysScreen())),
                      child: Text('Tümünü Gör',
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.rose,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemCount: SpecialDayCategory.values.length,
                  itemBuilder: (ctx, i) {
                    final cat = SpecialDayCategory.values[i];
                    final colors = cat.colors;
                    return GestureDetector(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  CategoryDetailScreen(category: cat))),
                      child: Container(
                        width: 84,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colors[0].withOpacity(0.85),
                              colors[1].withOpacity(0.85),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(cat.emoji,
                                style: const TextStyle(fontSize: 26)),
                            const SizedBox(height: 6),
                            Text(
                              cat.title,
                              style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ── Hızlı Tasarım Kartları ────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                child: Text('Hızlı Başla',
                    style: Theme.of(context).textTheme.titleLarge),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _QuickCard(
                        icon: Icons.palette_outlined,
                        color: AppColors.rose,
                        title: 'Serbest Tasarım',
                        subtitle: 'İstediğin gibi\nbuket oluştur',
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const FreeDesignScreen())),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickCard(
                        icon: Icons.text_fields_rounded,
                        color: AppColors.green,
                        title: 'İsimden Buket',
                        subtitle: 'Çiçek alfabesiyle\nözel anlam yarat',
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const NameInputScreen())),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Çiçek Sözlüğü ────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                child: Text('Çiçek Sözlüğü',
                    style: Theme.of(context).textTheme.titleLarge),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final all = flowerAlphabet.entries.toList();
                    if (i >= all.length) return null;
                    final f = all[i].value;
                    return _FlowerGridCard(
                        flower: f,
                        onTap: () => showFlowerDetail(context, f));
                  },
                  childCount: flowerAlphabet.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Çiçek Kart ───────────────────────────────────────────────────────────────
class _FlowerGridCard extends StatelessWidget {
  final Flower flower;
  final VoidCallback onTap;
  const _FlowerGridCard({required this.flower, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: flower.color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 6),
                child: Image.asset(
                  flower.assetPath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Center(
                    child: Text(flower.letter,
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: flower.color)),
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: flower.color.withOpacity(0.08),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(14)),
              ),
              child: Column(children: [
                Text(flower.letter,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: flower.color)),
                Text(
                  flower.nameTr,
                  style: const TextStyle(
                      fontSize: 9, color: AppColors.textLight),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hızlı Başla Kartı ────────────────────────────────────────────────────────
class _QuickCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(title,
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppColors.textLight,
                    height: 1.4)),
          ],
        ),
      ),
    );
  }
}
