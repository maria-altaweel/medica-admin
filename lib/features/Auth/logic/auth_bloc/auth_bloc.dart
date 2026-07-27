import 'package:flutter_bloc/flutter_bloc.dart';
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
      // محاولة تسجيل الدخول عبر الـ Repo
      final adminModel = await _authRepo.login(event.phone, event.password);

      // إذا نجحت العملية
      emit(LoginSuccess(adminModel: adminModel));
    } catch (e) {
      // إذا حدث خطأ (سواء من السيرفر أو الشبكة)
      // سنرسل نص الخطأ ليتم عرضه في الـ UI
      emit(LoginError(message: e.toString()));
    }
  }
}
