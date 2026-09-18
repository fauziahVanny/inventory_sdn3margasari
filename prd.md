# Product Requirements Document (PRD)
## Sistem Inventarisasi Sarana dan Prasarana Berbasis Multi-Platform
### Studi Kasus: SDN 3 Margasari, Purwakarta

---

## 1. Informasi Dokumen

| Item | Keterangan |
|---|---|
| Judul Proyek | Rancang Bangun Sistem Inventarisasi Sarana dan Prasarana Berbasis Multi-Platform di SDN 3 Margasari Purwakarta |
| Jenis Dokumen | Kerja Praktik (KP) – Pendekatan Software Engineering, penyelesaian *by project* |
| Instansi Mitra | SDN 3 Margasari, Purwakarta |
| Metodologi Pengembangan | Agile (perubahan dari Prototype, karena kebutuhan operator sekolah sering berubah secara mendadak) |
| Framework | Flutter (multi-platform: Android, iOS, Web/Desktop) |
| Versi Dokumen | 1.0 |
| Status | Draft |

---

## 2. Latar Belakang

SDN 3 Margasari Purwakarta saat ini mengelola data inventaris sarana dan prasarana (sarpras) kelas maupun ruangan lain secara manual/tidak terpusat. Proses pencatatan barang, pembaruan kondisi barang, dan pelaporan ke kepala sekolah maupun ke pihak atasan (dinas) memakan waktu lama, rawan human error, dan sulit dikoordinasikan karena melibatkan banyak pihak: wali kelas per kelas, operator sekolah (OPS), dan kepala sekolah.

Dibutuhkan sebuah sistem informasi inventaris berbasis aplikasi yang memungkinkan:
- Wali kelas mencatat dan memperbarui data inventaris kelasnya masing-masing secara mandiri.
- Data dari seluruh kelas terkumpul otomatis ke satu database terpusat.
- Operator sekolah (OPS) dapat merekap seluruh data menjadi satu laporan sekolah.
- Kepala sekolah dapat melakukan persetujuan (ACC) laporan secara digital.
- Laporan akhir dapat dicetak dalam format PDF, lengkap dengan tanda tangan kepala sekolah.

## 3. Tujuan Proyek

1. Memudahkan wali kelas dalam mencatat dan memperbarui data inventaris kelas masing-masing.
2. Memusatkan (sentralisasi) seluruh data inventaris sekolah dalam satu sistem/database.
3. Memudahkan OPS dalam merekap laporan dari seluruh kelas menjadi satu laporan sekolah.
4. Menyederhanakan proses persetujuan (ACC) laporan oleh kepala sekolah.
5. Menghasilkan laporan inventaris dalam format PDF yang siap dicetak dan dilaporkan ke atasan/dinas.
6. Menyediakan sistem pengkodean barang yang konsisten dan mudah ditelusuri.

## 4. Ruang Lingkup (Scope)

### 4.1 Termasuk dalam Ruang Lingkup (In-Scope)
- Manajemen data inventaris per kelas (CRUD) oleh wali kelas.
- Manajemen data inventaris ruangan non-kelas (perpustakaan, ruang guru, ruang kepala sekolah) — sesuai kode ruangan yang didefinisikan.
- Rekapitulasi otomatis seluruh data kelas menjadi satu laporan sekolah oleh OPS.
- Alur persetujuan (approval workflow) laporan oleh kepala sekolah.
- Fitur cetak laporan ke PDF (per kelas maupun laporan gabungan seluruh sekolah).
- Sistem penggunaan kode barang otomatis/semi-otomatis.
- Autentikasi & manajemen peran pengguna (role-based access): Wali Kelas, OPS, Kepala Sekolah.
- Riwayat perubahan data barang (jumlah awal vs jumlah sekarang, kondisi, dsb).

### 4.2 Tidak Termasuk dalam Ruang Lingkup (Out-of-Scope)
- Manajemen keuangan/akuntansi sekolah secara mendalam (hanya mencatat sumber dana, bukan pembukuan).
- Integrasi langsung dengan sistem Dapodik/Dinas Pendidikan (kecuali disepakati sebagai pengembangan lanjutan).
- Manajemen kepegawaian atau data siswa.

