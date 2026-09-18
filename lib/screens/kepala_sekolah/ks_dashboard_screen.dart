import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/laporan_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/common/app_drawer.dart';
import '../../widgets/common/stat_card.dart';
import '../../widgets/laporan/laporan_card.dart';

/// Dashboard Kepala Sekolah
class KsDashboardScreen extends StatefulWidget {
  const KsDashboardScreen({super.key});

  @override
  State<KsDashboardScreen> createState() => _KsDashboardScreenState();
}

class _KsDashboardScreenState extends State<KsDashboardScreen> {
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
    
    context.read<LaporanProvider>().fetchLaporan();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final laporanProv = context.watch<LaporanProvider>();
    final dashboardProv = context.watch<DashboardProvider>();
    final user = auth.currentUser;

    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final stats = dashboardProv.statistikGlobal?['ringkasan'] ?? {
      'total_item': 0, 'total_layak': 0, 'total_rusak_sedang': 0, 'total_rusak_berat': 0, 'total_hilang': 0
    };
    final laporanStats = dashboardProv.laporanStatistik?['statistik'] ?? {
      'draft': 0, 'diajukan': 0, 'disetujui': 0, 'revisi': 0
    };
    
    final menungguAcc = laporanProv.laporanMenungguAcc;

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Kepala Sekolah')),
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
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.indigo.shade700, Colors.indigo.shade900],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withValues(alpha: 0.3),
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
                              const Text(
                                'Selamat Datang 👋',
                                style: TextStyle(fontSize: 14, color: Colors.white70),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.nama,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Kepala Sekolah • SDN 3 Margasari',
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
                          child: const Icon(Icons.school, color: Colors.white, size: 28),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Statistik
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
                      icon: Icons.pending_actions,
                      label: 'Menunggu',
                      value: '${laporanStats['diajukan'] ?? 0}',
                      color: AppColors.statusDiajukan,
                      onTap: () => context.go('/ks/approval'),
                    ),
                    StatCard(
                      icon: Icons.verified,
                      label: 'Disetujui',
                      value: '${laporanStats['disetujui'] ?? 0}',
                      color: AppColors.statusDisetujui,
                    ),
                    StatCard(
                      icon: Icons.inventory_2,
                      label: 'Total',
                      value: '${stats['total_item'] ?? 0}',
                      color: AppColors.primary,
                    ),
                    StatCard(
                      icon: Icons.warning_amber,
                      label: 'Perhatian',
                      value: '${(stats['total_rusak_berat'] ?? 0) + (stats['total_hilang'] ?? 0)}',
                      color: AppColors.error,
                    ),
                  ],
                ),
              const SizedBox(height: 24),

              // Laporan menunggu ACC
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Menunggu Persetujuan',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (menungguAcc.isNotEmpty)
                    TextButton(
                      onPressed: () => context.go('/ks/approval'),
                      child: const Text('Lihat Semua'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (laporanProv.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (menungguAcc.isEmpty)
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
                      Icon(Icons.check_circle_outline, size: 48, color: AppColors.kondisiLayak.withValues(alpha: 0.5)),
                      const SizedBox(height: 12),
                      Text(
                        'Tidak ada laporan menunggu',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              else
                ...menungguAcc.take(3).map((lap) => LaporanCard(
                  laporan: lap,
                  onTap: () => context.go('/ks/approval/detail/${lap.id}'),
                )),
            ],
          ),
        ),
      ),
    );
  }
}
