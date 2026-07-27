import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:medica_admin/core/helpers/constant.dart';
import 'package:medica_admin/core/helpers/shared_pref_helper.dart';

class ApiService {
  // جلب الهيدرز باستخدام توكن الأدمن الجديد
  Future<Map<String, String>> _getHeaders(String? customToken) async {
    final token = customToken ?? await SharedPrefHelper.getAdminToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.trim().isNotEmpty)
        'Authorization': 'Bearer ${token.trim()}',
    };
  }

  // دالة POST
  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    try {
      print("البيانات المرسلة للسيرفر: ${jsonEncode(body)}");
      final headers = await _getHeaders(token);

      final response = await http.post(
        Uri.parse("$baseUrl/$endpoint"),
        headers: headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } on SocketException {
      throw Exception('لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة');
    } on http.ClientException {
      throw Exception("فشل الاتصال بالسيرفر، يرجى المحاولة لاحقاً");
    } catch (e) {
      throw Exception("حدث خطأ غير متوقع: ${e.toString()}");
    }
  }

  // دالة GET
  Future<dynamic> get(String endpoint, {String? token}) async {
    try {
      final headers = await _getHeaders(token);

      final response = await http.get(
        Uri.parse("$baseUrl/$endpoint"),
        headers: headers,
      );
      return _handleResponse(response);
    } on SocketException {
      throw Exception('لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة');
    } on http.ClientException {
      throw Exception("فشل الاتصال بالسيرفر، يرجى المحاولة لاحقاً");
    } catch (e) {
      throw Exception("حدث خطأ غير متوقع: ${e.toString()}");
    }
  }

  // دالة PUT
  Future<dynamic> put(String endpoint, {Object? body, String? token}) async {
    try {
      final headers = await _getHeaders(token);

      final response = await http.put(
        Uri.parse("$baseUrl/$endpoint"),
        headers: headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } on SocketException {
      throw Exception('لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة');
    } on http.ClientException {
      throw Exception("فشل الاتصال بالسيرفر، يرجى المحاولة لاحقاً");
    } catch (e) {
      throw Exception("حدث خطأ غير متوقع: ${e.toString()}");
    }
  }

  // دالة DELETE
  Future<dynamic> delete(String endpoint, {String? token}) async {
    try {
      final headers = await _getHeaders(token);
      final response = await http.delete(
        Uri.parse("$baseUrl/$endpoint"),
        headers: headers,
      );
      return _handleResponse(response);
    } on SocketException {
      throw Exception('لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة');
    } on http.ClientException {
      throw Exception("فشل الاتصال بالسيرفر، يرجى المحاولة لاحقاً");
    } catch (e) {
      throw Exception("حدث خطأ غير متوقع: ${e.toString()}");
    }
  }

  // دالة رفع الصور والملفات
  Future<dynamic> postMultipart({
    required String endpoint,
    required Map<String, String> fields,
    File? file,
    required String fileKey,
    String? token,
  }) async {
    try {
      final uri = Uri.parse("$baseUrl/$endpoint");
      var request = http.MultipartRequest('POST', uri);

      final headers = await _getHeaders(token);
      request.headers.addAll({
        'Accept': 'application/json',
        if (headers.containsKey('Authorization'))
          'Authorization': headers['Authorization']!,
      });

      request.fields.addAll(fields);

      if (file != null) {
        request.files.add(
          await http.MultipartFile.fromPath(fileKey, file.path),
        );
      }
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } on SocketException {
      throw Exception('لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة');
    } on http.ClientException {
      throw Exception("فشل الاتصال بالسيرفر، يرجى المحاولة لاحقاً");
    } catch (e) {
      throw Exception("حدث خطأ غير متوقع: ${e.toString()}");
    }
  }

  // معالجة الردود باللغة العربية مباشرة وبدون لغات
  dynamic _handleResponse(http.Response response) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (e) {
      throw Exception(
        "خطأ في بنية البيانات المستلمة من السيرفر (Status: ${response.statusCode})",
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else if (response.statusCode == 401) {
      SharedPrefHelper.removeAdminToken(); // حذف التوكن عند انتهاء الجلسة
      throw Exception("انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى");
    } else {
      final errorMessage = body is Map
          ? (body['message'] ?? "حدث خطأ ما في السيرفر")
          : "حدث خطأ ما في السيرفر";
      throw Exception(errorMessage);
    }
  }
}
