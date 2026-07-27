import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:medica_admin/core/networking/api_service.dart';
import 'package:medica_admin/features/Auth/data/repos/auth_repo.dart';
import 'package:medica_admin/features/Auth/data/repos/auth_repo_imp.dart';
import 'package:medica_admin/features/Auth/logic/auth_bloc/auth_bloc.dart';
import 'package:medica_admin/features/clinics/data/repos/clinic_repo.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_bloc.dart';

import 'package:medica_admin/features/dashbord/data/repos/dashboard_repo.dart';
import 'package:medica_admin/features/dashbord/logic/dashboardhome_bloc/dashboardhome_bloc.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // الخدمة الأساسية للتطبيق (مركزية وموحدة)
  getIt.registerLazySingleton<ApiService>(() => ApiService());
  // تسجيل الـ AuthRepo
  getIt.registerLazySingleton<AuthRepo>(() => AuthRepoImp(getIt<ApiService>()));

  getIt.registerFactory(() => AuthBloc(getIt<AuthRepo>()));
  //homedashboard
  getIt.registerLazySingleton(() => DashboardHomeRepo(getIt<ApiService>()));
  getIt.registerFactory(() => DashboardHomeBloc(getIt()));
  getIt.registerLazySingleton<ClinicsRepo>(() => ClinicsRepo(getIt()));
  getIt.registerFactory<ClinicsBloc>(() => ClinicsBloc(getIt()));
}
