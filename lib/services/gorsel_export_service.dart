import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/models.dart';
import '../utils/web_download.dart';
import '../widgets/bouquet_exporter.dart';

// ── Sonuç ────────────────────────────────────────────────────
enum ExportResult { success, permissionDenied, renderFailed, appNotFound, error }

// ── Paylaşım Hedefi ──────────────────────────────────────────
enum ShareTarget {
  instagramStory,
  whatsapp,
  messages,
  email,
  gallery,
  generic,
}

/// GorselExportService — render + paylaşım mantığının tek noktası.
///
/// PNG tasarımı: buket + "Bloomix ile oluşturuldu" (fiyat/brick YOK).
///
/// Web  → triggerWebDownload() — dart:html Blob anchor ile direkt indirme.
///         Tüm butonlar aynı PNG'yi indirir (native app açılamaz).
/// Mobil → Share.shareXFiles — sistem native share sheet,
///         Instagram/WhatsApp/Mail sistem listesinde görünür.
class GorselExportService {
  GorselExportService._();

  // Web'de 2.0× (1.5× yerine) — 1080px canvas için daha iyi kaynak kalitesi.
  // Mobil'de 3.0× (Retina/OLED ekranlar için tam çözünürlük).
  static double get _pixelRatio => kIsWeb ? 2.0 : 3.0;

  // ── Render ────────────────────────────────────────────────

  /// Kare PNG bytes'ı (isim + watermark dahil).
  static Future<Uint8List?> squareBytes(
    RenderRepaintBoundary boundary,
    Bouquet bouquet, {
    String? displayName,
  }) =>
      BouquetExporter.renderSquare(
        boundary: boundary,
        bouquet: bouquet,
        displayName: displayName ?? bouquet.name,
        pixelRatio: _pixelRatio,
      );

  /// 9:16 hikaye PNG bytes'ı.
  static Future<Uint8List?> storyBytes(
    RenderRepaintBoundary boundary,
    Bouquet bouquet, {
    String? displayName,
  }) =>
      BouquetExporter.renderStory(
        boundary: boundary,
        bouquet: bouquet,
        displayName: displayName ?? bouquet.name,
        pixelRatio: _pixelRatio,
      );

  // ── Galeriye Kaydet ───────────────────────────────────────

  static Future<ExportResult> saveToGallery(
    RenderRepaintBoundary boundary,
    Bouquet bouquet, {
    String? displayName,
  }) async {
    final bytes = await squareBytes(boundary, bouquet,
        displayName: displayName);
    if (bytes == null) return ExportResult.renderFailed;

    if (kIsWeb) {
      // Web: dart:html Blob anchor ile doğrudan indirme
      try {
        triggerWebDownload(bytes, 'bloomix_${bouquet.id}_${_ts()}.png');
        return ExportResult.success;
      } catch (_) {
        return ExportResult.error;
      }
    }

    // Mobil: Gal kütüphanesi
    try {
      if (!await Gal.hasAccess(toAlbum: true)) {
        if (!await Gal.requestAccess(toAlbum: true)) {
          return ExportResult.permissionDenied;
        }
      }
      await Gal.putImageBytes(
        bytes,
        name: 'bloomix_${bouquet.id}_${_ts()}',
        album: 'Bloomix',
      );
      return ExportResult.success;
    } on GalException {
      return ExportResult.permissionDenied;
    } catch (_) {
      return ExportResult.error;
    }
  }

  // ── Bytes ile Paylaş ──────────────────────────────────────

  /// Render edilmiş [bytes]'ı [target] platforma gönderir.
  /// Web'de ek olarak url_launcher ile hedef uygulama açılmaya çalışılır.
  static Future<void> shareBytes(
    Uint8List bytes,
    ShareTarget target,
    Bouquet bouquet,
  ) async {
    switch (target) {
      case ShareTarget.instagramStory:
        await _shareInstagram(bytes, bouquet);
        break;
      case ShareTarget.whatsapp:
        await _shareWhatsApp(bytes, bouquet);
        break;
      case ShareTarget.messages:
        await _shareMessages(bytes, bouquet);
        break;
      case ShareTarget.email:
        await _shareEmail(bytes, bouquet);
        break;
      case ShareTarget.generic:
      default:
        await _shareGeneric(bytes, bouquet);
        break;
    }
  }

