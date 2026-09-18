import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/barang_provider.dart';
import '../../core/services/api_service.dart';
import '../../models/kategori_model.dart';
import '../../widgets/common/app_drawer.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/barang/barang_card.dart';
import '../../utils/pdf_helper.dart';

/// Daftar barang inventaris kelas (Wali Kelas)
class WkBarangListScreen extends StatefulWidget {
  const WkBarangListScreen({super.key});

  @override
  State<WkBarangListScreen> createState() => _WkBarangListScreenState();
}

class _WkBarangListScreenState extends State<WkBarangListScreen> {
  List<KategoriModel> _kategoriList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final kelasId = auth.currentUser?.kelasId;
      if (kelasId != null) {
        context.read<BarangProvider>().fetchBarangByKelas(kelasId);
      }
    });
    _loadKategori();
  }

  Future<void> _loadKategori() async {
    try {
      final res = await ApiService.get('/kategori');
      if (mounted) {
        setState(() {
          _kategoriList = (res['data'] as List).map((e) => KategoriModel.fromJson(e)).toList();
        });
      }
    } catch (e) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final barangProv = context.watch<BarangProvider>();
    final barangList = barangProv.filteredBarang;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Barang'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print, color: AppColors.primary),
            tooltip: 'Cetak Laporan PDF',
            onPressed: () => PdfHelper.generateAndDownloadWkPdf(context, barangList, auth.currentUser!),
          ),
          IconButton(
            icon: Icon(
              barangProv.filterKondisi != null || barangProv.filterKategoriId != null
                  ? Icons.filter_alt
                  : Icons.filter_alt_outlined,
              color: barangProv.filterKondisi != null || barangProv.filterKategoriId != null
                  ? AppColors.primary
                  : null,
            ),
            onPressed: () => _showFilterSheet(context, barangProv),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              onChanged: (v) => barangProv.setSearch(v),
              decoration: InputDecoration(
                hintText: 'Cari barang...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: barangProv.searchQuery != null && barangProv.searchQuery!.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => barangProv.setSearch(''),
                      )
                    : null,
              ),
            ),
          ),
          // Active filters
          if (barangProv.filterKondisi != null || barangProv.filterKategoriId != null)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  if (barangProv.filterKondisi != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(barangProv.filterKondisi!.label),
                        onDeleted: () => barangProv.setFilterKondisi(null),
                        deleteIconColor: AppColors.textSecondary,
                      ),
                    ),
                  if (barangProv.filterKategoriId != null)
                    Chip(
                      label: Text(
                        _kategoriList.firstWhere((k) => k.id == barangProv.filterKategoriId!, orElse: () => KategoriModel(id: '', kode: '', namaKategori: '')).namaKategori,
                      ),
                      onDeleted: () => barangProv.setFilterKategori(null),
                      deleteIconColor: AppColors.textSecondary,
                    ),
                ],
              ),
            ),
          // List
          Expanded(
            child: barangList.isEmpty
                ? EmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: 'Belum Ada Barang',
                    subtitle: 'Tap tombol + untuk menambahkan barang inventaris kelas Anda',
                    buttonLabel: 'Tambah Barang',
                    onButtonPressed: () => context.go('/wk/barang/tambah'),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 24),
                          itemCount: barangList.length,
                          itemBuilder: (_, i) {
                            final barang = barangList[i];
                            return BarangCard(
                              barang: barang,
                              onTap: () => context.go('/wk/barang/detail/${barang.id}'),
                              onEdit: () => context.go('/wk/barang/edit/${barang.id}'),
                              onDelete: () => _showDeleteDialog(context, barangProv, barang.id, barang.namaBarang),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                        child: SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () => PdfHelper.generateAndDownloadWkPdf(context, barangList, auth.currentUser!),
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text('Cetak Dokumen PDF'),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/wk/barang/tambah'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, BarangProvider prov) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        // StatefulBuilder agar chip state update tanpa tutup sheet
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final isDark = Theme.of(ctx).brightness == Brightness.dark;

            // Warna chip tidak aktif — kontras di light & dark
            final unselectedBg = isDark
                ? Colors.grey.shade700
                : Colors.grey.shade200;
            final unselectedLabel = isDark
                ? Colors.white
                : Colors.black87;

            // Warna chip aktif — biru primer selalu kontras
            const selectedBg = AppColors.primary;
            const selectedLabel = Colors.white;

            Widget buildChip({
              required String label,
              required bool isSelected,
              required VoidCallback onTap,
            }) {
              return GestureDetector(
                onTap: onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? selectedBg : unselectedBg,
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected
                        ? null
                        : Border.all(
                            color: isDark
                                ? Colors.grey.shade500
                                : Colors.grey.shade400,
                          ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? selectedLabel : unselectedLabel,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.fromLTRB(
                  24, 16, 24, MediaQuery.of(ctx).padding.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Filter Barang',
                          style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              )),
                      TextButton.icon(
                        onPressed: () {
                          prov.resetFilters();
                          setSheetState(() {});
                        },
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Reset'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),
                  // --- Kondisi ---
                  Row(
                    children: [
                      const Icon(Icons.layers_outlined, size: 16),
                      const SizedBox(width: 6),
                      Text('Kondisi',
                          style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              )),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: KondisiBarang.values.map((k) {
                      final isSelected = prov.filterKondisi == k;
                      return buildChip(
                        label: k.label,
                        isSelected: isSelected,
                        onTap: () {
                          setSheetState(() {
                            prov.setFilterKondisi(isSelected ? null : k);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  // --- Kategori ---
                  Row(
                    children: [
                      const Icon(Icons.category_outlined, size: 16),
                      const SizedBox(width: 6),
                      Text('Kategori',
                          style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              )),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _kategoriList.map((k) {
                      final isSelected = prov.filterKategoriId == k.id;
                      return buildChip(
                        label: k.namaKategori,
                        isSelected: isSelected,
                        onTap: () {
                          setSheetState(() {
                            prov.setFilterKategori(isSelected ? null : k.id);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  // --- Tombol Terapkan ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Terapkan Filter',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            );
          },
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
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await prov.deleteBarang(id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(success ? '"$nama" berhasil dihapus' : 'Gagal menghapus barang')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

