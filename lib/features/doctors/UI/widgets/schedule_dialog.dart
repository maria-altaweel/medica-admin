import 'package:flutter/material.dart';
import 'package:medica_admin/core/helpers/App_Colors.dart';
import 'package:medica_admin/features/doctors/data/models/doctor_schedule_model.dart';

class ScheduleDialog extends StatefulWidget {
  final String dayName;
  final DoctorScheduleModel? existingSchedule;
  final Function(int dayOfWeek, String startTime, String endTime, bool isActive)
  onSave;

  const ScheduleDialog({
    super.key,
    required this.dayName,
    this.existingSchedule,
    required this.onSave,
  });

  @override
  State<ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<ScheduleDialog> {
  late String startTime;
  late String endTime;
  late bool isActive;
  late int selectedDayOfWeek;

  final List<String> _daysNames = [
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
  ];

  @override
  void initState() {
    super.initState();
    startTime = widget.existingSchedule?.startTime.isNotEmpty == true
        ? widget.existingSchedule!.startTime
        : '08:00';
    endTime = widget.existingSchedule?.endTime.isNotEmpty == true
        ? widget.existingSchedule!.endTime
        : '14:00';
    isActive = widget.existingSchedule?.isActive ?? true;
    selectedDayOfWeek = widget.existingSchedule?.dayOfWeek ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit =
        widget.existingSchedule != null &&
        widget.existingSchedule!.startTime.isNotEmpty;

    return AlertDialog(
      backgroundColor: AppColors.scaffoldBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        isEdit ? 'تعديل جدول دوام (${widget.dayName})' : 'إضافة جدول دوام جديد',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          fontSize: 18,
        ),
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // إذا كانت الحالة "إضافة"، نعرض قائمة اختيار اليوم
            if (!isEdit) ...[
              const Text(
                "اختر اليوم *",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.textField,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: selectedDayOfWeek,
                    isExpanded: true,
                    dropdownColor: AppColors.scaffoldBackground,
                    items: List.generate(7, (index) {
                      return DropdownMenuItem(
                        value: index,
                        child: Text(
                          _daysNames[index],
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                      );
                    }),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => selectedDayOfWeek = val);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              Text(
                "اليوم: ${widget.dayName}",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // حقول الوقت (البداية والنهاية)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: startTime)
                      ..selection = TextSelection.fromPosition(
                        TextPosition(offset: startTime.length),
                      ),
                    decoration: InputDecoration(
                      labelText: 'وقت البداية *',
                      filled: true,
                      fillColor: AppColors.textField,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.borderColor,
                        ),
                      ),
                    ),
                    onChanged: (val) => startTime = val,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: endTime)
                      ..selection = TextSelection.fromPosition(
                        TextPosition(offset: endTime.length),
                      ),
                    decoration: InputDecoration(
                      labelText: 'وقت النهاية *',
                      filled: true,
                      fillColor: AppColors.textField,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.borderColor,
                        ),
                      ),
                    ),
                    onChanged: (val) => endTime = val,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // زر تفعيل / إيقاف الحالة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "حالة الدوام (نشط)",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Switch(
                  value: isActive,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => isActive = val),
                ),
              ],
            ),
            const Divider(height: 24, color: AppColors.borderColor),
            const Text(
              "تعليمات:\n- صيغة الوقت (HH:mm) مثل 08:00.\n- تأكد من أن وقت النهاية بعد وقت البداية.",
              style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'إلغاء',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            widget.onSave(selectedDayOfWeek, startTime, endTime, isActive);
            Navigator.pop(context);
          },
          child: const Text('حفظ', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
