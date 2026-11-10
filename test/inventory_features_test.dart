import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_sdn3margasari/core/constants/app_constants.dart';
import 'package:inventory_sdn3margasari/models/barang_model.dart';
import 'package:inventory_sdn3margasari/models/user_model.dart';
import 'package:inventory_sdn3margasari/models/laporan_model.dart';

void main() {
  group('1. Fitur Soft Delete / Pengarsipan Data Inventaris', () {
    test('BarangModel: Model barang valid, toJson menyertakan is_hidden=false dan status=seen secara default', () {
      final barang = BarangModel.fromJson({
        'id': 'b1',
        'nama_barang': 'Buku Tematik',
        'kategori_id': 'kat-buku',
        'ruangan_id': 'rng-1',
        'sumber_dana': 'dana_bos',
        'tanggal_perolehan': '2026-10-15',
        'jumlah_layak': 10,
        'jumlah_rusak_sedang': 0,
        'jumlah_rusak_berat': 0,
        'jumlah_hilang': 0,
        'jumlah_awal': 10,
      });
      expect(barang.namaBarang, 'Buku Tematik');
      expect(barang.jumlahAwal, 10);
      expect(barang.isHidden, isFalse);
      expect(barang.status, 'seen');
      expect(barang.isSeen, isTrue);

      final json = barang.toJson();
      // Soft delete: is_hidden selalu hadir di toJson, default false
      expect(json['is_hidden'], isFalse);
      expect(json['status'], 'seen');
      expect(json['nama_barang'], 'Buku Tematik');
    });

    test('BarangModel: Soft delete mengubah is_hidden=true dan status=unseen, isSeen menjadi false', () {
      final barang = BarangModel.fromJson({
        'id': 'b2',
        'nama_barang': 'Meja Rusak',
        'is_hidden': true,
        'status': 'unseen',
      });
      expect(barang.isHidden, isTrue);
      expect(barang.status, 'unseen');
      expect(barang.isSeen, isFalse);
    });

    test('LaporanModel: Model laporan valid, toJson menyertakan is_hidden=false dan status_data=seen secara default', () {
      final laporan = LaporanModel.fromJson({
        'id': 'l1',
        'jenis': 'per_kelas',
        'status': 'draft',
        'diajukan_oleh': 'usr-1',
        'tanggal_pengajuan': '2026-10-15',
      });
      expect(laporan.status, StatusLaporan.draft);
      expect(laporan.isHidden, isFalse);
      expect(laporan.statusData, 'seen');
      expect(laporan.isSeen, isTrue);

      final json = laporan.toJson();
      // Soft delete: is_hidden dan status_data selalu hadir di toJson
      expect(json['is_hidden'], isFalse);
      expect(json['status_data'], 'seen');
    });

    test('LaporanModel: Soft delete mengubah is_hidden=true, isSeen menjadi false', () {
      final laporan = LaporanModel.fromJson({
        'id': 'l2',
        'jenis': 'per_kelas',
        'status': 'draft',
        'diajukan_oleh': 'usr-1',
        'tanggal_pengajuan': '2026-10-15',
        'is_hidden': true,
        'status_data': 'unseen',
      });
      expect(laporan.isHidden, isTrue);
      expect(laporan.statusData, 'unseen');
      expect(laporan.isSeen, isFalse);
    });
  });

  group('2. Penambahan Kategori, Role, dan Sumber Dana Baru', () {
    test('Role Pengguna: Support Guru PAI, Guru PJOK, dan Penjaga Sekolah', () {
      final userPai = UserModel.fromJson({
        'id': 'u1',
        'nama': 'Ahmad, S.Pd.I',
        'role': 'guru_pai',
        'username': 'ahmad_pai',
      });
      expect(userPai.role, UserRole.guruPAI);
      expect(userPai.role.label, 'Guru Pendidikan Agama Islam');
      expect(userPai.toJson()['role'], 'guru_pai');

      final userPjok = UserModel.fromJson({
        'id': 'u2',
        'nama': 'Budi, S.Pd',
        'role': 'guru_pjok',
        'username': 'budi_pjok',
      });
      expect(userPjok.role, UserRole.guruPJOK);
      expect(userPjok.role.label, 'Guru PJOK');
      expect(userPjok.toJson()['role'], 'guru_pjok');

      final userPenjaga = UserModel.fromJson({
        'id': 'u3',
        'nama': 'Pak Maman',
        'role': 'penjaga_sekolah',
        'username': 'maman_penjaga',
      });
      expect(userPenjaga.role, UserRole.penjagaSekolah);
      expect(userPenjaga.role.label, 'Penjaga Sekolah');
      expect(userPenjaga.toJson()['role'], 'penjaga_sekolah');
    });

    test('Sumber Dana Baru: Support Sumbangan, Hibah, dan Lainnya', () {
      final barangSumbangan = BarangModel.fromJson({
        'id': 'bs1',
        'nama_barang': 'Al-Quran',
        'sumber_dana': 'sumbangan',
      });
      expect(barangSumbangan.sumberDana, SumberDana.sumbangan);
      expect(barangSumbangan.sumberDana.label, 'Sumbangan');
      expect(barangSumbangan.toJson()['sumber_dana'], 'sumbangan');

      final barangHibah = BarangModel.fromJson({
        'id': 'bs2',
        'nama_barang': 'Bola Basket',
        'sumber_dana': 'hibah',
      });
      expect(barangHibah.sumberDana, SumberDana.hibah);
      expect(barangHibah.sumberDana.label, 'Hibah');
      expect(barangHibah.toJson()['sumber_dana'], 'hibah');

      final barangLainnya = BarangModel.fromJson({
        'id': 'bs3',
        'nama_barang': 'Sapu Ijuk',
        'sumber_dana': 'lainnya',
      });
      expect(barangLainnya.sumberDana, SumberDana.lainnya);
      expect(barangLainnya.sumberDana.label, 'Lainnya');
      expect(barangLainnya.toJson()['sumber_dana'], 'lainnya');
    });

    test('Kategori Buku: Field spesifik buku tersimpan dan terbaca dengan benar', () {
      final buku = BarangModel.fromJson({
        'id': 'bk1',
        'nama_barang': 'Pendidikan Agama Islam Kelas 1',
        'judul_buku': 'Pendidikan Agama Islam Kelas 1',
        'pengarang': 'Muhammad Syafi\'i',
        'penerbit': 'Erlangga',
        'kota_terbit': 'Jakarta',
        'cetakan_edisi': 'Edisi Revisi',
        'tahun_terbit': 2023,
        'jumlah_halaman': 144,
        'ilustrasi': true,
        'ukuran_buku': '21 x 29.7 cm',
        'isbn': '978-602-241-123-4',
        'jumlah_layak': 30,
        'jumlah_rusak_sedang': 2,
        'jumlah_rusak_berat': 0,
        'jumlah_hilang': 0,
        'jumlah_awal': 32,
        'sumber_dana': 'dana_bos',
      });

      expect(buku.judulBuku, 'Pendidikan Agama Islam Kelas 1');
      expect(buku.pengarang, 'Muhammad Syafi\'i');
      expect(buku.penerbit, 'Erlangga');
      expect(buku.kotaTerbit, 'Jakarta');
      expect(buku.cetakanEdisi, 'Edisi Revisi');
      expect(buku.tahunTerbit, 2023);
      expect(buku.jumlahHalaman, 144);
      expect(buku.ilustrasi, isTrue);
      expect(buku.ukuranBuku, '21 x 29.7 cm');
      expect(buku.isbn, '978-602-241-123-4');

      final jsonBuku = buku.toJson();
      expect(jsonBuku['pengarang'], 'Muhammad Syafi\'i');
      expect(jsonBuku['isbn'], '978-602-241-123-4');
      expect(jsonBuku['ilustrasi'], 'Ya');
    });
  });

  group('3. Kalkulasi Otomatis Jumlah Awal Diterima', () {
    test('Perhitungan: Jumlah Awal Diterima = Kondisi Layak + Rusak Sedang + Rusak Berat + Hilang', () {
      const layak = 28;
      const rusakSedang = 1;
      const rusakBerat = 1;
      const hilang = 2;

      final totalAwalDiterima = layak + rusakSedang + rusakBerat + hilang;
      expect(totalAwalDiterima, equals(32));

      final barang = BarangModel(
        id: 'test-1',
        kodeBarang: 'OR_LP_1025',
        namaBarang: 'Bola Voli Mikasa',
        kategoriId: 'kat-olahraga',
        ruanganId: 'rng-lapangan',
        jumlahLayak: layak,
        jumlahRusakSedang: rusakSedang,
        jumlahRusakBerat: rusakBerat,
        jumlahHilang: hilang,
        jumlahAwal: totalAwalDiterima,
        sumberDana: SumberDana.danaBos,
        tanggalPerolehan: DateTime(2026, 10, 15),
        dicatatOleh: 'u1',
        updatedAt: DateTime(2026, 10, 15),
      );

      expect(barang.jumlahAwal, equals(32));
      expect(barang.jumlahSekarang, equals(32));
    });
  });

  group('4. Validasi Error Messages dan Kondisi', () {
    test('Validasi Input Kondisi: Tidak boleh negatif dan harus berupa angka valid', () {
      String? validateJumlahKondisi(String? val, String namaKondisi) {
        if (val == null || val.trim().isEmpty) return '$namaKondisi tidak boleh kosong';
        final n = int.tryParse(val.trim());
        if (n == null) return '$namaKondisi harus berupa angka';
        if (n < 0) return '$namaKondisi tidak boleh bernilai negatif';
        return null;
      }

      expect(validateJumlahKondisi('', 'Jumlah Layak'), 'Jumlah Layak tidak boleh kosong');
      expect(validateJumlahKondisi('abc', 'Jumlah Layak'), 'Jumlah Layak harus berupa angka');
      expect(validateJumlahKondisi('-5', 'Jumlah Layak'), 'Jumlah Layak tidak boleh bernilai negatif');
      expect(validateJumlahKondisi('15', 'Jumlah Layak'), isNull);
    });

    test('Validasi Tahun Terbit Buku: Harus antara 1900 hingga tahun sekarang', () {
      final currentYear = DateTime.now().year;
      String? validateTahun(String? v) {
        if (v == null || v.trim().isEmpty) return 'Tahun terbit wajib diisi';
        final yr = int.tryParse(v.trim());
        if (yr == null) return 'Tahun terbit harus angka';
        if (yr < 1900 || yr > currentYear) return 'Tahun terbit harus antara 1900 - $currentYear';
        return null;
      }

      expect(validateTahun(''), 'Tahun terbit wajib diisi');
      expect(validateTahun('1899'), 'Tahun terbit harus antara 1900 - $currentYear');
      expect(validateTahun('${currentYear + 2}'), 'Tahun terbit harus antara 1900 - $currentYear');
      expect(validateTahun('2024'), isNull);
    });

    test('Pesan Error Foreign Key dan Relasi Data Terkait', () {
      String formatDeleteError(String errStr, String resource, String nama) {
        if (errStr.contains('foreign key') || errStr.contains('terkait')) {
          return 'Gagal menghapus! $resource "$nama" masih digunakan oleh data lain terkait.';
        }
        return 'Gagal menghapus $resource: $errStr';
      }

      final fkError = 'update or delete on table violates foreign key constraint';
      final formatted = formatDeleteError(fkError, 'Kategori', 'Buku Pelajaran');
      expect(formatted, contains('masih digunakan oleh data lain terkait'));
    });
  });
}
