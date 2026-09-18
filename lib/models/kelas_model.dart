/// Model data kelas
class KelasModel {
  final String id;
  final String namaKelas; // e.g. "Kelas 1"
  final String? waliKelasId; // relasi ke user

  const KelasModel({
    required this.id,
    required this.namaKelas,
    this.waliKelasId,
  });

  factory KelasModel.fromJson(Map<String, dynamic> json) {
    return KelasModel(
      id: json['id'] ?? '',
      namaKelas: json['nama_kelas'] ?? '',
      waliKelasId: json['wali_kelas_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'nama_kelas': namaKelas,
      'wali_kelas_id': waliKelasId,
    };
  }
}
