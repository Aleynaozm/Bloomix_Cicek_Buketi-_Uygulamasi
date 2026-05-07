// Platform-bağımsız web indirme arayüzü.
// Web derlemelerinde dart:html, diğerlerinde stub kullanılır.
export 'web_download_stub.dart'
    if (dart.library.html) 'web_download_impl.dart';
