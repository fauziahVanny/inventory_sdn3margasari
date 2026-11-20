import '../core/constants/app_constants.dart';

/// Model laporan inventaris
class LaporanModel {
  final String id;
  final JenisLaporan jenis;
  final StatusLaporan status;
  final String diajukanOleh; // user id (OPS)
  final String? disetujuiOleh; // user id (Kepala Sekolah)
  final DateTime tanggalPengajuan;
  final DateTime? tanggalAcc;
  final DateTime? tanggalAksi; // timestamp saat Kepsek klik ACC/Revisi
  final String? filePdfUrl;
  final String? catatanRevisi; // catatan dari Kepsek jika revisi
  final String? kelasId; // jika jenis == perKelas
  final String? namaPengaju;
  final String? namaPenyetuju;
  final String? namaKelas;

  // Soft delete fields
  final bool isHidden;
  final String statusData;

  // Getter to determine if laporan is seen (not hidden and not unseen)
  bool get isSeen => !isHidden && statusData != 'unseen';

  const LaporanModel({
    required this.id,
    required this.jenis,
    required this.status,
    required this.diajukanOleh,
    this.disetujuiOleh,
    required this.tanggalPengajuan,
    this.tanggalAcc,
    this.tanggalAksi, // nullable — aman untuk data lama yang belum ada field ini
    this.filePdfUrl,
    this.catatanRevisi,
    this.kelasId,
    this.namaPengaju,
    this.namaPenyetuju,
    this.namaKelas,
    this.isHidden = false,
    this.statusData = 'seen',
  });

  LaporanModel copyWith({
    String? id,
    JenisLaporan? jenis,
    StatusLaporan? status,
    String? diajukanOleh,
    String? disetujuiOleh,
    DateTime? tanggalPengajuan,
    DateTime? tanggalAcc,
    DateTime? tanggalAksi,
    String? filePdfUrl,
    String? catatanRevisi,
    String? kelasId,
    String? namaPengaju,
    String? namaPenyetuju,
    String? namaKelas,
    bool? isHidden,
    String? statusData,
  }) {
    return LaporanModel(
      id: id ?? this.id,
      jenis: jenis ?? this.jenis,
      status: status ?? this.status,
      diajukanOleh: diajukanOleh ?? this.diajukanOleh,
      disetujuiOleh: disetujuiOleh ?? this.disetujuiOleh,
      tanggalPengajuan: tanggalPengajuan ?? this.tanggalPengajuan,
      tanggalAcc: tanggalAcc ?? this.tanggalAcc,
      tanggalAksi: tanggalAksi ?? this.tanggalAksi,
      filePdfUrl: filePdfUrl ?? this.filePdfUrl,
      catatanRevisi: catatanRevisi ?? this.catatanRevisi,
      kelasId: kelasId ?? this.kelasId,
      namaPengaju: namaPengaju ?? this.namaPengaju,
      namaPenyetuju: namaPenyetuju ?? this.namaPenyetuju,
      namaKelas: namaKelas ?? this.namaKelas,
      isHidden: isHidden ?? this.isHidden,
      statusData: statusData ?? this.statusData,
    );
  }

  factory LaporanModel.fromJson(Map<String, dynamic> json) {
    JenisLaporan parsedJenis;
    switch (json['jenis']) {
      case 'gabungan_sekolah':
        parsedJenis = JenisLaporan.gabunganSekolah;
        break;
      case 'per_kelas':
      default:
        parsedJenis = JenisLaporan.perKelas;
        break;
    }

    StatusLaporan parsedStatus;
    switch (json['status']) {
      case 'diajukan':
        parsedStatus = StatusLaporan.diajukan;
        break;
      case 'disetujui':
        parsedStatus = StatusLaporan.disetujui;
        break;
      case 'revisi':
        parsedStatus = StatusLaporan.revisi;
        break;
      case 'draft':
      default:
        parsedStatus = StatusLaporan.draft;
        break;
    }

    DateTime? parsedTanggalAksi;
    try {
      if (json['tanggal_aksi'] != null) {
        parsedTanggalAksi = DateTime.parse(json['tanggal_aksi'].toString());
      }
    } catch (_) {
      parsedTanggalAksi = null;
    }

    DateTime? parsedTanggalAcc;
    try {
      if (json['tanggal_acc'] != null) {
        parsedTanggalAcc = DateTime.parse(json['tanggal_acc'].toString());
      }
    } catch (_) {
      parsedTanggalAcc = null;
    }

    return LaporanModel(
      id: json['id'] ?? '',
      jenis: parsedJenis,
      status: parsedStatus,
      diajukanOleh: json['diajukan_oleh'] ?? '',
      disetujuiOleh: json['disetujui_oleh'],
      tanggalPengajuan: json['tanggal_pengajuan'] != null
          ? DateTime.tryParse(json['tanggal_pengajuan'].toString()) ?? DateTime.now()
          : DateTime.now(),
      tanggalAcc: parsedTanggalAcc,
      tanggalAksi: parsedTanggalAksi,
      filePdfUrl: json['file_pdf_url'],
      catatanRevisi: json['catatan_revisi'],
      kelasId: json['kelas_id'],
      namaPengaju: json['nama_pengaju'],
      namaPenyetuju: json['nama_penyetuju'],
      namaKelas: json['nama_kelas'],
      isHidden: json['is_hidden'] ?? false,
      statusData: json['status_data'] ?? 'seen',
    );
  }

  Map<String, dynamic> toJson() {
    String jenisStr;
    switch (jenis) {
      case JenisLaporan.gabunganSekolah:
        jenisStr = 'gabungan_sekolah';
        break;
      case JenisLaporan.perKelas:
        jenisStr = 'per_kelas';
        break;
    }

    String statusStr;
    switch (status) {
      case StatusLaporan.draft:
        statusStr = 'draft';
        break;
      case StatusLaporan.diajukan:
        statusStr = 'diajukan';
        break;
      case StatusLaporan.disetujui:
        statusStr = 'disetujui';
        break;
      case StatusLaporan.revisi:
        statusStr = 'revisi';
        break;
    }

    return {
      if (id.isNotEmpty) 'id': id,
      'jenis': jenisStr,
      'status': statusStr,
      'diajukan_oleh': diajukanOleh,
      'disetujui_oleh': disetujuiOleh,
      'tanggal_pengajuan': tanggalPengajuan.toIso8601String(),
      'tanggal_acc': tanggalAcc?.toIso8601String(),
      'tanggal_aksi': tanggalAksi?.toIso8601String(),
      'file_pdf_url': filePdfUrl,
      'catatan_revisi': catatanRevisi,
      'kelas_id': kelasId,
      'nama_pengaju': namaPengaju,
      'nama_penyetuju': namaPenyetuju,
      'nama_kelas': namaKelas,
      'is_hidden': isHidden,
      'status_data': statusData,
    };
  }
}
