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

/// Form tambah / edit barang inventaris
class WkTambahBarangScreen extends StatefulWidget {
  final String? barangId; // null = tambah baru, ada = edit

  const WkTambahBarangScreen({super.key, this.barangId});

  @override
  State<WkTambahBarangScreen> createState() => _WkTambahBarangScreenState();
}

class _WkTambahBarangScreenState extends State<WkTambahBarangScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _jumlahAwalController = TextEditingController();
  final _jumlahLayakController = TextEditingController();
  final _jumlahRusakSedangController = TextEditingController();
  final _jumlahRusakBeratController = TextEditingController();
  final _jumlahHilangController = TextEditingController();
  final _merekController = TextEditingController();
  final _keteranganController = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      // Load existing data
      final barangProv = context.read<BarangProvider>();
      final barang = barangProv.allBarang.firstWhere((b) => b.id == widget.barangId);
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
    } else {
      // Default ruangan untuk kelas
      _selectedRuanganId = 'rng-1'; // Kelas
    }
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    try {
      final resKat = await ApiService.get('/kategori');
      final resRng = await ApiService.get('/ruangan');
      final resKls = await ApiService.get('/kelas');

      if (mounted) {
        setState(() {
          _kategoriList = (resKat['data'] as List).map((e) => KategoriModel.fromJson(e)).toList();
          _ruanganList = (resRng['data'] as List).map((e) => RuanganModel.fromJson(e)).toList();
          _kelasList = (resKls['data'] as List).map((e) => KelasModel.fromJson(e)).toList();
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingData = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat pilihan: $e')));
      }
    }
  }

  @override
  void dispose() {
      _namaController.dispose();
      _jumlahAwalController.dispose();
      _jumlahLayakController.dispose();
      _jumlahRusakSedangController.dispose();
      _jumlahRusakBeratController.dispose();
      _jumlahHilangController.dispose();
      _merekController.dispose();
      _keteranganController.dispose();
      super.dispose();
    }

  Future<void> _updateKodeBarang() async {
    if (_selectedKategoriId == null || _selectedRuanganId == null) return;
    final barangProv = context.read<BarangProvider>();
    final auth = context.read<AuthProvider>();
    final kode = await barangProv.generateKodeBarang(
      kategoriId: _selectedKategoriId!,
      ruanganId: _selectedRuanganId!,
      kelasId: auth.currentUser!.role == UserRole.ops ? _selectedKelasId : auth.currentUser!.kelasId,
      tanggalPerolehan: _tanggalPerolehan,
    );
    if (mounted) {
      setState(() => _generatedKode = kode ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Barang' : 'Tambah Barang'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.read<AuthProvider>().currentUser?.role == UserRole.ops) {
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
              // Kelas
              _buildLabel('Kelas'),
              if (context.watch<AuthProvider>().currentUser?.role == UserRole.ops)
                DropdownButtonFormField<String>(
                  initialValue: _selectedKelasId,
                  decoration: const InputDecoration(hintText: 'Pilih Kelas'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('- Tidak ada / Umum -')),
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
                  initialValue: context.read<AuthProvider>().currentUser?.namaKelas ?? 'Kelas Anda',
                  enabled: false,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
              const SizedBox(height: 16),
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
                      const Icon(Icons.qr_code, color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Column(
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
                    ],
                  ),
                ),

              // Nama Barang
              _buildLabel('Nama Barang'),
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(hintText: 'Contoh: Meja Siswa'),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              
              // Merek Barang
              _buildLabel('Merek Barang (Opsional)'),
              TextFormField(
                controller: _merekController,
                decoration: const InputDecoration(hintText: 'Contoh: Olympic, Maspion, dll'),
              ),
              const SizedBox(height: 16),

              // Kategori
              _buildLabel('Kategori'),
              DropdownButtonFormField<String>(
                initialValue: _selectedKategoriId,
                decoration: const InputDecoration(hintText: 'Pilih kategori'),
                items: _kategoriList.map((k) {
                  return DropdownMenuItem(value: k.id, child: Text(k.namaKategori));
                }).toList(),
                validator: (v) => v == null ? 'Pilih kategori' : null,
                onChanged: (v) {
                  setState(() => _selectedKategoriId = v);
                  _updateKodeBarang();
                },
              ),
              const SizedBox(height: 16),

              // Ruangan
              _buildLabel('Ruangan'),
              DropdownButtonFormField<String>(
                initialValue: _selectedRuanganId,
                decoration: const InputDecoration(hintText: 'Pilih ruangan'),
                items: _ruanganList.map((r) {
                  return DropdownMenuItem(value: r.id, child: Text(r.namaRuangan));
                }).toList(),
                validator: (v) => v == null ? 'Pilih ruangan' : null,
                onChanged: (v) {
                  setState(() => _selectedRuanganId = v);
                  _updateKodeBarang();
                },
              ),
              const SizedBox(height: 16),

              _buildLabel('Jumlah (Sesuai Kondisi)'),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Layak', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _jumlahLayakController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '0'),
                          validator: (v) => v == null || v.isEmpty ? 'Wajib' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('R.Sedang', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _jumlahRusakSedangController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '0'),
                          validator: (v) => v == null || v.isEmpty ? 'Wajib' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('R.Berat', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _jumlahRusakBeratController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '0'),
                          validator: (v) => v == null || v.isEmpty ? 'Wajib' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hilang', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _jumlahHilangController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '0'),
                          validator: (v) => v == null || v.isEmpty ? 'Wajib' : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildLabel('Jumlah Awal Keseluruhan'),
              TextFormField(
                controller: _jumlahAwalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: '0'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Wajib diisi';
                  if (int.tryParse(v) == null) return 'Angka saja';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Keterangan Tambahan
              _buildLabel('Keterangan Tambahan (Opsional)'),
              TextFormField(
                controller: _keteranganController,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Tuliskan rincian kerusakan atau info lainnya...'),
              ),
              const SizedBox(height: 16),

              // Sumber Dana
              _buildLabel('Sumber Dana'),
              DropdownButtonFormField<SumberDana>(
                initialValue: _selectedSumber,
                decoration: const InputDecoration(),
                items: SumberDana.values.map((s) {
                  return DropdownMenuItem(value: s, child: Text(s.label));
                }).toList(),
                onChanged: (v) => setState(() => _selectedSumber = v!),
              ),
              const SizedBox(height: 16),

              // Tanggal Perolehan
              _buildLabel('Tanggal Perolehan'),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20, color: AppColors.textSecondary),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('dd MMMM yyyy', 'id').format(_tanggalPerolehan),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  child: Text(isEditing ? 'Simpan Perubahan' : 'Tambah Barang'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
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

    final newBarang = BarangModel(
      id: isEditing ? widget.barangId! : const Uuid().v4(),
      kodeBarang: _generatedKode,
      namaBarang: _namaController.text,
      merek: _merekController.text.trim().isEmpty ? null : _merekController.text.trim(),
      keteranganTambahan: _keteranganController.text.trim().isEmpty ? null : _keteranganController.text.trim(),
      kategoriId: _selectedKategoriId!,
      ruanganId: _selectedRuanganId!,
      kelasId: user.role == UserRole.ops ? _selectedKelasId : user.kelasId,
      jumlahLayak: int.parse(_jumlahLayakController.text),
      jumlahRusakSedang: int.parse(_jumlahRusakSedangController.text),
      jumlahRusakBerat: int.parse(_jumlahRusakBeratController.text),
      jumlahHilang: int.parse(_jumlahHilangController.text),
      jumlahAwal: int.parse(_jumlahAwalController.text),
      sumberDana: _selectedSumber,
      tanggalPerolehan: _tanggalPerolehan,
      dicatatOleh: user.id,
      updatedAt: DateTime.now(),
    );

    bool success;
    if (isEditing) {
      success = await barangProv.updateBarang(newBarang);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(success ? 'Barang berhasil diperbarui' : 'Gagal memperbarui barang')),
        );
      }
    } else {
      success = await barangProv.addBarang(newBarang);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(success ? 'Barang berhasil ditambahkan' : 'Gagal menambah barang')),
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
