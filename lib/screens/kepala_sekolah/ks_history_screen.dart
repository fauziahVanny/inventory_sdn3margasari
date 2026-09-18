import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/laporan_provider.dart';
import '../../models/laporan_model.dart';
import '../../widgets/common/app_drawer.dart';

/// Halaman History Laporan — hanya menampilkan laporan dengan status
/// "Disetujui (ACC)" atau "Revisi" yang sudah ditindaklanjuti Kepala Sekolah.
///
/// Null-safety: field [tanggalAksi] bisa null untuk data lama;
/// tampilan akan fallback ke "-" tanpa crash.
class KsHistoryScreen extends StatefulWidget {
  const KsHistoryScreen({super.key});

  @override
  State<KsHistoryScreen> createState() => _KsHistoryScreenState();
}

class _KsHistoryScreenState extends State<KsHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LaporanProvider>().fetchLaporanHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final laporanProv = context.watch<LaporanProvider>();
    final isDesktop = MediaQuery.of(context).size.width >= 720;

    return Scaffold(
      appBar: AppBar(
        title: const Text('History Laporan'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                context.read<LaporanProvider>().fetchLaporanHistory(),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () =>
            context.read<LaporanProvider>().fetchLaporanHistory(),
        child: _buildBody(context, laporanProv, isDesktop),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    LaporanProvider prov,
    bool isDesktop,
  ) {
    // ── Loading State ──
    if (prov.isLoadingHistory) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Memuat history laporan...',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    // ── Error State ──
    if (prov.historyError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 64,
                color: AppColors.error.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'Gagal Memuat Data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                prov.historyError!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () =>
                    context.read<LaporanProvider>().fetchLaporanHistory(),
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    // ── Empty State ──
    if (prov.historyList.isEmpty) {
      return LayoutBuilder(
        builder: (ctx, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(
                        color: AppColors.primarySurface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.history_toggle_off_rounded,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Belum Ada History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'History laporan yang telah di-ACC atau\ndiminta Revisi akan muncul di sini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // ── Data tersedia ──
    return isDesktop
        ? _buildDesktopLayout(context, prov.historyList)
        : _buildMobileLayout(context, prov.historyList);
  }

  // ─────────────────────────────────────────────
  // LAYOUT MOBILE: ListView + Card vertikal
  // Aman dari overflow — setiap item dalam Card terpisah
  // ─────────────────────────────────────────────
  Widget _buildMobileLayout(BuildContext context, List<LaporanModel> list) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: list.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _HistoryCard(
        laporan: list[i],
        onTap: () => context.go('/ks/history/detail/${list[i].id}'),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // LAYOUT DESKTOP/WEB: DataTable lebar
  // ─────────────────────────────────────────────
  Widget _buildDesktopLayout(BuildContext context, List<LaporanModel> list) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'History Laporan',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${list.length} laporan',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Laporan yang telah ditindaklanjuti (ACC / Revisi)',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor:
                      WidgetStateProperty.all(AppColors.background),
                  headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  dataTextStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                  dividerThickness: 1,
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(label: Text('No')),
                    DataColumn(label: Text('Judul Laporan')),
                    DataColumn(label: Text('Jenis')),
                    DataColumn(label: Text('Diajukan Oleh')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Tanggal Aksi')),
                    DataColumn(label: Text('Aksi')),
                  ],
                  rows: list.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final lap = entry.value;
                    final isAcc = lap.status == StatusLaporan.disetujui;

                    // Null-safe: tanggalAksi null untuk data lama → tampilkan "-"
                    final tanggalAksiStr = lap.tanggalAksi != null
                        ? dateFormat.format(lap.tanggalAksi!)
                        : '-';

                    final judulLaporan =
                        lap.jenis == JenisLaporan.gabunganSekolah
                            ? 'Laporan Gabungan Sekolah'
                            : 'Laporan ${lap.namaKelas ?? "(Tanpa Kelas)"}';

                    return DataRow(
                      onSelectChanged: (_) =>
                          context.go('/ks/history/detail/${lap.id}'),
                      cells: [
                        DataCell(Text('${idx + 1}')),
                        DataCell(
                          ConstrainedBox(
                            constraints:
                                const BoxConstraints(maxWidth: 220),
                            child: Text(
                              judulLaporan,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        DataCell(Text(lap.jenis.label)),
                        DataCell(Text(lap.namaPengaju ?? '-')),
                        DataCell(
                          _StatusChip(status: lap.status, isAcc: isAcc),
                        ),
                        DataCell(Text(tanggalAksiStr)),
                        DataCell(
                          Tooltip(
                            message: 'Lihat Detail',
                            child: IconButton(
                              icon: const Icon(Icons.open_in_new_rounded,
                                  size: 18),
                              color: AppColors.primary,
                              onPressed: () => context
                                  .go('/ks/history/detail/${lap.id}'),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Card untuk tampilan Mobile
// ──────────────────────────────────────────────────────────
class _HistoryCard extends StatelessWidget {
  final LaporanModel laporan;
  final VoidCallback? onTap;

  const _HistoryCard({required this.laporan, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isAcc = laporan.status == StatusLaporan.disetujui;
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id');

    final judulLaporan = laporan.jenis == JenisLaporan.gabunganSekolah
        ? 'Laporan Gabungan Sekolah'
        : 'Laporan ${laporan.namaKelas ?? "(Tanpa Kelas)"}';

    // Null-safe: tampilkan teks fallback jika data lama tidak memiliki tanggalAksi
    final tanggalAksiStr = laporan.tanggalAksi != null
        ? dateFormat.format(laporan.tanggalAksi!)
        : 'Data lama (tidak tercatat)';

    final statusColor = isAcc ? AppColors.kondisiLayak : AppColors.warning;
    final statusBgColor = isAcc
        ? AppColors.kondisiLayak.withValues(alpha: 0.1)
        : AppColors.warning.withValues(alpha: 0.1);
    final statusIcon =
        isAcc ? Icons.verified_rounded : Icons.replay_rounded;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
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
            // Judul + badge status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    judulLaporan,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _StatusChip(status: laporan.status, isAcc: isAcc),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.category_outlined,
              label: 'Jenis',
              value: laporan.jenis.label,
            ),
            const SizedBox(height: 6),
            _InfoRow(
              icon: Icons.person_outline_rounded,
              label: 'Diajukan Oleh',
              value: laporan.namaPengaju ?? '-',
            ),
            const SizedBox(height: 6),
            const Divider(height: 16, thickness: 1, color: AppColors.divider),

            // Tanggal aksi — dengan indikator warna sesuai status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(statusIcon, size: 14, color: statusColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tanggal Aksi',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tanggalAksiStr,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          // Abu-abu & italic untuk data lama yang null
                          color: laporan.tanggalAksi != null
                              ? AppColors.textPrimary
                              : AppColors.textHint,
                          fontStyle: laporan.tanggalAksi != null
                              ? FontStyle.normal
                              : FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Badge status dengan indikator warna
// Hijau = ACC, Kuning/Orange = Revisi
// ──────────────────────────────────────────────────────────
class _StatusChip extends StatelessWidget {
  final StatusLaporan status;
  final bool isAcc;

  const _StatusChip({required this.status, required this.isAcc});

  @override
  Widget build(BuildContext context) {
    final color = isAcc ? AppColors.kondisiLayak : AppColors.warning;
    final bgColor = isAcc
        ? AppColors.kondisiLayak.withValues(alpha: 0.12)
        : AppColors.warning.withValues(alpha: 0.12);
    final icon = isAcc ? Icons.check_circle_rounded : Icons.replay_rounded;
    final label = isAcc ? 'ACC' : 'Revisi';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Row info untuk mobile card
// ──────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
