import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/models.dart';
import '../widgets/bouquet_exporter.dart';

/// Paylaşım ve galeri kayıt sonucu.
enum ShareResult { success, permissionDenied, renderFailed, error }

/// Bloomix paylaşım servisi — tüm export/paylaş işlemlerinin tek noktası.
///
/// Web'de [gal] ve [dart:io] çalışmadığı için [kIsWeb] ile ayrıştırılmıştır:
/// • Web  → [Share.shareXFiles] + [XFile.fromData] (tarayıcı indir/paylaş dialogu)
/// • Mobil → [Gal] (galeri) / temp-file + [Share.shareXFiles] (share sheet)
class ShareService {
  ShareService._(); // instantiate edilemez

  // ─────────────────────────────────────────────────────────
  // PNG İNDİR → Galeri (mobil) / Tarayıcı indir (web)
  // ─────────────────────────────────────────────────────────

  static Future<ShareResult> saveToGallery(
    RenderRepaintBoundary boundary,
    Bouquet bouquet,
  ) async {
    final bytes = await BouquetExporter.renderSquare(
      boundary: boundary,
      bouquet: bouquet,
    );
    if (bytes == null) return ShareResult.renderFailed;

    // ── Web ──────────────────────────────────────────────
    if (kIsWeb) {
      try {
        await Share.shareXFiles([
          XFile.fromData(
            bytes,
            name:
                'bloomix_${bouquet.id}_${DateTime.now().millisecondsSinceEpoch}.png',
            mimeType: 'image/png',
          ),
        ]);
        return ShareResult.success;
      } catch (_) {
        return ShareResult.error;
      }
    }

    // ── Mobil ────────────────────────────────────────────
    try {
      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        final granted = await Gal.requestAccess(toAlbum: true);
        if (!granted) return ShareResult.permissionDenied;
      }
      await Gal.putImageBytes(
        bytes,
        name:
            'bloomix_${bouquet.id}_${DateTime.now().millisecondsSinceEpoch}',
        album: 'Bloomix',
      );
      return ShareResult.success;
    } on GalException {
      return ShareResult.permissionDenied;
    } catch (_) {
      return ShareResult.error;
    }
  }

  // ─────────────────────────────────────────────────────────
  // HİKAYE PAYLAŞ → 9:16
  // ─────────────────────────────────────────────────────────

  static Future<ShareResult> shareAsStory(
    RenderRepaintBoundary boundary,
    Bouquet bouquet,
  ) async {
    final bytes = await BouquetExporter.renderStory(
      boundary: boundary,
      bouquet: bouquet,
    );
    if (bytes == null) return ShareResult.renderFailed;

    try {
      final xFile = kIsWeb
          ? XFile.fromData(
              bytes,
              name: 'bloomix_story_${bouquet.id}.png',
              mimeType: 'image/png',
            )
          : XFile(
              (await _writeTempFile(bytes,
                      name: 'bloomix_story_${bouquet.id}'))
                  .path,
              mimeType: 'image/png',
            );

      await Share.shareXFiles(
        [xFile],
        text:
            '🌸 Bloomix tasarımım: ${bouquet.name} · ${bouquet.legoCount} brick',
        subject: 'Bloomix Buket',
      );
      return ShareResult.success;
    } catch (_) {
      return ShareResult.error;
    }
  }

  // ─────────────────────────────────────────────────────────
  // HIZLI PAYLAŞ → WhatsApp / Mesaj / E-posta
  // ─────────────────────────────────────────────────────────

  static Future<ShareResult> shareQuick(
    RenderRepaintBoundary boundary,
    Bouquet bouquet,
  ) async {
    final bytes = await BouquetExporter.renderSquare(
      boundary: boundary,
      bouquet: bouquet,
    );
    if (bytes == null) return ShareResult.renderFailed;

    try {
      final xFile = kIsWeb
          ? XFile.fromData(
              bytes,
              name: 'bloomix_${bouquet.id}.png',
              mimeType: 'image/png',
            )
          : XFile(
              (await _writeTempFile(bytes, name: 'bloomix_${bouquet.id}'))
                  .path,
              mimeType: 'image/png',
            );

      await Share.shareXFiles(
        [xFile],
        text: '🌸 Bloomix tasarımım: ${bouquet.name}\n'
            '${bouquet.legoCount} brick · ₺${bouquet.price.toStringAsFixed(0)}\n\n'
            'Bloomix ile sen de tasarla.',
      );
      return ShareResult.success;
    } catch (_) {
      return ShareResult.error;
    }
  }

  // ─────────────────────────────────────────────────────────
  // SADECE RENDER ET → Uint8List döner (test/önizleme için)
  // ─────────────────────────────────────────────────────────

  static Future<Uint8List?> renderSquareBytes(
    RenderRepaintBoundary boundary,
    Bouquet bouquet,
  ) =>
      BouquetExporter.renderSquare(boundary: boundary, bouquet: bouquet);

  static Future<Uint8List?> renderStoryBytes(
    RenderRepaintBoundary boundary,
    Bouquet bouquet,
  ) =>
      BouquetExporter.renderStory(boundary: boundary, bouquet: bouquet);

  // ─────────────────────────────────────────────────────────
  // YARDIMCI: Geçici dosyaya yaz (yalnızca mobil çağrılır)
  // ─────────────────────────────────────────────────────────

  static Future<File> _writeTempFile(List<int> bytes,
      {required String name}) async {
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/${name}_${DateTime.now().millisecondsSinceEpoch}.png';
    return File(path).writeAsBytes(bytes);
  }

  // ─────────────────────────────────────────────────────────
  // MESAJ ÜRETİCİ
  // ─────────────────────────────────────────────────────────

  static String messageFor(ShareResult result) {
    switch (result) {
      case ShareResult.success:
        return 'İşlem başarıyla tamamlandı';
      case ShareResult.permissionDenied:
        return 'Galeri izni reddedildi. Ayarlardan izin verin.';
      case ShareResult.renderFailed:
        return 'Görsel oluşturulamadı. Tekrar deneyin.';
      case ShareResult.error:
        return 'Beklenmeyen bir hata oluştu.';
    }
  }
}
