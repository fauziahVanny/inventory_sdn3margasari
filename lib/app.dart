import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'providers/auth_provider.dart';

/// Widget utama aplikasi
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final appRouter = AppRouter(authProvider: authProvider);

    return MaterialApp.router(
      title: 'Inventaris SDN 3 Margasari',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter.router,
    );
  }
}
