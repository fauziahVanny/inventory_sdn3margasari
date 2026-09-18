import '../core/constants/app_constants.dart';

/// Model barang inventaris
class BarangModel {
  final String id;
  final String kodeBarang; // auto-generate: FR_KE1_1025
  final String namaBarang;
  final String? merek;
  final String kategoriId;
  final String ruanganId;
  final String? kelasId; // nullable, jika barang di kelas
  final String? namaKategori;
  final String? namaRuangan;
  final String? namaKelas;
  final String? namaPencatat;
  final String? keteranganTambahan;
  final int jumlahLayak;
  final int jumlahRusakSedang;
  final int jumlahRusakBerat;
  final int jumlahHilang;
  final int jumlahAwal;
  final SumberDana sumberDana;
  
  int get jumlahSekarang => jumlahLayak + jumlahRusakSedang + jumlahRusakBerat + jumlahHilang;
  final DateTime tanggalPerolehan;
  final String dicatatOleh; // user id
  final DateTime updatedAt;

  const BarangModel({
    required this.id,
    required this.kodeBarang,
    required this.namaBarang,
    this.merek,
    required this.kategoriId,
    required this.ruanganId,
    this.kelasId,
    this.namaKategori,
    this.namaRuangan,
    this.namaKelas,
    this.namaPencatat,
    this.keteranganTambahan,
    required this.jumlahLayak,
    required this.jumlahRusakSedang,
    required this.jumlahRusakBerat,
    required this.jumlahHilang,
    required this.jumlahAwal,
    required this.sumberDana,
    required this.tanggalPerolehan,
    required this.dicatatOleh,
    required this.updatedAt,
  });

  BarangModel copyWith({
    String? id,
    String? kodeBarang,
    String? namaBarang,
    String? merek,
    String? kategoriId,
    String? ruanganId,
    String? kelasId,
    String? namaKategori,
    String? namaRuangan,
    String? namaKelas,
    String? namaPencatat,
    String? keteranganTambahan,
    int? jumlahLayak,
    int? jumlahRusakSedang,
    int? jumlahRusakBerat,
    int? jumlahHilang,
    int? jumlahAwal,
    SumberDana? sumberDana,
    DateTime? tanggalPerolehan,
    String? dicatatOleh,
    DateTime? updatedAt,
  }) {
    return BarangModel(
      id: id ?? this.id,
      kodeBarang: kodeBarang ?? this.kodeBarang,
      namaBarang: namaBarang ?? this.namaBarang,
      merek: merek ?? this.merek,
      kategoriId: kategoriId ?? this.kategoriId,
      ruanganId: ruanganId ?? this.ruanganId,
      kelasId: kelasId ?? this.kelasId,
      namaKategori: namaKategori ?? this.namaKategori,
      namaRuangan: namaRuangan ?? this.namaRuangan,
      namaKelas: namaKelas ?? this.namaKelas,
      namaPencatat: namaPencatat ?? this.namaPencatat,
      keteranganTambahan: keteranganTambahan ?? this.keteranganTambahan,
      jumlahLayak: jumlahLayak ?? this.jumlahLayak,
      jumlahRusakSedang: jumlahRusakSedang ?? this.jumlahRusakSedang,
      jumlahRusakBerat: jumlahRusakBerat ?? this.jumlahRusakBerat,
      jumlahHilang: jumlahHilang ?? this.jumlahHilang,
      jumlahAwal: jumlahAwal ?? this.jumlahAwal,
      sumberDana: sumberDana ?? this.sumberDana,
      tanggalPerolehan: tanggalPerolehan ?? this.tanggalPerolehan,
      dicatatOleh: dicatatOleh ?? this.dicatatOleh,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory BarangModel.fromJson(Map<String, dynamic> json) {
    SumberDana parsedSumber;
    switch (json['sumber_dana']) {
      case 'bantuan_pemerintah':
        parsedSumber = SumberDana.bantuanPemerintah;
        break;
      case 'komite_sekolah':
        parsedSumber = SumberDana.komiteSekolah;
        break;
      case 'beli_sendiri':
        parsedSumber = SumberDana.beliSendiri;
        break;
      case 'dana_bos':
      default:
        parsedSumber = SumberDana.danaBos;
        break;
    }
    
    return BarangModel(
      id: json['id'] ?? '',
      kodeBarang: json['kode_barang'] ?? '',
      namaBarang: json['nama_barang'] ?? '',
      merek: json['merek'],
      kategoriId: json['kategori_id'] ?? '',
      ruanganId: json['ruangan_id'] ?? '',
      kelasId: json['kelas_id'],
      namaKategori: json['nama_kategori'],
      namaRuangan: json['nama_ruangan'],
      namaKelas: json['nama_kelas'],
      namaPencatat: json['nama_pencatat'],
      keteranganTambahan: json['keterangan_tambahan'],
      jumlahLayak: json['jumlah_layak'] ?? 0,
      jumlahRusakSedang: json['jumlah_rusak_sedang'] ?? 0,
      jumlahRusakBerat: json['jumlah_rusak_berat'] ?? 0,
      jumlahHilang: json['jumlah_hilang'] ?? 0,
      jumlahAwal: json['jumlah_awal'] ?? 0,
      sumberDana: parsedSumber,
      tanggalPerolehan: json['tanggal_perolehan'] != null 
          ? DateTime.parse(json['tanggal_perolehan']) 
          : DateTime.now(),
      dicatatOleh: json['dicatat_oleh'] ?? '',
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    String sumberStr;
    switch (sumberDana) {
      case SumberDana.bantuanPemerintah: sumberStr = 'bantuan_pemerintah'; break;
      case SumberDana.komiteSekolah: sumberStr = 'komite_sekolah'; break;
      case SumberDana.beliSendiri: sumberStr = 'beli_sendiri'; break;
      case SumberDana.danaBos: sumberStr = 'dana_bos'; break;
    }
    
    return {
      if (id.isNotEmpty) 'id': id,
      'nama_barang': namaBarang,
      'merek': merek,
      'kategori_id': kategoriId,
      'ruangan_id': ruanganId,
      'kelas_id': kelasId,
      'keterangan_tambahan': keteranganTambahan,
      'jumlah_layak': jumlahLayak,
      'jumlah_rusak_sedang': jumlahRusakSedang,
      'jumlah_rusak_berat': jumlahRusakBerat,
      'jumlah_hilang': jumlahHilang,
      'jumlah_awal': jumlahAwal,
      'sumber_dana': sumberStr,
      'tanggal_perolehan': tanggalPerolehan.toIso8601String().split('T')[0],
    };
  }
}
