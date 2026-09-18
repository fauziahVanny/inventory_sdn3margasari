import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/laporan_provider.dart';
import '../../providers/barang_provider.dart';
import '../../models/laporan_model.dart';
import '../../widgets/common/app_drawer.dart';

/// Halaman Laporan Hasil Akhir (OPS)
///
/// Menampilkan seluruh laporan inventaris yang telah di-ACC (disetujui)
/// oleh Kepala Sekolah. Setiap item dapat diklik untuk melihat detail
/// dan memiliki tombol unduh PDF rekapitulasi inventaris final.
class OpsHasilAkhirScreen extends StatefulWidget {
  const OpsHasilAkhirScreen({super.key});

  @override
  State<OpsHasilAkhirScreen> createState() => _OpsHasilAkhirScreenState();
}

class _OpsHasilAkhirScreenState extends State<OpsHasilAkhirScreen> {
  bool _isPdfLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LaporanProvider>().fetchLaporan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final laporanProv = context.watch<LaporanProvider>();
    final laporanAcc = laporanProv
        .getLaporanByStatus(StatusLaporan.disetujui)
      ..sort((a, b) {
        // Urutkan dari yang terbaru disetujui
        final aDate = a.tanggalAksi ?? a.tanggalPengajuan;
        final bDate = b.tanggalAksi ?? b.tanggalPengajuan;
        return bDate.compareTo(aDate);
      });

