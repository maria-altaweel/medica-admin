import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/core/networking/service_locator.dart';
import 'package:medica_admin/features/Auth/UI/login_page.dart';
import 'package:medica_admin/features/Auth/logic/auth_bloc/auth_bloc.dart';
import 'package:medica_admin/features/clinics/UI/pages/clinic_details_screen.dart';
import 'package:medica_admin/features/dashbord/UI/pages/admin_layout.dart';
import 'package:medica_admin/features/dashbord/logic/dashboardhome_bloc/dashboardhome_bloc.dart';
import 'package:medica_admin/features/dashbord/logic/dashboardhome_bloc/dashboardhome_event.dart';
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
      case Routes.clinicDetailsScreen:
        final clinicId = settings.arguments as int; // نستقبل الـ ID المُمرر
        return MaterialPageRoute(
          builder: (_) =>
              AdminLayout(body: ClinicDetailsScreen(clinicId: clinicId)),
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
