import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/barang_model.dart';

/// Card item barang untuk daftar inventaris
class BarangCard extends StatelessWidget {
  final BarangModel barang;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const BarangCard({
    super.key,
    required this.barang,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Nama & Kode
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon kategori
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(barang.kategoriId),
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          barang.namaBarang,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            barang.kodeBarang,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Rincian kondisi
                  _buildConditionChips(context, barang),
                ],
              ),
              const SizedBox(height: 12),
              // Info detail
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    _infoChip(
                      context,
                      Icons.category_outlined,
                      barang.namaKategori ?? '-',
                    ),
                    const SizedBox(width: 16),
                    _infoChip(
                      context,
                      Icons.room_outlined,
                      barang.namaRuangan ?? '-',
                    ),
                    const Spacer(),
                    // Jumlah
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${barang.jumlahSekarang}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'dari ${barang.jumlahAwal}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (barang.merek != null && barang.merek!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Merek: ${barang.merek}', style: Theme.of(context).textTheme.bodySmall),
              ],
              const SizedBox(height: 4),
              Text(
                'Tanggal Masuk: ${barang.tanggalPerolehan.day}/${barang.tanggalPerolehan.month}/${barang.tanggalPerolehan.year}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              // Kondisi items
              // Actions
              if (showActions && (onEdit != null || onDelete != null)) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onEdit != null)
                      TextButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          textStyle: const TextStyle(fontSize: 13),
                        ),
                      ),
                    if (onDelete != null)
                      TextButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Hapus'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                          textStyle: const TextStyle(fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConditionChips(BuildContext context, BarangModel barang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (barang.jumlahLayak > 0) _miniChip(context, 'L: ${barang.jumlahLayak}', AppColors.success),
        if (barang.jumlahRusakSedang > 0) _miniChip(context, 'RS: ${barang.jumlahRusakSedang}', AppColors.warning),
        if (barang.jumlahRusakBerat > 0) _miniChip(context, 'RB: ${barang.jumlahRusakBerat}', AppColors.error),
        if (barang.jumlahHilang > 0) _miniChip(context, 'H: ${barang.jumlahHilang}', Colors.grey),
      ],
    );
  }

  Widget _miniChip(BuildContext context, String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _infoChip(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String? kode) {
    switch (kode) {
      case 'FR':
        return Icons.chair_outlined;
      case 'EL':
        return Icons.electrical_services_outlined;
      case 'PK':
        return Icons.construction_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }
}
