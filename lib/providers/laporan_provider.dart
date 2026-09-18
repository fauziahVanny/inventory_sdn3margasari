import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/services/api_service.dart';
import '../models/laporan_model.dart';

/// Provider untuk mengelola data laporan
class LaporanProvider extends ChangeNotifier {
  List<LaporanModel> _laporanList = [];
  List<LaporanModel> _historyList = [];
  bool _isLoading = false;
  bool _isLoadingHistory = false;
  String? _errorMessage;
  String? _historyError;

  List<LaporanModel> get allLaporan => _laporanList;
  List<LaporanModel> get historyList => _historyList;
  bool get isLoading => _isLoading;
  bool get isLoadingHistory => _isLoadingHistory;
  String? get errorMessage => _errorMessage;
  String? get historyError => _historyError;

  /// Fetch semua laporan
  Future<void> fetchLaporan() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/laporan');
      if (response['success'] == true) {
        final List data = response['data'];
        _laporanList = data.map((json) => LaporanModel.fromJson(json)).toList();
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Laporan yang menunggu persetujuan (untuk Kepala Sekolah)
  List<LaporanModel> get laporanMenungguAcc =>
      _laporanList.where((l) => l.status == StatusLaporan.diajukan).toList();

  /// Laporan yang sudah disetujui
  List<LaporanModel> get laporanDisetujui =>
      _laporanList.where((l) => l.status == StatusLaporan.disetujui).toList();

  /// Laporan berdasarkan status
  List<LaporanModel> getLaporanByStatus(StatusLaporan status) =>
      _laporanList.where((l) => l.status == status).toList();

  /// Tambah laporan baru
  Future<bool> addLaporan(LaporanModel laporan) async {
    try {
      final response = await ApiService.post('/laporan', laporan.toJson());
      if (response['success'] == true) {
        _laporanList.add(LaporanModel.fromJson(response['data']));
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Ajukan laporan
  Future<bool> ajukanLaporan(String id) async {
    try {
      final response = await ApiService.put('/laporan/$id/ajukan', null);
      if (response['success'] == true) {
        final index = _laporanList.indexWhere((l) => l.id == id);
        if (index != -1) {
          _laporanList[index] = LaporanModel.fromJson(response['data']);
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Setujui laporan (ACC) — menyertakan tanggal_aksi (timestamp saat tombol ditekan)
  Future<bool> setujuiLaporan(String id) async {
    try {
      final response = await ApiService.put('/laporan/$id/setujui', {
        'tanggal_aksi': DateTime.now().toIso8601String(),
      });
      if (response['success'] == true) {
        final index = _laporanList.indexWhere((l) => l.id == id);
        if (index != -1) {
          _laporanList[index] = LaporanModel.fromJson(response['data']);
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Kembalikan laporan untuk revisi — menyertakan tanggal_aksi
  Future<bool> revisiLaporan(String id, String catatan) async {
    try {
      final response = await ApiService.put('/laporan/$id/revisi', {
        'catatan_revisi': catatan,
        'tanggal_aksi': DateTime.now().toIso8601String(),
      });
      if (response['success'] == true) {
        final index = _laporanList.indexWhere((l) => l.id == id);
        if (index != -1) {
          _laporanList[index] = LaporanModel.fromJson(response['data']);
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Fetch history laporan (status: disetujui / revisi) untuk Kepala Sekolah
  Future<void> fetchLaporanHistory() async {
    _isLoadingHistory = true;
    _historyError = null;
    notifyListeners();

    try {
      // Coba endpoint khusus history dulu; jika tidak ada, filter dari semua laporan
      final response = await ApiService.get('/laporan/history');
      if (response['success'] == true) {
        final List data = response['data'] as List;
        _historyList = data
            .map((json) => LaporanModel.fromJson(json as Map<String, dynamic>))
            .where((l) =>
                l.status == StatusLaporan.disetujui ||
                l.status == StatusLaporan.revisi)
            .toList()
          ..sort((a, b) {
            // Urutkan dari yang terbaru — null-safe: data lama tanpa tanggalAksi ke bawah
            final aDate = a.tanggalAksi ?? a.tanggalPengajuan;
            final bDate = b.tanggalAksi ?? b.tanggalPengajuan;
            return bDate.compareTo(aDate);
          });
      }
    } catch (_) {
      // Fallback: gunakan data yang sudah ada di _laporanList
      try {
        if (_laporanList.isNotEmpty) {
          _historyList = _laporanList
              .where((l) =>
                  l.status == StatusLaporan.disetujui ||
                  l.status == StatusLaporan.revisi)
              .toList()
            ..sort((a, b) {
              final aDate = a.tanggalAksi ?? a.tanggalPengajuan;
              final bDate = b.tanggalAksi ?? b.tanggalPengajuan;
              return bDate.compareTo(aDate);
            });
          _historyError = null; // berhasil dari cache
        } else {
          // Belum ada data sama sekali — fetch semua dulu
          await fetchLaporan();
          _historyList = _laporanList
              .where((l) =>
                  l.status == StatusLaporan.disetujui ||
                  l.status == StatusLaporan.revisi)
              .toList()
            ..sort((a, b) {
              final aDate = a.tanggalAksi ?? a.tanggalPengajuan;
              final bDate = b.tanggalAksi ?? b.tanggalPengajuan;
              return bDate.compareTo(aDate);
            });
        }
      } catch (e) {
        _historyError = e.toString();
      }
    }

    _isLoadingHistory = false;
    notifyListeners();
  }

  /// Hapus laporan (hanya jika draft)
  Future<bool> deleteLaporan(String id) async {
    try {
      final response = await ApiService.delete('/laporan/$id');
      if (response['success'] == true) {
        _laporanList.removeWhere((l) => l.id == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Hapus laporan
  Future<bool> hapusLaporan(String id) async {
    try {
      final response = await ApiService.delete('/laporan/$id');
      if (response['success'] == true) {
        _laporanList.removeWhere((l) => l.id == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
