import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/barang_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/common/app_drawer.dart';
import '../../widgets/common/stat_card.dart';
import '../../widgets/barang/barang_card.dart';
import '../../utils/pdf_helper.dart';

/// Dashboard utama Wali Kelas
class WkDashboardScreen extends StatefulWidget {
  const WkDashboardScreen({super.key});

  @override
  State<WkDashboardScreen> createState() => _WkDashboardScreenState();
}

class _WkDashboardScreenState extends State<WkDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user != null && user.kelasId != null) {
      context.read<BarangProvider>().fetchBarangByKelas(user.kelasId!);
      context.read<DashboardProvider>().fetchStatistikKelas(user.kelasId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final barangProv = context.watch<BarangProvider>();
    final dashboardProv = context.watch<DashboardProvider>();
    final user = auth.currentUser;

    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final allBarangKelas = barangProv.allBarang;
    final stats = dashboardProv.statistikKelas?['ringkasan'] ?? {
      'total_item': 0,
      'total_layak': 0,
      'total_rusak_sedang': 0,
      'total_rusak_berat': 0,
      'total_hilang': 0,
    };

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard'),
            Text(
              user.namaKelas ?? '',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print, color: AppColors.primary),
            tooltip: 'Cetak Laporan PDF',
            onPressed: () => PdfHelper.generateAndDownloadWkPdf(context, allBarangKelas, user),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat Datang! 👋',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.nama,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Wali ${user.namaKelas ?? ''} • SDN 3 Margasari',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Statistik
              Text(
                'Ringkasan Inventaris',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              if (dashboardProv.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 180,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 120,
                  ),
                  children: [
                    StatCard(
                      icon: Icons.inventory_2,
                      label: 'Total',
                      value: '${stats['total_item'] ?? 0}',
                      color: AppColors.primary,
                    ),
                    StatCard(
                      icon: Icons.check_circle,
                      label: 'Layak',
                      value: '${stats['total_layak'] ?? 0}',
                      color: AppColors.kondisiLayak,
                    ),
                    StatCard(
                      icon: Icons.warning_amber,
                      label: 'Rusak Sedang',
                      value: '${stats['total_rusak_sedang'] ?? 0}',
                      color: AppColors.kondisiRusakSedang,
                    ),
                    StatCard(
                      icon: Icons.error_outline,
                      label: 'Rusak Berat',
                      value: '${stats['total_rusak_berat'] ?? 0}',
                      color: AppColors.kondisiRusakBerat,
                    ),
                    StatCard(
                      icon: Icons.help_outline,
                      label: 'Hilang',
                      value: '${stats['total_hilang'] ?? 0}',
                      color: AppColors.kondisiHilang,
                    ),
                  ],
                ),
              const SizedBox(height: 24),

              // Barang terbaru
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Barang Terbaru',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/wk/barang'),
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (barangProv.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (allBarangKelas.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.textHint),
                      const SizedBox(height: 12),
                      Text(
                        'Belum ada data barang',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              else
                ...allBarangKelas.take(3).map((barang) => Padding(
                  padding: const EdgeInsets.only(bottom: 0),
                  child: BarangCard(
                    barang: barang,
                    showActions: false,
                    onTap: () => context.go('/wk/barang/detail/${barang.id}'),
                  ),
                )),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/wk/barang/tambah'),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Barang'),
      ),
    );
  }
}
