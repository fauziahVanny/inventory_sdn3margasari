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
  
  // Atribut Khusus Kategori Buku
  final String? judulBuku;
  final String? pengarang;
  final String? penerbit;
  final String? kotaTerbit;
  final String? cetakanEdisi;
  final int? tahunTerbit;
  final int? jumlahHalaman;
  final bool? ilustrasi;
  final String? ukuranBuku;
  final String? isbn;

  // Atribut Soft Delete
  final bool isHidden;

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
    
    // Inisialisasi Buku
    this.judulBuku,
    this.pengarang,
    this.penerbit,
    this.kotaTerbit,
    this.cetakanEdisi,
    this.tahunTerbit,
    this.jumlahHalaman,
    this.ilustrasi,
    this.ukuranBuku,
    this.isbn,
    
    this.isHidden = false, // Default tidak diarsipkan
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
    String? judulBuku,
    String? pengarang,
    String? penerbit,
    String? kotaTerbit,
    String? cetakanEdisi,
    int? tahunTerbit,
    int? jumlahHalaman,
    bool? ilustrasi,
    String? ukuranBuku,
    String? isbn,
    bool? isHidden,
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
      judulBuku: judulBuku ?? this.judulBuku,
      pengarang: pengarang ?? this.pengarang,
      penerbit: penerbit ?? this.penerbit,
      kotaTerbit: kotaTerbit ?? this.kotaTerbit,
      cetakanEdisi: cetakanEdisi ?? this.cetakanEdisi,
      tahunTerbit: tahunTerbit ?? this.tahunTerbit,
      jumlahHalaman: jumlahHalaman ?? this.jumlahHalaman,
      ilustrasi: ilustrasi ?? this.ilustrasi,
      ukuranBuku: ukuranBuku ?? this.ukuranBuku,
      isbn: isbn ?? this.isbn,
      isHidden: isHidden ?? this.isHidden,
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
      case 'sumbangan':
        parsedSumber = SumberDana.sumbangan;
        break;
      case 'hibah':
        parsedSumber = SumberDana.hibah;
        break;
      case 'lainnya':
        parsedSumber = SumberDana.lainnya;
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
      judulBuku: json['judul_buku'],
      pengarang: json['pengarang'],
      penerbit: json['penerbit'],
      kotaTerbit: json['kota_terbit'],
      cetakanEdisi: json['cetakan_edisi'],
      tahunTerbit: json['tahun_terbit'],
      jumlahHalaman: json['jumlah_halaman'],
      ilustrasi: json['ilustrasi'],
      ukuranBuku: json['ukuran_buku'],
      isbn: json['isbn'],
      isHidden: json['is_hidden'] ?? false,
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
      case SumberDana.sumbangan: sumberStr = 'sumbangan'; break;
      case SumberDana.hibah: sumberStr = 'hibah'; break;
      case SumberDana.lainnya: sumberStr = 'lainnya'; break;
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
      if (judulBuku != null) 'judul_buku': judulBuku,
      if (pengarang != null) 'pengarang': pengarang,
      if (penerbit != null) 'penerbit': penerbit,
      if (kotaTerbit != null) 'kota_terbit': kotaTerbit,
      if (cetakanEdisi != null) 'cetakan_edisi': cetakanEdisi,
      if (tahunTerbit != null) 'tahun_terbit': tahunTerbit,
      if (jumlahHalaman != null) 'jumlah_halaman': jumlahHalaman,
      if (ilustrasi != null) 'ilustrasi': ilustrasi,
      if (ukuranBuku != null) 'ukuran_buku': ukuranBuku,
      if (isbn != null) 'isbn': isbn,
      'is_hidden': isHidden,
      'tanggal_perolehan': tanggalPerolehan.toIso8601String().split('T')[0],
    };
  }
}