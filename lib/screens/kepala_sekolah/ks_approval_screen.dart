import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/laporan_provider.dart';
import '../../widgets/common/app_drawer.dart';
import '../../widgets/laporan/laporan_card.dart';
import '../../widgets/common/empty_state.dart';

/// Halaman daftar laporan yang menunggu ACC (Kepala Sekolah)
class KsApprovalScreen extends StatelessWidget {
  const KsApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final laporanProv = context.watch<LaporanProvider>();
    final menungguAcc = laporanProv.laporanMenungguAcc;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Persetujuan Laporan'),
      ),
      drawer: const AppDrawer(),
      body: menungguAcc.isEmpty
          ? const EmptyState(
              icon: Icons.check_circle_outline,
              title: 'Semua Laporan Telah Ditinjau',
              subtitle: 'Tidak ada laporan yang menunggu persetujuan saat ini',
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: menungguAcc.length,
              itemBuilder: (_, i) => LaporanCard(
                laporan: menungguAcc[i],
                onTap: () => context.go('/ks/approval/detail/${menungguAcc[i].id}'),
              ),
            ),
    );
  }
}
