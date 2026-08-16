import 'package:flutter/material.dart';
import 'package:medica_admin/core/helpers/App_Colors.dart';
import 'package:medica_admin/features/doctors/data/models/doctor_schedule_model.dart';

class ScheduleRowItem extends StatelessWidget {
  final int index;
  final String dayName;
  final DoctorScheduleModel schedule;
  final VoidCallback onEditPressed;

  const ScheduleRowItem({
    super.key,
    required this.index,
    required this.dayName,
    required this.schedule,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasData = schedule.startTime.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // الرقم التسلسلي
          SizedBox(
            width: 40,
            child: Text(
              "$index",
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          // اسم اليوم
          Expanded(
            flex: 2,
            child: Text(
              dayName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          // وقت البدء
          Expanded(
            flex: 2,
            child: Text(
              hasData ? schedule.startTime : "---",
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
          // وقت الانتهاء
          Expanded(
            flex: 2,
            child: Text(
              hasData ? schedule.endTime : "---",
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
          // حالة الدوام (نشط / غير محدد)
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: hasData && schedule.isActive
                        ? AppColors.success
                        : AppColors.textTertiary,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  hasData ? (schedule.isActive ? "نشط" : "متوقف") : "غير محدد",
                  style: TextStyle(
                    color: hasData && schedule.isActive
                        ? AppColors.success
                        : AppColors.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // زر التعديل فقط (تم إلغاء زر الحذف بناءً على طلبك)
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  side: const BorderSide(color: AppColors.primary),
                  backgroundColor: AppColors.lightPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: onEditPressed,
                icon: const Icon(
                  Icons.edit,
                  size: 14,
                  color: AppColors.primary,
                ),
                label: const Text(
                  "تعديل",
                  style: TextStyle(fontSize: 12, color: AppColors.primary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
