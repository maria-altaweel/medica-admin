import 'package:flutter/material.dart';
import 'package:medica_admin/core/helpers/app_colors.dart';

class ClinicActionButtons extends StatelessWidget {
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ClinicActionButtons({
    super.key,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIconButton(
          icon: Icons.remove_red_eye_outlined,
          color: AppColors.info,
          bgColor: AppColors.infoLight,
          onPressed: onView,
          tooltip: 'عرض التفاصيل',
        ),
        const SizedBox(width: 6),
        _buildIconButton(
          icon: Icons.edit_outlined,
          color: AppColors.edit,
          bgColor: AppColors.editLight,
          onPressed: onEdit,
          tooltip: 'تعديل',
        ),
        const SizedBox(width: 6),
        _buildIconButton(
          icon: Icons.delete_outline,
          color: AppColors.error,
          bgColor: AppColors.errorLight,
          onPressed: onDelete,
          tooltip: 'حذف',
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
      ),
    );
  }
}