## 5. Stakeholder & Peran Pengguna

| Peran | Deskripsi | Hak Akses Utama |
|---|---|---|
| **Wali Kelas** | Guru penanggung jawab kelas tertentu (contoh: Kelas 1 – Bu Dewi Candra Sahara, S.Pd) | Input, edit, hapus (CRUD) data inventaris kelasnya sendiri; tidak dapat mengakses data kelas lain |
| **Operator Sekolah (OPS)** | Admin sistem, bertugas merekap seluruh laporan | Melihat & merekap seluruh data dari semua kelas dan ruangan; menyusun laporan gabungan; mengajukan laporan ke kepala sekolah; mencetak PDF |
| **Kepala Sekolah** | Pemberi persetujuan akhir | Melihat laporan gabungan; menyetujui (ACC) atau menolak/minta revisi; tanda tangan digital otomatis pada laporan yang disetujui |
| **(Opsional) Admin/Developer** | Pengelola sistem teknis | Manajemen akun pengguna, master data (kategori barang, kode ruangan, dll) |

### 5.1 Matriks Hak Akses (Permission Matrix)

| Fitur | Wali Kelas | OPS | Kepala Sekolah |
|---|:---:|:---:|:---:|
| Input data barang kelas sendiri | ✅ | ❌ | ❌ |
| Edit/hapus data barang kelas sendiri | ✅ | ❌ | ❌ |
| Lihat data barang kelas sendiri | ✅ | ✅ | ✅ |
| Lihat data seluruh kelas | ❌ | ✅ | ✅ |
| Rekap laporan gabungan sekolah | ❌ | ✅ | ✅ (lihat saja) |
| Ajukan laporan untuk ACC | ❌ | ✅ | ❌ |
| ACC / setujui laporan | ❌ | ❌ | ✅ |
| Cetak PDF per kelas | ✅ (kelas sendiri) | ✅ (semua kelas) | ✅ |
| Cetak PDF laporan gabungan | ❌ | ✅ | ✅ |

## 6. Kebutuhan Fungsional (Functional Requirements)

### FR-1 Autentikasi & Manajemen Peran
- FR-1.1 Sistem menyediakan login berbasis akun dengan role (Wali Kelas, OPS, Kepala Sekolah).
- FR-1.2 Setiap wali kelas terhubung/ditugaskan ke satu kelas tertentu (mapping user–kelas).

### FR-2 Manajemen Data Inventaris (CRUD) — Wali Kelas
- FR-2.1 Wali kelas dapat menambahkan barang baru pada kelasnya, meliputi: nama barang, kategori, kode barang (auto-generate), lokasi/ruangan, kondisi, jumlah awal, jumlah sekarang, sumber perolehan, tanggal perolehan (tanggal/bulan/tahun).
- FR-2.2 Wali kelas dapat mengedit data barang yang sudah ada (misal: memperbarui kondisi atau jumlah barang).
- FR-2.3 Wali kelas dapat menghapus data barang (dengan konfirmasi, dan idealnya tercatat di log/riwayat).
- FR-2.4 Wali kelas dapat melihat seluruh data inventaris kelasnya dalam bentuk tabel.
- FR-2.5 Sistem mencatat riwayat perubahan (jumlah awal tidak berubah, jumlah sekarang dapat diperbarui setiap ada perubahan/kerusakan/kehilangan).

### FR-3 Rekapitulasi & Pelaporan — OPS
- FR-3.1 OPS dapat melihat data inventaris dari seluruh kelas dan seluruh ruangan (perpustakaan, ruang guru, ruang kepala sekolah).
- FR-3.2 Sistem secara otomatis menggabungkan (agregasi) data seluruh kelas menjadi satu laporan sekolah saat diminta OPS.
- FR-3.3 OPS dapat memfilter/mencari data berdasarkan kelas, kategori barang, kondisi, atau sumber dana.
- FR-3.4 OPS dapat mengajukan laporan gabungan kepada kepala sekolah untuk proses ACC.
- FR-3.5 OPS dapat mencetak laporan (per kelas atau gabungan) ke format PDF.

