import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/core/helpers/shared_pref_helper.dart'; // 👈 استيراد الـ SharedPrefHelper
import 'package:medica_admin/features/Auth/data/model/admin_model.dart';

import '../../data/repos/auth_repo.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepo _authRepo;

  AuthBloc(this._authRepo) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
  }
  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(LoginLoading());
    try {
      // 1. محاولة تسجيل الدخول عبر الـ Repo
      final adminModel = await _authRepo.login(event.phone, event.password);

      // 🔬 طباعة للتأكد من شكل وجدوى التوكن القادم من الـ API
      print("==== API Token Value: ${adminModel.token} ====");

      // 2. التحقق من أن التوكن ليس null وليس فارغاً
      if (adminModel.token != null && adminModel.token!.isNotEmpty) {
        await SharedPrefHelper.saveAdminToken(adminModel.token!);
        print("==== Token Saved Successfully in SharedPref! ====");
      } else {
        print("==== Error: Token is NULL or EMPTY from API response! ====");
      }

      // 3. إرسال حالة النجاح للـ UI
      emit(LoginSuccess(adminModel: adminModel));
    } catch (e) {
      print("==== Login Exception: $e ====");
      emit(LoginError(message: e.toString()));
    }
  }
}
