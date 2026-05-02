import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import 'collection_detail_screen.dart';

/// Koleksiyonum — tüm koleksiyonların listesi + Tüm Tasarımlarım virtual.
/// Üstte "+ Yeni Koleksiyon Oluştur" + sistem favori + custom koleksiyonlar.
class CollectionsScreen extends StatelessWidget {
  const CollectionsScreen({super.key});

  Future<void> _createDialog(BuildContext context) async {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String emoji = '📁';
    final emojis = const [
      '📁','💐','🌸','🌷','🌹','💖','✨','💍','🎁','🌿','🌻','🦋','🌺','🍃'
    ];
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) {
        return StatefulBuilder(builder: (ctx, setSheet) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
                20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 14),
              Text('Yeni Koleksiyon',
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark)),
              const SizedBox(height: 14),
              // Emoji seçici
              SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: emojis.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final e = emojis[i];
                    final sel = e == emoji;
                    return GestureDetector(
                      onTap: () => setSheet(() => emoji = e),
                      child: Container(
                        width: 50,
                        decoration: BoxDecoration(
                          color: sel
                              ? AppColors.rose.withOpacity(0.15)
                              : AppColors.cream,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: sel
                                  ? AppColors.rose
                                  : AppColors.border,
                              width: sel ? 2 : 1),
                        ),
                        child: Center(
                            child:
                                Text(e, style: const TextStyle(fontSize: 22))),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: nameCtrl,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Koleksiyon Adı',
                  hintText: 'Romantik Buketlerim',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Açıklama (opsiyonel)',
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_rounded),
                  label: Text('Oluştur',
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;
                    context.read<AppProvider>().createCollection(
                          name: name,
                          emoji: emoji,
                          description: descCtrl.text.trim().isEmpty
                              ? null
                              : descCtrl.text.trim(),
                        );
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ]),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, prov, _) {
      final allSaved = prov.saved;
      final collections = prov.collections;

      return Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          title: const Text('Koleksiyonum'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_rounded),
              tooltip: 'Yeni Koleksiyon',
              onPressed: () => _createDialog(context),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            // ── Header bilgi ──────────────────────────────────────
            Text(
              'Tasarımların Burada',
              style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark),
            ),
            const SizedBox(height: 4),
            Text(
              '${allSaved.length} kayıtlı tasarım · ${collections.length} koleksiyon',
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textMid,
                  height: 1.5),
            ),
            const SizedBox(height: 22),

            // ── Yeni koleksiyon CTA + Tüm Tasarımlarım ────────────
            Row(children: [
              Expanded(
                child: _NewCollectionCard(onTap: () => _createDialog(context)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AllSavedCard(
                  count: allSaved.length,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const CollectionDetailScreen(virtualAll: true))),
                ),
              ),
            ]),
            const SizedBox(height: 20),

            // ── Koleksiyon listesi ────────────────────────────────
            Text('Koleksiyonlarım',
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark)),
            const SizedBox(height: 12),
            if (collections.isEmpty)
              const SizedBox.shrink()
            else
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.95,
                children: collections
                    .map((c) => _CollectionCard(
                          collection: c,
                          covers: prov
                              .bouquetsInCollection(c.id)
                              .take(4)
                              .toList(),
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => CollectionDetailScreen(
                                        collectionId: c.id,
                                      ))),
                        ))
                    .toList(),
              ),

            if (allSaved.isEmpty) ...[
              const SizedBox(height: 30),
              _EmptyHint(),
            ],
          ],
        ),
      );
    });
  }
}

// ── Card widget'ları ────────────────────────────────────────

class _NewCollectionCard extends StatelessWidget {
  final VoidCallback onTap;
  const _NewCollectionCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppColors.rose.withOpacity(0.5),
              width: 1.5,
              style: BorderStyle.solid),
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.rose.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_rounded,
                    color: AppColors.rose, size: 24),
              ),
              const SizedBox(height: 10),
              Text('Yeni\nKoleksiyon',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.rose,
                      height: 1.2)),
            ]),
      ),
    );
  }
}

class _AllSavedCard extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _AllSavedCard({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        height: 130,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.rose.withOpacity(0.95),
              AppColors.roseDark,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: AppColors.rose.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.inventory_2_rounded,
                  color: AppColors.white, size: 28),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Tüm Tasarımlar',
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                        height: 1.2)),
                Text('$count kayıtlı buket',
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.white.withOpacity(0.85))),
              ]),
            ]),
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  final BouquetCollection collection;
  final List<SavedBouquet> covers;
  final VoidCallback onTap;
  const _CollectionCard({
    required this.collection,
    required this.covers,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Mosaic kapak — ilk 4 buketin renk paleti
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              color: AppColors.cream,
              child: covers.isEmpty
                  ? Center(
                      child: Text(collection.emoji,
                          style: const TextStyle(fontSize: 56)),
                    )
                  : _CoverMosaic(covers: covers),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(collection.emoji,
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(collection.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark)),
                    ),
                  ]),
                  const SizedBox(height: 2),
                  Text('${collection.count} buket',
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textLight)),
                ]),
          ),
        ]),
      ),
    );
  }
}

class _CoverMosaic extends StatelessWidget {
  final List<SavedBouquet> covers;
  const _CoverMosaic({required this.covers});

  @override
  Widget build(BuildContext context) {
    final cells = covers.take(4).toList();
    if (cells.length == 1) {
      return _coverCell(cells[0]);
    }
    if (cells.length == 2) {
      return Row(children: [
        Expanded(child: _coverCell(cells[0])),
        Expanded(child: _coverCell(cells[1])),
      ]);
    }
    if (cells.length == 3) {
      return Column(children: [
        Expanded(child: _coverCell(cells[0])),
        Expanded(child: Row(children: [
          Expanded(child: _coverCell(cells[1])),
          Expanded(child: _coverCell(cells[2])),
        ])),
      ]);
    }
    return Column(children: [
      Expanded(child: Row(children: [
        Expanded(child: _coverCell(cells[0])),
        Expanded(child: _coverCell(cells[1])),
      ])),
      Expanded(child: Row(children: [
        Expanded(child: _coverCell(cells[2])),
        Expanded(child: _coverCell(cells[3])),
      ])),
    ]);
  }

  Widget _coverCell(SavedBouquet s) {
    final color = s.bouquet.flowers.isEmpty
        ? AppColors.cream
        : s.bouquet.flowers.first.color;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.5), color.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(child: Text('🌸', style: TextStyle(fontSize: 22))),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
                color: AppColors.roseLight.withOpacity(0.3),
                shape: BoxShape.circle),
            child: const Center(
                child: Icon(Icons.inventory_2_outlined,
                    size: 40, color: AppColors.rose)),
          ),
          const SizedBox(height: 14),
          Text('Henüz tasarımın yok',
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark)),
          const SizedBox(height: 4),
          Text(
              'Buket tasarlarken 💾 ile kaydet, ❤️ ile favorile, 📤 ile paylaş.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textMid,
                  height: 1.55)),
        ]),
      ),
    );
  }
}
