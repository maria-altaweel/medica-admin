import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medica_admin/core/helpers/app_colors.dart';

class SalariesFiltersWidget extends StatelessWidget {
  const SalariesFiltersWidget({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.onClinicTap,
    required this.selectedClinicName,
    required this.onResetPressed,
    required this.periodStart,
    required this.periodEnd,
    required this.onDateChanged,
  });

  final String? selectedStatus;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onClinicTap;
  final String? selectedClinicName;
  final VoidCallback onResetPressed;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final Function(DateTime? start, DateTime? end) onDateChanged;

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? periodStart : periodEnd) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      if (isStart) {
        onDateChanged(picked, periodEnd);
      } else {
        onDateChanged(periodStart, picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // 1. اختيار العيادة
        _buildFilterBox(
          width: 200,
          label: selectedClinicName ?? "اختر العيادة...",
          onTap: onClinicTap,
        ),

        // 2. اختيار التاريخ (من)
        _buildFilterBox(
          width: 150,
          label: periodStart != null
              ? DateFormat('yyyy-MM-dd').format(periodStart!)
              : "من تاريخ",
          onTap: () => _pickDate(context, true),
        ),

        // 3. اختيار التاريخ (إلى)
        _buildFilterBox(
          width: 150,
          label: periodEnd != null
              ? DateFormat('yyyy-MM-dd').format(periodEnd!)
              : "إلى تاريخ",
          onTap: () => _pickDate(context, false),
        ),

        // 4. حالة الراتب
        SizedBox(
          width: 150,
          child: DropdownButtonFormField<String>(
            value: selectedStatus,
            decoration: _inputDecoration("حالة الراتب"),
            items: const [
              DropdownMenuItem(value: null, child: Text("الكل")),
              DropdownMenuItem(value: "pending", child: Text("قيد الانتظار")),
              DropdownMenuItem(value: "approved", child: Text("معتمد")),
              DropdownMenuItem(value: "paid", child: Text("تم التسليم")),
            ],
            onChanged: onStatusChanged,
          ),
        ),

        // 5. زر إعادة الضبط
        TextButton.icon(
          onPressed: onResetPressed,
          icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
          label: const Text(
            "إعادة ضبط",
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBox({
    required double width,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.textField,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Text(label, style: const TextStyle(fontSize: 14)),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    isDense: true,
    filled: true,
    fillColor: AppColors.textField,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
  );
}
