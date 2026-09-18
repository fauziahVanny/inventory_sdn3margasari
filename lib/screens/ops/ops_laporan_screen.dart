import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/laporan_provider.dart';
import '../../models/laporan_model.dart';
import '../../core/services/api_service.dart';
import '../../models/kelas_model.dart';
import '../../widgets/common/app_drawer.dart';
import '../../widgets/laporan/laporan_card.dart';
import 'package:uuid/uuid.dart';

/// Manajemen laporan (OPS)
class OpsLaporanScreen extends StatefulWidget {
  const OpsLaporanScreen({super.key});

  @override
  State<OpsLaporanScreen> createState() => _OpsLaporanScreenState();
}

class _OpsLaporanScreenState extends State<OpsLaporanScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<KelasModel> _kelasList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LaporanProvider>().fetchLaporan();
    });
    _loadKelas();
  }

  Future<void> _loadKelas() async {
    try {
      final res = await ApiService.get('/kelas');
      if (mounted) {
        setState(() {
          _kelasList = (res['data'] as List).map((e) => KelasModel.fromJson(e)).toList();
        });
      }
    } catch (e) {
      // ignore
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final laporanProv = context.watch<LaporanProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            Tab(text: 'Semua (${laporanProv.allLaporan.length})'),
            Tab(text: 'Diajukan (${laporanProv.getLaporanByStatus(StatusLaporan.diajukan).length})'),
            Tab(text: 'Disetujui (${laporanProv.getLaporanByStatus(StatusLaporan.disetujui).length})'),
            Tab(text: 'Revisi (${laporanProv.getLaporanByStatus(StatusLaporan.revisi).length})'),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLaporanList(laporanProv.allLaporan),
          _buildLaporanList(laporanProv.getLaporanByStatus(StatusLaporan.diajukan)),
          _buildLaporanList(laporanProv.getLaporanByStatus(StatusLaporan.disetujui)),
          _buildLaporanList(laporanProv.getLaporanByStatus(StatusLaporan.revisi)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateLaporanDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Buat Laporan'),
      ),
    );
  }

  Widget _buildLaporanList(List<LaporanModel> list) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, size: 64, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text('Belum ada laporan', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 12, bottom: 100),
      itemCount: list.length,
      itemBuilder: (_, i) => LaporanCard(
        laporan: list[i],
        onTap: () => context.go('/ops/laporan/detail/${list[i].id}'),
      ),
    );
  }

  void _showCreateLaporanDialog(BuildContext context) {
    JenisLaporan selectedJenis = JenisLaporan.gabunganSekolah;
    String? selectedKelasId;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Buat Laporan Baru'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Jenis Laporan', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<JenisLaporan>(
                    initialValue: selectedJenis,
                    items: JenisLaporan.values.map((j) {
                      return DropdownMenuItem(value: j, child: Text(j.label));
                    }).toList(),
                    onChanged: (v) {
                      setDialogState(() {
                        selectedJenis = v!;
                        if (v == JenisLaporan.gabunganSekolah) selectedKelasId = null;
                      });
                    },
                  ),
                  if (selectedJenis == JenisLaporan.perKelas) ...[
                    const SizedBox(height: 16),
                    Text('Pilih Kelas', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: selectedKelasId,
                      decoration: const InputDecoration(hintText: 'Pilih kelas'),
                      items: _kelasList.map((k) {
                        return DropdownMenuItem(value: k.id, child: Text(k.namaKelas));
                      }).toList(),
                      onChanged: (v) => setDialogState(() => selectedKelasId = v),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedJenis == JenisLaporan.perKelas && selectedKelasId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Silakan pilih kelas terlebih dahulu')),
                      );
                      return;
                    }
                    
                    final laporanProv = context.read<LaporanProvider>();
                    final success = await laporanProv.addLaporan(LaporanModel(
                      id: const Uuid().v4(),
                      jenis: selectedJenis,
                      status: StatusLaporan.draft,
                      diajukanOleh: context.read<AuthProvider>().currentUser!.id,
                      tanggalPengajuan: DateTime.now(),
                      kelasId: selectedKelasId,
                    ));
                    if (context.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(success ? 'Laporan berhasil dibuat' : 'Gagal membuat laporan')),
                      );
                    }
                  },
                  child: const Text('Buat'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
