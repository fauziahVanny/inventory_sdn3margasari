import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/barang_provider.dart';
import '../../models/barang_model.dart';
import '../../core/services/api_service.dart';
import '../../models/kategori_model.dart';
import '../../models/ruangan_model.dart';
import '../../models/kelas_model.dart';

/// Form tambah / edit barang inventaris multi-kategori
class WkTambahBarangScreen extends StatefulWidget {
  final String? barangId; // null = tambah baru, ada = edit

  const WkTambahBarangScreen({super.key, this.barangId});

  @override
  State<WkTambahBarangScreen> createState() => _WkTambahBarangScreenState();
}

class _WkTambahBarangScreenState extends State<WkTambahBarangScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controller Umum
  final _namaController = TextEditingController();
  final _jumlahAwalController = TextEditingController(text: '0');
  final _jumlahLayakController = TextEditingController(text: '0');
  final _jumlahRusakSedangController = TextEditingController(text: '0');
  final _jumlahRusakBeratController = TextEditingController(text: '0');
  final _jumlahHilangController = TextEditingController(text: '0');
  final _merekController = TextEditingController();
  final _keteranganController = TextEditingController();

  // Controller khusus Buku
  final _judulController = TextEditingController();
  final _pengarangController = TextEditingController();
  final _penerbitController = TextEditingController();
  final _kotaTerbitController = TextEditingController();
  final _cetakanEdisiController = TextEditingController();
  final _tahunTerbitController = TextEditingController();
  final _jumlahHalamanController = TextEditingController();
  final _ukuranBukuController = TextEditingController();
  final _isbnController = TextEditingController();
  bool _ilustrasi = false; // Ya / Tidak

  String? _selectedKategoriId;
  String? _selectedRuanganId;
  String? _selectedKelasId;
  SumberDana _selectedSumber = SumberDana.danaBos;
  DateTime _tanggalPerolehan = DateTime.now();
  String _generatedKode = '';

  bool get isEditing => widget.barangId != null;

  List<KategoriModel> _kategoriList = [];
  List<RuanganModel> _ruanganList = [];
  List<KelasModel> _kelasList = [];
  bool _isLoadingData = true;

  // Deteksi kategori terpilih
  bool get isBuku {
    final kat = _kategoriList.where((k) => k.id == _selectedKategoriId).firstOrNull;
    if (kat == null) return false;
    final name = kat.namaKategori.toLowerCase();
    final kode = kat.kode.toUpperCase();
    return name.contains('buku') || kode == 'BK';
  }

  bool get isOlahraga {
    final kat = _kategoriList.where((k) => k.id == _selectedKategoriId).firstOrNull;
    if (kat == null) return false;
    final name = kat.namaKategori.toLowerCase();
    final kode = kat.kode.toUpperCase();
    return name.contains('olahraga') || kode == 'OR';
  }

  @override
  void initState() {
    super.initState();

    // Listener real-time on-change untuk kalkulasi otomatis Jumlah Awal Diterima
    _jumlahLayakController.addListener(_calculateJumlahAwal);
    _jumlahRusakSedangController.addListener(_calculateJumlahAwal);
    _jumlahRusakBeratController.addListener(_calculateJumlahAwal);
    _jumlahHilangController.addListener(_calculateJumlahAwal);

    if (isEditing) {
      // Load data yang sudah ada
      final barangProv = context.read<BarangProvider>();
      final barang = barangProv.allBarang.firstWhere(
        (b) => b.id == widget.barangId,
        orElse: () => throw Exception('Barang tidak ditemukan'),
      );

      _namaController.text = barang.namaBarang;
      _jumlahAwalController.text = barang.jumlahAwal.toString();
      _jumlahLayakController.text = barang.jumlahLayak.toString();
      _jumlahRusakSedangController.text = barang.jumlahRusakSedang.toString();
      _jumlahRusakBeratController.text = barang.jumlahRusakBerat.toString();
      _jumlahHilangController.text = barang.jumlahHilang.toString();
      _selectedKategoriId = barang.kategoriId;
      _selectedRuanganId = barang.ruanganId;
      _selectedKelasId = barang.kelasId;
      _merekController.text = barang.merek ?? '';
      _keteranganController.text = barang.keteranganTambahan ?? '';
      _selectedSumber = barang.sumberDana;
      _tanggalPerolehan = barang.tanggalPerolehan;
      _generatedKode = barang.kodeBarang;

      // Data buku
      _judulController.text = barang.judulBuku ?? barang.namaBarang;
      _pengarangController.text = barang.pengarang ?? '';
      _penerbitController.text = barang.penerbit ?? '';
      _kotaTerbitController.text = barang.kotaTerbit ?? '';
      _cetakanEdisiController.text = barang.cetakanEdisi ?? '';
      _tahunTerbitController.text = barang.tahunTerbit?.toString() ?? '';
      _jumlahHalamanController.text = barang.jumlahHalaman?.toString() ?? '';
      _ilustrasi = barang.ilustrasi ?? false;
      _ukuranBukuController.text = barang.ukuranBuku ?? '';
      _isbnController.text = barang.isbn ?? '';
    } else {
      _selectedRuanganId = 'rng-1'; // Default
    }

    _loadDropdownData();
  }

  /// Logika Kalkulasi Otomatis: Jumlah Awal Diterima = Kondisi Layak + Rusak Sedang + Rusak Berat + Hilang
  void _calculateJumlahAwal() {
    final layak = int.tryParse(_jumlahLayakController.text.trim()) ?? 0;
    final sedang = int.tryParse(_jumlahRusakSedangController.text.trim()) ?? 0;
    final berat = int.tryParse(_jumlahRusakBeratController.text.trim()) ?? 0;
    final hilang = int.tryParse(_jumlahHilangController.text.trim()) ?? 0;
    final total = layak + sedang + berat + hilang;

    if (_jumlahAwalController.text != total.toString()) {
      _jumlahAwalController.text = total.toString();
    }
  }

  String? _validateJumlahKondisi(String? v) {
    if (v == null || v.trim().isEmpty) return 'Wajib diisi';
    final n = int.tryParse(v.trim());
    if (n == null) return 'Harus angka';
    if (n < 0) return 'Tidak boleh < 0';
    return null;
  }

  Future<void> _loadDropdownData() async {
    try {
      final resKat = await ApiService.get('/kategori');
      final resRng = await ApiService.get('/ruangan');
      final resKls = await ApiService.get('/kelas');

      if (mounted) {
        final apiCategories = (resKat['data'] as List).map((e) => KategoriModel.fromJson(e)).toList();

        // Kategori bawaan sesuai requirement jika belum ada di database
        final defaultCategories = [
          const KategoriModel(id: 'kat-buku', kode: 'BK', namaKategori: 'Buku'),
          const KategoriModel(id: 'kat-olahraga', kode: 'OR', namaKategori: 'Peralatan Olahraga'),
          const KategoriModel(id: 'kat-furniture', kode: 'FR', namaKategori: 'Furniture'),
          const KategoriModel(id: 'kat-elektronik', kode: 'EL', namaKategori: 'Elektronik'),
          const KategoriModel(id: 'kat-perkakas', kode: 'PK', namaKategori: 'Perkakas'),
          const KategoriModel(id: 'kat-lainnya', kode: 'LN', namaKategori: 'Lainnya'),
        ];

        final mergedCategories = <KategoriModel>[...apiCategories];
        for (final def in defaultCategories) {
          if (!mergedCategories.any((c) =>
              c.namaKategori.toLowerCase() == def.namaKategori.toLowerCase() ||
              c.kode.toUpperCase() == def.kode.toUpperCase())) {
            mergedCategories.add(def);
          }
        }

        setState(() {
          _kategoriList = mergedCategories;
          _ruanganList = (resRng['data'] as List).map((e) => RuanganModel.fromJson(e)).toList();
          _kelasList = (resKls['data'] as List).map((e) => KelasModel.fromJson(e)).toList();

          if (_selectedKategoriId == null && _kategoriList.isNotEmpty) {
            _selectedKategoriId = _kategoriList.first.id;
          }
          if (_selectedRuanganId == null && _ruanganList.isNotEmpty) {
            _selectedRuanganId = _ruanganList.first.id;
          }
          _isLoadingData = false;
        });

        if (!isEditing) {
          _updateKodeBarang();
        }
      }
    } catch (e) {
      if (mounted) {
        // Fallback offline categories
        setState(() {
          _kategoriList = const [
            KategoriModel(id: 'kat-buku', kode: 'BK', namaKategori: 'Buku'),
            KategoriModel(id: 'kat-olahraga', kode: 'OR', namaKategori: 'Peralatan Olahraga'),
            KategoriModel(id: 'kat-furniture', kode: 'FR', namaKategori: 'Furniture'),
            KategoriModel(id: 'kat-elektronik', kode: 'EL', namaKategori: 'Elektronik'),
            KategoriModel(id: 'kat-perkakas', kode: 'PK', namaKategori: 'Perkakas'),
            KategoriModel(id: 'kat-lainnya', kode: 'LN', namaKategori: 'Lainnya'),
          ];
          _selectedKategoriId ??= _kategoriList.first.id;
          _isLoadingData = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _jumlahLayakController.removeListener(_calculateJumlahAwal);
    _jumlahRusakSedangController.removeListener(_calculateJumlahAwal);
    _jumlahRusakBeratController.removeListener(_calculateJumlahAwal);
    _jumlahHilangController.removeListener(_calculateJumlahAwal);

    _namaController.dispose();
    _jumlahAwalController.dispose();
    _jumlahLayakController.dispose();
    _jumlahRusakSedangController.dispose();
    _jumlahRusakBeratController.dispose();
    _jumlahHilangController.dispose();
    _merekController.dispose();
    _keteranganController.dispose();

    _judulController.dispose();
    _pengarangController.dispose();
    _penerbitController.dispose();
    _kotaTerbitController.dispose();
    _cetakanEdisiController.dispose();
    _tahunTerbitController.dispose();
    _jumlahHalamanController.dispose();
    _ukuranBukuController.dispose();
    _isbnController.dispose();

    super.dispose();
  }

  Future<void> _updateKodeBarang() async {
    if (_selectedKategoriId == null || _selectedRuanganId == null) return;
    final barangProv = context.read<BarangProvider>();
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return;

    final targetKelasId = (user.role == UserRole.ops || user.kelasId == null)
        ? _selectedKelasId
        : user.kelasId;

    final kode = await barangProv.generateKodeBarang(
      kategoriId: _selectedKategoriId!,
      ruanganId: _selectedRuanganId!,
      kelasId: targetKelasId,
      tanggalPerolehan: _tanggalPerolehan,
    );
    if (mounted && kode != null) {
      setState(() => _generatedKode = kode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final isOpsOrNoClass = user?.role == UserRole.ops || user?.kelasId == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Barang' : 'Tambah Barang'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (user?.role == UserRole.ops) {
              context.go('/ops/rekap');
            } else {
              context.go('/wk/barang');
            }
          },
        ),
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Kategori Barang (Paling Utama)
                    _buildLabel('Kategori Barang'),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedKategoriId,
                      decoration: const InputDecoration(
                        hintText: 'Pilih kategori',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: _kategoriList.map((k) {
                        return DropdownMenuItem(value: k.id, child: Text(k.namaKategori));
                      }).toList(),
                      validator: (v) => v == null ? 'Pilih kategori' : null,
                      onChanged: (v) {
                        setState(() => _selectedKategoriId = v);
                        _updateKodeBarang();
                      },
                    ),
                    SizedBox(height: 16),

                    // Lokasi / Kelas
                    _buildLabel('Lokasi / Kelas'),
                    if (isOpsOrNoClass)
                      DropdownButtonFormField<String>(
                        initialValue: _selectedKelasId,
                        decoration: const InputDecoration(
                          hintText: 'Pilih Kelas',
                          prefixIcon: Icon(Icons.meeting_room_outlined),
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('- Tidak ada / Ruangan Umum -')),
                          ..._kelasList.map((k) {
                            return DropdownMenuItem(value: k.id, child: Text(k.namaKelas));
                          }),
                        ],
                        onChanged: (v) {
                          setState(() => _selectedKelasId = v);
                          _updateKodeBarang();
                        },
                      )
                    else
                      TextFormField(
                        initialValue: user?.namaKelas ?? 'Kelas Anda',
                        enabled: false,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          prefixIcon: Icon(Icons.meeting_room_outlined),
                        ),
                      ),
                    SizedBox(height: 16),

                    // Ruangan
                    _buildLabel('Ruangan'),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedRuanganId,
                      decoration: const InputDecoration(
                        hintText: 'Pilih ruangan',
                        prefixIcon: Icon(Icons.room_outlined),
                      ),
                      items: _ruanganList.map((r) {
                        return DropdownMenuItem(value: r.id, child: Text(r.namaRuangan));
                      }).toList(),
                      validator: (v) => v == null ? 'Pilih ruangan' : null,
                      onChanged: (v) {
                        setState(() => _selectedRuanganId = v);
                        _updateKodeBarang();
                      },
                    ),
                    SizedBox(height: 16),

                    // Kode barang preview
                    if (_generatedKode.isNotEmpty || isEditing)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.qr_code, color: AppColors.primary, size: 22),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Kode Barang (Otomatis)',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    _generatedKode.isEmpty ? '-' : _generatedKode,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontFamily: 'monospace',
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // ══════════════════════════════════════════════════════════════════
                    // FIELD DINAMIS BERDASARKAN KATEGORI
                    // ══════════════════════════════════════════════════════════════════

                    if (isBuku) ...[
                      // ── KATEGORI BUKU ──
                      _buildSectionHeader('Detail Data Buku', Icons.menu_book),
                      
                      _buildLabel('Judul Buku'),
                      TextFormField(
                        controller: _judulController,
                        decoration: const InputDecoration(hintText: 'Masukkan judul buku'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Judul wajib diisi' : null,
                      ),
                      SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Pengarang'),
                                TextFormField(
                                  controller: _pengarangController,
                                  decoration: const InputDecoration(hintText: 'Nama pengarang'),
                                  validator: (v) => v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Penerbit'),
                                TextFormField(
                                  controller: _penerbitController,
                                  decoration: const InputDecoration(hintText: 'Nama penerbit'),
                                  validator: (v) => v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Kota Terbit'),
                                TextFormField(
                                  controller: _kotaTerbitController,
                                  decoration: const InputDecoration(hintText: 'Contoh: Bandung'),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Cetakan / Edisi'),
                                TextFormField(
                                  controller: _cetakanEdisiController,
                                  decoration: const InputDecoration(hintText: 'Contoh: Cetakan ke-2'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Tahun Terbit'),
                                TextFormField(
                                  controller: _tahunTerbitController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(hintText: 'Contoh: 2022'),
                                  validator: (v) {
                                    if (v != null && v.trim().isNotEmpty) {
                                      final y = int.tryParse(v.trim());
                                      if (y == null) return 'Harus angka';
                                      if (y < 1900 || y > DateTime.now().year + 1) {
                                        return 'Tahun 1900-${DateTime.now().year + 1}';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Jumlah Halaman'),
                                TextFormField(
                                  controller: _jumlahHalamanController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(hintText: 'Contoh: 128'),
                                  validator: (v) {
                                    if (v != null && v.trim().isNotEmpty) {
                                      final hlm = int.tryParse(v.trim());
                                      if (hlm == null) return 'Harus angka';
                                      if (hlm <= 0) return 'Minimal 1 hlm';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Ukuran Buku'),
                                TextFormField(
                                  controller: _ukuranBukuController,
                                  decoration: const InputDecoration(hintText: 'Contoh: A4 / 21x29 cm'),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('ISBN'),
                                TextFormField(
                                  controller: _isbnController,
                                  decoration: const InputDecoration(hintText: '978-xxx-xxx-x'),
                                  validator: (v) {
                                    if (v != null && v.trim().isNotEmpty) {
                                      final clean = v.replaceAll('-', '').trim();
                                      if (clean.length < 10) {
                                        return 'ISBN min. 10 digit';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14),

                      // Ilustrasi (Ya / Tidak)
                      _buildLabel('Ilustrasi Gambar'),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _ilustrasi ? 'Memiliki Ilustrasi (Ya)' : 'Tidak Memiliki Ilustrasi (Tidak)',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Switch(
                              value: _ilustrasi,
                              onChanged: (v) => setState(() => _ilustrasi = v),
                              activeThumbColor: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 18),

                      // Kondisi Buku
                      _buildLabel('Kondisi Buku'),
                      _buildKondisiRow(
                        labelLayak: 'Layak/Baik',
                        labelSedang: 'R. Sedang',
                        labelBerat: 'R. Berat',
                        labelHilang: 'Hilang',
                      ),
                      SizedBox(height: 16),

                    ] else if (isOlahraga) ...[
                      // ── KATEGORI PERALATAN OLAHRAGA ──
                      _buildSectionHeader('Detail Peralatan Olahraga', Icons.sports_basketball),

                      _buildLabel('Nama Peralatan'),
                      TextFormField(
                        controller: _namaController,
                        decoration: const InputDecoration(hintText: 'Contoh: Bola Voli, Matras Senam, Raket'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Nama peralatan wajib diisi' : null,
                      ),
                      SizedBox(height: 16),

                      _buildLabel('Kondisi Peralatan (Baik, Rusak, Hilang)'),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Baik', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success)),
                                SizedBox(height: 4),
                                TextFormField(
                                  controller: _jumlahLayakController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(hintText: '0'),
                                  validator: _validateJumlahKondisi,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Rusak', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.error)),
                                SizedBox(height: 4),
                                TextFormField(
                                  controller: _jumlahRusakSedangController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(hintText: '0'),
                                  validator: _validateJumlahKondisi,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Hilang', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                                SizedBox(height: 4),
                                TextFormField(
                                  controller: _jumlahHilangController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(hintText: '0'),
                                  validator: _validateJumlahKondisi,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                    ] else ...[
                      // ── KATEGORI STANDAR / LAINNYA ──
                      _buildSectionHeader('Detail Barang Umum', Icons.inventory_2_outlined),

                      _buildLabel('Nama Barang'),
                      TextFormField(
                        controller: _namaController,
                        decoration: const InputDecoration(hintText: 'Contoh: Meja Siswa, Papan Tulis'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Nama barang wajib diisi' : null,
                      ),
                      SizedBox(height: 16),

                      _buildLabel('Merek Barang (Opsional)'),
                      TextFormField(
                        controller: _merekController,
                        decoration: const InputDecoration(hintText: 'Contoh: Olympic, Maspion, dll'),
                      ),
                      SizedBox(height: 16),

                      _buildLabel('Kondisi Barang'),
                      _buildKondisiRow(
                        labelLayak: 'Layak',
                        labelSedang: 'R. Sedang',
                        labelBerat: 'R. Berat',
                        labelHilang: 'Hilang',
                      ),
                      SizedBox(height: 16),
                    ],

                    // ══════════════════════════════════════════════════════════════════
                    // KALKULASI OTOMATIS: JUMLAH AWAL DITERIMA
                    // ══════════════════════════════════════════════════════════════════
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLabel(isBuku ? 'Jumlah Buku / Jumlah Awal Diterima' : 'Jumlah Awal Diterima'),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome, size: 12, color: AppColors.primary),
                              SizedBox(width: 4),
                              Text(
                                'Otomatis Terhitung',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    TextFormField(
                      controller: _jumlahAwalController,
                      keyboardType: TextInputType.number,
                      readOnly: true, // Otomatis terhitung on-change tanpa perlu diketik manual
                      decoration: InputDecoration(
                        hintText: '0',
                        filled: true,
                        fillColor: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white10
                            : Colors.grey.shade100,
                        prefixIcon: Icon(Icons.calculate_outlined, color: AppColors.primary),
                        helperText: 'Dihitung real-time: Layak + Rusak Sedang + Rusak Berat + Hilang',
                        helperStyle: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Jumlah awal wajib terhitung';
                        final num = int.tryParse(v.trim());
                        if (num == null) return 'Harus berupa angka';
                        if (num <= 0) return 'Total jumlah minimal 1 unit (isi pada kondisi barang)';
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Keterangan Tambahan
                    _buildLabel('Keterangan Tambahan (Opsional)'),
                    TextFormField(
                      controller: _keteranganController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'Tuliskan catatan khusus atau rincian lainnya...',
                        prefixIcon: Icon(Icons.notes_outlined),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Sumber Dana (Dropdown lengkap termasuk Sumbangan, Hibah, Lainnya)
                    _buildLabel(isBuku ? 'Sumber Buku' : 'Sumber Dana'),
                    DropdownButtonFormField<SumberDana>(
                      initialValue: _selectedSumber,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                      ),
                      items: SumberDana.values.map((s) {
                        return DropdownMenuItem(value: s, child: Text(s.label));
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedSumber = v);
                      },
                    ),
                    SizedBox(height: 16),

                    // Tanggal Perolehan / Penerimaan
                    _buildLabel(isBuku ? 'Tanggal Penerimaan Buku' : 'Tanggal Penerimaan / Perolehan'),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Theme.of(context).colorScheme.outline),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, size: 20, color: AppColors.textSecondary),
                            SizedBox(width: 12),
                            Text(
                              DateFormat('dd MMMM yyyy', 'id').format(_tanggalPerolehan),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 32),

                    // Submit button
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _handleSubmit,
                        icon: Icon(isEditing ? Icons.save_outlined : Icons.add_circle_outline),
                        label: Text(isEditing ? 'Simpan Perubahan' : 'Tambah Barang'),
                      ),
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKondisiRow({
    required String labelLayak,
    required String labelSedang,
    required String labelBerat,
    required String labelHilang,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(labelLayak, style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600)),
              SizedBox(height: 4),
              TextFormField(
                controller: _jumlahLayakController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: '0'),
                validator: _validateJumlahKondisi,
              ),
            ],
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(labelSedang, style: TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.w600)),
              SizedBox(height: 4),
              TextFormField(
                controller: _jumlahRusakSedangController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: '0'),
                validator: _validateJumlahKondisi,
              ),
            ],
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(labelBerat, style: TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w600)),
              SizedBox(height: 4),
              TextFormField(
                controller: _jumlahRusakBeratController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: '0'),
                validator: _validateJumlahKondisi,
              ),
            ],
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(labelHilang, style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w600)),
              SizedBox(height: 4),
              TextFormField(
                controller: _jumlahHilangController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: '0'),
                validator: _validateJumlahKondisi,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalPerolehan,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _tanggalPerolehan = picked);
      _updateKodeBarang();
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final barangProv = context.read<BarangProvider>();
    final user = auth.currentUser!;

    if (!isEditing && _generatedKode.isEmpty) {
      await _updateKodeBarang();
    }

    // Tentukan nama barang sesuai kategori
    final effectiveNamaBarang = isBuku
        ? _judulController.text.trim()
        : _namaController.text.trim();

    // Pastikan perhitungan jumlah awal konsisten
    _calculateJumlahAwal();
    final awal = int.tryParse(_jumlahAwalController.text.trim()) ?? 0;
    final layak = int.tryParse(_jumlahLayakController.text.trim()) ?? 0;
    final sedang = int.tryParse(_jumlahRusakSedangController.text.trim()) ?? 0;
    final berat = int.tryParse(_jumlahRusakBeratController.text.trim()) ?? 0;
    final hilang = int.tryParse(_jumlahHilangController.text.trim()) ?? 0;

    final targetKelasId = (user.role == UserRole.ops || user.kelasId == null)
        ? _selectedKelasId
        : user.kelasId;

    final newBarang = BarangModel(
      id: isEditing ? widget.barangId! : const Uuid().v4(),
      kodeBarang: _generatedKode.isNotEmpty ? _generatedKode : 'BRG-${DateTime.now().millisecondsSinceEpoch}',
      namaBarang: effectiveNamaBarang,
      merek: isBuku
          ? (_penerbitController.text.trim().isNotEmpty ? _penerbitController.text.trim() : null)
          : (_merekController.text.trim().isNotEmpty ? _merekController.text.trim() : null),
      keteranganTambahan: _keteranganController.text.trim().isNotEmpty ? _keteranganController.text.trim() : null,
      kategoriId: _selectedKategoriId!,
      ruanganId: _selectedRuanganId ?? 'rng-1',
      kelasId: targetKelasId,
      jumlahLayak: layak,
      jumlahRusakSedang: sedang,
      jumlahRusakBerat: berat,
      jumlahHilang: hilang,
      jumlahAwal: awal,
      sumberDana: _selectedSumber,
      tanggalPerolehan: _tanggalPerolehan,
      dicatatOleh: user.id,
      updatedAt: DateTime.now(),
      // Data buku
      judulBuku: isBuku ? _judulController.text.trim() : null,
      pengarang: isBuku && _pengarangController.text.trim().isNotEmpty ? _pengarangController.text.trim() : null,
      penerbit: isBuku && _penerbitController.text.trim().isNotEmpty ? _penerbitController.text.trim() : null,
      kotaTerbit: isBuku && _kotaTerbitController.text.trim().isNotEmpty ? _kotaTerbitController.text.trim() : null,
      cetakanEdisi: isBuku && _cetakanEdisiController.text.trim().isNotEmpty ? _cetakanEdisiController.text.trim() : null,
      tahunTerbit: isBuku ? int.tryParse(_tahunTerbitController.text.trim()) : null,
      jumlahHalaman: isBuku ? int.tryParse(_jumlahHalamanController.text.trim()) : null,
      ilustrasi: isBuku ? _ilustrasi : null,
      ukuranBuku: isBuku && _ukuranBukuController.text.trim().isNotEmpty ? _ukuranBukuController.text.trim() : null,
      isbn: isBuku && _isbnController.text.trim().isNotEmpty ? _isbnController.text.trim() : null,
    );

    bool success;
    if (isEditing) {
      success = await barangProv.updateBarang(newBarang);
      if (mounted) {
        final err = barangProv.errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Barang berhasil diperbarui'
                : (err != null && err.isNotEmpty
                    ? err
                    : 'Gagal memperbarui barang. Periksa kelengkapan data atau koneksi ke server.')),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    } else {
      success = await barangProv.addBarang(newBarang);
      if (mounted) {
        final err = barangProv.errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Barang berhasil ditambahkan'
                : (err != null && err.isNotEmpty
                    ? err
                    : 'Gagal menambah barang. Periksa kelengkapan data atau koneksi ke server.')),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }

    if (mounted && success) {
      if (user.role == UserRole.ops) {
        context.go('/ops/rekap');
      } else {
        context.go('/wk/barang');
      }
    }
  }
}
