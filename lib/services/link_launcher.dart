import 'package:flutter/services.dart';

/// Membuka aplikasi lain (YouTube, browser, WhatsApp) lewat Intent Android.
///
/// Memakai MethodChannel ke MainActivity.kt, sehingga tidak perlu
/// plugin tambahan.
class LinkLauncher {
  LinkLauncher._();

  static const MethodChannel _channel = MethodChannel('nontonin/launcher');

  /// Membuka trailer langsung di aplikasi YouTube. Jika aplikasi YouTube
  /// tidak terpasang, trailer dibuka di browser.
  static Future<bool> openYoutube(String videoKey) async {
    try {
      final ok =
          await _channel.invokeMethod<bool>('openYoutube', {'key': videoKey});
      return ok ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Membuka alamat web di aplikasi yang sesuai (browser, WhatsApp, dll).
  static Future<bool> openUrl(String url) async {
    try {
      final ok = await _channel.invokeMethod<bool>('openUrl', {'url': url});
      return ok ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}
