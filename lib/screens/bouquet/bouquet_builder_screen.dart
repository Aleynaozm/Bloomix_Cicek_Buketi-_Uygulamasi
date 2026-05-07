import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/widgets.dart';
import '../../widgets/save_to_collection_sheet.dart';
import '../../widgets/share_sheet.dart';
import '../shop/cart_screen.dart';
import 'free_design_screen.dart';

// ── Ek ücret sabitleri ─────────────────────────────────────
const double _kGiftNoteFee = 50.0;
const double _kNftMintFee  = 299.0;

/// Tasarımım — buket önizleme + siparişe hazırlık ekranı.
class BouquetBuilderScreen extends StatefulWidget {
  const BouquetBuilderScreen({super.key});

  @override
  State<BouquetBuilderScreen> createState() => _BouquetBuilderScreenState();
}

class _BouquetBuilderScreenState extends State<BouquetBuilderScreen> {
  final GlobalKey _previewKey = GlobalKey();
  final TextEditingController _noteCtrl = TextEditingController();

  DateTime? _deliveryDate;
  bool _isNftActive   = false;
  bool _isMinting     = false;
  String? _mintHash;            // Mock blockchain hash

  // ── Fiyat hesapları ───────────────────────────────────────
  bool get _hasNote => _noteCtrl.text.trim().isNotEmpty;
  double get _noteExtra => _hasNote ? _kGiftNoteFee : 0.0;
  double get _nftExtra  => _isNftActive ? _kNftMintFee : 0.0;
  double get _totalExtra => _noteExtra + _nftExtra;

