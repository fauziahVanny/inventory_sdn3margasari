import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

/// Layanan utilitas untuk memeriksa koneksi jaringan.
///
/// Menggunakan pendekatan yang aman untuk semua platform:
/// - Web: mencoba HTTP request sederhana karena dart:io tidak tersedia
/// - Android/iOS/Desktop: menggunakan InternetAddress.lookup (DNS lookup)
class NetworkService {
  /// Memeriksa apakah perangkat saat ini terhubung ke internet.
  ///
  /// Mengembalikan [true] jika ada koneksi internet aktif,
  /// [false] jika perangkat offline atau tidak ada koneksi.
  static Future<bool> isConnected() async {
    if (kIsWeb) {
      // Pada platform web, dart:io tidak tersedia.
      // Gunakan HTTP request ringan ke endpoint publik untuk memeriksa koneksi.
      return _checkViaHttp();
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

  /// Pemeriksaan koneksi via HTTP request (untuk platform web).
  static Future<bool> _checkViaHttp() async {
    try {
      final response = await http
          .head(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode < 500;
    } catch (_) {
      return false;
    }
  }
}
