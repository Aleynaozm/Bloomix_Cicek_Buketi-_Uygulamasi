// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

// Web'de Blob URL oluşturarak tarayıcı üzerinden PNG indirir.
// AnchorElement.click() share_plus'tan bağımsız, direkt çalışır.
void triggerWebDownload(List<int> bytes, String filename) {
  final blob = html.Blob([bytes], 'image/png');
  final url = html.Url.createObjectUrlFromBlob(blob);
  (html.AnchorElement()
        ..href = url
        ..download = filename)
      .click();
  html.Url.revokeObjectUrl(url);
}
