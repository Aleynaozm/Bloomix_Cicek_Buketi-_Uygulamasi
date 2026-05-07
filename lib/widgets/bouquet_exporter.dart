import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import '../models/models.dart';

/// Buket görselini estetik export formatına dönüştüren servis.
///
/// Görsel hiyerarşisi (yukarıdan aşağıya):
///   1. Kullanıcı ismi  — pembe, modern, küçük punto   (varsa)
///   2. Buket görseli  — ortalanmış, maksimum alan
///   3. "Bloomix ile oluşturuldu" — zarif script, antrasit gri
class BouquetExporter {
  static const _portraitW = 1080.0;
  static const _portraitH = 1350.0;
  static const _storyW    = 1080.0;
  static const _storyH    = 1920.0;

  static const _bgColor    = Color(0xFFF9F9F7);
  static const _nameColor  = Color(0xFFCE6B82); // pembe-gül
  static const _wmarkColor = Color(0xFF6B6B6B); // antrasit gri

  static const _sidePad = 80.0;
  static const _topPad  = 60.0;

  // ── Public API ────────────────────────────────────────────

  static Future<Uint8List?> renderSquare({
    required RenderRepaintBoundary boundary,
    required Bouquet bouquet,
    String? displayName,
    double pixelRatio = 3.0,
  }) async {
    try {
      final img = await boundary.toImage(pixelRatio: pixelRatio);
      return _render(
        captured: img,
        cW: _portraitW,
        cH: _portraitH,
        bouquetFraction: 0.62,
        displayName: displayName,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<Uint8List?> renderStory({
    required RenderRepaintBoundary boundary,
    required Bouquet bouquet,
    String? displayName,
    double pixelRatio = 3.0,
  }) async {
    try {
      final img = await boundary.toImage(pixelRatio: pixelRatio);
      return _render(
        captured: img,
        cW: _storyW,
        cH: _storyH,
        bouquetFraction: 0.56,
        displayName: displayName,
      );
    } catch (_) {
      return null;
    }
  }

  // ── Render motoru ─────────────────────────────────────────

  static Future<Uint8List?> _render({
    required ui.Image captured,
    required double cW,
    required double cH,
    required double bouquetFraction,
    String? displayName,
  }) async {
    final name    = (displayName != null && displayName.isNotEmpty) ? displayName : null;
    final hasName = name != null;

    // ── Font boyutları ────────────────────────────────────
    final nameFontSize = cW * 0.042;   // küçük, modern
    final wmarkSize    = cW * 0.028;

    // ── Blok yükseklikleri ────────────────────────────────
    final nameBlockH  = hasName ? nameFontSize * 1.4 + 36.0 : 0.0;
    final wmarkBlockH = wmarkSize * 1.4 + 48.0;

    // ── Buket ölçülendirme ────────────────────────────────
    final maxBouquetW = cW - 2 * _sidePad;
    final maxBouquetH = cH * bouquetFraction;

    final srcW  = captured.width.toDouble();
    final srcH  = captured.height.toDouble();
    final scale = (srcW / maxBouquetW > srcH / maxBouquetH)
        ? maxBouquetW / srcW
        : maxBouquetH / srcH;
    final drawW = srcW * scale;
    final drawH = srcH * scale;

    // ── Dikey yerleşim ─────────────────────────────────────
    // İçerik bloğu: [isim] + buket + watermark — kanvas içinde ortalanır.
    final totalH   = nameBlockH + drawH + wmarkBlockH + 40.0;
    final blockTop = ((cH - totalH) / 2).clamp(_topPad, cH.toDouble());

    double cursorY = blockTop;

    final nameY    = hasName ? cursorY : 0.0;
    if (hasName) cursorY += nameBlockH;

    final bouquetY = cursorY + (hasName ? 8.0 : 0.0);
    cursorY        = cH - wmarkBlockH;
    final wmarkY   = cursorY + 16.0;

    // ── Canvas ────────────────────────────────────────────
    final recorder = ui.PictureRecorder();
    final canvas   = Canvas(recorder);

    // Zemin
    canvas.drawRect(
      Rect.fromLTWH(0, 0, cW, cH),
      Paint()..color = _bgColor,
    );

    // İsim — pembe, modern Poppins, küçük, letter-spaced
    if (hasName) {
      _paintText(
        canvas,
        name,
        x: cW / 2,
        y: nameY,
        fontSize: nameFontSize,
        color: _nameColor,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
        textAlign: TextAlign.center,
        maxWidth: cW * 0.80,
        letterSpacing: 1.2,
      );
    }

    // Buket
    final bouquetX = (cW - drawW) / 2;
    canvas.save();
    canvas.translate(bouquetX, bouquetY);
    canvas.scale(scale);
    canvas.drawImage(captured, Offset.zero, Paint());
    canvas.restore();

    // Zarif ayraç çizgisi
    final dividerY = bouquetY + drawH + 18.0;
    canvas.drawLine(
      Offset(cW * 0.35, dividerY),
      Offset(cW * 0.65, dividerY),
      Paint()
        ..color = const Color(0xFFE0C8C8)
        ..strokeWidth = 0.8,
    );

    // Watermark — antrasit gri, Dancing Script
    _paintText(
      canvas,
      'Bloomix ile oluşturuldu',
      x: cW / 2,
      y: wmarkY,
      fontSize: wmarkSize,
      color: _wmarkColor,
      fontFamily: 'Dancing Script',
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.italic,
      textAlign: TextAlign.center,
      maxWidth: cW * 0.70,
    );

    // PNG
    final pic      = recorder.endRecording();
    final outImage = await pic.toImage(cW.toInt(), cH.toInt());
    final bytes    = await outImage.toByteData(format: ui.ImageByteFormat.png);
    return bytes?.buffer.asUint8List();
  }

  // ── Canvas metin çizici ────────────────────────────────────
  static void _paintText(
    Canvas canvas,
    String text, {
    required double x,
    required double y,
    required double fontSize,
    Color color = const Color(0xFF1C1410),
    FontWeight fontWeight = FontWeight.w500,
    FontStyle fontStyle = FontStyle.normal,
    String? fontFamily,
    TextAlign textAlign = TextAlign.left,
    double? maxWidth,
    double letterSpacing = 0.0,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          fontFamily: fontFamily,
          letterSpacing: letterSpacing,
          height: 1.4,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: textAlign,
    )..layout(maxWidth: maxWidth ?? double.infinity);

    final drawX = switch (textAlign) {
      TextAlign.center => x - tp.width / 2,
      TextAlign.right  => x - tp.width,
      _                => x,
    };
    tp.paint(canvas, Offset(drawX, y));
  }
}