  @override
  void initState() {
    super.initState();
    _noteCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  // ── Teslimat tarihi seçici ─────────────────────────────────
  Future<void> _pickDeliveryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deliveryDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Teslimat Tarihi Seç',
      cancelText: 'İptal',
      confirmText: 'Onayla',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.rose,
            onPrimary: Colors.white,
            surface: AppColors.cream,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _deliveryDate = picked);
  }

  // ── NFT toggle + mock mint simülasyonu ─────────────────────
  Future<void> _toggleNft() async {
    if (_isNftActive) {
      // Kapat
      setState(() {
        _isNftActive = false;
        _mintHash = null;
      });
      return;
    }

    // Aç → yükleme animasyonu → mock onay
    setState(() => _isMinting = true);

    // Simüle blockchain gecikmesi
    await Future.delayed(const Duration(milliseconds: 2200));

    if (!mounted) return;
    final hash = _mockHash();
    setState(() {
      _isNftActive = true;
      _isMinting   = false;
      _mintHash    = hash;
    });

    _toast('Blockchain kaydı oluşturuldu ✅', bg: const Color(0xFF6B48FF));
  }

  /// Simüle edilmiş mock Ethereum hash'i.
  String _mockHash() {
    const chars = '0123456789abcdef';
    final rng = Random();
    final hex = List.generate(16, (_) => chars[rng.nextInt(chars.length)]).join();
    return '0x$hex...';
  }

  // ── Sepete ekle ────────────────────────────────────────────
  void _showAddToCartSheet(Bouquet bouquet, AppProvider prov) {
    if (bouquet.flowers.length < 5) {
      _toast(
        'En az 5 çiçek gerekli. ${5 - bouquet.flowers.length} çiçek daha ekle.',
        bg: const Color(0xFFE08020),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TypeSelectionSheet(
        bouquet: bouquet,
        noteText: _noteCtrl.text.trim(),
        deliveryDate: _deliveryDate,
        isNft: _isNftActive,
        mintHash: _mintHash,
        giftNoteFee: _noteExtra,
        nftMintFee: _nftExtra,
        onSelect: (isLego) {
          Navigator.pop(context);
          prov.addToCart(
            bouquet,
            isLego: isLego,
            giftNote: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
            deliveryDate: _deliveryDate,
            isNft: _isNftActive,
            giftNoteFee: _noteExtra,
            nftMintFee: _nftExtra,
            nftHash: _mintHash,
          );
          _toast('${bouquet.name} sepete eklendi 🛍️');
        },
      ),
    );
  }

  // ── Paylaş ─────────────────────────────────────────────────
  void _share(Bouquet b) =>
      ShareSheet.show(context, previewKey: _previewKey, bouquet: b);

  void _toast(String msg, {Color? bg}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: bg ?? AppColors.rose,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      content: Row(children: [
        const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
        const SizedBox(width: 10),
        Expanded(
          child: Text(msg,
              style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ]),
      duration: const Duration(seconds: 2),
    ));
  }

  // ── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, prov, _) {
      final isFreeDesign = prov.isFreeDesign;
      final placed       = prov.placedFlowers;
      final bouquet      = prov.currentBouquet;
      final isFavorite   = bouquet != null && prov.isFavorite(bouquet.id);
      final cartCount    = prov.cartCount;

      final normalTotal = (bouquet?.normalPrice ?? 0) + _totalExtra;
      final legoTotal   = (bouquet?.price ?? 0) + _totalExtra;

      return Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          backgroundColor: AppColors.cream,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            prov.inputName.isEmpty ? 'Buketim' : prov.inputName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 20,
              color: AppColors.rose,
              letterSpacing: 0.5,
            ),
          ),
          centerTitle: true,
          actions: [
            // ✏ Düzenle
            IconButton(
              tooltip: 'Tasarımı Düzenle',
              icon: const Icon(Icons.edit_rounded, color: AppColors.rose),
              onPressed: bouquet == null
                  ? null
                  : () {
                      prov.loadBouquetForEdit(bouquet);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FreeDesignScreen(
                            initialPlaced: prov.placedFlowers.toList(),
                          ),
                        ),
                      );
                    },
            ),
            // ❤ Favori
            IconButton(
              tooltip: isFavorite ? 'Favorilerden çıkar' : 'Favorile',
              icon: Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_outline_rounded,
                color: AppColors.rose,
              ),
              onPressed: bouquet == null
                  ? null
                  : () {
                      prov.toggleFavorite(bouquet);
                      _toast(isFavorite
                          ? 'Favorilerden çıkarıldı'
                          : 'Favorilere eklendi 💖');
                    },
            ),
            // 💾 Koleksiyon
            IconButton(
              tooltip: 'Koleksiyona Kaydet',
              icon: const Icon(Icons.bookmark_outline_rounded,
                  color: AppColors.rose),
              onPressed: bouquet == null
                  ? null
                  : () => SaveToCollectionSheet.show(context, bouquet),
            ),
            // 📤 Paylaş
            IconButton(
              tooltip: 'Paylaş',
              icon: const Icon(Icons.ios_share_rounded,
                  color: AppColors.rose),
              onPressed: bouquet == null ? null : () => _share(bouquet),
            ),
            // 🛒 Sepet (badge)
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  tooltip: 'Sepetim',
                  icon: const Icon(Icons.shopping_bag_outlined,
                      color: AppColors.rose),
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CartScreen())),
                ),
                if (cartCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                          color: AppColors.rose, shape: BoxShape.circle),
                      constraints:
                          const BoxConstraints(minWidth: 17, minHeight: 17),
                      child: Text(
                        cartCount > 9 ? '9+' : '$cartCount',
                        style: GoogleFonts.poppins(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),

        body: SafeArea(
          top: false,
          child: Column(children: [
            // ── Kanvas ──────────────────────────────────────
            Expanded(
              flex: 5,
              child: RepaintBoundary(
                key: _previewKey,
                child: Container(
                  color: AppColors.cream,
                  child: Column(children: [
                    Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        child: placed.isEmpty
                            ? const Center(
                                child: Text('Çiçek yok',
                                    style: TextStyle(
                                        color: AppColors.textLight)))
                            : BouquetPreview(
                                flowers: prov.flowers,
                                placed: placed.isNotEmpty
                                    ? placed.toList()
                                    : null,
                                ribbon: prov.ribbon,
                                template: prov.template,
                              ),
                      ),
                    ),
                    if (_hasNote)
                      _NotePreview(text: _noteCtrl.text.trim()),
                  ]),
                ),
              ),
            ),

            // ── Alt kaydırılabilir bölüm ─────────────────────
            Expanded(
              flex: 4,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                    16, 8, 16, MediaQuery.of(context).padding.bottom + 16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // Alfabe bilgisi — yalnızca alfabe akışında göster
                  if (!isFreeDesign && prov.flowers.isNotEmpty) ...[
                    Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              for (final f in prov.flowers)
                                TextSpan(
                                  text: f.letter,
                                  style: GoogleFonts.dmSerifDisplay(
                                      fontSize: 32,
                                      color: f.color,
                                      letterSpacing: 6),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 6,
                      runSpacing: 6,
                      children: prov.flowers
                          .map((f) => GestureDetector(
                                onTap: () => showFlowerDetail(context, f),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: f.color.withOpacity(0.10),
                                    borderRadius:
                                        BorderRadius.circular(50),
                                    border: Border.all(
                                        color: f.color.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(f.letter,
                                            style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: f.color)),
                                        const SizedBox(width: 5),
                                        Text(f.nameTr,
                                            style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                color: AppColors.textLight)),
                                      ]),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                  ],


                  // ── Hediye Notu ──────────────────────────────
                  _GiftNoteSection(controller: _noteCtrl),
                  const SizedBox(height: 10),

                  // ── Teslimat Tarihi ──────────────────────────
                  DeliveryDateTile(
                    selectedDate: _deliveryDate,
                    onTap: _pickDeliveryDate,
                    onClear: _deliveryDate == null
                        ? null
                        : () => setState(() => _deliveryDate = null),
                  ),
                  const SizedBox(height: 8),

                  // ── NFT Mint ─────────────────────────────────
                  NFTMintTile(
                    isActive: _isNftActive,
                    isMinting: _isMinting,
                    mintHash: _mintHash,
                    mintFee: _kNftMintFee,
                    onToggle: _isMinting ? null : _toggleNft,
                  ),
                  const SizedBox(height: 12),

                  // ── Fiyat barı ───────────────────────────────
                  if (bouquet != null)
                    _PriceBar(
                      normalTotal: normalTotal,
                      legoTotal: legoTotal,
                      legoCount: bouquet.legoCount,
                      hasNote: _hasNote,
                      noteFee: _kGiftNoteFee,
                      hasNft: _isNftActive,
                      nftFee: _kNftMintFee,
                      hasDelivery: _deliveryDate != null,
                      deliveryDate: _deliveryDate,
                    ),
                  const SizedBox(height: 12),

                  // ── Sepete Ekle butonu ───────────────────────
                  GradientButton(
                    label: 'Sepete Ekle',
                    icon: Icons.add_shopping_cart_rounded,
                    onPressed: bouquet == null
                        ? null
                        : () => _showAddToCartSheet(bouquet, prov),
                  ),
                ]),
              ),
            ),
          ]),
        ),
      );
    });
  }
}

