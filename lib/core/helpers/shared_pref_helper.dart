import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  // مفاتيح ثابتة مخصصة للأدمن فقط
  static const String _adminTokenKey = 'admin_token';

  // دالة عامة لحفظ أي نوع من البيانات
  static Future<void> setData(String key, dynamic value) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    if (value == null) {
      await sharedPreferences.remove(key);
    } else if (value is String) {
      await sharedPreferences.setString(key, value);
    } else if (value is int) {
      await sharedPreferences.setInt(key, value);
    } else if (value is bool) {
      await sharedPreferences.setBool(key, value);
    } else if (value is double) {
      await sharedPreferences.setDouble(key, value);
    }
  }

  // دالة عامة لجلب البيانات بشكل صحيح وآمن
  static Future<dynamic> getData(String key) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    return sharedPreferences.get(key);
  }

  // دالة مخصصة لحفظ توكن الأدمن عند تسجيل الدخول ناجح
  static Future<void> saveAdminToken(String token) async {
    await setData(_adminTokenKey, token);
  }

  // دالة لجلب توكن الأدمن (سنستخدمها في الـ ApiService)
  static Future<String?> getAdminToken() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    return sharedPreferences.getString(_adminTokenKey);
  }

  // دالة لحذف التوكن وتسجيل الخروج
  static Future<void> removeAdminToken() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    await sharedPreferences.remove(_adminTokenKey);
  }
}
