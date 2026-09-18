import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/barang_provider.dart';

/// Detail satu barang inventaris
class WkDetailBarangScreen extends StatelessWidget {
  final String barangId;

  const WkDetailBarangScreen({super.key, required this.barangId});

  @override
  Widget build(BuildContext context) {
    final barangProv = context.watch<BarangProvider>();
    final barang = barangProv.allBarang.where((b) => b.id == barangId).firstOrNull;

    if (barang == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Barang')),
        body: const Center(child: Text('Barang tidak ditemukan')),
      );
    }

    final dateFormat = DateFormat('dd MMMM yyyy', 'id');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Barang'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/wk/barang'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.go('/wk/barang/edit/${barang.id}'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          barang.namaBarang,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      barang.kodeBarang,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.95),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _statBubble('Jumlah Awal', '${barang.jumlahAwal}'),
                      const SizedBox(width: 12),
                      _statBubble('Jumlah Sekarang', '${barang.jumlahSekarang}'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Rincian Kondisi
            _buildSection(context, 'Rincian Kondisi', [
              _infoRow(context, 'Layak', '${barang.jumlahLayak} unit', Icons.check_circle_outline, color: AppColors.success),
              _infoRow(context, 'Rusak Sedang', '${barang.jumlahRusakSedang} unit', Icons.build_outlined, color: AppColors.warning),
              _infoRow(context, 'Rusak Berat', '${barang.jumlahRusakBerat} unit', Icons.error_outline, color: AppColors.error),
              _infoRow(context, 'Hilang', '${barang.jumlahHilang} unit', Icons.help_outline, color: Colors.grey),
            ]),
            const SizedBox(height: 20),

            // Detail info
            _buildSection(context, 'Informasi Barang', [
              if (barang.merek != null && barang.merek!.isNotEmpty)
                _infoRow(context, 'Merek', barang.merek!, Icons.branding_watermark_outlined),
              _infoRow(context, 'Kategori', barang.namaKategori ?? '-', Icons.category_outlined),
              _infoRow(context, 'Ruangan', barang.namaRuangan ?? '-', Icons.room_outlined),
              _infoRow(context, 'Sumber Dana', barang.sumberDana.label, Icons.account_balance_wallet_outlined),
              _infoRow(context, 'Tanggal Perolehan', dateFormat.format(barang.tanggalPerolehan), Icons.calendar_today_outlined),
              if (barang.keteranganTambahan != null && barang.keteranganTambahan!.isNotEmpty) ...[
                const Divider(height: 24),
                _infoRow(context, 'Keterangan Tambahan', barang.keteranganTambahan!, Icons.info_outline),
              ],
            ]),
            const SizedBox(height: 16),
            _buildSection(context, 'Informasi Pencatatan', [
              _infoRow(context, 'Dicatat Oleh', barang.namaPencatat ?? '-', Icons.person_outline),
              _infoRow(context, 'Terakhir Diperbarui', dateFormat.format(barang.updatedAt), Icons.update),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _statBubble(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value, IconData icon, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
