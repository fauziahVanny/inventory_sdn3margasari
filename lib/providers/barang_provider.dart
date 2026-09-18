import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/services/api_service.dart';
import '../models/barang_model.dart';

/// Provider untuk mengelola data barang inventaris
class BarangProvider extends ChangeNotifier {
  List<BarangModel> _barangList = [];
  bool _isLoading = false;
  String? _errorMessage;

  String? _searchQuery;
  KondisiBarang? _filterKondisi;
  String? _filterKategoriId;

  List<BarangModel> get allBarang => _barangList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String? get searchQuery => _searchQuery;
  KondisiBarang? get filterKondisi => _filterKondisi;
  String? get filterKategoriId => _filterKategoriId;

  /// Fetch semua barang (untuk OPS & Kepsek)
  Future<void> fetchBarang() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/barang');
      if (response['success'] == true) {
        final List data = response['data'];
        _barangList = data.map((json) => BarangModel.fromJson(json)).toList();
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Fetch barang berdasarkan kelas (untuk Wali Kelas)
  Future<void> fetchBarangByKelas(String kelasId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/barang/kelas/$kelasId');
      if (response['success'] == true) {
        final List data = response['data'];
        _barangList = data.map((json) => BarangModel.fromJson(json)).toList();
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Ambil barang dari cache yang sudah difilter
  List<BarangModel> get filteredBarang => _applyFilters(_barangList);

  /// Ambil barang berdasarkan kelas filter dari cache
  List<BarangModel> getBarangByKelasFilter(String? kelasId) {
    if (kelasId == null) return filteredBarang;
    return _applyFilters(
      _barangList.where((b) => b.kelasId == kelasId).toList(),
    );
  }

  /// Terapkan filter search, kondisi, kategori
  List<BarangModel> _applyFilters(List<BarangModel> items) {
    var result = items;

    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      final query = _searchQuery!.toLowerCase();
      result = result.where((b) =>
        b.namaBarang.toLowerCase().contains(query) ||
        b.kodeBarang.toLowerCase().contains(query)
      ).toList();
    }

    if (_filterKondisi != null) {
      result = result.where((b) {
        switch (_filterKondisi!) {
          case KondisiBarang.layak: return b.jumlahLayak > 0;
          case KondisiBarang.rusakSedang: return b.jumlahRusakSedang > 0;
          case KondisiBarang.rusakBerat: return b.jumlahRusakBerat > 0;
          case KondisiBarang.hilang: return b.jumlahHilang > 0;
        }
      }).toList();
    }

    if (_filterKategoriId != null) {
      result = result.where((b) => b.kategoriId == _filterKategoriId).toList();
    }

    return result;
  }

  /// Set search query
  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Set filter kondisi
  void setFilterKondisi(KondisiBarang? kondisi) {
    _filterKondisi = kondisi;
    notifyListeners();
  }

  /// Set filter kategori
  void setFilterKategori(String? kategoriId) {
    _filterKategoriId = kategoriId;
    notifyListeners();
  }

  /// Reset semua filter
  void resetFilters() {
    _searchQuery = null;
    _filterKondisi = null;
    _filterKategoriId = null;
    notifyListeners();
  }

  /// Tambah barang baru via API
  Future<bool> addBarang(BarangModel barang) async {
    try {
      final response = await ApiService.post('/barang', barang.toJson());
      if (response['success'] == true) {
        _barangList.add(BarangModel.fromJson(response['data']));
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

  /// Update barang via API
  Future<bool> updateBarang(BarangModel updatedBarang) async {
    try {
      final response = await ApiService.put('/barang/${updatedBarang.id}', updatedBarang.toJson());
      if (response['success'] == true) {
        final index = _barangList.indexWhere((b) => b.id == updatedBarang.id);
        if (index != -1) {
          _barangList[index] = BarangModel.fromJson(response['data']);
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

  /// Hapus barang via API
  Future<bool> deleteBarang(String id) async {
    try {
      final response = await ApiService.delete('/barang/$id');
      if (response['success'] == true) {
        _barangList.removeWhere((b) => b.id == id);
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

  /// Generate kode barang otomatis via API
  Future<String?> generateKodeBarang({
    required String kategoriId,
    required String ruanganId,
    String? kelasId,
    required DateTime tanggalPerolehan,
  }) async {
    try {
      final tglStr = tanggalPerolehan.toIso8601String().split('T')[0];
      String url = '/barang/generate-kode?kategori_id=$kategoriId&ruangan_id=$ruanganId&tanggal_perolehan=$tglStr';
      if (kelasId != null) url += '&kelas_id=$kelasId';

      final response = await ApiService.get(url);
      if (response['success'] == true) {
        return response['data']['kode_barang'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
