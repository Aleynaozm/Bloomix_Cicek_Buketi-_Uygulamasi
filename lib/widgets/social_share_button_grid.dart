import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/gorsel_export_service.dart';
import '../theme/app_theme.dart';

/// 6 butonlu 3×2 sosyal medya paylaşım ızgarası.
/// Her buton: SVG logo + platform etiketi.
class SocialShareButtonGrid extends StatelessWidget {
  final void Function(ShareTarget) onTap;
  final bool disabled;

  const SocialShareButtonGrid({
    super.key,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    const buttons = [
      // ── Satır 1 ──────────────────────────────────────────
      _ButtonData(
        svgData: _SvgIcons.instagram,
        label: 'Instagram\nHikaye',
        badge: '9:16',
        target: ShareTarget.instagramStory,
      ),
      _ButtonData(
        svgData: _SvgIcons.whatsapp,
        label: 'WhatsApp',
        target: ShareTarget.whatsapp,
      ),
      _ButtonData(
        svgData: _SvgIcons.messages,
        label: 'Mesajlar',
        target: ShareTarget.messages,
      ),
      // ── Satır 2 ──────────────────────────────────────────
      _ButtonData(
        svgData: _SvgIcons.email,
        label: 'E-posta',
        target: ShareTarget.email,
      ),
      _ButtonData(
        svgData: _SvgIcons.gallery,
        label: 'Galeriye\nKaydet',
        isHighlighted: true,
        target: ShareTarget.gallery,
      ),
      _ButtonData(
        svgData: _SvgIcons.more,
        label: 'Diğer\nPaylaşım',
        target: ShareTarget.generic,
      ),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      const columns = 3;
      const spacing = 16.0;
      final itemW =
          (constraints.maxWidth - (columns - 1) * spacing) / columns;

      return Column(
        children: [
          // Satır 1
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: buttons
                .take(3)
                .map((b) => SizedBox(
                      width: itemW,
                      child: _SocialButton(
                        data: b,
                        onTap: disabled ? null : () => onTap(b.target),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 18),
          // Satır 2
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: buttons
                .skip(3)
                .map((b) => SizedBox(
                      width: itemW,
                      child: _SocialButton(
                        data: b,
                        onTap: disabled ? null : () => onTap(b.target),
                      ),
                    ))
                .toList(),
          ),
        ],
      );
    });
  }
}

// ── Buton Verisi ──────────────────────────────────────────────
class _ButtonData {
  final String svgData;
  final String label;
  final String? badge;
  final bool isHighlighted;
  final ShareTarget target;

  const _ButtonData({
    required this.svgData,
    required this.label,
    this.badge,
    this.isHighlighted = false,
    required this.target,
  });
}

// ── Tek Buton ─────────────────────────────────────────────────
class _SocialButton extends StatelessWidget {
  final _ButtonData data;
  final VoidCallback? onTap;

