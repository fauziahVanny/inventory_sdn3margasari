import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/laporan_provider.dart';
import '../../providers/barang_provider.dart';
import '../../widgets/laporan/status_badge.dart';
import '../../widgets/barang/barang_card.dart';

/// Detail laporan & approval / revisi (Kepala Sekolah)
class KsDetailLaporanScreen extends StatefulWidget {
  final String laporanId;

  const KsDetailLaporanScreen({super.key, required this.laporanId});

  @override
  State<KsDetailLaporanScreen> createState() => _KsDetailLaporanScreenState();
}

class _KsDetailLaporanScreenState extends State<KsDetailLaporanScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final laporanProv = context.read<LaporanProvider>();
      final laporan = laporanProv.allLaporan.where((l) => l.id == widget.laporanId).firstOrNull;
      if (laporan != null) {
        if (laporan.jenis == JenisLaporan.perKelas && laporan.kelasId != null) {
          context.read<BarangProvider>().fetchBarangByKelas(laporan.kelasId!);
        } else {
          context.read<BarangProvider>().fetchBarang();
        }
      } else {
        context.read<BarangProvider>().fetchBarang();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final laporanProv = context.watch<LaporanProvider>();
    final laporan = laporanProv.allLaporan.where((l) => l.id == widget.laporanId).firstOrNull;

    if (laporan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Laporan')),
        body: const Center(child: Text('Laporan tidak ditemukan')),
      );
    }

    final dateFormat = DateFormat('dd MMMM yyyy', 'id');
    final namaKelas = laporan.namaKelas;
    final namaPengaju = laporan.namaPengaju;

    final barangProv = context.watch<BarangProvider>();
    // Ambil barang terkait
    final barangList = laporan.jenis == JenisLaporan.perKelas && laporan.kelasId != null
        ? barangProv.allBarang.where((b) => b.kelasId == laporan.kelasId).toList()
        : barangProv.allBarang;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Laporan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/ks/approval'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info laporan
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          laporan.jenis == JenisLaporan.gabunganSekolah
                              ? 'Laporan Gabungan Sekolah'
                              : 'Laporan ${namaKelas ?? '(Tanpa Kelas)'}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      StatusBadge(status: laporan.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _infoRow(context, 'Diajukan oleh', namaPengaju ?? '-'),
                  _infoRow(context, 'Tanggal Pengajuan', dateFormat.format(laporan.tanggalPengajuan)),
                  _infoRow(context, 'Jenis', laporan.jenis.label),
                  _infoRow(context, 'Total Barang', '${barangList.length} item'),
                  if (laporan.tanggalAcc != null)
                    _infoRow(context, 'Tanggal ACC', dateFormat.format(laporan.tanggalAcc!)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Catatan revisi (jika ada)
            if (laporan.catatanRevisi != null && laporan.catatanRevisi!.isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.warning, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Catatan Revisi',
                          style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.warning),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(laporan.catatanRevisi!, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),

            // Preview barang
            Text(
              'Preview Data Barang',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...barangList.take(5).map((b) => BarangCard(barang: b, showActions: false)),
            if (barangList.length > 5)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    '...dan ${barangList.length - 5} barang lainnya',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Action buttons (hanya jika status diajukan)
            if (laporan.status == StatusLaporan.diajukan)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showRevisiDialog(context, laporanProv),
                      icon: const Icon(Icons.replay, color: AppColors.warning),
                      label: const Text('Revisi'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.warning,
                        side: const BorderSide(color: AppColors.warning),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () => _showAccDialog(context, laporanProv),
                      icon: const Icon(Icons.verified),
                      label: const Text('Setujui (ACC)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.kondisiLayak,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showAccDialog(BuildContext context, LaporanProvider prov) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Setujui Laporan'),
        content: const Text(
          'Dengan menyetujui laporan ini, tanda tangan digital Anda akan dibubuhkan secara otomatis pada dokumen PDF.\n\nLanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              prov.setujuiLaporan(widget.laporanId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Laporan berhasil disetujui ✅'),
                  backgroundColor: AppColors.kondisiLayak,
                ),
              );
              context.go('/ks/approval');
            },
            icon: const Icon(Icons.verified),
            label: const Text('Setujui'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.kondisiLayak),
          ),
        ],
      ),
    );
  }

  void _showRevisiDialog(BuildContext context, LaporanProvider prov) {
    final catatanController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kembalikan untuk Revisi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Berikan catatan revisi untuk OPS:'),
            const SizedBox(height: 12),
            TextField(
              controller: catatanController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Tulis catatan revisi...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              prov.revisiLaporan(widget.laporanId, catatanController.text);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Laporan dikembalikan untuk revisi'),
                  backgroundColor: AppColors.warning,
                ),
              );
              context.go('/ks/approval');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: const Text('Kirim Revisi'),
          ),
        ],
      ),
    );
  }
}
