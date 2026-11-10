import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class ApiService {
  static const String baseUrl = AppConstants.baseUrl;
  
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static String _formatError(dynamic e) {
    final str = e.toString().replaceAll('Exception: ', '').trim();
    if (str.contains('SocketException') ||
        str.contains('Connection refused') ||
        str.contains('Failed host lookup') ||
        str.contains('ClientException')) {
      return 'Tidak dapat terhubung ke server. Pastikan server backend sedang aktif.';
    }
    if (str.contains('TimeoutException')) {
      return 'Batas waktu koneksi ke server habis. Silakan coba lagi.';
    }
    if (str.contains('FormatException')) {
      return 'Format data respons dari server tidak valid.';
    }
    return str;
  }

  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
      );
      return _processResponse(response);
    } catch (e) {
      throw Exception(_formatError(e));
    }
  }

  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
        body: jsonEncode(body),
      );
      return _processResponse(response);
    } catch (e) {
      throw Exception(_formatError(e));
    }
  }

  static Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic>? body) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(response);
    } catch (e) {
      throw Exception(_formatError(e));
    }
  }

  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
      );
      return _processResponse(response);
    } catch (e) {
      throw Exception(_formatError(e));
    }
  }

  static Map<String, dynamic> _processResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded;
      } else {
        String message = decoded['message'] ?? 'Terjadi kesalahan pada server (Kode: ${response.statusCode})';
        throw Exception(message);
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Format respons tidak valid (Kode: ${response.statusCode})');
      }
      rethrow;
    }
  }
}
