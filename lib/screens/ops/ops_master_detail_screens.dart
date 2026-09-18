import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/api_service.dart';
import '../../widgets/common/app_drawer.dart';

/// CRUD Kategori Barang
class OpsMasterKategoriScreen extends StatefulWidget {
  const OpsMasterKategoriScreen({super.key});

  @override
  State<OpsMasterKategoriScreen> createState() => _OpsMasterKategoriScreenState();
}

class _OpsMasterKategoriScreenState extends State<OpsMasterKategoriScreen> {
  List<dynamic> _list = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.get('/kategori');
      if (res['success'] == true && mounted) {
        setState(() => _list = res['data'] as List);
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _showFormDialog({Map<String, dynamic>? item}) async {
    final isEdit = item != null;
    final namaCtrl = TextEditingController(text: isEdit ? item['nama_kategori'] : '');
    final kodeCtrl = TextEditingController(text: isEdit ? item['kode_kategori'] : '');
    final deskCtrl = TextEditingController(text: isEdit ? item['deskripsi'] : '');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Edit Kategori' : 'Tambah Kategori'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _fieldLabel('Nama Kategori'),
              TextField(
                controller: namaCtrl,
                decoration: _inputDeco('Contoh: Furniture'),
              ),
              const SizedBox(height: 14),
              _fieldLabel('Kode Kategori (2-3 huruf)'),
              TextField(
                controller: kodeCtrl,
                textCapitalization: TextCapitalization.characters,
                maxLength: 4,
                decoration: _inputDeco('Contoh: FR'),
              ),
              const SizedBox(height: 14),
              _fieldLabel('Deskripsi (Opsional)'),
              TextField(
                controller: deskCtrl,
                maxLines: 2,
                decoration: _inputDeco('Keterangan tambahan...'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (namaCtrl.text.trim().isEmpty || kodeCtrl.text.trim().isEmpty) return;
              final body = {
                'nama_kategori': namaCtrl.text.trim(),
                'kode_kategori': kodeCtrl.text.trim().toUpperCase(),
                'deskripsi': deskCtrl.text.trim().isEmpty ? null : deskCtrl.text.trim(),
              };
              try {
                if (isEdit) {
                  await ApiService.put('/kategori/${item['id']}', body);
                } else {
                  await ApiService.post('/kategori', body);
                }
                if (ctx.mounted) Navigator.pop(ctx, true);
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: Text(isEdit ? 'Simpan' : 'Tambah'),
          ),
        ],
      ),
    );
    if (result == true) _loadData();
  }

  Future<void> _delete(String id, String nama) async {
    final ok = await _confirmDelete(context, nama);
    if (!ok) return;
    try {
      await ApiService.delete('/kategori/$id');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$nama berhasil dihapus'), backgroundColor: AppColors.success),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kategori Barang'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/ops/master'),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _list.isEmpty
              ? _emptyState('Belum ada kategori', Icons.category_outlined)
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: _list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final item = _list[i] as Map<String, dynamic>;
                      return _itemCard(
                        leading: _kodeBadge(item['kode_kategori'] ?? '?', const Color(0xFF1565C0)),
                        title: item['nama_kategori'] ?? '-',
                        subtitle: item['deskripsi'] ?? 'Tidak ada deskripsi',
                        onEdit: () => _showFormDialog(item: item),
                        onDelete: () => _delete(item['id'], item['nama_kategori']),
                      );
                    },
                  ),
                ),
    );
  }
}

// ─── Ruangan ──────────────────────────────────────────────────────────────────

class OpsMasterRuanganScreen extends StatefulWidget {
  const OpsMasterRuanganScreen({super.key});

  @override
  State<OpsMasterRuanganScreen> createState() => _OpsMasterRuanganScreenState();
}

