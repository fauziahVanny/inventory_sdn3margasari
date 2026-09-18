import 'package:flutter/material.dart';

/// Palet warna aplikasi Inventaris SDN 3 Margasari
class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primarySurface = Color(0xFFE3F2FD);

  // Secondary / Accent
  static const Color secondary = Color(0xFF00897B);
  static const Color secondaryLight = Color(0xFF4DB6AC);
  static const Color secondarySurface = Color(0xFFE0F2F1);

  // Background & Surface
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardSurface = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status / Kondisi Barang
  static const Color kondisiLayak = Color(0xFF43A047);
  static const Color kondisiRusakSedang = Color(0xFFFFA726);
  static const Color kondisiRusakBerat = Color(0xFFE53935);
  static const Color kondisiHilang = Color(0xFF78909C);

  // Status Laporan
  static const Color statusDraft = Color(0xFF9E9E9E);
  static const Color statusDiajukan = Color(0xFF42A5F5);
  static const Color statusDisetujui = Color(0xFF43A047);
  static const Color statusRevisi = Color(0xFFFFA726);

  // Misc
  static const Color divider = Color(0xFFE5E7EB);
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF42A5F5);

  // Shadow
  static const Color shadow = Color(0x1A000000);
}
