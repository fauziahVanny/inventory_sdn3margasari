import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';

/// Sidebar/drawer navigasi berdasarkan role pengguna
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return const SizedBox.shrink();

    final namaKelas = user.namaKelas;

    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24,
              left: 20,
              right: 20,
              bottom: 24,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      user.nama.isNotEmpty ? user.nama[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.nama,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    namaKelas != null
                        ? '${user.role.label} • $namaKelas'
                        : user.role.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Menu items berdasarkan role
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: _getMenuItems(context, user.role),
            ),
          ),
          // Logout
          const Divider(height: 1),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout, color: AppColors.error, size: 20),
            ),
            title: const Text(
              'Keluar',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.of(context).pop(); // tutup drawer
              _showLogoutDialog(context);
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
        ],
      ),
    );
  }

  List<Widget> _getMenuItems(BuildContext context, UserRole role) {
    switch (role) {
      case UserRole.waliKelas:
        return [
          _menuItem(context, Icons.dashboard_outlined, 'Dashboard', '/wk/dashboard'),
          _menuItem(context, Icons.inventory_2_outlined, 'Daftar Barang', '/wk/barang'),
          _menuItem(context, Icons.person_outline, 'Profil', '/profile'),
        ];
      case UserRole.ops:
        return [
          _menuItem(context, Icons.dashboard_outlined, 'Dashboard', '/ops/dashboard'),
          _menuItem(context, Icons.assessment_outlined, 'Rekap Data', '/ops/rekap'),
          _menuItem(context, Icons.description_outlined, 'Laporan', '/ops/laporan'),
          _menuItem(context, Icons.workspace_premium_rounded, 'Laporan Hasil Akhir', '/ops/hasil-akhir'),
          _menuItem(context, Icons.storage_rounded, 'Data Master', '/ops/master'),
          _menuItem(context, Icons.person_outline, 'Profil', '/profile'),
        ];
      case UserRole.kepalaSekolah:
        return [
          _menuItem(context, Icons.dashboard_outlined, 'Dashboard', '/ks/dashboard'),
          _menuItem(context, Icons.approval_outlined, 'Persetujuan', '/ks/approval'),
          _menuItem(context, Icons.history_rounded, 'History Laporan', '/ks/history'),
          _menuItem(context, Icons.person_outline, 'Profil', '/profile'),
        ];
    }
  }

  Widget _menuItem(BuildContext context, IconData icon, String title, String route) {
    final currentLocation = GoRouterState.of(context).uri.toString();
    final isActive = currentLocation == route;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primarySurface : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          Navigator.of(context).pop(); // tutup drawer
          if (!isActive) context.go(route);
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              ctx.read<AuthProvider>().logout();
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}