class _OpsMasterRuanganScreenState extends State<OpsMasterRuanganScreen> {
  List<dynamic> _list = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.get('/ruangan');
      if (res['success'] == true && mounted) {
        setState(() => _list = res['data'] as List);
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _showFormDialog({Map<String, dynamic>? item}) async {
    final isEdit = item != null;
    final namaCtrl = TextEditingController(text: isEdit ? item['nama_ruangan'] : '');
    final kodeCtrl = TextEditingController(text: isEdit ? item['kode_ruangan'] : '');
    final deskCtrl = TextEditingController(text: isEdit ? item['deskripsi'] : '');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Edit Ruangan' : 'Tambah Ruangan'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _fieldLabel('Nama Ruangan'),
              TextField(controller: namaCtrl, decoration: _inputDeco('Contoh: Kelas')),
              const SizedBox(height: 14),
              _fieldLabel('Kode Ruangan (2-4 huruf)'),
              TextField(
                controller: kodeCtrl,
                textCapitalization: TextCapitalization.characters,
                maxLength: 4,
                decoration: _inputDeco('Contoh: KE'),
              ),
              const SizedBox(height: 14),
              _fieldLabel('Deskripsi (Opsional)'),
              TextField(controller: deskCtrl, maxLines: 2, decoration: _inputDeco('Keterangan...')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (namaCtrl.text.trim().isEmpty || kodeCtrl.text.trim().isEmpty) return;
              final body = {
                'nama_ruangan': namaCtrl.text.trim(),
                'kode_ruangan': kodeCtrl.text.trim().toUpperCase(),
                'deskripsi': deskCtrl.text.trim().isEmpty ? null : deskCtrl.text.trim(),
              };
              try {
                if (isEdit) {
                  await ApiService.put('/ruangan/${item['id']}', body);
                } else {
                  await ApiService.post('/ruangan', body);
                }
                if (ctx.mounted) Navigator.pop(ctx, true);
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: Text(isEdit ? 'Simpan' : 'Tambah'),
          ),
        ],
      ),
    );
    if (result == true) _loadData();
  }

  Future<void> _delete(String id, String nama) async {
    final ok = await _confirmDelete(context, nama);
    if (!ok) return;
    try {
      await ApiService.delete('/ruangan/$id');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$nama berhasil dihapus'), backgroundColor: AppColors.success),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ruangan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/ops/master'),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
        backgroundColor: const Color(0xFF00897B),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _list.isEmpty
              ? _emptyState('Belum ada ruangan', Icons.meeting_room_outlined)
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: _list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final item = _list[i] as Map<String, dynamic>;
                      return _itemCard(
                        leading: _kodeBadge(item['kode_ruangan'] ?? '?', const Color(0xFF00897B)),
                        title: item['nama_ruangan'] ?? '-',
                        subtitle: item['deskripsi'] ?? 'Tidak ada deskripsi',
                        onEdit: () => _showFormDialog(item: item),
                        onDelete: () => _delete(item['id'], item['nama_ruangan']),
                      );
                    },
                  ),
                ),
    );
  }
}

// ─── Kelas ────────────────────────────────────────────────────────────────────

class OpsMasterKelasScreen extends StatefulWidget {
  const OpsMasterKelasScreen({super.key});

  @override
  State<OpsMasterKelasScreen> createState() => _OpsMasterKelasScreenState();
}