// ══════════════════════════════════════════════════════════════
// MODÜLER WİDGET'LAR
// ══════════════════════════════════════════════════════════════

// ── Hediye Notu Önizleme ────────────────────────────────────
class _NotePreview extends StatelessWidget {
  final String text;
  const _NotePreview({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      decoration: BoxDecoration(
        color: AppColors.cream,
        border:
            Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Column(children: [
        Row(children: [
          const Expanded(
              child: Divider(color: AppColors.rose, thickness: 0.5)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.favorite_rounded,
                size: 12, color: AppColors.rose.withOpacity(0.6)),
          ),
          const Expanded(
              child: Divider(color: AppColors.rose, thickness: 0.5)),
        ]),
        const SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.dancingScript(
            fontSize: 18,
            color: AppColors.rose,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
      ]),
    );
  }
}

// ── Hediye Notu Girişi ───────────────────────────────────────
class _GiftNoteSection extends StatelessWidget {
  final TextEditingController controller;
  const _GiftNoteSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Row(children: [
            const Icon(Icons.mail_outline_rounded,
                size: 17, color: AppColors.rose),
            const SizedBox(width: 8),
            Text('Hediye Notu Ekle',
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            const Spacer(),
            _FeeBadge(label: '+₺${_kGiftNoteFee.toStringAsFixed(0)}'),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: TextField(
            controller: controller,
            maxLines: 2,
            maxLength: 120,
            style: GoogleFonts.poppins(
                fontSize: 13, color: AppColors.textDark),
            decoration: InputDecoration(
              hintText: 'Sevdiklerinize güzel bir mesaj yazın...',
              hintStyle: GoogleFonts.poppins(
                  fontSize: 12, color: AppColors.textLight),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.rose, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              counterStyle: GoogleFonts.poppins(
                  fontSize: 10, color: AppColors.textLight),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: Row(children: [
            const Icon(Icons.info_outline_rounded,
                size: 12, color: AppColors.textLight),
            const SizedBox(width: 4),
            Text('Opsiyonel · Hediye notu ek ücretlidir',
                style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppColors.textLight,
                    fontStyle: FontStyle.italic)),
          ]),
        ),
      ]),
    );
  }
}

