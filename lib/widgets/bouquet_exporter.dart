import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import '../models/models.dart';

/// Buket görselini estetik export formatına dönüştüren servis.
///
/// Her iki çıktı da aynı tasarım diline sahiptir:
/// • Cream zemin (#F9F9F7)
/// • Buket tam ortada, canvas'ın ~%60'ını kaplıyor
/// • "Bloomix ile oluşturuldu" — Dancing Script, yumuşak antrasit
///
/// Fiyat, brick sayısı veya teknik bilgi yoktur.
///
/// Formatlar:
/// • [renderSquare] → 1080 × 1350 (Portre 4:5) — WhatsApp / Galeri
/// • [renderStory]  → 1080 × 1920 (9:16)       — Instagram Hikaye
class BouquetExporter {
  // ── Canvas boyutları ──────────────────────────────────────
  static const _portraitW = 1080.0;
  static const _portraitH = 1350.0; // Portre 4:5 — WhatsApp / Galeri
  static const _storyW    = 1080.0;
  static const _storyH    = 1920.0; // Story 9:16 — Instagram

  // ── Tasarım sabitleri ─────────────────────────────────────
  /// Hafif kırık beyaz / krem zemin — buketin renklerini patlatır.
  static const _bgColor    = Color(0xFFF9F9F7);
  /// Yumuşak antrasit — saf siyah değil, ılık kahve tonu.
  static const _textColor  = Color(0xFF4A3F35);

  static const _sidePad    = 80.0;   // Yatay kenar boşluğu
  static const _topPad     = 80.0;   // Buket üst boşluğu
  static const _textGap    = 52.0;   // Buket alt kenarı → metin

  // ─────────────────────────────────────────────────────────
  // PORTRE 4:5 — WhatsApp / Galeri / Genel Paylaşım
  // ─────────────────────────────────────────────────────────

  /// 1080 × 1350 portre — kare/WhatsApp paylaşımı için.
  static Future<Uint8List?> renderSquare({
    required RenderRepaintBoundary boundary,
    required Bouquet bouquet,
    double pixelRatio = 3.0,
  }) async {
    try {
      final captured = await boundary.toImage(pixelRatio: pixelRatio);
      return _renderCanvas(
        captured: captured,
        cW: _portraitW,
        cH: _portraitH,
        bouquetFraction: 0.62, // Canvas yüksekliğinin %62'si buket için
      );
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────
  // 9:16 HİKAYE — Instagram Story
  // ─────────────────────────────────────────────────────────

  /// 1080 × 1920 dikey hikaye — Instagram Story için.
  static Future<Uint8List?> renderStory({
    required RenderRepaintBoundary boundary,
    required Bouquet bouquet,
    double pixelRatio = 3.0,
  }) async {
    try {
      final captured = await boundary.toImage(pixelRatio: pixelRatio);
      return _renderCanvas(
        captured: captured,
        cW: _storyW,
        cH: _storyH,
        bouquetFraction: 0.58, // 9:16'da %58 buket için (daha uzun canvas)
      );
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────
  // ORTAK RENDER MOTORU
  // ─────────────────────────────────────────────────────────

  static Future<Uint8List?> _renderCanvas({
    required ui.Image captured,
    required double cW,   // canvas genişlik
    required double cH,   // canvas yükseklik
    required double bouquetFraction,
  }) async {
    // ── Buket boyutlandırma ───────────────────────────────
    final maxBouquetW = cW - 2 * _sidePad;
    final maxBouquetH = cH * bouquetFraction;

    final srcW = captured.width.toDouble();
    final srcH = captured.height.toDouble();
    final scale = (srcW / maxBouquetW > srcH / maxBouquetH)
        ? maxBouquetW / srcW   // genişliğe göre sınır
        : maxBouquetH / srcH;  // yüksekliğe göre sınır

    final drawW = srcW * scale;
    final drawH = srcH * scale;

    // ── Pozisyonlama ─────────────────────────────────────
    // Buket yatayda tam orta; dikeyİ: tüm blok (buket+boşluk+metin)
    // canvas'a dikey olarak ortalanır.
    final fontSize  = cW * 0.028; // küçük, zarif
    final bouquetX  = (cW - drawW) / 2;
    final bouquetY  = ((cH - drawH) / 2 - cH * 0.04).clamp(_topPad, cH.toDouble());
    final textY     = cH * 0.925; // canvas'ın en altına yakın

    // ── Canvas ───────────────────────────────────────────
    final recorder  = ui.PictureRecorder();
    final canvas    = Canvas(recorder);

    // Krem zemin
    canvas.drawRect(
      Rect.fromLTWH(0, 0, cW, cH),
      Paint()..color = _bgColor,
    );

    // Buket (en-boy oranı korunarak ölçeklendirilmiş)
    canvas.save();
    canvas.translate(bouquetX, bouquetY);
    canvas.scale(scale);
    canvas.drawImage(captured, Offset.zero, Paint());
    canvas.restore();

    // "Bloomix ile oluşturuldu" — Dancing Script
    _paintText(
      canvas,
      'Bloomix ile oluşturuldu',
      x: cW / 2,
      y: textY,
      fontSize: fontSize,
      color: const Color(0xFF9E8F85),
      fontFamily: 'Dancing Script',
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.italic,
      textAlign: TextAlign.center,
      maxWidth: cW * 0.70,
    );

    // ── PNG'e çevir ───────────────────────────────────────
    final pic      = recorder.endRecording();
    final outImage = await pic.toImage(cW.toInt(), cH.toInt());
    final bytes    = await outImage.toByteData(format: ui.ImageByteFormat.png);
    return bytes?.buffer.asUint8List();
  }

  // ─────────────────────────────────────────────────────────
  // YARDIMCI: Canvas metin çizici
  // ─────────────────────────────────────────────────────────

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
          height: 1.0,
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
