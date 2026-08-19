import 'dart:convert';
import 'dart:typed_data'; // 👈 بدلاً من dart:io لمنع أخطاء الويب
import 'package:http/http.dart' as http;
import 'package:medica_admin/core/helpers/Image_Picker_helper.dart';
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
    } on http.ClientException {
      throw Exception("فشل الاتصال بالسيرفر، يرجى المحاولة لاحقاً");
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
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
    } on http.ClientException {
      throw Exception("فشل الاتصال بالسيرفر، يرجى المحاولة لاحقاً");
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
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
    } on http.ClientException {
      throw Exception("فشل الاتصال بالسيرفر، يرجى المحاولة لاحقاً");
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }

  Future<dynamic> patch(String endpoint, {Object? body, String? token}) async {
    try {
      final headers = await _getHeaders(token);

      final response = await http.patch(
        Uri.parse("$baseUrl/$endpoint"),
        headers: headers,
        // إذا كان الـ body فارغ لا نرسله كـ null حتى لا يضرب jsonEncode
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } on http.ClientException {
      throw Exception("فشل الاتصال بالسيرفر، يرجى المحاولة لاحقاً");
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
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
    } on http.ClientException {
      throw Exception("فشل الاتصال بالسيرفر، يرجى المحاولة لاحقاً");
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }

  // 🔑 دالة رفع الصور والملفات المتوافقة 100% مع الويب والموبايل
  Future<dynamic> postMultipart({
    required String endpoint,
    required Map<String, String> fields,
    PickedFileData? file, // 👈 تغيير النوع لـ PickedFileData
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

      // 🔑 الحل الجذري للويب: رفع من الـ bytes بدلاً من path
      if (file != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            fileKey,
            file.bytes,
            filename: file.name,
          ),
        );
      }
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } on http.ClientException {
      throw Exception("فشل الاتصال بالسيرفر، يرجى المحاولة لاحقاً");
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }

  // معالجة الردود
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
      SharedPrefHelper.removeAdminToken();
      throw Exception("انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى");
    } else if (response.statusCode == 422) {
      // 🔑 التقاط أخطاء الـ Validation الدقيقة من لارافيل
      if (body is Map && body.containsKey('errors') && body['errors'] is Map) {
        final Map<String, dynamic> errors = body['errors'];
        if (errors.isNotEmpty) {
          // استخراج أول خطأ من أول حقل وإرجاعه
          final firstKey = errors.keys.first;
          final firstErrorList = errors[firstKey];
          if (firstErrorList is List && firstErrorList.isNotEmpty) {
            throw Exception(firstErrorList.first.toString());
          }
        }
      }
      // في حال كان خطأ Custom بدون حقل errors (مثل: end_time must be after start_time)
      final errorMessage = body is Map
          ? (body['message'] ?? "البيانات المدخلة غير صالحة")
          : "البيانات المدخلة غير صالحة";
      throw Exception(errorMessage);
    } else {
      final errorMessage = body is Map
          ? (body['message'] ?? "حدث خطأ ما في السيرفر")
          : "حدث خطأ ما في السيرفر";
      throw Exception(errorMessage);
    }
  }
}
