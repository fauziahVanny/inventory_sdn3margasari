import '../core/constants/app_constants.dart';

/// Model data pengguna sistem
class UserModel {
  final String id;
  final String nama;
  final UserRole role;
  final String? kelasId; // nullable, hanya untuk wali kelas
  final String username;
  final String password;
  final String? nip;
  final String? namaKelas; // dari profile API

  const UserModel({
    required this.id,
    required this.nama,
    required this.role,
    this.kelasId,
    required this.username,
    required this.password,
    this.nip,
    this.namaKelas,
  });

  UserModel copyWith({
    String? id,
    String? nama,
    UserRole? role,
    String? kelasId,
    String? username,
    String? password,
    String? nip,
    String? namaKelas,
  }) {
    return UserModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      role: role ?? this.role,
      kelasId: kelasId ?? this.kelasId,
      username: username ?? this.username,
      password: password ?? this.password,
      nip: nip ?? this.nip,
      namaKelas: namaKelas ?? this.namaKelas,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    UserRole parsedRole;
    switch (json['role']) {
      case 'kepala_sekolah':
        parsedRole = UserRole.kepalaSekolah;
        break;
      case 'wali_kelas':
        parsedRole = UserRole.waliKelas;
        break;
      case 'guru_pai':
      case 'guru_pendidikan_agama_islam':
        parsedRole = UserRole.guruPAI;
        break;
      case 'guru_pjok':
        parsedRole = UserRole.guruPJOK;
        break;
      case 'penjaga_sekolah':
        parsedRole = UserRole.penjagaSekolah;
        break;
      case 'ops':
      default:
        parsedRole = UserRole.ops;
        break;
    }
    return UserModel(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      role: parsedRole,
      kelasId: json['kelas_id'],
      username: json['username'] ?? '',
      password: '', // API tidak mengembalikan password
      nip: json['nip'],
      namaKelas: json['nama_kelas'],
    );
  }

  Map<String, dynamic> toJson() {
    String roleStr;
    switch (role) {
      case UserRole.kepalaSekolah: roleStr = 'kepala_sekolah'; break;
      case UserRole.waliKelas: roleStr = 'wali_kelas'; break;
      case UserRole.guruPAI: roleStr = 'guru_pai'; break;
      case UserRole.guruPJOK: roleStr = 'guru_pjok'; break;
      case UserRole.penjagaSekolah: roleStr = 'penjaga_sekolah'; break;
      case UserRole.ops: roleStr = 'ops'; break;
    }
    return {
      'id': id,
      'nama': nama,
      'role': roleStr,
      'kelas_id': kelasId,
      'username': username,
      'nip': nip,
    };
  }
}