    final isDesktop = MediaQuery.of(context).size.width >= 720;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Hasil Akhir'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<LaporanProvider>().fetchLaporan(),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => context.read<LaporanProvider>().fetchLaporan(),
        child: _buildBody(context, laporanProv, laporanAcc, isDesktop),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    LaporanProvider prov,
    List<LaporanModel> laporanAcc,
    bool isDesktop,
  ) {
    // ── Loading ──
    if (prov.isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Memuat laporan hasil akhir...',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    // ── Error ──
    if (prov.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_rounded,
                  size: 64, color: AppColors.error.withValues(alpha: 0.5)),
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
                prov.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.read<LaporanProvider>().fetchLaporan(),
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    // ── Empty ──
    if (laporanAcc.isEmpty) {
      return LayoutBuilder(
        builder: (_, constraints) => SingleChildScrollView(
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
                      decoration: BoxDecoration(
                        color: AppColors.kondisiLayak.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        size: 48,
                        color: AppColors.kondisiLayak,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Belum Ada Laporan Final',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Laporan yang telah disetujui (ACC) oleh\nKepala Sekolah akan tampil di sini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return isDesktop
        ? _buildDesktopLayout(context, laporanAcc)
        : _buildMobileLayout(context, laporanAcc);
  }

  // ──────────────────────────────────────────────
  // MOBILE: ListView + Card
  // ──────────────────────────────────────────────
  Widget _buildMobileLayout(
      BuildContext context, List<LaporanModel> list) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: list.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _HasilAkhirCard(
        laporan: list[i],
        isPdfLoading: _isPdfLoading,
        onTapDetail: () =>
            context.go('/ops/laporan/detail/${list[i].id}'),
        onTapPdf: () => _unduhPdf(context, list[i]),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // DESKTOP: Tabel + tombol aksi per baris
  // ──────────────────────────────────────────────
  Widget _buildDesktopLayout(
      BuildContext context, List<LaporanModel> list) {
    final dateFormat = DateFormat('dd MMM yyyy', 'id');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            children: [
              // Ikon dekoratif
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.kondisiLayak.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.workspace_premium_rounded,
                    color: AppColors.kondisiLayak, size: 24),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Laporan Hasil Akhir',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Rekapitulasi inventaris yang telah disetujui Kepala Sekolah',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.kondisiLayak.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.kondisiLayak
                          .withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_rounded,
                        size: 14, color: AppColors.kondisiLayak),
                    const SizedBox(width: 6),
                    Text(
                      '${list.length} laporan final',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.kondisiLayak,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Tabel ──
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
                    DataColumn(label: Text('Tgl Disetujui')),
                    DataColumn(label: Text('Aksi')),
                  ],
                  rows: list.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final lap = entry.value;

                    final judulLaporan =
                        lap.jenis == JenisLaporan.gabunganSekolah
                            ? 'Laporan Gabungan Sekolah'
                            : 'Laporan ${lap.namaKelas ?? "(Tanpa Kelas)"}';

                    final tglAcc = (lap.tanggalAksi ?? lap.tanggalAcc) != null
                        ? dateFormat.format(
                            lap.tanggalAksi ?? lap.tanggalAcc!)
                        : '-';

                    return DataRow(
                      cells: [
                        DataCell(Text('${idx + 1}')),
                        DataCell(
                          InkWell(
                            onTap: () => context
                                .go('/ops/laporan/detail/${lap.id}'),
                            child: ConstrainedBox(
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
                        ),
                        DataCell(Text(lap.jenis.label)),
                        DataCell(Text(lap.namaPengaju ?? '-')),
                        DataCell(Text(tglAcc)),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Tombol detail
                              Tooltip(
                                message: 'Lihat Detail',
                                child: IconButton(
                                  icon: const Icon(
                                      Icons.open_in_new_rounded,
                                      size: 18),
                                  color: AppColors.primary,
                                  onPressed: () => context.go(
                                      '/ops/laporan/detail/${lap.id}'),
                                ),
                              ),
                              const SizedBox(width: 4),
                              // Tombol PDF
                              Tooltip(
                                message: 'Unduh PDF',
                                child: IconButton(
                                  icon: _isPdfLoading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        )
                                      : const Icon(
                                          Icons.picture_as_pdf_rounded,
                                          size: 18),
                                  color: AppColors.error,
                                  onPressed: _isPdfLoading
                                      ? null
                                      : () => _unduhPdf(context, lap),
                                ),
                              ),
                            ],
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

  // ──────────────────────────────────────────────
  // Fungsi Generate & Download PDF
  // Reuse logic dari OpsDetailLaporanScreen
  // ──────────────────────────────────────────────
  Future<void> _unduhPdf(BuildContext context, LaporanModel laporan) async {
    if (_isPdfLoading) return;

    setState(() => _isPdfLoading = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⏳ Menyiapkan PDF rekapitulasi...'),
        duration: Duration(seconds: 2),
      ),
    );

    try {
      // Fetch barang sesuai jenis laporan
      final barangProv = context.read<BarangProvider>();
      if (laporan.jenis == JenisLaporan.perKelas &&
          laporan.kelasId != null) {
        await barangProv.fetchBarangByKelas(laporan.kelasId!);
      } else {
        await barangProv.fetchBarang();
      }

      final barangList =
          laporan.jenis == JenisLaporan.perKelas &&
                  laporan.kelasId != null
              ? barangProv.allBarang
                  .where((b) => b.kelasId == laporan.kelasId)
                  .toList()
              : barangProv.allBarang;

      final lingkup = laporan.jenis == JenisLaporan.gabunganSekolah
          ? 'Gabungan Sekolah'
          : laporan.namaKelas ?? 'Sekolah';

      final dateFormat = DateFormat('dd MMMM yyyy', 'id');
      final tglAcc = (laporan.tanggalAksi ?? laporan.tanggalAcc) != null
          ? dateFormat.format(laporan.tanggalAksi ?? laporan.tanggalAcc!)
          : '-';

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context ctx) => [
            // ── Kop Surat ──
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    'LAPORAN INVENTARIS FINAL',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'SDN 3 Margasari — Purwakarta',
                    style: const pw.TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            pw.Divider(thickness: 2),
            pw.SizedBox(height: 12),

            // ── Info laporan ──
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _pdfInfoRow('Lingkup', lingkup),
                      _pdfInfoRow('Jenis', laporan.jenis.label),
                      _pdfInfoRow(
                          'Diajukan Oleh', laporan.namaPengaju ?? '-'),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _pdfInfoRow('Status', 'DISETUJUI ✓'),
                      _pdfInfoRow('Tanggal ACC', tglAcc),
                      _pdfInfoRow(
                          'Disetujui Oleh',
                          laporan.namaPenyetuju ?? 'Kepala Sekolah'),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 16),

            // ── Tabel Barang ──
            pw.Text(
              'Daftar Inventaris (${barangList.length} item)',
              style: pw.TextStyle(
                  fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headers: [
                'No', 'Kode Barang', 'Nama Barang', 'Merek',
                'L', 'RS', 'RB', 'H', 'Total',
                'Tgl Masuk', 'Sumber Dana', 'Keterangan',
              ],
              data: List<List<String>>.generate(
                barangList.length,
                (i) {
                  final b = barangList[i];
                  final total = b.jumlahLayak +
                      b.jumlahRusakSedang +
                      b.jumlahRusakBerat +
                      b.jumlahHilang;
                  return [
                    '${i + 1}',
                    b.kodeBarang,
                    b.namaBarang,
                    b.merek ?? '-',
                    b.jumlahLayak.toString(),
                    b.jumlahRusakSedang.toString(),
                    b.jumlahRusakBerat.toString(),
                    b.jumlahHilang.toString(),
                    total.toString(),
                    DateFormat('dd/MM/yyyy').format(b.tanggalPerolehan),
                    b.sumberDana.label,
                    b.keteranganTambahan ?? '-',
                  ];
                },
              ),
              headerStyle: pw.TextStyle(
                  fontSize: 9, fontWeight: pw.FontWeight.bold),
              cellStyle: const pw.TextStyle(fontSize: 8),
              cellAlignments: {
                0: pw.Alignment.center,
                4: pw.Alignment.center,
                5: pw.Alignment.center,
                6: pw.Alignment.center,
                7: pw.Alignment.center,
                8: pw.Alignment.center,
              },
            ),

            // ── Ringkasan ──
            pw.SizedBox(height: 12),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 0.5),
                borderRadius:
                    const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _pdfSummaryItem(
                      'Layak',
                      '${barangList.fold(0, (s, b) => s + b.jumlahLayak)}'),
                  _pdfSummaryItem(
                      'Rusak Sedang',
                      '${barangList.fold(0, (s, b) => s + b.jumlahRusakSedang)}'),
                  _pdfSummaryItem(
                      'Rusak Berat',
                      '${barangList.fold(0, (s, b) => s + b.jumlahRusakBerat)}'),
                  _pdfSummaryItem(
                      'Hilang',
                      '${barangList.fold(0, (s, b) => s + b.jumlahHilang)}'),
                  _pdfSummaryItem(
                      'Total Item',
                      '${barangList.length}'),
                ],
              ),
            ),
            pw.SizedBox(height: 40),

            // ── Tanda tangan ──
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('Dibuat Oleh,'),
                    pw.SizedBox(height: 50),
                    pw.Text(
                      laporan.namaPengaju ?? 'Operator Sekolah',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text('Operator Sekolah'),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('Mengetahui & Menyetujui,'),
                    pw.SizedBox(height: 50),
                    pw.Text(
                      laporan.namaPenyetuju ?? 'Kepala Sekolah',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text('Kepala Sekolah'),
                  ],
                ),
              ],
            ),
          ],
        ),
      );

      final bytes = await pdf.save();
      final namaFile =
          'laporan_final_${lingkup.replaceAll(' ', '_')}_${laporan.id.substring(0, 8)}.pdf';

      if (kIsWeb) {
        final base64String = base64Encode(bytes);
        final anchor = html.AnchorElement(
            href:
                'data:application/octet-stream;base64,$base64String')
          ..target = 'blank'
          ..download = namaFile;
        html.document.body?.append(anchor);
        anchor.click();
        anchor.remove();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ PDF "$namaFile" berhasil diunduh!'),
              backgroundColor: AppColors.kondisiLayak,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Cetak PDF tersedia di versi Web. Gunakan browser untuk mengunduh.'),
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat PDF: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPdfLoading = false);
    }
  }

  pw.Widget _pdfInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 110,
            child: pw.Text('$label:',
                style: const pw.TextStyle(fontSize: 10)),
          ),
          pw.Text(value,
              style: pw.TextStyle(
                  fontSize: 10, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  pw.Widget _pdfSummaryItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(value,
            style: pw.TextStyle(
                fontSize: 13, fontWeight: pw.FontWeight.bold)),
        pw.Text(label, style: const pw.TextStyle(fontSize: 8)),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// Card untuk tampilan Mobile
// ──────────────────────────────────────────────
class _HasilAkhirCard extends StatelessWidget {
  final LaporanModel laporan;
  final bool isPdfLoading;
  final VoidCallback onTapDetail;
  final VoidCallback onTapPdf;

  const _HasilAkhirCard({
    required this.laporan,
    required this.isPdfLoading,
    required this.onTapDetail,
    required this.onTapPdf,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy', 'id');

    final judulLaporan = laporan.jenis == JenisLaporan.gabunganSekolah
        ? 'Laporan Gabungan Sekolah'
        : 'Laporan ${laporan.namaKelas ?? "(Tanpa Kelas)"}';

    final tglAcc = (laporan.tanggalAksi ?? laporan.tanggalAcc) != null
        ? dateFormat
            .format(laporan.tanggalAksi ?? laporan.tanggalAcc!)
        : 'Tidak tercatat';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTapDetail,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppColors.kondisiLayak.withValues(alpha: 0.3)),
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
                // ── Baris atas: judul + badge ACC ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ikon laporan
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.kondisiLayak
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.description_rounded,
                        size: 20,
                        color: AppColors.kondisiLayak,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            judulLaporan,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            laporan.jenis.label,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Badge ACC
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.kondisiLayak
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.kondisiLayak
                                .withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded,
                              size: 12, color: AppColors.kondisiLayak),
                          SizedBox(width: 4),
                          Text(
                            'FINAL',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.kondisiLayak,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(
                    height: 1, thickness: 1, color: AppColors.divider),
                const SizedBox(height: 12),

                // ── Info baris ──
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Oleh: ${laporan.namaPengaju ?? '-'}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.calendar_today_rounded,
                        size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      tglAcc,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Tombol aksi ──
                Row(
                  children: [
                    // Lihat Detail
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onTapDetail,
                        icon: const Icon(Icons.open_in_new_rounded,
                            size: 16),
                        label: const Text('Lihat Detail'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          textStyle: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Unduh PDF
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isPdfLoading ? null : onTapPdf,
                        icon: isPdfLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white),
                              )
                            : const Icon(Icons.picture_as_pdf_rounded,
                                size: 16),
                        label: Text(
                            isPdfLoading ? 'Menyiapkan...' : 'Unduh PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          textStyle: const TextStyle(fontSize: 13),
                        ),
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