class _OpsMasterKelasScreenState extends State<OpsMasterKelasScreen> {
  List<dynamic> _list = [];
  List<dynamic> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        ApiService.get('/kelas'),
        ApiService.get('/users'),
      ]);
      if (mounted) {
        setState(() {
          _list = results[0]['success'] == true ? results[0]['data'] as List : [];
          _users = results[1]['success'] == true
              ? (results[1]['data'] as List)
                  .where((u) => u['role'] == 'wali_kelas')
                  .toList()
              : [];
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _showFormDialog({Map<String, dynamic>? item}) async {
    final isEdit = item != null;
    final namaCtrl = TextEditingController(text: isEdit ? item['nama_kelas'] : '');
    String? selectedWaliId = isEdit ? item['wali_kelas_id'] : null;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Kelas' : 'Tambah Kelas'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _fieldLabel('Nama Kelas'),
                TextField(
                  controller: namaCtrl,
                  decoration: _inputDeco('Contoh: Kelas 1'),
                ),
                const SizedBox(height: 14),
                _fieldLabel('Wali Kelas (Opsional)'),
                DropdownButtonFormField<String>(
                  value: selectedWaliId,
                  isExpanded: true,
                  decoration: _inputDeco('Pilih wali kelas'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('- Belum ada -')),
                    ..._users.map((u) => DropdownMenuItem(
                          value: u['id'] as String,
                          child: Text(u['nama'] ?? '-', overflow: TextOverflow.ellipsis),
                        )),
                  ],
                  onChanged: (v) => setDialogState(() => selectedWaliId = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                if (namaCtrl.text.trim().isEmpty) return;
                final body = {
                  'nama_kelas': namaCtrl.text.trim(),
                  'wali_kelas_id': selectedWaliId,
                };
                try {
                  if (isEdit) {
                    await ApiService.put('/kelas/${item['id']}', body);
                  } else {
                    await ApiService.post('/kelas', body);
                  }
                  if (ctx.mounted) Navigator.pop(ctx, true);
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              child: Text(isEdit ? 'Simpan' : 'Tambah'),
            ),
          ],
        ),
      ),
    );
    if (result == true) _loadData();
  }

  Future<void> _delete(String id, String nama) async {
    final ok = await _confirmDelete(context, nama);
    if (!ok) return;
    try {
      await ApiService.delete('/kelas/$id');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$nama berhasil dihapus'), backgroundColor: AppColors.success),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kelas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/ops/master'),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
        backgroundColor: const Color(0xFFE65100),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _list.isEmpty
              ? _emptyState('Belum ada kelas', Icons.class_outlined)
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: _list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final item = _list[i] as Map<String, dynamic>;
                      final waliNama = item['wali_kelas_nama'] as String? ?? 'Belum ada wali kelas';
                      return _itemCard(
                        leading: _kodeBadge(
                          (item['nama_kelas'] as String? ?? '?').replaceAll('Kelas ', ''),
                          const Color(0xFFE65100),
                          fontSize: 18,
                        ),
                        title: item['nama_kelas'] ?? '-',
                        subtitle: 'Wali Kelas: $waliNama',
                        onEdit: () => _showFormDialog(item: item),
                        onDelete: () => _delete(item['id'], item['nama_kelas']),
                      );
                    },
                  ),
                ),
    );
  }
}

// ─── Pengguna ─────────────────────────────────────────────────────────────────

class OpsMasterPenggunaScreen extends StatefulWidget {
  const OpsMasterPenggunaScreen({super.key});

  @override
  State<OpsMasterPenggunaScreen> createState() => _OpsMasterPenggunaScreenState();
}

class _OpsMasterPenggunaScreenState extends State<OpsMasterPenggunaScreen> {
  List<dynamic> _list = [];
  bool _isLoading = true;