### FR-4 Persetujuan (Approval) — Kepala Sekolah
- FR-4.1 Kepala sekolah menerima notifikasi/daftar laporan yang menunggu persetujuan.
- FR-4.2 Kepala sekolah dapat melihat detail laporan gabungan sebelum menyetujui.
- FR-4.3 Kepala sekolah dapat menyetujui (ACC) atau mengembalikan laporan untuk revisi (beserta catatan).
- FR-4.4 Saat laporan di-ACC, sistem otomatis membubuhkan tanda tangan digital/cap ACC (gambar tanda tangan yang sudah disiapkan sebelumnya) beserta tanggal persetujuan pada dokumen PDF.

### FR-5 Cetak Laporan PDF
- FR-5.1 Sistem dapat menghasilkan laporan PDF per kelas (oleh wali kelas atau OPS).
- FR-5.2 Sistem dapat menghasilkan laporan PDF gabungan seluruh sekolah (oleh OPS, setelah/sebelum ACC).
- FR-5.3 Laporan PDF memuat: kop surat sekolah, judul laporan, tabel data barang (kode, nama, kategori, ruangan, kondisi, jumlah awal, jumlah sekarang, sumber dana, tanggal perolehan), nama & tanda tangan wali kelas terkait, serta tanda tangan kepala sekolah (jika sudah di-ACC).

### FR-6 Sistem Pengkodean Barang (Item Code Generator)
- FR-6.1 Sistem menghasilkan kode barang otomatis dengan format:
  `[KODE_KATEGORI]_[KODE_RUANGAN]_[BULAN][TANGGAL PEROLEHAN]`
  Contoh: `FR_GR_1025` → Furniture, Ruang Guru, diperoleh bulan 10 tanggal 25 (atau format tanggal yang disepakati lebih lanjut agar tidak ambigu — lihat catatan di bagian 9).
- FR-6.2 Kode kategori barang: `FR` = Furniture, `EL` = Elektronik, `PK` = Perkakas (dapat ditambah kategori baru oleh admin).
- FR-6.3 Kode ruangan: `KE` = Kelas, `PE` = Perpustakaan, `KS` = Ruang Kepala Sekolah, `GR` = Ruang Guru (dapat ditambah oleh admin, misal `LB` = Laboratorium jika diperlukan).
- FR-6.4 Jika kode ruangan adalah Kelas (`KE`), sistem menambahkan nomor kelas, misal `FR_KE1_1025` untuk Kelas 1.

### FR-7 Manajemen Kondisi & Sumber Dana Barang
- FR-7.1 Kondisi barang terdiri dari 4 kategori: Layak, Rusak Sedang, Rusak Berat, Hilang.
- FR-7.2 Sumber perolehan barang terdiri dari: Bantuan Pemerintah, Dana BOS, Komite Sekolah, Beli Sendiri (Swadaya Sekolah) — dapat ditambah oleh admin.

## 7. Kebutuhan Non-Fungsional (Non-Functional Requirements)

| Kategori | Kebutuhan |
|---|---|
| Multi-Platform | Aplikasi dapat berjalan di Android, iOS, dan idealnya Web/Desktop (dibangun dengan Flutter) |
| Usability | Antarmuka sederhana dan mudah dipahami oleh guru yang mungkin awam teknologi |
| Performance | Proses rekapitulasi data dan generate PDF selesai dalam waktu wajar (< 5 detik untuk data skala sekolah dasar) |
| Security | Autentikasi berbasis akun & role; data sensitif (misal tanda tangan digital) tidak dapat diakses/dimanipulasi oleh role yang tidak berwenang |
| Reliability | Data tersimpan di database terpusat (cloud/local server) dengan backup berkala |
| Maintainability | Struktur kode modular agar mudah dikembangkan (sesuai prinsip Agile: mudah menerima perubahan requirement) |
| Offline Capability (opsional) | Idealnya wali kelas tetap bisa input data walau koneksi internet terbatas, lalu sinkron otomatis saat online |

