import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/core/networking/service_locator.dart';
import 'package:medica_admin/features/Auth/UI/login_page.dart';
import 'package:medica_admin/features/Auth/logic/auth_bloc/auth_bloc.dart';
import 'package:medica_admin/features/clinics/UI/pages/clinic_details_screen.dart';
import 'package:medica_admin/features/clinics/UI/pages/clinics_screen.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_bloc.dart';
import 'package:medica_admin/features/dashbord/UI/pages/admin_layout.dart';
import 'package:medica_admin/features/dashbord/logic/dashboardhome_bloc/dashboardhome_bloc.dart';
import 'package:medica_admin/features/dashbord/logic/dashboardhome_bloc/dashboardhome_event.dart';
import 'package:medica_admin/features/doctors/UI/pages/doctor_schedule_screen.dart';
import 'package:medica_admin/features/doctors/data/repos/doctor_repo.dart';
import 'package:medica_admin/features/doctors/logic/doctor_cubit/doctor_cubit.dart';
import 'package:medica_admin/features/salaries/UI/pages/create_salary_screen.dart';
import 'routes.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.loginScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<AuthBloc>(),
            child: const LoginScreen(),
          ),
        );

      case Routes.dashboardScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) =>
                getIt<DashboardHomeBloc>()..add(FetchDashboardHomeData()),
            child: const AdminLayout(),
          ),
        );

      // 🩺 مسار شاشة قائمة العيادات الرئيسية
      case Routes.clinicsScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<ClinicsBloc>(),
            child: const AdminLayout(body: ClinicsScreen()),
          ),
        );

      // 🩺 مسار شاشة تفاصيل العيادة
      case Routes.clinicDetailsScreen:
        final clinicId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<ClinicsBloc>(),
            child: AdminLayout(body: ClinicDetailsScreen(clinicId: clinicId)),
          ),
        );

      // 👨‍⚕️ مسار قائمة الأطباء (initialIndex: 2)
      case Routes.doctorsScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<DoctorCubit>(),
            child: const AdminLayout(initialIndex: 2),
          ),
        );

      // 📋 مسار طلبات انضمام الأطباء (initialIndex: 3)
      case Routes.doctorRequestsScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<DoctorCubit>(),
            child: const AdminLayout(initialIndex: 3),
          ),
        );
      case Routes.doctorScheduleScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => AdminLayout(
            body: DoctorScheduleScreen(
              clinicId: args['clinicId'],
              clinicDoctorId: args['clinicDoctorId'],
              doctorRepository: getIt<DoctorRepository>(),
            ),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('لا يوجد مسار مطابقة لهذا الرابط: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
