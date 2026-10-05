import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/laporan_model.dart';
import '../laporan/status_badge.dart';

/// Card laporan untuk daftar laporan
class LaporanCard extends StatelessWidget {
  final LaporanModel laporan;
  final VoidCallback? onTap;

  const LaporanCard({
    super.key,
    required this.laporan,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy', 'id');
    final namaKelas = laporan.namaKelas;


    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: laporan.jenis == JenisLaporan.gabunganSekolah
                          ? AppColors.secondarySurface
                          : AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      laporan.jenis == JenisLaporan.gabunganSekolah
                          ? Icons.summarize
                          : Icons.description_outlined,
                      color: laporan.jenis == JenisLaporan.gabunganSekolah
                          ? AppColors.secondary
                          : AppColors.primary,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          laporan.jenis == JenisLaporan.gabunganSekolah
                              ? 'Laporan Gabungan Sekolah'
                              : 'Laporan ${namaKelas ?? '(Tanpa Kelas)'}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Diajukan: ${dateFormat.format(laporan.tanggalPengajuan)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(status: laporan.status),
                ],
              ),
              // Info tambahan
              if (laporan.status == StatusLaporan.disetujui && laporan.tanggalAcc != null) ...[
                SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.kondisiLayak.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.kondisiLayak.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.verified, size: 16, color: AppColors.kondisiLayak),
                      SizedBox(width: 8),
                      Text(
                        'Disetujui: ${dateFormat.format(laporan.tanggalAcc!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.kondisiLayak,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (laporan.status == StatusLaporan.revisi && laporan.catatanRevisi != null) ...[
                SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, size: 16, color: AppColors.warning),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Catatan: ${laporan.catatanRevisi}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
