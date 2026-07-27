import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/core/networking/service_locator.dart';
import 'package:medica_admin/core/routing/routes.dart';
import 'package:medica_admin/features/dashbord/UI/widgets/clinic_overview_table_widget.dart';
import 'package:medica_admin/features/dashbord/UI/widgets/dashboard_charts_section.dart';
import 'package:medica_admin/features/dashbord/UI/widgets/dashboard_header_section.dart';
import 'package:medica_admin/features/dashbord/UI/widgets/top_specialization_widget.dart';
import 'package:medica_admin/features/dashbord/logic/dashboardhome_bloc/dashboardhome_bloc.dart';
import 'package:medica_admin/features/dashbord/logic/dashboardhome_bloc/dashboardhome_event.dart';
import 'package:medica_admin/features/dashbord/logic/dashboardhome_bloc/dashboardhome_state.dart';

// 1. هاد كلاس الـ Wrapper (المغلف) المسؤول عن توفير البلوك للشاشة
class DashboardHomeWrapper extends StatelessWidget {
  const DashboardHomeWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // هون عم نقري البلوك من الـ GetIt ومنعطيه أمر يجلب البيانات فوراً ..add(...)
      create: (context) =>
          getIt<DashboardHomeBloc>()..add(FetchDashboardHomeData()),
      child: const DashboardHomeScreen(), // استدعاء شاشتك الأصلية
    );
  }
}

// 2. شاشتك الأصلية تماماً مثل ما كتبناها سابقاً ولكن بدون BlocProvider داخلي
class DashboardHomeScreen extends StatelessWidget {
  const DashboardHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: BlocBuilder<DashboardHomeBloc, DashboardHomeState>(
        builder: (context, state) {
          if (state is DashboardHomeLoading || state is DashboardHomeInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DashboardHomeError) {
            return Center(
              child: Text(
                'حدث خطأ: ${state.message}',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          } else if (state is DashboardHomeSuccess) {
            final data = state.response.data;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'لوحة التحكم الرئيسية',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 20),
                  DashboardHeaderSection(counts: data.counts),
                  const SizedBox(height: 24),
                  DashboardChartsSection(
                    todayAppointments: data.todayAppointments,
                    monthlyRevenue: data.monthlyRevenue,
                    revenueChangePercentage: data.revenueChangePercentage,
                    doctorAttendance: data.doctorAttendance,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: ClinicsOverviewTableWidget(
                          clinicsOverview: data.clinicsOverview,
                          onViewClinicDetails: (clinicId) {
                            print("ابعايدة المختارة :ID$clinicId");
                            Navigator.pushNamed(
                              context,
                              Routes.clinicDetailsScreen,
                              arguments: clinicId,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 1,
                        child: TopSpecializationsWidget(
                          specializations: data.topSpecializations,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
