import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/gorsel_export_service.dart';
import 'social_share_button_grid.dart';

/// Modern paylaşım paneli (Bottom Sheet).
///
/// Açmak için:
/// ```dart
/// ShareSheetWidget.show(context, previewKey: _key, bouquet: bouquet);
/// ```
///
/// Eski [ShareSheet] adıyla uyumluluk için typedef aşağıda tanımlıdır.
class ShareSheetWidget extends StatefulWidget {
  final GlobalKey previewKey;
  final Bouquet bouquet;
  final String? displayName;

  const ShareSheetWidget._({
    required this.previewKey,
    required this.bouquet,
    this.displayName,
  });

  static Future<void> show(
    BuildContext context, {
    required GlobalKey previewKey,
    required Bouquet bouquet,
    String? displayName,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ShareSheetWidget._(
        previewKey: previewKey,
        bouquet: bouquet,
        displayName: displayName,
      ),
    );
  }

  @override
  State<ShareSheetWidget> createState() => _ShareSheetWidgetState();
}

// ── Eski isimle uyumluluk ─────────────────────────────────────
typedef ShareSheet = ShareSheetWidget;

class _ShareSheetWidgetState extends State<ShareSheetWidget> {
  bool _rendering = false;

  RenderRepaintBoundary? get _boundary =>
      widget.previewKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;

  // ── Paylaşım Ana Akışı ────────────────────────────────────

  Future<void> _handleTap(ShareTarget target) async {
    if (_rendering) return;

    final boundary = _boundary;
    if (boundary == null) {
      _toast('Önizleme yakalanamadı', error: true);
      return;
    }

    if (target == ShareTarget.gallery) {
      await _doGallerySave(boundary);
      return;
    }

    await _doShare(target, boundary);
  }

  /// Galeri kayıt: tam busy (render + kayıt birlikte)
  Future<void> _doGallerySave(RenderRepaintBoundary boundary) async {
    setState(() => _rendering = true);
    try {
      final result = await GorselExportService.saveToGallery(
        boundary,
        widget.bouquet,
        displayName: widget.displayName,
      );
      if (!mounted) return;
      if (result == ExportResult.success) {
        Navigator.pop(context);
        _toast('Galeriye kaydedildi 📥');
      } else {
        _toast(GorselExportService.messageFor(result), error: true);
      }
    } finally {
      if (mounted) setState(() => _rendering = false);
    }
  }

  /// Paylaşım: render sırasında loading, sonra sistem paneli
  Future<void> _doShare(
      ShareTarget target, RenderRepaintBoundary boundary) async {
    // 1) Render (loading göster)
    setState(() => _rendering = true);
    Uint8List? bytes;
    try {
      bytes = target == ShareTarget.instagramStory
          ? await GorselExportService.storyBytes(boundary, widget.bouquet,
              displayName: widget.displayName)
          : await GorselExportService.squareBytes(boundary, widget.bouquet,
              displayName: widget.displayName);
    } finally {
      if (mounted) setState(() => _rendering = false);
    }

    if (bytes == null) {
      _toast('Görsel oluşturulamadı. Tekrar deneyin.', error: true);
      return;
    }

    // 2) Paylaş (loading yok — sistem share sheet devralır)
    try {
      await GorselExportService.shareBytes(bytes, target, widget.bouquet);
    } catch (_) {
      if (mounted) _toast('Paylaşım başarısız. Tekrar deneyin.', error: true);
    }
  }

  // ── Toast ────────────────────────────────────────────────

  void _toast(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      backgroundColor: error ? Colors.red.shade600 : AppColors.rose,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14)),
      content: Row(children: [
        Icon(
          error
              ? Icons.error_outline_rounded
              : Icons.check_circle_outline_rounded,
          color: Colors.white,
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            msg,
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13),
          ),
        ),
      ]),
      duration: const Duration(seconds: 3),
    ));
  }

  // ── UI ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Stack(
        children: [
          // ── Ana içerik ──────────────────────────────────
          SafeArea(
            top: false,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(height: 12),

              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Başlık
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(children: [
                  Text(
                    'Tasarımı Paylaş',
                    style: GoogleFonts.poppins(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Bloomix ile tasarladığın buketi sevdiklerinle paylaş',
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: AppColors.textMid,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ]),
              ),
              const SizedBox(height: 26),

              // Sosyal medya ızgarası
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SocialShareButtonGrid(
                  onTap: _handleTap,
                  disabled: _rendering,
                ),
              ),
              const SizedBox(height: 22),

              // Watermark bilgisi
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Text(
                  '🌸  Paylaşılan tüm görsellere "Bloomix ile yapıldı" watermarkı eklenir',
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    color: AppColors.textLight,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ]),
          ),

          // ── Loading Overlay ─────────────────────────────
          if (_rendering)
            const Positioned.fill(
              child: ClipRRect(
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(28)),
                child: _LoadingOverlay(),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Loading Overlay ───────────────────────────────────────────
class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cream.withValues(alpha: 0.92),
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Bloomix spinner
          const SizedBox(
            width: 64,
            height: 64,
            child: Stack(alignment: Alignment.center, children: [
              CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.rose),
              ),
              Text(
                '🌸',
                style: TextStyle(fontSize: 26),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          Text(
            'Görselin hazırlanıyor...',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Buket export ediliyor',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textMid,
            ),
          ),
        ]),
      ),
    );
  }
}
