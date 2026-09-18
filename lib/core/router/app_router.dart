import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';

// Screens
import '../../screens/auth/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/wali_kelas/wk_dashboard_screen.dart';
import '../../screens/wali_kelas/wk_barang_list_screen.dart';
import '../../screens/wali_kelas/wk_tambah_barang_screen.dart';
import '../../screens/wali_kelas/wk_detail_barang_screen.dart';
import '../../screens/ops/ops_dashboard_screen.dart';
import '../../screens/ops/ops_rekap_screen.dart';
import '../../screens/ops/ops_laporan_screen.dart';
import '../../screens/ops/ops_detail_laporan_screen.dart';
import '../../screens/ops/ops_detail_kelas_screen.dart';
import '../../screens/ops/ops_master_screen.dart';
import '../../screens/ops/ops_master_detail_screens.dart';
import '../../screens/ops/ops_hasil_akhir_screen.dart';
import '../../screens/kepala_sekolah/ks_dashboard_screen.dart';
import '../../screens/kepala_sekolah/ks_approval_screen.dart';
import '../../screens/kepala_sekolah/ks_detail_laporan_screen.dart';
import '../../screens/kepala_sekolah/ks_history_screen.dart';
import '../../screens/shared/profile_screen.dart';

/// Konfigurasi routing aplikasi menggunakan GoRouter
class AppRouter {
  final AuthProvider authProvider;

  AppRouter({required this.authProvider});

  late final GoRouter router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final isCheckingAuth = authProvider.isCheckingAuth;
      final isLoggedIn = authProvider.isLoggedIn;
      final isLoginRoute = state.uri.toString() == '/login';
      final isSplashRoute = state.uri.toString() == '/splash';

      if (isCheckingAuth) {
        return isSplashRoute ? null : '/splash';
      }

      if (!isLoggedIn) {
        return isLoginRoute ? null : '/login';
      }

      // Jika sudah login, redirect dari login atau splash ke dashboard sesuai role
      if (isLoggedIn && (isLoginRoute || isSplashRoute)) {
        switch (authProvider.currentRole!) {
          case UserRole.waliKelas:
            return '/wk/dashboard';
          case UserRole.ops:
            return '/ops/dashboard';
          case UserRole.kepalaSekolah:
            return '/ks/dashboard';
        }
      }

      return null; // Tidak ada redirect
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, _) => const LoginScreen(),
      ),

      // ── Wali Kelas Routes ──
      GoRoute(
        path: '/wk/dashboard',
        builder: (_, _) => const WkDashboardScreen(),
      ),
      GoRoute(
        path: '/wk/barang',
        builder: (_, _) => const WkBarangListScreen(),
      ),
      GoRoute(
        path: '/wk/barang/tambah',
        builder: (_, _) => const WkTambahBarangScreen(),
      ),
      GoRoute(
        path: '/wk/barang/edit/:id',
        builder: (_, state) => WkTambahBarangScreen(
          barangId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: '/wk/barang/detail/:id',
        builder: (_, state) => WkDetailBarangScreen(
          barangId: state.pathParameters['id']!,
        ),
      ),

      // ── OPS Routes ──
      GoRoute(
        path: '/ops/dashboard',
        builder: (_, _) => const OpsDashboardScreen(),
      ),
      GoRoute(
        path: '/ops/rekap',
        builder: (_, _) => const OpsRekapScreen(),
      ),
      GoRoute(
        path: '/ops/rekap/tambah',
        builder: (_, _) => const WkTambahBarangScreen(),
      ),
      GoRoute(
        path: '/ops/rekap/edit/:id',
        builder: (_, state) => WkTambahBarangScreen(
          barangId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: '/ops/laporan',
        builder: (_, _) => const OpsLaporanScreen(),
      ),
      GoRoute(
        path: '/ops/laporan/detail/:id',
        builder: (_, state) => OpsDetailLaporanScreen(
          laporanId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/ops/kelas/:id',
        builder: (_, state) => OpsDetailKelasScreen(
          kelasId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/ops/master',
        builder: (_, _) => const OpsMasterScreen(),
      ),
      GoRoute(
        path: '/ops/master/kategori',
        builder: (_, _) => const OpsMasterKategoriScreen(),
      ),
      GoRoute(
        path: '/ops/master/ruangan',
        builder: (_, _) => const OpsMasterRuanganScreen(),
      ),
      GoRoute(
        path: '/ops/master/kelas',
        builder: (_, _) => const OpsMasterKelasScreen(),
      ),
      GoRoute(
        path: '/ops/master/pengguna',
        builder: (_, _) => const OpsMasterPenggunaScreen(),
      ),
      GoRoute(
        path: '/ops/hasil-akhir',
        builder: (_, _) => const OpsHasilAkhirScreen(),
      ),

      // ── Kepala Sekolah Routes ──
      GoRoute(
        path: '/ks/dashboard',
        builder: (_, _) => const KsDashboardScreen(),
      ),
      GoRoute(
        path: '/ks/approval',
        builder: (_, _) => const KsApprovalScreen(),
      ),
      GoRoute(
        path: '/ks/approval/detail/:id',
        builder: (_, state) => KsDetailLaporanScreen(
          laporanId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/ks/history',
        builder: (_, _) => const KsHistoryScreen(),
      ),
      GoRoute(
        path: '/ks/history/detail/:id',
        builder: (_, state) => KsDetailLaporanScreen(
          laporanId: state.pathParameters['id']!,
        ),
      ),

      // ── Shared Routes ──
      GoRoute(
        path: '/profile',
        builder: (_, _) => const ProfileScreen(),
      ),
    ],
  );
}
