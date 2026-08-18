import 'package:flutter/material.dart';
import 'package:medica_admin/core/helpers/App_Colors.dart'; // ملف الألوان الخاص بك

class LeaveStatusBadge extends StatelessWidget {
  final String? status;

  const LeaveStatusBadge({super.key, this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status?.toLowerCase()) {
      case 'approved':
        bgColor = AppColors.successLight;
        textColor = AppColors.success;
        text = 'مقبولة';
        break;
      case 'rejected':
        bgColor = AppColors.errorLight;
        textColor = AppColors.error;
        text = 'مرفوض';
        break;
      case 'pending':
      default:
        bgColor = AppColors.warningLight;
        textColor = AppColors.warning;
        text = 'معلقة';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