// ── Teslimat Tarihi Tile ─────────────────────────────────────
class DeliveryDateTile extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const DeliveryDateTile({
    super.key,
    required this.selectedDate,
    required this.onTap,
    this.onClear,
  });

  String _formatDate(DateTime d) {
    const months = [
      '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final hasDate = selectedDate != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: hasDate
              ? const Color(0xFF3070D0).withOpacity(0.06)
              : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasDate
                ? const Color(0xFF3070D0).withOpacity(0.40)
                : AppColors.border,
            width: hasDate ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF3070D0).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.calendar_month_rounded,
                size: 20, color: Color(0xFF3070D0)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
              Text('Teslimat Tarihi',
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark)),
              Text(
                hasDate
                    ? 'Planlanan: ${_formatDate(selectedDate!)}'
                    : 'Teslimat için bir tarih seç',
                style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: hasDate
                        ? const Color(0xFF3070D0)
                        : AppColors.textLight),
              ),
            ]),
          ),
          if (hasDate && onClear != null)
            GestureDetector(
              onTap: onClear,
              child: const Icon(Icons.close_rounded,
                  size: 18, color: AppColors.textLight),
            )
          else
            const Icon(Icons.chevron_right_rounded,
                size: 20, color: AppColors.textLight),
        ]),
      ),
    );
  }
}

// ── NFT Mint Tile ────────────────────────────────────────────
class NFTMintTile extends StatelessWidget {
  final bool isActive;
  final bool isMinting;
  final String? mintHash;
  final double mintFee;
  final VoidCallback? onToggle;