  const _SocialButton({required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: onTap == null ? 0.45 : 1.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // İkon + badge
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topRight,
              children: [
                SvgPicture.string(
                  data.svgData,
                  width: 58,
                  height: 58,
                ),
                if (data.badge != null)
                  Positioned(
                    top: -5,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.rose,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.rose.withValues(alpha: 0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        data.badge!,
                        style: GoogleFonts.poppins(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 9),
            // Etiket
            Text(
              data.label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight:
                    data.isHighlighted ? FontWeight.w700 : FontWeight.w500,
                color: data.isHighlighted
                    ? AppColors.rose
                    : AppColors.textDark,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ── SVG İkon Sabitleri ────────────────────────────────────────
abstract class _SvgIcons {
  /// Instagram — renkli gradient kare + kamera çerçevesi
  static const instagram = '''
<svg viewBox="0 0 52 52" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <radialGradient id="ig" cx="28%" cy="112%" r="155%">
      <stop offset="0%"  stop-color="#fdf497"/>
      <stop offset="8%"  stop-color="#fd8e31"/>
      <stop offset="38%" stop-color="#fd5949"/>
      <stop offset="58%" stop-color="#d6249f"/>
      <stop offset="92%" stop-color="#285AEB"/>
    </radialGradient>
  </defs>
  <rect width="52" height="52" rx="13" fill="url(#ig)"/>
  <rect x="12" y="12" width="28" height="28" rx="8"
        fill="none" stroke="white" stroke-width="2.5"/>
  <circle cx="26" cy="26" r="7.5"
          fill="none" stroke="white" stroke-width="2.5"/>
  <circle cx="36" cy="16" r="2.2" fill="white"/>
</svg>
''';

  /// WhatsApp — yeşil yuvarlak kare + konuşma balonu
  static const whatsapp = '''
<svg viewBox="0 0 52 52" xmlns="http://www.w3.org/2000/svg">
  <rect width="52" height="52" rx="13" fill="#25D366"/>
  <path d="M26 10c-8.84 0-16 7.16-16 16 0 2.82.74 5.47 2.04 7.77L10 42l8.42-2.01A15.9 15.9 0 0026 42c8.84 0 16-7.16 16-16S34.84 10 26 10zm7.8 22.03c-.35 1-1.72 1.82-2.87 2.06-.76.16-1.76.29-5.11-1.2-4.29-1.87-7.05-6.22-7.27-6.51-.21-.29-1.75-2.33-1.75-4.45 0-2.12 1.11-3.16 1.5-3.59.36-.4.79-.5 1.05-.5h.73c.23 0 .54-.09.84.66.35.78 1.19 2.88 1.29 3.09.1.21.17.46.03.74-.14.28-.21.45-.43.69-.21.24-.44.53-.63.72-.21.2-.43.43-.18.84.24.42 1.08 1.79 2.32 2.9 1.6 1.43 2.95 1.87 3.37 2.09.42.21.66.17.91-.12.25-.29 1.05-1.23 1.33-1.65.28-.43.56-.36.94-.21.38.14 2.41 1.14 2.83 1.34.41.21.69.32.79.5.1.18.1 1.07-.19 2.1z"
        fill="white"/>
</svg>
''';

  /// Mesajlar — mavi gradient + konuşma balonu
  static const messages = '''
<svg viewBox="0 0 52 52" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="msg" x1="50%" y1="0%" x2="50%" y2="100%">
      <stop offset="0%"  stop-color="#5AC8FA"/>
      <stop offset="100%" stop-color="#007AFF"/>
    </linearGradient>
  </defs>
  <rect width="52" height="52" rx="13" fill="url(#msg)"/>
  <path d="M10 16a4 4 0 014-4h24a4 4 0 014 4v14a4 4 0 01-4 4H19l-9 6V16z"
        fill="white"/>
</svg>
''';

  /// E-posta — kırmızı + zarf
  static const email = '''
<svg viewBox="0 0 52 52" xmlns="http://www.w3.org/2000/svg">
  <rect width="52" height="52" rx="13" fill="#EA4335"/>
  <rect x="9" y="17" width="34" height="22" rx="2.5" fill="white"/>
  <path d="M9 17l17 13 17-13"
        fill="none" stroke="#EA4335" stroke-width="2.5"
        stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';

  /// Galeriye Kaydet — pembe gradient + indir oku
  static const gallery = '''
<svg viewBox="0 0 52 52" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="gal" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%"   stop-color="#FFB8D4"/>
      <stop offset="100%" stop-color="#FF74B3"/>
    </linearGradient>
  </defs>
  <rect width="52" height="52" rx="13" fill="url(#gal)"/>
  <path d="M26 12v22"
        stroke="white" stroke-width="2.8" stroke-linecap="round"/>
  <path d="M17 27l9 9 9-9"
        fill="none" stroke="white" stroke-width="2.8"
        stroke-linecap="round" stroke-linejoin="round"/>
  <rect x="10" y="38" width="32" height="3" rx="1.5" fill="white"/>
</svg>
''';

  /// Diğer Paylaşım — gri + üç nokta
  static const more = '''
<svg viewBox="0 0 52 52" xmlns="http://www.w3.org/2000/svg">
  <rect width="52" height="52" rx="13" fill="#8E8E93"/>
  <circle cx="17" cy="26" r="3.5" fill="white"/>
  <circle cx="26" cy="26" r="3.5" fill="white"/>
  <circle cx="35" cy="26" r="3.5" fill="white"/>
</svg>
''';
}
