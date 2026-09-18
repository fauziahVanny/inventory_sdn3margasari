import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:printing/printing.dart';
import 'package:universal_html/html.dart' as html;
import '../models/barang_model.dart';
import '../models/user_model.dart';

class PdfHelper {
  /// Generate dokumen PDF laporan inventaris Wali Kelas.
  /// - Di Web   : langsung download via browser anchor
  /// - Di Mobile: tampilkan dialog preview/share menggunakan package `printing`
  static Future<void> generateAndDownloadWkPdf(
      BuildContext context, List<BarangModel> barangList, UserModel user) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Menyiapkan dokumen PDF...'),
        duration: Duration(seconds: 2),
      ),
    );

    final pdf = pw.Document();
    final namaKelas = user.namaKelas ?? '';
    final now = DateFormat('dd MMMM yyyy', 'id').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) {
          return [
            // Header
            pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 12),
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(width: 1.5)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'LAPORAN INVENTARIS SARANA & PRASARANA',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Kelas $namaKelas — SDN 3 Margasari Purwakarta',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Wali Kelas: ${user.nama}   |   Dicetak: $now',
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
            // Tabel
            pw.TableHelper.fromTextArray(
              headers: [
                'No', 'Kode Barang', 'Nama Barang', 'Merek/Tipe',
                'L', 'RS', 'RB', 'H', 'Total',
                'Tgl Masuk', 'Sumber Dana', 'Keterangan',
              ],
              data: List<List<String>>.generate(barangList.length, (i) {
                final b = barangList[i];
                final total = b.jumlahLayak + b.jumlahRusakSedang +
                    b.jumlahRusakBerat + b.jumlahHilang;
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
              }),
              headerStyle: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
              cellStyle: const pw.TextStyle(fontSize: 8),
              rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
              oddRowDecoration: const pw.BoxDecoration(color: PdfColors.blue50),
              cellAlignments: {
                0: pw.Alignment.center,
                4: pw.Alignment.center,
                5: pw.Alignment.center,
                6: pw.Alignment.center,
                7: pw.Alignment.center,
                8: pw.Alignment.center,
              },
            ),
            pw.SizedBox(height: 32),
            // Tanda tangan
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _ttdBox('Mengetahui,\nWali Kelas $namaKelas', user.nama, user.nip),
                _ttdBox('Mengetahui,\nKepala Sekolah', 'BUBUN MUNAWAR B., S.Pd',
                    '197207182008011001'),
              ],
            ),
          ];
        },
      ),
    );

    final bytes = await pdf.save();

    if (kIsWeb) {
      // --- Web: download via anchor ---
      final base64String = base64Encode(bytes);
      final anchor = html.AnchorElement(
          href: 'data:application/octet-stream;base64,$base64String')
        ..target = 'blank'
        ..download = 'laporan_kelas_${namaKelas.replaceAll(' ', '_')}.pdf';
      html.document.body?.append(anchor);
      anchor.click();
      anchor.remove();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ PDF berhasil diunduh!')),
        );
      }
    } else {
      // --- Mobile/Desktop: preview & share via printing ---
      if (context.mounted) {
        await Printing.layoutPdf(
          onLayout: (_) async => bytes,
          name: 'Laporan_Inventaris_Kelas_$namaKelas',
          format: PdfPageFormat.a4.landscape,
        );
      }
    }
  }

  static pw.Widget _ttdBox(String judul, String nama, String? nip) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(judul, textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(fontSize: 10)),
        pw.SizedBox(height: 50),
        pw.Container(
          width: 160,
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide()),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(nama, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        if (nip != null)
          pw.Text('NIP. $nip', style: const pw.TextStyle(fontSize: 9)),
      ],
    );
  }
}