  const NFTMintTile({
    super.key,
    required this.isActive,
    required this.isMinting,
    required this.mintFee,
    this.mintHash,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    const nftColor = Color(0xFF6B48FF);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isActive
            ? nftColor.withOpacity(0.06)
            : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? nftColor.withOpacity(0.40)
              : AppColors.border,
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Başlık satırı ──────────────────────────────
          Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: nftColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: isMinting
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: nftColor),
                    )
                  : Icon(
                      isActive
                          ? Icons.verified_rounded
                          : Icons.diamond_outlined,
                      size: 20,
                      color: nftColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                Text('NFT Olarak Mint Et',
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark)),
                Text(
                  isMinting
                      ? 'Blockchain kaydı oluşturuluyor...'
                      : isActive
                          ? 'Mint edildi · +₺${mintFee.toStringAsFixed(0)}'
                          : 'Tasarımını blok zincirinde kalıcı yap',
                  style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: isMinting || isActive
                          ? nftColor
                          : AppColors.textLight),
                ),
              ]),
            ),
            // ── Switch ──────────────────────────────────
            GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 46,
                height: 26,
                decoration: BoxDecoration(
                  color: isActive
                      ? nftColor
                      : AppColors.border,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  alignment: isActive
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.all(3),
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: isMinting
                        ? const Padding(
                            padding: EdgeInsets.all(4),
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: nftColor),
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ]),

          // ── Mint ücret rozeti (kapalıyken) ─────────────
          if (!isActive && !isMinting) ...[
            const SizedBox(height: 8),
            Row(children: [
              _FeeBadge(
                label: '+₺${mintFee.toStringAsFixed(0)} Minting Fee',
                color: nftColor,
              ),
            ]),
          ],

          // ── Hash önizleme (mint tamamlandıysa) ─────────
          if (isActive && mintHash != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: nftColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: nftColor.withOpacity(0.25)),
              ),
              child: Row(children: [
                const Icon(Icons.link_rounded,
                    size: 14, color: nftColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    mintHash!,
                    style: GoogleFonts.sourceCodePro(
                        fontSize: 11, color: nftColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.check_circle_rounded,
                    size: 14, color: nftColor),
              ]),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Ücret Rozeti ────────────────────────────────────────────
class _FeeBadge extends StatelessWidget {
  final String label;
  final Color? color;
  const _FeeBadge({required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.rose;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withOpacity(0.30)),
      ),
      child: Text(label,
          style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: c)),
    );
  }
}

// ── Fiyat Barı ───────────────────────────────────────────────
class _PriceBar extends StatelessWidget {
  final double normalTotal;
  final double legoTotal;
  final int legoCount;
  final bool hasNote;
  final double noteFee;
  final bool hasNft;
  final double nftFee;
  final bool hasDelivery;
  final DateTime? deliveryDate;

  const _PriceBar({
    required this.normalTotal,
    required this.legoTotal,
    required this.legoCount,
    required this.hasNote,
    required this.noteFee,
    required this.hasNft,
    required this.nftFee,
    required this.hasDelivery,
    this.deliveryDate,
  });

  @override
  Widget build(BuildContext context) {
    final hasExtras = hasNote || hasNft;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
              Text('🌸 Normal Buket',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: AppColors.textLight)),
              Text('₺${normalTotal.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.rose)),
            ]),
          ),
          Container(width: 1, height: 36, color: AppColors.border),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
              Text('🧱 LEGO · $legoCount brick',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: AppColors.textLight)),
              Text('₺${legoTotal.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF3070D0))),
            ]),
          ),
        ]),

        if (hasExtras) ...[
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),
          if (hasNote)
            _ExtraRow(
                icon: Icons.mail_outline_rounded,
                label: 'Hediye notu',
                fee: noteFee),
          if (hasNft) ...[
            if (hasNote) const SizedBox(height: 4),
            _ExtraRow(
                icon: Icons.diamond_outlined,
                label: 'NFT Minting Fee',
                fee: nftFee,
                color: const Color(0xFF6B48FF)),
          ],
        ],

        if (hasDelivery && deliveryDate != null) ...[
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.calendar_month_rounded,
                size: 13, color: Color(0xFF3070D0)),
            const SizedBox(width: 6),
            Text('Teslimat: ${_fmt(deliveryDate!)}',
                style: GoogleFonts.poppins(
                    fontSize: 11, color: AppColors.textMid)),
          ]),
        ],
      ]),
    );
  }

  static String _fmt(DateTime d) {
    const m = [
      '', 'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
    ];
    return '${d.day} ${m[d.month]} ${d.year}';
  }
}

class _ExtraRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double fee;
  final Color? color;

  const _ExtraRow({
    required this.icon,
    required this.label,
    required this.fee,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.rose;
    return Row(children: [
      Icon(icon, size: 13, color: c),
      const SizedBox(width: 6),
      Expanded(
          child: Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 11, color: AppColors.textMid))),
      Text('+₺${fee.toStringAsFixed(0)}',
          style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: c)),
    ]);
  }
}