## 8. Struktur Data (Konsep Skema Basis Data)

### 8.1 Tabel `users`
| Field | Tipe | Keterangan |
|---|---|---|
| id | UUID/Integer | Primary key |
| nama | String | Nama pengguna |
| role | Enum | wali_kelas / ops / kepala_sekolah |
| kelas_id | FK (nullable) | Relasi ke tabel kelas (khusus wali kelas) |
| username/email | String | Untuk login |
| password | String (hashed) | Untuk login |

### 8.2 Tabel `kelas`
| Field | Tipe | Keterangan |
|---|---|---|
| id | UUID/Integer | Primary key |
| nama_kelas | String | Misal "Kelas 1" |
| wali_kelas_id | FK | Relasi ke `users` |

### 8.3 Tabel `kategori_barang`
| Field | Tipe | Keterangan |
|---|---|---|
| id | Integer | Primary key |
| kode | String | FR / EL / PK |
| nama_kategori | String | Furniture / Elektronik / Perkakas |

### 8.4 Tabel `ruangan`
| Field | Tipe | Keterangan |
|---|---|---|
| id | Integer | Primary key |
| kode | String | KE / PE / KS / GR |
| nama_ruangan | String | Kelas / Perpustakaan / Ruang Kepala Sekolah / Ruang Guru |

### 8.5 Tabel `barang_inventaris`
| Field | Tipe | Keterangan |
|---|---|---|
| id | UUID/Integer | Primary key |
| kode_barang | String | Hasil generate otomatis, misal FR_GR_1025 |
| nama_barang | String | Misal "Papan Tulis" |
| kategori_id | FK | Relasi ke `kategori_barang` |
| ruangan_id | FK | Relasi ke `ruangan` |
| kelas_id | FK (nullable) | Jika barang berada di kelas tertentu |
| kondisi | Enum | layak / rusak_sedang / rusak_berat / hilang |
| jumlah_awal | Integer | Jumlah saat pertama diperoleh |
| jumlah_sekarang | Integer | Jumlah terkini |
| sumber_dana | Enum | bantuan_pemerintah / dana_bos / komite_sekolah / beli_sendiri |
| tanggal_perolehan | Date | Tanggal/bulan/tahun diterima |
| dicatat_oleh | FK | Relasi ke `users` (wali kelas) |
| updated_at | Timestamp | Waktu pembaruan terakhir |

### 8.6 Tabel `laporan`
| Field | Tipe | Keterangan |
|---|---|---|
| id | UUID/Integer | Primary key |
| jenis | Enum | per_kelas / gabungan_sekolah |
| status | Enum | draft / diajukan / disetujui / revisi |
| diajukan_oleh | FK | Relasi ke `users` (OPS) |
| disetujui_oleh | FK (nullable) | Relasi ke `users` (kepala sekolah) |
| tanggal_pengajuan | Date | |
| tanggal_acc | Date (nullable) | |
| file_pdf_url | String | Lokasi file hasil cetak |

## 9. Catatan Penting Terkait Sistem Kode Barang

Format `FR_GR_1025` berpotensi ambigu (misal antara "Oktober tanggal 25" vs "bulan 1, tanggal 025"). Disarankan untuk KP ini menetapkan format eksplisit sejak awal, contoh:

- Format: `[KATEGORI]_[RUANGAN]_[MMDD]` → `FR_GR_1025` = diperoleh 25 Oktober (bulan 10, tanggal 25).
- Jika ada lebih dari satu barang dengan kombinasi kategori+ruangan+tanggal yang sama, tambahkan nomor urut di belakang, misal `FR_GR_1025-02`.
- Untuk barang di kelas, sertakan nomor kelas pada kode ruangan: `KE1`, `KE2`, dst.

Bagian ini sebaiknya didiskusikan dan dikonfirmasi bersama dosen pembimbing dan pihak sekolah, lalu didokumentasikan sebagai keputusan final di bab metodologi laporan KP.

## 10. Alur Proses Bisnis (Business Process Flow)