  // ── Platform-özel paylaşım ────────────────────────────────
  //
  // Tüm hedefler tek akış: görsel oluştur → XFile → Share.shareXFiles
  // Sistem native share sheet açılır; kullanıcı uygulamayı oradan seçer.
  // Instagram Hikaye → 9:16 format,  Diğerleri → kare format.

  /// Web → PNG indir. Mobil → sistem share sheet (Instagram/WA listede görünür).
  static Future<void> _shareInstagram(
      Uint8List bytes, Bouquet bouquet) async {
    if (kIsWeb) {
      triggerWebDownload(bytes, 'bloomix_hikaye_${bouquet.id}_${_ts()}.png');
      return;
    }
    await Share.shareXFiles(
      [await _buildXFile(bytes, 'bloomix_story_${bouquet.id}')],
      subject: 'Bloomix Buket Hikayem',
      text: 'Bloomix ile tasarladim: ${bouquet.name}',
    );
  }

  static Future<void> _shareWhatsApp(
      Uint8List bytes, Bouquet bouquet) async {
    if (kIsWeb) {
      triggerWebDownload(bytes, 'bloomix_${bouquet.id}_${_ts()}.png');
      return;
    }
    await Share.shareXFiles(
      [await _buildXFile(bytes, 'bloomix_${bouquet.id}')],
      text: 'Bloomix ile buket tasarladim: ${bouquet.name}',
    );
  }

  static Future<void> _shareMessages(
      Uint8List bytes, Bouquet bouquet) async {
    if (kIsWeb) {
      triggerWebDownload(bytes, 'bloomix_${bouquet.id}_${_ts()}.png');
      return;
    }
    await Share.shareXFiles(
      [await _buildXFile(bytes, 'bloomix_${bouquet.id}')],
      text: 'Bak ne tasarladim! ${bouquet.name} - Bloomix',
    );
  }

  static Future<void> _shareEmail(Uint8List bytes, Bouquet bouquet) async {
    if (kIsWeb) {
      triggerWebDownload(bytes, 'bloomix_${bouquet.id}_${_ts()}.png');
      return;
    }
    await Share.shareXFiles(
      [await _buildXFile(bytes, 'bloomix_${bouquet.id}')],
      subject: 'Benim Bloomix Tasarimim!',
      text: '${bouquet.name} buketi - Bloomix',
    );
  }

  static Future<void> _shareGeneric(
      Uint8List bytes, Bouquet bouquet) async {
    if (kIsWeb) {
      triggerWebDownload(bytes, 'bloomix_${bouquet.id}_${_ts()}.png');
      return;
    }
    await Share.shareXFiles(
      [await _buildXFile(bytes, 'bloomix_${bouquet.id}')],
      text: 'Bloomix tasarimim: ${bouquet.name}',
      subject: '${bouquet.name} - Bloomix',
    );
  }

  // ── XFile oluşturucu ──────────────────────────────────────

  /// Web → XFile.fromData, Mobil → geçici dosyadan XFile
  static Future<XFile> _buildXFile(Uint8List bytes, String name) async {
    if (kIsWeb) {
      return XFile.fromData(bytes, name: '$name.png', mimeType: 'image/png');
    }
    final file = await _writeTempFile(bytes, name: name);
    return XFile(file.path, mimeType: 'image/png');
  }

  static Future<File> _writeTempFile(List<int> bytes,
      {required String name}) async {
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/${name}_${_ts()}.png';
    return File(path).writeAsBytes(bytes);
  }

  static String _ts() => DateTime.now().millisecondsSinceEpoch.toString();

  // ── Kullanıcı Mesajı ─────────────────────────────────────

  static String messageFor(ExportResult result) {
    switch (result) {
      case ExportResult.success:
        return 'Başarıyla tamamlandı ✓';
      case ExportResult.permissionDenied:
        return 'Galeri izni reddedildi. Ayarlardan izin verin.';
      case ExportResult.renderFailed:
        return 'Görsel oluşturulamadı. Tekrar deneyin.';
      case ExportResult.appNotFound:
        return 'Uygulama bulunamadı.';
      case ExportResult.error:
        return 'Beklenmeyen bir hata oluştu.';
    }
  }
}
