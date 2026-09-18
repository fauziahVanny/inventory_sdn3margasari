import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/api_service.dart';
import '../../providers/barang_provider.dart';
import '../../widgets/common/app_drawer.dart';
import '../../widgets/barang/barang_card.dart';

/// Rekap data inventaris seluruh sekolah (OPS)
class OpsRekapScreen extends StatefulWidget {
  const OpsRekapScreen({super.key});

  @override
  State<OpsRekapScreen> createState() => _OpsRekapScreenState();
}

class _OpsRekapScreenState extends State<OpsRekapScreen> {
  String? _selectedKelasId;
  List<dynamic> _kelasList = [];
  List<dynamic> _kategoriList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    context.read<BarangProvider>().fetchBarang();
    // Also load kelas and kategori lists
    try {
      final respKelas = await ApiService.get('/kelas');
      if (respKelas['success'] == true && mounted) {
        setState(() => _kelasList = respKelas['data'] as List);
      }
      final respKategori = await ApiService.get('/kategori');
      if (respKategori['success'] == true && mounted) {
        setState(() => _kategoriList = respKategori['data'] as List);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final barangProv = context.watch<BarangProvider>();
    final barangList = _selectedKelasId != null
        ? barangProv.getBarangByKelasFilter(_selectedKelasId)
        : barangProv.filteredBarang;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekap Data'),
        actions: [
          IconButton(
            icon: Icon(
              barangProv.filterKondisi != null || barangProv.filterKategoriId != null
                  ? Icons.filter_alt
                  : Icons.filter_alt_outlined,
            ),
            onPressed: () => _showFilterSheet(context, barangProv),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              onChanged: (v) => barangProv.setSearch(v),
              decoration: const InputDecoration(
                hintText: 'Cari barang...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          // Kelas filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _kelasChip(null, 'Semua'),
                ..._kelasList.map((k) => _kelasChip(k['id'], k['nama_kelas'] ?? 'Kelas')),
              ],
            ),
          ),
          // Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${barangList.length} barang ditemukan',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          // List
          Expanded(
            child: barangList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: AppColors.textHint),
                        const SizedBox(height: 16),
                        Text('Tidak ada data', style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    itemCount: barangList.length,
                    itemBuilder: (_, i) {
                      final barang = barangList[i];
                      return BarangCard(
                        barang: barang,
                        showActions: true,
                        onTap: () {},
                        onEdit: () => context.go('/ops/rekap/edit/${barang.id}'),
                        onDelete: () => _showDeleteDialog(context, barangProv, barang.id, barang.namaBarang),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/ops/rekap/tambah'),
        tooltip: 'Tambah Barang',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _kelasChip(String? kelasId, String label) {
    final isSelected = _selectedKelasId == kelasId;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.primarySurface,
        checkmarkColor: AppColors.primary,
        onSelected: (_) {
          setState(() => _selectedKelasId = kelasId);
        },
      ),
    );
  }

  void _showFilterSheet(BuildContext context, BarangProvider prov) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filter', style: Theme.of(context).textTheme.titleLarge),
                  TextButton(
                    onPressed: () {
                      prov.resetFilters();
                      Navigator.pop(ctx);
                    },
                    child: const Text('Reset'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Kondisi', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: KondisiBarang.values.map((k) {
                  return FilterChip(
                    label: Text(k.label),
                    selected: prov.filterKondisi == k,
                    onSelected: (selected) {
                      prov.setFilterKondisi(selected ? k : null);
                      Navigator.pop(ctx);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text('Kategori', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _kategoriList.map((k) {
                  return FilterChip(
                    label: Text(k['nama_kategori'] ?? 'Kategori'),
                    selected: prov.filterKategoriId == k['id'],
                    onSelected: (selected) {
                      prov.setFilterKategori(selected ? k['id'] : null);
                      Navigator.pop(ctx);
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: MediaQuery.of(ctx).padding.bottom + 16),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, BarangProvider prov, String id, String nama) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Barang'),
        content: Text('Apakah Anda yakin ingin menghapus "$nama"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              prov.deleteBarang(id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('"$nama" berhasil dihapus')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