  final Map<String, String> _roleLabels = {
    'wali_kelas': 'Wali Kelas',
    'ops': 'Operator Sekolah',
    'kepala_sekolah': 'Kepala Sekolah',
  };
  final Map<String, Color> _roleColors = {
    'wali_kelas': AppColors.primary,
    'ops': AppColors.secondary,
    'kepala_sekolah': const Color(0xFF6A1B9A),
  };
  final Map<String, IconData> _roleIcons = {
    'wali_kelas': Icons.school_outlined,
    'ops': Icons.admin_panel_settings_outlined,
    'kepala_sekolah': Icons.stars_outlined,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.get('/users');
      if (res['success'] == true && mounted) {
        setState(() => _list = res['data'] as List);
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _showFormDialog({Map<String, dynamic>? item}) async {
    final isEdit = item != null;
    final namaCtrl = TextEditingController(text: isEdit ? item['nama'] : '');
    final nipCtrl = TextEditingController(text: isEdit ? item['nip'] : '');
    final usernameCtrl = TextEditingController(text: isEdit ? item['username'] : '');
    final passCtrl = TextEditingController();
    String selectedRole = isEdit ? item['role'] : 'wali_kelas';

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Pengguna' : 'Tambah Pengguna'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _fieldLabel('Nama Lengkap'),
                TextField(controller: namaCtrl, decoration: _inputDeco('Nama beserta gelar')),
                const SizedBox(height: 12),
                _fieldLabel('NIP'),
                TextField(
                  controller: nipCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _inputDeco('Nomor Induk Pegawai'),
                ),
                const SizedBox(height: 12),
                _fieldLabel('Username'),
                TextField(controller: usernameCtrl, decoration: _inputDeco('Username login')),
                const SizedBox(height: 12),
                _fieldLabel(isEdit ? 'Password Baru (kosongkan jika tidak diubah)' : 'Password'),
                TextField(
                  controller: passCtrl,
                  obscureText: true,
                  decoration: _inputDeco('Min. 6 karakter'),
                ),
                const SizedBox(height: 12),
                _fieldLabel('Role'),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  isExpanded: true,
                  decoration: _inputDeco('Pilih role'),
                  items: _roleLabels.entries.map((e) => DropdownMenuItem(
                    value: e.key,
                    child: Text(e.value),
                  )).toList(),
                  onChanged: (v) => setDialogState(() => selectedRole = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                if (namaCtrl.text.trim().isEmpty || usernameCtrl.text.trim().isEmpty) return;
                final body = <String, dynamic>{
                  'nama': namaCtrl.text.trim(),
                  'nip': nipCtrl.text.trim(),
                  'username': usernameCtrl.text.trim(),
                  'role': selectedRole,
                };
                if (passCtrl.text.isNotEmpty) {
                  body['password'] = passCtrl.text;
                }
                try {
                  if (isEdit) {
                    await ApiService.put('/users/${item['id']}', body);
                  } else {
                    await ApiService.post('/users', body);
                  }
                  if (ctx.mounted) Navigator.pop(ctx, true);
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              child: Text(isEdit ? 'Simpan' : 'Tambah'),
            ),
          ],
        ),
      ),
    );
    if (result == true) _loadData();
  }

  Future<void> _delete(String id, String nama) async {
    final ok = await _confirmDelete(context, nama);
    if (!ok) return;
    try {
      await ApiService.delete('/users/$id');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$nama berhasil dihapus'), backgroundColor: AppColors.success),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pengguna'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/ops/master'),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(),
        icon: const Icon(Icons.person_add),
        label: const Text('Tambah'),
        backgroundColor: const Color(0xFF6A1B9A),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _list.isEmpty
              ? _emptyState('Belum ada pengguna', Icons.people_outline)
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: _list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final item = _list[i] as Map<String, dynamic>;
                      final role = item['role'] as String? ?? '';
                      final color = _roleColors[role] ?? AppColors.textSecondary;
                      final icon = _roleIcons[role] ?? Icons.person_outline;
                      final roleLabel = _roleLabels[role] ?? role;
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  (item['nama'] as String? ?? '?').isNotEmpty
                                      ? (item['nama'] as String)[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: color,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['nama'] ?? '-',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '@${item['username']} • ${item['nip'] ?? '-'}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Icon(icon, size: 12, color: color),
                                      const SizedBox(width: 4),
                                      Text(
                                        roleLabel,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                              onSelected: (v) {
                                if (v == 'edit') _showFormDialog(item: item);
                                if (v == 'delete') _delete(item['id'], item['nama']);
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 16), SizedBox(width: 8), Text('Edit')])),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: const Row(children: [Icon(Icons.delete_outline, size: 16, color: Colors.red), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: Colors.red))]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

Widget _fieldLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
    );

InputDecoration _inputDeco(String hint) => InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      isDense: true,
    );

Widget _kodeBadge(String text, Color color, {double fontSize = 14}) => Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700, color: color),
        ),
      ),
    );

Widget _itemCard({
  required Widget leading,
  required String title,
  required String subtitle,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
}) =>
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
            onSelected: (v) {
              if (v == 'edit') onEdit();
              if (v == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 16), SizedBox(width: 8), Text('Edit')])),
              const PopupMenuItem(
                value: 'delete',
                child: Row(children: [Icon(Icons.delete_outline, size: 16, color: Colors.red), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: Colors.red))]),
              ),
            ],
          ),
        ],
      ),
    );

Widget _emptyState(String message, IconData icon) => Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(message, style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
          ],
        ),
      ),
    );

Future<bool> _confirmDelete(BuildContext context, String nama) async {
  return await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Hapus Data'),
          content: Text('Apakah Anda yakin ingin menghapus "$nama"?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Hapus'),
            ),
          ],
        ),
      ) ??
      false;
}