1. **Wali Kelas** login → membuka menu inventaris kelasnya → menambah/mengubah data barang (CRUD) → data tersimpan otomatis ke database pusat.
2. **OPS** login → membuka dashboard rekap → sistem menampilkan data gabungan dari seluruh kelas & ruangan secara real-time → OPS menyusun/memvalidasi laporan gabungan.
3. **OPS** mengajukan laporan (status: *diajukan*) kepada **Kepala Sekolah**.
4. **Kepala Sekolah** login → melihat laporan yang diajukan → memilih **Setujui (ACC)** atau **Kembalikan untuk Revisi**.
   - Jika disetujui → sistem membubuhkan tanda tangan digital otomatis + tanggal → status laporan menjadi *disetujui*.
   - Jika revisi → laporan dikembalikan ke OPS dengan catatan.
5. **OPS** mencetak laporan yang sudah disetujui ke format PDF, siap dilaporkan ke atasan/dinas.

## 11. Metodologi Pengembangan: Agile

Karena requirement dari OPS sekolah cenderung berubah-ubah secara mendadak, metode **Agile** (dengan pendekatan iteratif, misal Scrum sederhana atau Kanban) lebih sesuai dibanding Prototype, karena:
- Memungkinkan pengembangan bertahap dalam beberapa iterasi/sprint pendek.
- Requirement baru atau perubahan dari pihak sekolah dapat diakomodasi di sprint berikutnya tanpa mengulang seluruh proses dari awal.
- Ada ruang untuk *feedback* rutin dari OPS, guru, dan kepala sekolah di setiap akhir sprint/iterasi.

**Catatan untuk laporan KP:** jelaskan alasan pergantian metodologi ini di bab metodologi, sertakan perbandingan singkat Prototype vs Agile, dan diskusikan dengan dosen pembimbing sebelum difinalisasi karena ini mengubah struktur bab metodologi laporan KP.

## 12. Kriteria Penerimaan (Acceptance Criteria) — Contoh

| Fitur | Kriteria Penerimaan |
|---|---|
| Input barang oleh wali kelas | Data barang baru langsung muncul di dashboard OPS tanpa perlu refresh manual/dengan sinkronisasi maksimal beberapa detik |
| Generate kode barang | Kode barang dihasilkan otomatis, unik, dan sesuai format yang ditentukan |
| ACC kepala sekolah | Setelah ACC, tanda tangan digital otomatis muncul di PDF dan status laporan berubah menjadi "disetujui" |
| Cetak PDF | File PDF dapat diunduh/dicetak, formatnya rapi dan memuat seluruh data yang relevan |
| Role-based access | Wali kelas tidak dapat melihat/mengedit data kelas lain |

## 13. Risiko & Batasan (Risks & Constraints)

- Perubahan requirement mendadak dari OPS — dimitigasi dengan metodologi Agile dan sprint pendek.
- Guru/wali kelas mungkin kurang terbiasa dengan aplikasi digital — perlu UI sederhana dan mungkin sesi pelatihan singkat.
- Ketersediaan infrastruktur (internet) di sekolah — perlu dipertimbangkan opsi offline-first jika koneksi sekolah terbatas.
- Keamanan tanda tangan digital kepala sekolah — perlu mekanisme agar tidak disalahgunakan (misal hanya bisa dipicu lewat akun kepala sekolah yang sudah terautentikasi).

## 14. Rencana Pengembangan Lanjutan (Future Enhancements — opsional)

- Notifikasi (push notification) saat ada laporan baru yang perlu di-ACC.
- Dashboard statistik kondisi barang sekolah (grafik jumlah barang rusak, dsb).
- Integrasi dengan sistem pelaporan dinas pendidikan (jika dibutuhkan di kemudian hari).
- Fitur QR Code pada barang fisik yang mengarah ke data barang di sistem.

---

*Dokumen ini dapat disesuaikan lebih lanjut berdasarkan diskusi dengan dosen pembimbing dan pihak sekolah (SDN 3 Margasari Purwakarta) sebelum masuk ke tahap perancangan sistem (use case diagram, ERD, wireframe, dsb).*