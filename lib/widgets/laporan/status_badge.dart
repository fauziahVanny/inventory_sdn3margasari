import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

/// Badge status laporan
class StatusBadge extends StatelessWidget {
  final StatusLaporan status;

  const StatusBadge({super.key, required this.status});

  Color get _color {
    switch (status) {
      case StatusLaporan.draft:
        return AppColors.statusDraft;
      case StatusLaporan.diajukan:
        return AppColors.statusDiajukan;
      case StatusLaporan.disetujui:
        return AppColors.statusDisetujui;
      case StatusLaporan.revisi:
        return AppColors.statusRevisi;
    }
  }

  IconData get _icon {
    switch (status) {
      case StatusLaporan.draft:
        return Icons.edit_note;
      case StatusLaporan.diajukan:
        return Icons.send;
      case StatusLaporan.disetujui:
        return Icons.verified;
      case StatusLaporan.revisi:
        return Icons.replay;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 16, color: _color),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}
