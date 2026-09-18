/// Model kategori barang
class KategoriModel {
  final String id;
  final String kode; // FR, EL, PK
  final String namaKategori; // Furniture, Elektronik, Perkakas

  const KategoriModel({
    required this.id,
    required this.kode,
    required this.namaKategori,
  });

  factory KategoriModel.fromJson(Map<String, dynamic> json) {
    return KategoriModel(
      id: json['id'] ?? '',
      kode: json['kode'] ?? '',
      namaKategori: json['nama_kategori'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'kode': kode,
      'nama_kategori': namaKategori,
    };
  }
}
