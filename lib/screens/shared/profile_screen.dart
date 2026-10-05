import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_drawer.dart';

/// Halaman profil pengguna
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser!;
    final namaKelas = user.namaKelas;

    return Scaffold(
      appBar: AppBar(title: Text('Profil')),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 20),
            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  user.nama.isNotEmpty ? user.nama[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              user.nama,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                user.role.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(height: 32),

            // Info card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).colorScheme.outline),
              ),
              child: Column(
                children: [
                  _profileRow(context, Icons.person_outline, 'Nama Lengkap', user.nama),
                  Divider(height: 24),
                  _profileRow(context, Icons.badge_outlined, 'Username', user.username),
                  Divider(height: 24),
                  _profileRow(context, Icons.work_outline, 'Peran', user.role.label),
                  if (namaKelas != null) ...[
                    Divider(height: 24),
                    _profileRow(context, Icons.class_outlined, 'Kelas', namaKelas),
                  ],
                  Divider(height: 24),
                  _profileRow(context, Icons.school_outlined, 'Sekolah', 'SDN 3 Margasari Purwakarta'),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Logout button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('Konfirmasi'),
                      content: Text('Apakah Anda yakin ingin keluar?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text('Batal'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            auth.logout();
                            context.go('/login');
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                          child: Text('Keluar'),
                        ),
                      ],
                    ),
                  );
                },
                icon: Icon(Icons.logout, color: AppColors.error),
                label: Text('Keluar dari Akun'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11)),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
