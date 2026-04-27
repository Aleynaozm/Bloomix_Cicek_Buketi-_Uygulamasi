import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/flower_data.dart';
import '../../widgets/widgets.dart';
import '../bouquet/alphabet_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _search = '';

  final _trendNames = ['AYŞE','EMİR','LALE','MERAL','SUDE','CAN','HIRA','YUSUF','ELİF','BORA'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keşfet')),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Search
              TextField(
                onChanged: (v) => setState(() => _search = v),
                decoration: InputDecoration(
                  hintText: 'Çiçek veya harf ara...',
                  prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textLight),
                  suffixIcon: _search.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () => setState(() => _search = ''))
                      : null,
                ),
              ),
              const SizedBox(height: 24),

              if (_search.isEmpty) ...[
                // Trending names
                SectionHeader(title: 'Trend İsimler', action: 'Alfabeye Git',
                  onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AlphabetScreen()))),
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, children: _trendNames.map((n) =>
                  ActionChip(
                    label: Text(n, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1)),
                    backgroundColor: AppColors.roseLight.withOpacity(0.3),
                    side: BorderSide(color: AppColors.rose.withOpacity(0.3)),
                    onPressed: () {},
                  )
                ).toList()),
                const SizedBox(height: 24),
                SectionHeader(title: 'Tüm Çiçekler'),
                const SizedBox(height: 14),
              ],
            ]),
          )),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final entries = flowerAlphabet.entries
                      .where((e) => _search.isEmpty ||
                          e.key.contains(_search.toUpperCase()) ||
                          e.value.nameTr.toLowerCase().contains(_search.toLowerCase()) ||
                          e.value.meaning.toLowerCase().contains(_search.toLowerCase()))
                      .toList();
                  if (i >= entries.length) return null;
                  final f = entries[i].value;
                  return GestureDetector(
                    onTap: () => showFlowerDetail(context, f),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: f.color.withOpacity(0.2)),
                      ),
                      child: Column(children: [
                        Expanded(child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 12, 10, 4),
                          child: FlowerCard(flower: f, size: 60),
                        )),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: f.color.withOpacity(0.08),
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                          ),
                          child: Column(children: [
                            Text(f.letter, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: f.color)),
                            Text(f.nameTr, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                          ]),
                        ),
                      ]),
                    ),
                  );
                },
                childCount: flowerAlphabet.entries
                    .where((e) => _search.isEmpty ||
                        e.key.contains(_search.toUpperCase()) ||
                        e.value.nameTr.toLowerCase().contains(_search.toLowerCase()))
                    .length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, childAspectRatio: 0.72,
                crossAxisSpacing: 10, mainAxisSpacing: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
