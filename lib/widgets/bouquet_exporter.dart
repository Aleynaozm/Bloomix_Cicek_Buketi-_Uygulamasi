import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../models/models.dart';

/// Buket görselini farklı formatlara render eden composite servis.
///
/// İki çıktı:
/// • `renderSquare`: kare PNG — buket + alt watermark stripi
/// • `renderStory`: 9:16 dikey PNG — pembe gradient zemin + buket + isim +
///   stat kart + Bloomix watermark (Instagram/WhatsApp story için ideal)
///
/// Her ikisi de "Bloomix ile yapıldı" markasını içerir.
class BouquetExporter {
  static const _watermarkColor = Color(0xFFFF74B3);
  static const _creamBg = Color(0xFFFAF7F2);
  static const _textDark = Color(0xFF1C1410);
  static const _textMid = Color(0xFF6B5B45);

  /// On-screen RepaintBoundary'i yakala + altına watermark şerifi ekle.
  /// Çıktı: kare PNG bytes (paylaşmaya/galeriye uygun).
  static Future<Uint8List?> renderSquare({
    required RenderRepaintBoundary boundary,
    required Bouquet bouquet,
    double pixelRatio = 3.0,
  }) async {
    try {
      // 1) Mevcut sahneyi yakala
      final captured = await boundary.toImage(pixelRatio: pixelRatio);
      final w = captured.width.toDouble();
      final srcH = captured.height.toDouble();
      const watermarkH = 160.0;
      final totalH = srcH + watermarkH;

      // 2) Yeni canvas — orijinal görsel + watermark
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Cream zemin
      canvas.drawRect(
        Rect.fromLTWH(0, 0, w, totalH),
        Paint()..color = _creamBg,
      );

      // Yakalanan görseli üste yerleştir
      canvas.drawImage(captured, Offset.zero, Paint());

      // Watermark şerifi (alt 160px)
      _drawWatermarkStrip(
        canvas,
        Rect.fromLTWH(0, srcH, w, watermarkH),
        bouquet,
      );

      // 3) PNG'e çevir
      final pic = recorder.endRecording();
      final outImage = await pic.toImage(w.toInt(), totalH.toInt());
      final bytes =
          await outImage.toByteData(format: ui.ImageByteFormat.png);
      return bytes?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  /// 1080×1920 dikey hikaye formatı: gradient zemin + buket + isim + stat
  /// kart + Bloomix watermark.
  static Future<Uint8List?> renderStory({
    required RenderRepaintBoundary boundary,
    required Bouquet bouquet,
    double pixelRatio = 3.0,
  }) async {
    try {
      final captured = await boundary.toImage(pixelRatio: pixelRatio);
      const w = 1080.0;
      const h = 1920.0;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // 1) Pembe gradient zemin (Bloomix marka)
      final bgRect = Rect.fromLTWH(0, 0, w, h);
      final bgGradient = ui.Gradient.linear(
        const Offset(0, 0),
        const Offset(w, h),
        [
          const Color(0xFFFFE3EF),
          const Color(0xFFFFB8D4),
          const Color(0xFFFF74B3),
        ],
        [0.0, 0.5, 1.0],
      );
      canvas.drawRect(bgRect, Paint()..shader = bgGradient);

      // Üst sol dekoratif çiçek emoji'si
      _paintText(
        canvas,
        '🌸',
        x: 80,
        y: 120,
        fontSize: 72,
        textAlign: TextAlign.left,
      );
      _paintText(
        canvas,
        '✨',
        x: w - 110,
        y: 140,
        fontSize: 56,
        textAlign: TextAlign.left,
      );

      // 2) Bloomix marka başlık (üstte)
      _paintText(
        canvas,
        'Bloomix',
        x: w / 2,
        y: 220,
        fontSize: 96,
        color: Colors.white,
        fontFamily: 'DM Serif Display',
        fontWeight: FontWeight.w400,
        textAlign: TextAlign.center,
        maxWidth: w - 80,
      );

      // 3) Buket adı (başlık altında)
      _paintText(
        canvas,
        '"${bouquet.name}"',
        x: w / 2,
        y: 360,
        fontSize: 42,
        color: Colors.white,
        fontWeight: FontWeight.w600,
        textAlign: TextAlign.center,
        maxWidth: w - 120,
      );

      // 4) Beyaz "kart" zemin (buket kapsayıcı)
      const cardPad = 60.0;
      const cardTop = 460.0;
      const cardH = 1000.0;
      final cardRect = RRect.fromRectAndRadius(
        const Rect.fromLTWH(cardPad, cardTop, w - 2 * cardPad, cardH),
        const Radius.circular(48),
      );
      canvas.drawRRect(
        cardRect,
        Paint()..color = Colors.white.withOpacity(0.96),
      );
      // Hafif drop shadow
      canvas.drawRRect(
        cardRect.shift(const Offset(0, 6)),
        Paint()
          ..color = Colors.black.withOpacity(0.10)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16)
          ..blendMode = BlendMode.dstATop,
      );

      // 5) Buket görseli (kart içinde merkezleyerek scale)
      final cardInnerW = w - 2 * cardPad - 80;
      final cardInnerH = cardH - 80 - 200; // alt boşluk: stat'ler için
      final imgW = captured.width.toDouble();
      final imgH = captured.height.toDouble();
      final scale = (cardInnerW / imgW < cardInnerH / imgH)
          ? cardInnerW / imgW
          : cardInnerH / imgH;
      final drawW = imgW * scale;
      final drawH = imgH * scale;
      final imgX = (w - drawW) / 2;
      final imgY = cardTop + 40;
      canvas.save();
      canvas.translate(imgX, imgY);
      canvas.scale(scale);
      canvas.drawImage(captured, Offset.zero, Paint());
      canvas.restore();

      // 6) Stat kartı (alt — kart içinde)
      final statY = cardTop + cardH - 180;
      _drawStatBar(canvas,
          rect: Rect.fromLTWH(cardPad + 40, statY, w - 2 * (cardPad + 40), 140),
          bouquet: bouquet);

      // 7) Alt watermark — "Bloomix ile yapıldı"
      _paintText(
        canvas,
        '🌸  Bloomix ile yapıldı',
        x: w / 2,
        y: h - 130,
        fontSize: 38,
        color: Colors.white,
        fontWeight: FontWeight.w700,
        textAlign: TextAlign.center,
      );
      _paintText(
        canvas,
        'Sen de tasarla',
        x: w / 2,
        y: h - 80,
        fontSize: 28,
        color: Colors.white.withOpacity(0.85),
        textAlign: TextAlign.center,
      );

      // 8) PNG
      final pic = recorder.endRecording();
      final outImage = await pic.toImage(w.toInt(), h.toInt());
      final bytes =
          await outImage.toByteData(format: ui.ImageByteFormat.png);
      return bytes?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  // ── Yardımcı painter'lar ──────────────────────────────────

  /// Kare PNG'in altına yapıştırılan watermark şerifi.
  static void _drawWatermarkStrip(
      Canvas canvas, Rect rect, Bouquet bouquet) {
    // Açık pembe zemin
    canvas.drawRect(
      rect,
      Paint()..color = const Color(0xFFFFE3EF).withOpacity(0.7),
    );
    // Üst kenar ince çizgi
    canvas.drawLine(
      rect.topLeft,
      rect.topRight,
      Paint()
        ..color = _watermarkColor.withOpacity(0.15)
        ..strokeWidth = 1.5,
    );

    // Sol: 🌸 Bloomix
    _paintText(
      canvas,
      '🌸',
      x: rect.left + 36,
      y: rect.top + 38,
      fontSize: 44,
      textAlign: TextAlign.left,
    );
    _paintText(
      canvas,
      'Bloomix',
      x: rect.left + 100,
      y: rect.top + 30,
      fontSize: 48,
      color: _watermarkColor,
      fontFamily: 'DM Serif Display',
      textAlign: TextAlign.left,
    );
    _paintText(
      canvas,
      'ile yapıldı',
      x: rect.left + 100,
      y: rect.top + 92,
      fontSize: 22,
      color: _textMid,
      textAlign: TextAlign.left,
    );

    // Sağ: brick + price özeti
    _paintText(
      canvas,
      '${bouquet.legoCount} brick',
      x: rect.right - 36,
      y: rect.top + 32,
      fontSize: 26,
      color: _textDark,
      fontWeight: FontWeight.w800,
      textAlign: TextAlign.right,
    );
    _paintText(
      canvas,
      '₺${bouquet.price.toStringAsFixed(0)}',
      x: rect.right - 36,
      y: rect.top + 76,
      fontSize: 36,
      color: _watermarkColor,
      fontWeight: FontWeight.w800,
      textAlign: TextAlign.right,
    );
  }

  /// Story formatındaki üç-stat şeridi.
  static void _drawStatBar(Canvas canvas,
      {required Rect rect, required Bouquet bouquet}) {
    final stats = [
      ('${bouquet.legoCount}', 'brick'),
      ('${bouquet.flowers.length}', 'çiçek'),
      ('₺${bouquet.price.toStringAsFixed(0)}', bouquet.size.label),
    ];
    final cellW = rect.width / stats.length;
    for (int i = 0; i < stats.length; i++) {
      final cx = rect.left + cellW * (i + 0.5);
      _paintText(
        canvas,
        stats[i].$1,
        x: cx,
        y: rect.top + 18,
        fontSize: 56,
        color: _watermarkColor,
        fontWeight: FontWeight.w800,
        textAlign: TextAlign.center,
      );
      _paintText(
        canvas,
        stats[i].$2,
        x: cx,
        y: rect.top + 92,
        fontSize: 26,
        color: _textMid,
        fontWeight: FontWeight.w600,
        textAlign: TextAlign.center,
      );
      // Dikey ayırıcı çizgi
      if (i < stats.length - 1) {
        final lineX = rect.left + cellW * (i + 1);
        canvas.drawLine(
          Offset(lineX, rect.top + 24),
          Offset(lineX, rect.bottom - 24),
          Paint()
            ..color = _textMid.withOpacity(0.15)
            ..strokeWidth = 1.0,
        );
      }
    }
  }

  /// TextPainter wrapper — canvas üzerine font/renk/hizalama ile metin yazar.
  /// (x, y) referans hizalamaya göre yorumlanır:
  ///   - left: (x = sol kenar, y = üst kenar)
  ///   - center: (x = orta, y = üst kenar)
  ///   - right: (x = sağ kenar, y = üst kenar)
  static void _paintText(
    Canvas canvas,
    String text, {
    required double x,
    required double y,
    required double fontSize,
    Color color = const Color(0xFF1C1410),
    FontWeight fontWeight = FontWeight.w500,
    String? fontFamily,
    TextAlign textAlign = TextAlign.left,
    double? maxWidth,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontFamily: fontFamily,
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: textAlign,
    )..layout(maxWidth: maxWidth ?? double.infinity);

    double drawX = x;
    if (textAlign == TextAlign.center) {
      drawX = x - tp.width / 2;
    } else if (textAlign == TextAlign.right) {
      drawX = x - tp.width;
    }
    tp.paint(canvas, Offset(drawX, y));
  }
}
