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

      // 2. 🔑 حفظ التوكن في SharedPreferences قبل الانتقال (عدّل اسم الخاصية حسب موديلك token أو token)
      if (adminModel.token != null) {
        await SharedPrefHelper.saveAdminToken(adminModel.token!);
      }

      // 3. إرسال حالة النجاح للـ UI
      emit(LoginSuccess(adminModel: adminModel));
    } catch (e) {
      // إذا حدث خطأ سنرسل نص الخطأ ليتم عرضه في الـ UI
      emit(LoginError(message: e.toString()));
    }
  }
}
