import 'package:medica_admin/core/helpers/shared_pref_helper.dart';
import 'package:medica_admin/core/networking/api_service.dart';
import 'package:medica_admin/features/Auth/data/model/admin_model.dart';

import 'auth_repo.dart';

class AuthRepoImp implements AuthRepo {
  final ApiService apiService;

  AuthRepoImp(this.apiService);

  @override
  Future<AdminModel> login(String phone, String password) async {
    // إرسال البيانات للسيرفر كما يطلب الـ Controller
    final response = await apiService.post("admin/login", {
      "phone": phone,
      "password": password,
    });

    // استخراج بيانات الأدمن والتوكن من الرد
    final adminModel = AdminModel.fromJson(response['data']);

    // حفظ التوكن في الـ Shared Preferences ليتم استخدامه في باقي التطبيق
    await SharedPrefHelper.saveAdminToken(adminModel.token);

    return adminModel;
  }
}
