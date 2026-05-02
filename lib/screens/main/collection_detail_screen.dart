import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/saved_bouquet_card.dart';
import '../bouquet/bouquet_builder_screen.dart';

/// Bir koleksiyonun (veya "Tüm Tasarımlar" virtual'ının) detay ekranı.
/// • virtualAll=true → tüm saved buketleri gösterir, edit/sil yok
/// • collectionId verilirse → o koleksiyonun içeriğini gösterir
class CollectionDetailScreen extends StatelessWidget {
  final String? collectionId;
  final bool virtualAll;

  const CollectionDetailScreen({
    super.key,
    this.collectionId,
    this.virtualAll = false,
  }) : assert(collectionId != null || virtualAll == true);

  Future<void> _renameDialog(
      BuildContext context, BouquetCollection c) async {
    final nameCtrl = TextEditingController(text: c.name);
    final descCtrl = TextEditingController(text: c.description ?? '');
    String emoji = c.emoji;
    final emojis = const [
      '📁','💐','🌸','🌷','🌹','💖','✨','💍','🎁','🌿','🌻','🦋','🌺','🍃'
    ];
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (sheetCtx) {
        return StatefulBuilder(builder: (ctx, setSheet) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
                20, 16, 20, MediaQuery.of(sheetCtx).viewInsets.bottom + 24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 14),
              Text('Koleksiyonu Düzenle',
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark)),
              const SizedBox(height: 14),
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
                decoration:
                    const InputDecoration(labelText: 'Koleksiyon Adı'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 2,
                decoration:
                    const InputDecoration(labelText: 'Açıklama (opsiyonel)'),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_rounded),
                  label: Text('Kaydet',
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;
                    context.read<AppProvider>().renameCollection(c.id,
                        name: name,
                        emoji: emoji,
                        description: descCtrl.text.trim().isEmpty
                            ? null
                            : descCtrl.text.trim());
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

  Future<void> _confirmDelete(
      BuildContext context, BouquetCollection c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Koleksiyonu Sil?'),
        content: Text(
            '"${c.name}" koleksiyonu silinecek. Buketler kütüphanede kalır.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Vazgeç')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil',
                style: TextStyle(color: AppColors.rose)),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<AppProvider>().deleteCollection(c.id);
      Navigator.pop(context);
    }
  }

  Future<void> _shareCollection(
      BuildContext context, String title, List<SavedBouquet> items) async {
    final lines = items
        .map((s) =>
            '• ${s.bouquet.name}  (${s.bouquet.legoCount} brick · ${s.bouquet.size.label})')
        .join('\n');
    final text = items.isEmpty
        ? '🌸 Bloomix koleksiyonum: "$title" (boş)'
        : '🌸 Bloomix koleksiyonum: "$title"\n\n$lines\n\nBloomix ile sen de tasarla.';
    await Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, prov, _) {
      final BouquetCollection? collection =
          collectionId == null ? null : _findCollection(prov, collectionId!);
      final List<SavedBouquet> items = virtualAll
          ? prov.saved.toList().reversed.toList()
          : (collection == null
              ? const []
              : prov.bouquetsInCollection(collection.id));
      final title = virtualAll
          ? 'Tüm Tasarımlarım'
          : (collection?.name ?? 'Koleksiyon');
      final emoji =
          virtualAll ? '📦' : (collection?.emoji ?? '📁');
      final canEdit = !virtualAll &&
          collection != null &&
          !collection.isSystem;
      final canDelete = canEdit;

      return Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          title: Text('$emoji  $title'),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_rounded),
              tooltip: 'Paylaş',
              onPressed: () => _shareCollection(context, title, items),
            ),
            if (canEdit)
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Düzenle',
                onPressed: () => _renameDialog(context, collection),
              ),
            if (canDelete)
              IconButton(
                icon:
                    const Icon(Icons.delete_outline_rounded, color: Colors.red),
                tooltip: 'Sil',
                onPressed: () => _confirmDelete(context, collection),
              ),
          ],
        ),
        body: items.isEmpty
            ? _EmptyState(title: title)
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  // Header
                  if (collection?.description != null) ...[
                    Text(collection!.description!,
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.textMid,
                            height: 1.55)),
                    const SizedBox(height: 8),
                  ],
                  Text('${items.length} buket',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),

                  // Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.72,
                    children: items
                        .map((s) => SavedBouquetCard(
                              saved: s,
                              showFavorite: true,
                              isFavorite: prov.isInCollection(
                                  s.id, 'sys_favorites'),
                              onFavoriteToggle: () =>
                                  prov.toggleFavorite(s.bouquet),
                              onLongPress: () => _itemActions(
                                  context, prov, s, collection),
                              onTap: () => _previewSaved(context, prov, s),
                            ))
                        .toList(),
                  ),
                ],
              ),
      );
    });
  }

  BouquetCollection? _findCollection(AppProvider prov, String id) {
    for (final c in prov.collections) {
      if (c.id == id) return c;
    }
    return null;
  }

  void _previewSaved(
      BuildContext context, AppProvider prov, SavedBouquet s) {
    // Saved'i editöre yükleyip BouquetBuilder'a git
    prov.loadTemplateBouquet(
      name: s.bouquet.name,
      flowers: s.bouquet.flowers,
      ribbon: s.bouquet.ribbon,
      size: s.bouquet.size,
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BouquetBuilderScreen()),
    );
  }

  Future<void> _itemActions(BuildContext context, AppProvider prov,
      SavedBouquet s, BouquetCollection? c) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (sheetCtx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 12),
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 14),
          Text(s.bouquet.name,
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark)),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.share_rounded, color: AppColors.rose),
            title: const Text('Paylaş'),
            onTap: () {
              Navigator.pop(sheetCtx);
              _shareSavedBouquet(context, s);
            },
          ),
          if (c != null && !c.isSystem)
            ListTile(
              leading: const Icon(Icons.remove_circle_outline_rounded,
                  color: Colors.red),
              title: Text('Bu koleksiyondan çıkar'),
              onTap: () {
                prov.removeFromCollection(s.id, c.id);
                Navigator.pop(sheetCtx);
              },
            ),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            title: const Text('Kütüphaneden tamamen sil'),
            onTap: () {
              prov.unsaveBouquet(s.id);
              Navigator.pop(sheetCtx);
            },
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  Future<void> _shareSavedBouquet(
      BuildContext context, SavedBouquet s) async {
    final b = s.bouquet;
    final text =
        '🌸 Bloomix tasarımım: ${b.name}\n${b.legoCount} brick · ${b.size.label}\n₺${b.price.toStringAsFixed(0)}\n\nBloomix ile sen de tasarla.';
    await Share.share(text);
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  const _EmptyState({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
                color: AppColors.roseLight.withOpacity(0.4),
                shape: BoxShape.circle),
            child: const Center(
                child: Icon(Icons.collections_bookmark_outlined,
                    size: 48, color: AppColors.rose)),
          ),
          const SizedBox(height: 16),
          Text('"$title" boş',
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark)),
          const SizedBox(height: 6),
          Text(
              'Buket tasarlarken kalp, kaydet veya bu koleksiyona ekle ile buraya buket gelir.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textMid,
                  height: 1.55)),
        ]),
      ),
    );
  }
}
