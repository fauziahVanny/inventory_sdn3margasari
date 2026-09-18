import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/barang_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/barang/barang_card.dart';
import '../../widgets/common/stat_card.dart';

/// Detail barang per kelas (dilihat OPS)
class OpsDetailKelasScreen extends StatefulWidget {
  final String kelasId;

  const OpsDetailKelasScreen({super.key, required this.kelasId});

  @override
  State<OpsDetailKelasScreen> createState() => _OpsDetailKelasScreenState();
}

class _OpsDetailKelasScreenState extends State<OpsDetailKelasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    context.read<BarangProvider>().fetchBarangByKelas(widget.kelasId);
    context.read<DashboardProvider>().fetchStatistikKelas(widget.kelasId);
  }

  @override
  Widget build(BuildContext context) {
    final barangProv = context.watch<BarangProvider>();
    final dashboardProv = context.watch<DashboardProvider>();
    final barangList = barangProv.allBarang;
    final stats = dashboardProv.statistikKelas?['ringkasan'] ?? {
      'total_item': 0,
      'total_layak': 0,
      'total_rusak_sedang': 0,
      'total_rusak_berat': 0,
      'total_hilang': 0,
    };
    final kelasInfo = dashboardProv.statistikKelas?['kelas'];
    final waliNama = kelasInfo?['wali_kelas_nama'] as String? ?? '-';
    final kelasNama = kelasInfo?['nama_kelas'] as String? ?? 'Detail Kelas';

    return Scaffold(
      appBar: AppBar(
        title: Text(kelasNama),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/ops/dashboard'),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info wali kelas
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Wali Kelas', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          Text(
                            waliNama,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Stats
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
                      label: 'R. Sedang',
                      value: '${stats['total_rusak_sedang'] ?? 0}',
                      color: AppColors.kondisiRusakSedang,
                    ),
                    StatCard(
                      icon: Icons.error_outline,
                      label: 'R. Berat',
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

              // Barang list
              Text(
                'Daftar Barang',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              if (barangProv.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (barangList.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text('Belum ada data barang', style: Theme.of(context).textTheme.bodyMedium),
                  ),
                )
              else
                ...barangList.map((barang) => BarangCard(
                  barang: barang,
                  showActions: false,
                )),
            ],
          ),
        ),
      ),
    );
  }
}
