import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';

/// Bouquet'i koleksiyonlara ekleyen bottom sheet.
/// Multi-select. Tüm aktif checkbox'lar uygulandığında "Tamam" basılır.
/// Yeni koleksiyon oluşturma da burada — inline expand.
class SaveToCollectionSheet extends StatefulWidget {
  /// Koleksiyonlara eklenecek/çıkarılacak bouquet.
  /// Henüz saved değilse otomatik olarak save edilir.
  final Bouquet bouquet;
  const SaveToCollectionSheet({super.key, required this.bouquet});

  static Future<void> show(BuildContext context, Bouquet bouquet) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => SaveToCollectionSheet(bouquet: bouquet),
    );
  }

  @override
  State<SaveToCollectionSheet> createState() => _SaveToCollectionSheetState();
}

class _SaveToCollectionSheetState extends State<SaveToCollectionSheet> {
  late String _savedId;
  late Set<String> _selected;
  bool _showCreate = false;
  final _newNameCtrl = TextEditingController();
  String _newEmoji = '📁';

  static const _emojis = [
    '📁','💐','🌸','🌷','🌹','💖','✨','💍','🎁','🌿','🌻','🦋','🌺','🍃'
  ];

  @override
  void initState() {
    super.initState();
    final prov = context.read<AppProvider>();
    // Buket henüz kayıtlı değilse otomatik kaydet (sheet açıldığında).
    _savedId = prov.saveBouquet(widget.bouquet);
    _selected = prov.collections
        .where((c) => c.savedBouquetIds.contains(_savedId))
        .map((c) => c.id)
        .toSet();
  }

  @override
  void dispose() {
    _newNameCtrl.dispose();
    super.dispose();
  }

  void _toggle(String collectionId) {
    setState(() {
      if (_selected.contains(collectionId)) {
        _selected.remove(collectionId);
      } else {
        _selected.add(collectionId);
      }
    });
  }

  void _commit() {
    final prov = context.read<AppProvider>();
    for (final c in prov.collections) {
      final wasIn = c.savedBouquetIds.contains(_savedId);
      final shouldBeIn = _selected.contains(c.id);
      if (wasIn && !shouldBeIn) {
        prov.removeFromCollection(_savedId, c.id);
      } else if (!wasIn && shouldBeIn) {
        prov.addToCollection(_savedId, c.id);
      }
    }
    Navigator.pop(context);
  }

  void _createNew() {
    final name = _newNameCtrl.text.trim();
    if (name.isEmpty) return;
    final prov = context.read<AppProvider>();
    final id = prov.createCollection(name: name, emoji: _newEmoji);
    setState(() {
      _selected.add(id);
      _showCreate = false;
      _newNameCtrl.clear();
      _newEmoji = '📁';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, prov, _) {
      final cols = prov.collections;
      return Padding(
        padding: EdgeInsets.fromLTRB(
            0, 0, 0, MediaQuery.of(context).viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.78),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(height: 12),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Koleksiyona Ekle',
                            style: GoogleFonts.poppins(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark)),
                        Text(widget.bouquet.name,
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textLight)),
                      ]),
                ),
                TextButton(
                    onPressed: _commit,
                    child: Text('Tamam',
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.rose))),
              ]),
            ),
            const SizedBox(height: 8),

            // Listeler
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  ...cols.map((c) => _CollectionTile(
                        collection: c,
                        selected: _selected.contains(c.id),
                        onTap: () => _toggle(c.id),
                      )),

                  // Yeni koleksiyon — inline expand
                  if (!_showCreate)
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.cream,
                        child: Icon(Icons.add_rounded,
                            color: AppColors.rose),
                      ),
                      title: Text('Yeni Koleksiyon Oluştur',
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.rose)),
                      onTap: () => setState(() => _showCreate = true),
                    )
                  else
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.cream,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Emoji seçici
                            SizedBox(
                              height: 44,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _emojis.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 6),
                                itemBuilder: (_, i) {
                                  final e = _emojis[i];
                                  final sel = e == _newEmoji;
                                  return GestureDetector(
                                    onTap: () =>
                                        setState(() => _newEmoji = e),
                                    child: Container(
                                      width: 44,
                                      decoration: BoxDecoration(
                                        color: sel
                                            ? AppColors.rose.withOpacity(0.15)
                                            : AppColors.white,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        border: Border.all(
                                            color: sel
                                                ? AppColors.rose
                                                : AppColors.border,
                                            width: sel ? 2 : 1),
                                      ),
                                      child: Center(
                                          child: Text(e,
                                              style: const TextStyle(
                                                  fontSize: 20))),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _newNameCtrl,
                              autofocus: true,
                              textCapitalization:
                                  TextCapitalization.sentences,
                              decoration: const InputDecoration(
                                hintText: 'Romantik Buketlerim',
                                isDense: true,
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () => setState(() {
                                    _showCreate = false;
                                    _newNameCtrl.clear();
                                  }),
                                  child: const Text('İptal'),
                                ),
                              ),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _createNew,
                                  child: const Text('Oluştur'),
                                ),
                              ),
                            ]),
                          ]),
                    ),
                ],
              ),
            ),
          ]),
        ),
      );
    });
  }
}

class _CollectionTile extends StatelessWidget {
  final BouquetCollection collection;
  final bool selected;
  final VoidCallback onTap;
  const _CollectionTile(
      {required this.collection,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: selected
            ? AppColors.rose
            : AppColors.cream,
        child: Text(collection.emoji,
            style: const TextStyle(fontSize: 18)),
      ),
      title: Text(collection.name,
          style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark)),
      subtitle: Text('${collection.count} buket',
          style: GoogleFonts.poppins(
              fontSize: 11, color: AppColors.textLight)),
      trailing: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? AppColors.rose : Colors.transparent,
          border: Border.all(
              color: selected ? AppColors.rose : AppColors.textLight,
              width: 2),
        ),
        child: selected
            ? const Icon(Icons.check_rounded,
                color: Colors.white, size: 16)
            : null,
      ),
      onTap: onTap,
    );
  }
}
