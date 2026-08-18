import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // 👈 هذا هو السطر الناقص الذي سبب الخطأ
import 'package:medica_admin/core/networking/service_locator.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_bloc.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_event.dart';
import 'core/helpers/shared_pref_helper.dart';
import 'core/routing/app_router.dart';
import 'core/routing/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. تهيئة الـ Service Locator
  setupServiceLocator();

  // 2. التحقق من التوكن مرة واحدة عند فتح التطبيق
  final String? token = await SharedPrefHelper.getAdminToken();
  final bool isLoggedIn = token != null && token.isNotEmpty;
  print("====maintoken:$token===");

  runApp(MedicaAdminApp(isLoggedIn: isLoggedIn));
}

class MedicaAdminApp extends StatelessWidget {
  final bool isLoggedIn;
  final AppRouter appRouter = AppRouter();

  MedicaAdminApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ClinicsBloc>()..add(FetchClinicsEvent()),
      child: MaterialApp(
        title: 'Medica Admin',
        debugShowCheckedModeBanner: false,

        // إعدادات اللغة العربية و RTL
        locale: const Locale('ar', 'AE'),
        supportedLocales: const [Locale('ar', 'AE')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xffFFFFFF),
          fontFamily: 'Cairo',
        ),

        // التوجيه عبر الـ AppRouter
        initialRoute: isLoggedIn ? Routes.dashboardScreen : Routes.loginScreen,
        onGenerateRoute: appRouter.generateRoute,
      ),
    );
  }
}
