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
import '../../models/user_model.dart';
import '../../providers/laporan_provider.dart';
import '../../providers/barang_provider.dart';
import '../../widgets/laporan/status_badge.dart';
import '../../widgets/barang/barang_card.dart';

/// Detail laporan untuk OPS dengan opsi cetak PDF
class OpsDetailLaporanScreen extends StatefulWidget {
  final String laporanId;

  const OpsDetailLaporanScreen({super.key, required this.laporanId});

  @override
  State<OpsDetailLaporanScreen> createState() => _OpsDetailLaporanScreenState();
}

class _OpsDetailLaporanScreenState extends State<OpsDetailLaporanScreen> {
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
    final barangList = laporan.jenis == JenisLaporan.perKelas && laporan.kelasId != null
        ? barangProv.allBarang.where((b) => b.kelasId == laporan.kelasId).toList()
        : barangProv.allBarang;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Laporan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/ops/laporan'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _generateAndDownloadPdf(context, laporan, namaKelas ?? 'Sekolah', namaPengaju, barangList),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Laporan
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
                        const Text(
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

            // Daftar Barang
            Text(
              'Daftar Barang',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...barangList.map((b) => BarangCard(barang: b, showActions: false)),
            const SizedBox(height: 24),

            // Tombol Aksi
            if (laporan.status == StatusLaporan.draft || laporan.status == StatusLaporan.revisi)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final success = await context.read<LaporanProvider>().ajukanLaporan(laporan.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(success ? 'Laporan berhasil diajukan' : 'Gagal mengajukan laporan')),
                      );
                      if (success) {
                        context.go('/ops/laporan');
                      }
                    }
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Ajukan ke Kepala Sekolah'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Hapus Laporan'),
                        content: const Text('Apakah Anda yakin ingin menghapus laporan ini? Data yang sudah dihapus tidak dapat dikembalikan.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && context.mounted) {
                      final success = await context.read<LaporanProvider>().hapusLaporan(laporan.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(success ? 'Laporan berhasil dihapus' : 'Gagal menghapus laporan')),
                        );
                        if (success) {
                          context.go('/ops/laporan');
                        }
                      }
                    }
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text('Hapus Laporan', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => _generateAndDownloadPdf(context, laporan, namaKelas ?? 'Sekolah', namaPengaju, barangList),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Cetak Dokumen PDF'),
              ),
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

  Future<void> _generateAndDownloadPdf(BuildContext context, laporan, String lingkup, String? namaPengaju, List barangList) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Menyiapkan dokumen PDF...')),
    );

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text('Laporan Inventaris SDN 3 Margasari', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Lingkup: $lingkup', style: const pw.TextStyle(fontSize: 14)),
            pw.Text('Diajukan oleh: ${namaPengaju ?? '-'}', style: const pw.TextStyle(fontSize: 14)),
            pw.Text('Status: ${laporan.status.label}', style: const pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: ['No', 'Kode Barang', 'Nama', 'Merek', 'L', 'RS', 'RB', 'H', 'Tgl Masuk', 'Asal Barang', 'Keterangan'],
              data: List<List<String>>.generate(
                barangList.length,
                (index) {
                  final b = barangList[index];
                  return [
                    '${index + 1}',
                    b.kodeBarang,
                    b.namaBarang,
                    b.merek ?? '-',
                    b.jumlahLayak.toString(),
                    b.jumlahRusakSedang.toString(),
                    b.jumlahRusakBerat.toString(),
                    b.jumlahHilang.toString(),
                    DateFormat('dd/MM/yyyy').format(b.tanggalPerolehan),
                    b.sumberDana.label,
                    b.keteranganTambahan ?? '-',
                  ];
                },
              ),
              headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              cellStyle: const pw.TextStyle(fontSize: 9),
            ),
            pw.SizedBox(height: 50),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  children: [
                    pw.Text('Diajukan Oleh,'),
                    pw.SizedBox(height: 60),
                    pw.Text(namaPengaju ?? 'SITI MUNIRAH, S.Pd'),
                    pw.Text('Operator Sekolah'),
                    pw.Text('NIP. 199611152025212070'),
                  ],
                ),
                if (laporan.status == StatusLaporan.disetujui)
                  pw.Column(
                    children: [
                      pw.Text('Disetujui Oleh,'),
                      pw.SizedBox(height: 60),
                      pw.Text('${laporan.namaPenyetuju ?? 'BUBUN MUNAWAR B., S.Pd'}\nKepala Sekolah', textAlign: pw.TextAlign.center),
                      pw.Text('NIP. 197207182008011001'),
                    ],
                  ),
              ],
            ),
          ];
        },
      ),
    );

    final bytes = await pdf.save();

    if (kIsWeb) {
      // Web download logic
      final base64String = base64Encode(bytes);
      final anchor = html.AnchorElement(href: 'data:application/octet-stream;base64,$base64String')
        ..target = 'blank'
        ..download = 'laporan_inventaris_${laporan.id}.pdf';
      
      html.document.body?.append(anchor);
      anchor.click();
      anchor.remove();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF berhasil diunduh!')),
        );
      }
    } else {
      // Fallback for mobile since printing plugin couldn't be installed
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cetak PDF saat ini baru didukung penuh di versi Web/Desktop.'),
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
