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
import 'package:medica_admin/features/doctors/data/repos/doctor_repo.dart';
import 'package:medica_admin/features/doctors/logic/doctor_cubit/doctor_cubit.dart';
import 'package:medica_admin/features/secretaries/data/repos/secretary_repo.dart';
import 'package:medica_admin/features/secretaries/data/repos/secretary_repo_imp.dart';
import 'package:medica_admin/features/secretaries/logic/secretary_cubit/secretary_cubit.dart';

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
  getIt.registerLazySingleton<SecretaryRepo>(() => SecretaryRepoImpl(getIt()));
  getIt.registerFactory<SecretaryCubit>(() => SecretaryCubit(getIt()));
  // 1. Repository
  getIt.registerLazySingleton<DoctorRepository>(
    () => DoctorRepository(getIt<ApiService>()),
  );
  // 2. Cubit
  getIt.registerFactory<DoctorCubit>(
    () => DoctorCubit(getIt<DoctorRepository>()),
  );
}
