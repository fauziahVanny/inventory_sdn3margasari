import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Layanan utilitas untuk memeriksa koneksi jaringan.
class NetworkService {
  /// Memeriksa apakah perangkat saat ini terhubung ke internet.
  static Future<bool> isConnected() async {
    if (kIsWeb) {
      // Bypass pengecekan untuk platform Web untuk menghindari error CORS di browser.
      // Sistem akan menganggap selalu online jika berjalan di Chrome/Edge.
      return true;
    } else {
      // Pada platform native (Android, iOS, Windows, macOS, Linux).
      // DNS lookup lebih cepat dan ringan daripada HTTP request.
      return _checkViaDnsLookup();
    }
  }

  /// Pemeriksaan koneksi via DNS lookup (untuk platform native).
  static Future<bool> _checkViaDnsLookup() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}