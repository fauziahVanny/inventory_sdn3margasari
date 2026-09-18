import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

/// Badge warna untuk kondisi barang
class KondisiBadge extends StatelessWidget {
  final KondisiBarang kondisi;
  final bool small;

  const KondisiBadge({
    super.key,
    required this.kondisi,
    this.small = false,
  });

  Color get _color {
    switch (kondisi) {
      case KondisiBarang.layak:
        return AppColors.kondisiLayak;
      case KondisiBarang.rusakSedang:
        return AppColors.kondisiRusakSedang;
      case KondisiBarang.rusakBerat:
        return AppColors.kondisiRusakBerat;
      case KondisiBarang.hilang:
        return AppColors.kondisiHilang;
    }
  }

  IconData get _icon {
    switch (kondisi) {
      case KondisiBarang.layak:
        return Icons.check_circle_outline;
      case KondisiBarang.rusakSedang:
        return Icons.warning_amber_rounded;
      case KondisiBarang.rusakBerat:
        return Icons.error_outline;
      case KondisiBarang.hilang:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 12,
        vertical: small ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: small ? 14 : 16, color: _color),
          SizedBox(width: small ? 4 : 6),
          Text(
            kondisi.label,
            style: TextStyle(
              fontSize: small ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}
