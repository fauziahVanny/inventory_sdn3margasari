/// Enum dan konstanta aplikasi Inventaris SDN 3 Margasari
library;

class AppConstants {
  // ── URL Backend ──────────────────────────────────────────────────
  // Backend Vercel Production
  // ─────────────────────────────────────────────────────────────────
  static const String baseUrl = 'https://database-sdn3margasari.vercel.app/api';
}

/// Peran pengguna dalam sistem
enum UserRole {
  waliKelas('Wali Kelas'),
  ops('Operator Sekolah'),
  kepalaSekolah('Kepala Sekolah');

  final String label;
  const UserRole(this.label);
}

/// Kondisi barang inventaris
enum KondisiBarang {
  layak('Layak'),
  rusakSedang('Rusak Sedang'),
  rusakBerat('Rusak Berat'),
  hilang('Hilang');

  final String label;
  const KondisiBarang(this.label);
}

/// Sumber perolehan/dana barang
enum SumberDana {
  bantuanPemerintah('Bantuan Pemerintah'),
  danaBos('Dana BOS'),
  komiteSekolah('Komite Sekolah'),
  beliSendiri('Beli Sendiri (Swadaya)');

  final String label;
  const SumberDana(this.label);
}

/// Status laporan
enum StatusLaporan {
  draft('Draft'),
  diajukan('Diajukan'),
  disetujui('Disetujui'),
  revisi('Revisi');

  final String label;
  const StatusLaporan(this.label);
}

/// Jenis laporan
enum JenisLaporan {
  perKelas('Per Kelas'),
  gabunganSekolah('Gabungan Sekolah');

  final String label;
  const JenisLaporan(this.label);
}
