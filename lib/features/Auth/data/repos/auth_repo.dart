import 'package:medica_admin/features/Auth/data/model/admin_model.dart';

abstract class AuthRepo {
  // دالة تسجيل الدخول التي سترجع مودل الأدمن
  Future<AdminModel> login(String phone, String password);
}
