import 'package:flutter/material.dart';
import 'package:medica_admin/core/helpers/App_Colors.dart';
import 'package:medica_admin/features/doctors/UI/widgets/edit_doctor_dialog.dart';

import 'package:medica_admin/features/doctors/data/models/doctor_model.dart';

class DoctorDetailsDialog extends StatelessWidget {
  final DoctorModel doctor;
  final int clinicId;

  const DoctorDetailsDialog({
    super.key,
    required this.doctor,
    required this.clinicId,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.scaffoldBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // الهيدر الأعلى (رجوع إلى قائمة الأطباء)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  label: const Text(
                    'العودة إلى قائمة الأطباء',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textTertiary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // صورة واسم الطبيب والبادج
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.lightPrimary,
              backgroundImage:
                  doctor.profile != null && doctor.profile!.isNotEmpty
                  ? NetworkImage(doctor.profile!)
                  : null,
              child: doctor.profile == null || doctor.profile!.isEmpty
                  ? const Icon(Icons.person, color: AppColors.primary, size: 40)
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              doctor.doctorName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: doctor.status == 'approved'
                    ? AppColors.successLight
                    : AppColors.warningLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                doctor.status == 'approved' ? 'معتمد' : 'معلق',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: doctor.status == 'approved'
                      ? AppColors.success
                      : AppColors.warning,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // قائمة البيانات بالتفصيل
            _buildDetailRow(
              Icons.phone_outlined,
              'رقم الهاتف',
              doctor.doctorPhone,
            ),
            _buildDetailRow(
              Icons.medical_services_outlined,
              'التخصص',
              doctor.specialization,
            ),
            _buildDetailRow(
              Icons.attach_money,
              'رسوم المعاينة',
              '\$ ${doctor.consultationFee}',
            ),
            _buildDetailRow(
              Icons.pie_chart_outline,
              'نسبة الراتب',
              '% ${doctor.salaryPercentage ?? 0}',
            ),
            _buildDetailRow(
              Icons.check_circle_outline,
              'متاح',
              doctor.isAvailable ? 'نعم' : 'لا',
              isAvailableColor: doctor.isAvailable,
            ),
            const SizedBox(height: 24),
            // الأزرار الرئيسية (تعديل البيانات، جدول الدوام)
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (_) =>
                        EditDoctorDialog(doctor: doctor, clinicId: clinicId),
                  );
                },
                child: const Text(
                  'تعديل البيانات',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String title,
    String value, {
    bool? isAvailableColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textTertiary),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isAvailableColor != null
                  ? (isAvailableColor ? AppColors.success : AppColors.error)
                  : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
