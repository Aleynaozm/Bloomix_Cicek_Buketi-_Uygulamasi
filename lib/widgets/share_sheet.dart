import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import 'bouquet_exporter.dart';

/// Paylaşım/export sheet — 3 mod:
/// • PNG İndir → galeriye watermark'lı kare PNG kaydet
/// • Hikaye Paylaş → 9:16 hikaye formatında paylaş (Instagram/WhatsApp)
/// • Hızlı Paylaş → kare PNG'i tüm uygulamalarla paylaş
class ShareSheet extends StatefulWidget {
  /// Buket önizlemesinin RepaintBoundary'sinin GlobalKey'i.
  final GlobalKey previewKey;
  final Bouquet bouquet;

  const ShareSheet._({
    required this.previewKey,
    required this.bouquet,
  });

  static Future<void> show(
    BuildContext context, {
    required GlobalKey previewKey,
    required Bouquet bouquet,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) =>
          ShareSheet._(previewKey: previewKey, bouquet: bouquet),
    );
  }

  @override
  State<ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<ShareSheet> {
  bool _busy = false;
  String _busyMsg = '';

  RenderRepaintBoundary? get _boundary {
    final ctx = widget.previewKey.currentContext;
    return ctx?.findRenderObject() as RenderRepaintBoundary?;
  }

  void _toast(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? Colors.red.shade600 : AppColors.rose,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        content: Row(children: [
          Icon(error ? Icons.error_outline : Icons.check_circle_outline_rounded,
              color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(msg,
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ]),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _saveToGallery() async {
    final boundary = _boundary;
    if (boundary == null) {
      _toast('Önizleme yakalanamadı', error: true);
      return;
    }
    setState(() {
      _busy = true;
      _busyMsg = 'PNG hazırlanıyor...';
    });
    try {
      final bytes = await BouquetExporter.renderSquare(
        boundary: boundary,
        bouquet: widget.bouquet,
      );
      if (bytes == null) {
        _toast('PNG oluşturulamadı', error: true);
        return;
      }
      // Galeri izni iste
      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        final granted = await Gal.requestAccess(toAlbum: true);
        if (!granted) {
          _toast('Galeri izni reddedildi', error: true);
          return;
        }
      }
      await Gal.putImageBytes(bytes,
          name: 'bloomix_${widget.bouquet.id}', album: 'Bloomix');
      if (!mounted) return;
      Navigator.pop(context);
      _toast('Galeriye kaydedildi 📥');
    } on GalException catch (e) {
      _toast('Hata: ${e.type.message}', error: true);
    } catch (e) {
      _toast('Beklenmeyen hata oluştu', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _shareStory() async {
    final boundary = _boundary;
    if (boundary == null) {
      _toast('Önizleme yakalanamadı', error: true);
      return;
    }
    setState(() {
      _busy = true;
      _busyMsg = 'Hikaye hazırlanıyor...';
    });
    try {
      final bytes = await BouquetExporter.renderStory(
        boundary: boundary,
        bouquet: widget.bouquet,
      );
      if (bytes == null) {
        _toast('Hikaye oluşturulamadı', error: true);
        return;
      }
      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/bloomix_story_${widget.bouquet.id}_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);
      if (!mounted) return;
      Navigator.pop(context);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text:
            '🌸 Bloomix tasarımım: ${widget.bouquet.name} · ${widget.bouquet.legoCount} brick',
        subject: 'Bloomix Buket',
      );
    } catch (e) {
      _toast('Hikaye paylaşılamadı', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _quickShare() async {
    final boundary = _boundary;
    if (boundary == null) {
      _toast('Önizleme yakalanamadı', error: true);
      return;
    }
    setState(() {
      _busy = true;
      _busyMsg = 'PNG hazırlanıyor...';
    });
    try {
      final bytes = await BouquetExporter.renderSquare(
        boundary: boundary,
        bouquet: widget.bouquet,
      );
      if (bytes == null) {
        _toast('PNG oluşturulamadı', error: true);
        return;
      }
      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/bloomix_${widget.bouquet.id}_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);
      if (!mounted) return;
      Navigator.pop(context);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text:
            '🌸 Bloomix tasarımım: ${widget.bouquet.name}\n${widget.bouquet.legoCount} brick · ${widget.bouquet.size.label} · ₺${widget.bouquet.price.toStringAsFixed(0)}\n\nBloomix ile sen de tasarla.',
      );
    } catch (e) {
      _toast('Paylaşılamadı', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 12),
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.rose.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.ios_share_rounded,
                    color: AppColors.rose),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tasarımı Paylaş',
                          style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark)),
                      Text('Bloomix watermark otomatik eklenir',
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.textMid)),
                    ]),
              ),
            ]),
          ),
          const SizedBox(height: 18),

          // ── 3 ana eylem ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(children: [
              _ActionTile(
                icon: Icons.download_rounded,
                title: 'PNG İndir',
                subtitle: 'Galerine kaydet',
                gradient: const [
                  Color(0xFFFFB8D4),
                  Color(0xFFFF74B3),
                ],
                onTap: _busy ? null : _saveToGallery,
              ),
              const SizedBox(height: 10),
              _ActionTile(
                icon: Icons.auto_stories_rounded,
                title: 'Hikaye Paylaş',
                subtitle: '9:16 marka tasarımı',
                gradient: const [
                  Color(0xFFE8C8E0),
                  Color(0xFFB060B0),
                ],
                badge: 'Önerilen',
                onTap: _busy ? null : _shareStory,
              ),
              const SizedBox(height: 10),
              _ActionTile(
                icon: Icons.send_rounded,
                title: 'Hızlı Paylaş',
                subtitle: 'WhatsApp, mesaj, e-posta...',
                gradient: const [
                  Color(0xFFC5D9F0),
                  Color(0xFF3070D0),
                ],
                onTap: _busy ? null : _quickShare,
              ),
            ]),
          ),
          const SizedBox(height: 16),

          // ── Loading durumu ─────────────────────────────────
          if (_busy) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(children: [
                const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.rose)),
                const SizedBox(width: 12),
                Text(_busyMsg,
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: AppColors.textMid)),
              ]),
            ),
            const SizedBox(height: 12),
          ],

          // ── Watermark info ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.rose.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                const Icon(Icons.info_outline_rounded,
                    size: 16, color: AppColors.rose),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tüm görsellere "🌸 Bloomix ile yapıldı" markası eklenir.',
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: AppColors.textMid, height: 1.4),
                  ),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final String? badge;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Opacity(
        opacity: disabled ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(title,
                          style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark)),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.rose.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(badge!,
                              style: GoogleFonts.poppins(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.rose)),
                        ),
                      ],
                    ]),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.textMid)),
                  ]),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textLight),
          ]),
        ),
      ),
    );
  }
}
