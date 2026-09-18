import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/api_service.dart';
import '../../models/kelas_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/common/app_drawer.dart';
import '../../widgets/common/stat_card.dart';

/// Dashboard OPS — ringkasan seluruh inventaris sekolah
class OpsDashboardScreen extends StatefulWidget {
  const OpsDashboardScreen({super.key});

  @override
  State<OpsDashboardScreen> createState() => _OpsDashboardScreenState();
}

class _OpsDashboardScreenState extends State<OpsDashboardScreen> {
  List<KelasModel> _kelasList = [];
  bool _isLoadingKelas = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final dashProv = context.read<DashboardProvider>();
    dashProv.fetchStatistikGlobal();
    dashProv.fetchLaporanStatistik();
    
    // Fetch Kelas
    setState(() => _isLoadingKelas = true);
    try {
      final response = await ApiService.get('/kelas');
      if (response['success'] == true) {
        final List data = response['data'];
        setState(() {
          _kelasList = data.map((j) => KelasModel.fromJson(j)).toList();
        });
      }
    } catch (e) {
      // ignore
    }
    setState(() => _isLoadingKelas = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dashboardProv = context.watch<DashboardProvider>();
    final user = auth.currentUser;

    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final stats = dashboardProv.statistikGlobal?['ringkasan'] ?? {
      'total_item': 0, 'total_layak': 0, 'total_rusak_sedang': 0, 'total_rusak_berat': 0, 'total_hilang': 0
    };
    final laporanStats = dashboardProv.laporanStatistik?['statistik'] ?? {
      'draft': 0, 'diajukan': 0, 'disetujui': 0, 'revisi': 0
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard OPS')),
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
                    colors: [AppColors.secondary, Color(0xFF00695C)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Halo, ${user.nama} 👋',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Operator Sekolah • SDN 3 Margasari',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.75),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 28),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Menu Cepat
              Text(
                'Menu Cepat',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _quickMenuCard(
                      context,
                      title: 'Data Master',
                      icon: Icons.storage_rounded,
                      color: const Color(0xFF5C35C9),
                      route: '/ops/master',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _quickMenuCard(
                      context,
                      title: 'Buat Laporan',
                      icon: Icons.add_chart_rounded,
                      color: AppColors.primary,
                      route: '/ops/laporan', // Can adjust route later if there's a specific route for creating
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Statistik Inventaris
              Text(
                'Ringkasan Inventaris Sekolah',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
                      onTap: () => context.go('/ops/rekap'),
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

              // Statistik Laporan
              Text(
                'Status Laporan',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              if (dashboardProv.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _laporanStat(context, '${laporanStats['draft'] ?? 0}', 'Draft', AppColors.statusDraft),
                      _laporanStat(context, '${laporanStats['diajukan'] ?? 0}', 'Diajukan', AppColors.statusDiajukan),
                      _laporanStat(context, '${laporanStats['disetujui'] ?? 0}', 'Disetujui', AppColors.statusDisetujui),
                      _laporanStat(context, '${laporanStats['revisi'] ?? 0}', 'Revisi', AppColors.statusRevisi),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Data Per Kelas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Data Per Kelas',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  TextButton(
                    onPressed: () => context.go('/ops/rekap'),
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_isLoadingKelas)
                const Center(child: CircularProgressIndicator())
              else if (_kelasList.isEmpty)
                const Center(child: Text('Belum ada kelas'))
              else
                ..._kelasList.map((kelas) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            kelas.namaKelas.replaceAll('Kelas ', ''),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        kelas.namaKelas,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      subtitle: const Text(
                        'Detail Kelas',
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.go('/ops/kelas/${kelas.id}'),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _laporanStat(BuildContext context, String value, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
  Widget _quickMenuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => context.go(route),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
