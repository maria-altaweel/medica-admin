import 'package:flutter/material.dart';
import 'package:medica_admin/core/helpers/App_Colors.dart';
import 'package:medica_admin/features/dashbord/data/models/dashboard_model.dart';

class DashboardHeaderSection extends StatelessWidget {
  final DashboardCounts counts;

  const DashboardHeaderSection({super.key, required this.counts});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'العيادات',
            value: counts.clinics.toString(),
            icon: Icons.local_hospital_outlined,
            iconColor: AppColors.primary,
            backgroundColor: AppColors.lightPrimary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            title: 'الأطباء',
            value: counts.doctors.toString(),
            icon: Icons.medical_services_outlined,
            iconColor: AppColors.success,
            backgroundColor: AppColors.successLight,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            title: 'المرضى',
            value: counts.patients.toString(),
            icon: Icons.people_outline,
            iconColor: AppColors.warning,
            backgroundColor: AppColors.warningLight,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            title: 'السكرتارية',
            value: counts.secretaries.toString(),
            icon: Icons.badge_outlined,
            iconColor: const Color(
              0xFF9C27B0,
            ), // لون بنفسجي مخصص أو فيك تستخدم أساسي
            backgroundColor: const Color(0xFFF3E5F5),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'إجمالي',
                style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
        ],
      ),
    );
  }
}
