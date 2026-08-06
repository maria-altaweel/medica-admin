import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:medica_admin/core/helpers/app_colors.dart';
import 'package:medica_admin/core/networking/service_locator.dart';
import 'package:medica_admin/core/widgets/App_Loadingindicator.dart';

import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_bloc.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_event.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_state.dart';
import 'package:medica_admin/features/dashbord/UI/pages/admin_layout.dart';
import 'package:medica_admin/features/secretaries/UI/pages/seretaries_screen.dart';
import 'package:medica_admin/features/secretaries/logic/secretary_cubit/secretary_cubit.dart';

import '../../data/models/clinic_details_model.dart';
import '../widgets/clinic_doctors_dialog.dart';

class ClinicDetailsScreen extends StatefulWidget {
  final int clinicId;

  const ClinicDetailsScreen({super.key, required this.clinicId});

  @override
  State<ClinicDetailsScreen> createState() => _ClinicDetailsScreenState();
}

class _ClinicDetailsScreenState extends State<ClinicDetailsScreen> {
  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  void _fetchDetails() {
    context.read<ClinicsBloc>().add(FetchClinicDetailsEvent(widget.clinicId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1️⃣ الهيدر: عنوان الشاشة + أزرار الإجراءات
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'تفاصيل العيادة',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkHeader,
                  ),
                ),
                Row(
                  children: [
                    // زر العودة
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: const Text('العودة إلى العيادات'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ), // 👈 تم إغلاق القوس بشكل صحيح
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            // 2️⃣ تفاصيل العيادة من الـ BLoC
            Expanded(
              child: BlocBuilder<ClinicsBloc, ClinicsState>(
                buildWhen: (previous, current) {
                  if (previous is ClinicDetailsSuccessState &&
                      current is ClinicsLoadingState) {
                    return false;
                  }
                  // 👈 تم التصحيح: إضافة العوامل المنطقية || (OR)
                  return current is ClinicsLoadingState ||
                      current is ClinicDetailsSuccessState ||
                      current is ClinicsErrorState;
                },
                builder: (context, state) {
                  if (state is ClinicsLoadingState) {
                    return const Center(child: AppLoadingIndicator());
                  } else if (state is ClinicDetailsSuccessState) {
                    final clinic = state.clinicDetails;
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // كارت المعلومات الرئيسية والإحصائيات
                          _buildMainInfoCard(clinic),
                          const SizedBox(height: 28),

                          // عنوان التخصصات
                          const Text(
                            'التخصصات في العيادة',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkHeader,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // شبكة التخصصات
                          _buildSpecializationsGrid(clinic),
                        ],
                      ),
                    );
                  } else if (state is ClinicsErrorState) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            state.errorMessage,
                            style: const TextStyle(color: AppColors.error),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _fetchDetails,
                            icon: const Icon(Icons.refresh),
                            label: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // كارت المعلومات الكبيرة العلوي
  Widget _buildMainInfoCard(ClinicDetailsModel clinic) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الشعار والمعلومات الرئيسية
          Expanded(
            flex: 2,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderColor),
                    image: clinic.logo != null
                        ? DecorationImage(
                            image: NetworkImage(clinic.logo!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: clinic.logo == null
                      ? const Icon(
                          Icons.medical_services_outlined,
                          size: 48,
                          color: AppColors.primary,
                        )
                      : null,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        clinic.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkHeader,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.location_on_outlined, clinic.address),
                      _buildInfoRow(Icons.phone_outlined, clinic.phone),
                      _buildInfoRow(
                        Icons.support_agent_outlined,
                        clinic.emergencyPhone,
                      ),
                      if (clinic.email != null)
                        _buildInfoRow(Icons.email_outlined, clinic.email!),
                      if (clinic.bankAccount != null)
                        _buildInfoRow(
                          Icons.account_balance_outlined,
                          clinic.bankAccount!,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // كروت الإحصائيات (التقييم، عدد الأطباء، التخصصات)
          Expanded(
            flex: 3,
            child: Row(
              children: [
                _buildStatBox(
                  'متوسط التقييم',
                  '${clinic.averageRating}',
                  Icons.star_outline,
                  iconColor: AppColors.star,
                ),
                const SizedBox(width: 12),
                _buildStatBox(
                  'عدد الأطباء',
                  '${clinic.doctorsCount}',
                  Icons.people_outline,
                ),
                const SizedBox(width: 12),
                _buildStatBox(
                  'عدد التخصصات',
                  '${clinic.specializations.length}',
                  Icons.category_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(
    String title,
    String value,
    IconData icon, {
    Color iconColor = AppColors.primary,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // شبكة كروت التخصصات
  Widget _buildSpecializationsGrid(ClinicDetailsModel clinic) {
    if (clinic.specializations.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'لا توجد تخصصات مضافة حالياً في هذه العيادة',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 900 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.6,
          ),
          itemCount: clinic.specializations.length,
          itemBuilder: (context, index) {
            final spec = clinic.specializations[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.scaffoldBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.lightPrimary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.local_hospital_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            spec.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${spec.doctorsCount} أطباء',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => BlocProvider.value(
                            value: context.read<ClinicsBloc>(),
                            child: ClinicDoctorsDialog(
                              clinicId: clinic.id,
                              specializationId: spec.id,
                              specializationName: spec.name,
                              clinicName: clinic.name,
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'عرض الأطباء',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
