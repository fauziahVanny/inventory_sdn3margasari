import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/api_service.dart';
import '../../widgets/common/app_drawer.dart';

/// Halaman utama Data Master — hub navigasi ke sub-menu
class OpsMasterScreen extends StatefulWidget {
  const OpsMasterScreen({super.key});

  @override
  State<OpsMasterScreen> createState() => _OpsMasterScreenState();
}

class _OpsMasterScreenState extends State<OpsMasterScreen> {
  Map<String, int> _counts = {
    'kategori': 0,
    'ruangan': 0,
    'kelas': 0,
    'pengguna': 0,
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        ApiService.get('/kategori'),
        ApiService.get('/ruangan'),
        ApiService.get('/kelas'),
        ApiService.get('/users'),
      ]);
      if (mounted) {
        setState(() {
          _counts = {
            'kategori': (results[0]['success'] == true) ? (results[0]['data'] as List).length : 0,
            'ruangan': (results[1]['success'] == true) ? (results[1]['data'] as List).length : 0,
            'kelas': (results[2]['success'] == true) ? (results[2]['data'] as List).length : 0,
            'pengguna': (results[3]['success'] == true) ? (results[3]['data'] as List).length : 0,
          };
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Data Master'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCounts,
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadCounts,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF5C35C9), Color(0xFF3A1F8C)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5C35C9).withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Data Master',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Kelola data referensi sistem inventaris sekolah',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.storage_rounded, color: Colors.white, size: 32),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Pilih Data Master',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // Menu Grid
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  mainAxisExtent: 180,
                ),
                children: [
                  _masterCard(
                    context,
                    icon: Icons.category_rounded,
                    title: 'Kategori',
                    subtitle: 'Jenis barang inventaris',
                    count: _counts['kategori']!,
                    color: const Color(0xFF1565C0),
                    route: '/ops/master/kategori',
                  ),
                  _masterCard(
                    context,
                    icon: Icons.meeting_room_rounded,
                    title: 'Ruangan',
                    subtitle: 'Lokasi penyimpanan barang',
                    count: _counts['ruangan']!,
                    color: const Color(0xFF00897B),
                    route: '/ops/master/ruangan',
                  ),
                  _masterCard(
                    context,
                    icon: Icons.class_rounded,
                    title: 'Kelas',
                    subtitle: 'Daftar kelas di sekolah',
                    count: _counts['kelas']!,
                    color: const Color(0xFFE65100),
                    route: '/ops/master/kelas',
                  ),
                  _masterCard(
                    context,
                    icon: Icons.people_rounded,
                    title: 'Pengguna',
                    subtitle: 'Akun dan hak akses',
                    count: _counts['pengguna']!,
                    color: const Color(0xFF6A1B9A),
                    route: '/ops/master/pengguna',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Info box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.info.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Data master merupakan data referensi yang digunakan di seluruh sistem inventaris. Perubahan akan langsung berdampak pada data barang dan laporan.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _masterCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required int count,
    required Color color,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => context.go(route),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.6)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const Spacer(),
            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            // Count badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 40,
                      height: 12,
                      child: LinearProgressIndicator(
                        backgroundColor: color.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    )
                  : Text(
                      '$count data',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
