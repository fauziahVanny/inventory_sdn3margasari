/// Model data ruangan
class RuanganModel {
  final String id;
  final String kode; // KE, PE, KS, GR
  final String namaRuangan; // Kelas, Perpustakaan, dll

  const RuanganModel({
    required this.id,
    required this.kode,
    required this.namaRuangan,
  });

  factory RuanganModel.fromJson(Map<String, dynamic> json) {
    return RuanganModel(
      id: json['id'] ?? '',
      kode: json['kode'] ?? '',
      namaRuangan: json['nama_ruangan'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'kode': kode,
      'nama_ruangan': namaRuangan,
    };
  }
}
