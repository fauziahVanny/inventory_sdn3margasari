import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

/// Halaman login
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF1E1E2C), const Color(0xFF12121D)]
                : [AppColors.primary, AppColors.primaryDark],
            stops: const [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Toggle dark/light di pojok kanan atas
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  tooltip: isDark ? 'Mode Terang' : 'Mode Gelap',
                  icon: Icon(
                    isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                    color: isDark ? Colors.amber : Colors.white70,
                    size: 26,
                  ),
                  onPressed: themeProvider.toggleTheme,
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildHeader(isDark),
                          SizedBox(height: 40),
                          _buildLoginCard(isDark),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF262638) : Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.school,
            size: 40,
            color: isDark ? AppColors.primaryLight : AppColors.primary,
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Inventaris Sarana dan Prasarana',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.white,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'SDN 3 Margasari',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.85),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(bool isDark) {
    final cardColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: isDark
            ? Border.all(color: Colors.white12)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Masuk ke Akun',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Silakan masukkan username dan password Anda',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white60 : AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 28),
            // Username
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Username wajib diisi' : null,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: 16),
            // Password
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Password wajib diisi' : null,
              onFieldSubmitted: (_) => _handleLogin(),
            ),
            SizedBox(height: 8),
            // Error message
            Consumer<AuthProvider>(
              builder: (_, auth, _) {
                if (auth.errorMessage != null) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: AppColors.error, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              auth.errorMessage!,
                              style: TextStyle(
                                  color: AppColors.error, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            SizedBox(height: 24),
            // Login button
            Consumer<AuthProvider>(
              builder: (_, auth, _) {
                return SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _handleLogin,
                    child: auth.isLoading
                        ? SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text('Masuk',
                            style: TextStyle(fontSize: 16)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    auth.clearError();

    final success = await auth.login(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success && mounted) {
      final role = auth.currentUser!.role;
      switch (role) {
        case UserRole.waliKelas:
          context.go('/wk/dashboard');
        case UserRole.ops:
          context.go('/ops/dashboard');
        case UserRole.kepalaSekolah:
          context.go('/ks/dashboard');
      }
    }
  }
}
