import 'package:flutter/material.dart';
import 'package:medica_admin/core/helpers/App_Colors.dart';

class LeaveRequestsFilterBar extends StatelessWidget {
  final String? selectedStatus;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String> onSearchChanged;
  final String? dateFrom;
  final String? dateTo;
  final ValueChanged<String?>? onDateFromChanged;
  final ValueChanged<String?>? onDateToChanged;
  final VoidCallback onReset; // 👈 إضافة دالة إعادة الضبط

  const LeaveRequestsFilterBar({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.onSearchChanged,
    this.dateFrom,
    this.dateTo,
    this.onDateFromChanged,
    this.onDateToChanged,
    required this.onReset, // 👈 جعلها مطلوبة
  });

  Future<void> _selectDate(
    BuildContext context,
    ValueChanged<String?>? onDateSelected,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && onDateSelected != null) {
      String formattedDate =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      onDateSelected(formattedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.light(primary: AppColors.primary),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          children: [
            // 1. حقل البحث
            SizedBox(
              width: 280,
              height: 45,
              child: TextField(
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'بحث باسم الطبيب أو السبب...',
                  hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 18,
                    color: Colors.grey,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            // 2. فلاتر التواريخ والحالة وزر إعادة الضبط
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // من تاريخ
                _buildDateField(
                  context,
                  label: 'من تاريخ',
                  date: dateFrom,
                  onTap: () => _selectDate(context, onDateFromChanged),
                ),
                const SizedBox(width: 12),

                // إلى تاريخ
                _buildDateField(
                  context,
                  label: 'إلى تاريخ',
                  date: dateTo,
                  onTap: () => _selectDate(context, onDateToChanged),
                ),
                const SizedBox(width: 12),

                // فلتر الحالة
                SizedBox(
                  width: 140,
                  height: 45,
                  child: DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'الحالة',
                      labelStyle: const TextStyle(fontSize: 12),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: null,
                        child: Text('الكل', style: TextStyle(fontSize: 12)),
                      ),
                      DropdownMenuItem(
                        value: 'pending',
                        child: Text('معلق', style: TextStyle(fontSize: 12)),
                      ),
                      DropdownMenuItem(
                        value: 'approved',
                        child: Text('معتمد', style: TextStyle(fontSize: 12)),
                      ),
                      DropdownMenuItem(
                        value: 'rejected',
                        child: Text('مرفوض', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                    onChanged: onStatusChanged,
                  ),
                ),
                const SizedBox(width: 12),

                // 👈 زر إعادة الضبط الجديد
                SizedBox(
                  height: 45,
                  child: TextButton.icon(
                    onPressed: onReset,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      backgroundColor: Colors.grey.shade100,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text(
                      'إعادة ضبط',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context, {
    required String label,
    String? date,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 140,
      height: 45,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(fontSize: 12),
            suffixIcon: Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: AppColors.primary,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 0,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
          child: Text(
            date ?? 'اختر تاريخ',
            style: TextStyle(
              fontSize: 11,
              color: date == null ? Colors.grey : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
