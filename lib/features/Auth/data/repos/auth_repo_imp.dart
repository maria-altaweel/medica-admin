import 'package:medica_admin/core/helpers/shared_pref_helper.dart';
import 'package:medica_admin/core/networking/api_service.dart';
import 'package:medica_admin/features/Auth/data/model/admin_model.dart';
import 'auth_repo.dart';

class AuthRepoImp implements AuthRepo {
  final ApiService apiService;

  AuthRepoImp(this.apiService);

  @override
  Future<AdminModel> login(String phone, String password) async {
    // إرسال البيانات للسيرفر
    final response = await apiService.post("admin/login", {
      "phone": phone,
      "password": password,
    });

    print("🔑 رد السيرفر الكامل عند اللوجن: $response");

    // 1. استخراج التوكن بأمان سواء كان في جذر الرد أو داخل data
    final String? token = response['token'] ?? response['data']?['token'];

    // 2. تحويل بيانات الأدمن
    final adminModel = AdminModel.fromJson(
      response['data'] ?? response['admin'] ?? response,
    );

    // 3. حفظ التوكن إذا كان موجوداً
    if (token != null && token.isNotEmpty) {
      await SharedPrefHelper.saveAdminToken(token);
      print("✅ تم حفظ التوكن بنجاح: $token");
    } else {
      print("❌ خطأ: التوكن جاء null من السيرفر ولم يتم الحفظ!");
    }

    return adminModel;
  }
}
