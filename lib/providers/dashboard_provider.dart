import 'package:flutter/material.dart';
import '../core/services/api_service.dart';

class DashboardProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? _statistikGlobal;
  Map<String, dynamic>? _laporanStatistik;
  Map<String, dynamic>? _statistikKelas;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  Map<String, dynamic>? get statistikGlobal => _statistikGlobal;
  Map<String, dynamic>? get laporanStatistik => _laporanStatistik;
  Map<String, dynamic>? get statistikKelas => _statistikKelas;

  /// Fetch statistik global (ops, kepsek)
  Future<void> fetchStatistikGlobal() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/dashboard/statistik');
      if (response['success'] == true) {
        _statistikGlobal = response['data'];
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Fetch statistik kelas tertentu (wali kelas, ops, kepsek)
  Future<void> fetchStatistikKelas(String kelasId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/dashboard/statistik/kelas/$kelasId');
      if (response['success'] == true) {
        _statistikKelas = response['data'];
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Fetch statistik laporan (ops, kepsek)
  Future<void> fetchLaporanStatistik() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/dashboard/laporan-statistik');
      if (response['success'] == true) {
        _laporanStatistik = response['data'];
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