// ── Tür Seçim Sayfası ────────────────────────────────────────
class _TypeSelectionSheet extends StatelessWidget {
  final Bouquet bouquet;
  final String noteText;
  final DateTime? deliveryDate;
  final bool isNft;
  final String? mintHash;
  final double giftNoteFee;
  final double nftMintFee;
  final void Function(bool isLego) onSelect;

  const _TypeSelectionSheet({
    required this.bouquet,
    required this.noteText,
    required this.deliveryDate,
    required this.isNft,
    required this.mintHash,
    required this.giftNoteFee,
    required this.nftMintFee,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final extras = giftNoteFee + nftMintFee;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).padding.bottom + 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(height: 20),
        Text('Buket Tipi Seç',
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark)),
        const SizedBox(height: 4),
        Text('Hangi versiyonu sepete eklemek istiyorsun?',
            style: GoogleFonts.poppins(
                fontSize: 12, color: AppColors.textLight)),

        // ── Seçimler özet ────────────────────────────────
        if (noteText.isNotEmpty || isNft || deliveryDate != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.rose.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.rose.withOpacity(0.2)),
            ),
            child: Column(children: [
              if (noteText.isNotEmpty)
                _SummaryRow(
                    icon: Icons.mail_outline_rounded,
                    text: '"$noteText"',
                    extra: '+₺${giftNoteFee.toStringAsFixed(0)}'),
              if (deliveryDate != null)
                _SummaryRow(
                    icon: Icons.calendar_month_rounded,
                    text: _DeliveryDateTileFmt.fmt(deliveryDate!),
                    color: const Color(0xFF3070D0)),
              if (isNft)
                _SummaryRow(
                    icon: Icons.diamond_outlined,
                    text: mintHash != null
                        ? 'NFT · ${mintHash!}'
                        : 'NFT mint',
                    extra: '+₺${nftMintFee.toStringAsFixed(0)}',
                    color: const Color(0xFF6B48FF)),
            ]),
          ),
        ],

        const SizedBox(height: 16),
        _TypeCard(
          emoji: '🌸',
          title: 'Normal Buket',
          subtitle: 'Gerçek çiçeklerle hazırlanır, kapınıza teslim',
          price: '₺${(bouquet.normalPrice + extras).toStringAsFixed(0)}',
          accentColor: AppColors.rose,
          onTap: () => onSelect(false),
        ),
        const SizedBox(height: 12),
        _TypeCard(
          emoji: '🧱',
          title: 'LEGO Buket',
          subtitle: '${bouquet.legoCount} brick · Kalıcı hatıra',
          price: '₺${(bouquet.price + extras).toStringAsFixed(0)}',
          accentColor: const Color(0xFF3070D0),
          onTap: () => onSelect(true),
        ),
      ]),
    );
  }
}

// Tarih formatlama (sheet içinde)
class _DeliveryDateTileFmt {
  static String fmt(DateTime d) {
    const months = [
      '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? extra;
  final Color? color;

  const _SummaryRow(
      {required this.icon,
      required this.text,
      this.extra,
      this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.rose;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Icon(icon, size: 13, color: c),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(fontSize: 11, color: c)),
        ),
        if (extra != null)
          Text(extra!,
              style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: c)),
      ]),
    );
  }
}

class _TypeCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String price;
  final Color accentColor;
  final VoidCallback onTap;

  const _TypeCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: accentColor.withOpacity(0.3), width: 1.5),
        ),
        child: Row(children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
                child:
                    Text(emoji, style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
              Text(title,
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark)),
              Text(subtitle,
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: AppColors.textLight)),
            ]),
          ),
          Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
            Text(price,
                style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: accentColor)),
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(12)),
              child: Text('Ekle',
                  style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ]),
        ]),
      ),
    );
  }
}
