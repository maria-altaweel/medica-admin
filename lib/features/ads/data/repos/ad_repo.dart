import 'package:medica_admin/core/helpers/Image_Picker_helper.dart'; // مسار الـ PickedFileData
import 'package:medica_admin/core/networking/api_service.dart';
import 'package:medica_admin/features/ads/data/models/ad_model.dart';

class AdRepository {
  final ApiService _apiService;

  AdRepository(this._apiService);

  /// 1. جلب قائمة الإعلانات (مع دعم الـ Pagination)
  Future<Map<String, dynamic>> getAds({
    required int clinicId,
    int limit = 15,
    int? lastId,
  }) async {
    // بناء الرابط
    String endpoint = "admin/clinics/$clinicId/ads?limit=$limit";

    if (lastId != null) {
      endpoint += "&last_id=$lastId";
    }

    final response = await _apiService.get(endpoint);
    print("Ads Response:$response");

    final List data = response['data'] ?? [];
    final List<AdModel> ads = data
        .map((json) => AdModel.fromJson(json))
        .toList();

    return {
      'ads': ads,
      'pagination':
          response['pagination'], // بيحتوي على has_more و next_last_id
    };
  }

  /// 2. إضافة إعلان جديد
  Future<AdModel> createAd({
    required int clinicId,
    required PickedFileData image,
  }) async {
    // استخدمنا postMultipart الموجودة بـ ApiService للرفع
    final response = await _apiService.postMultipart(
      endpoint: "admin/clinics/$clinicId/ads",
      fields: {}, // مافي حقول نصية أخرى غير الصورة
      file: image,
      fileKey: "image",
    );

    return AdModel.fromJson(response['data']);
  }

  /// 3. تعديل الإعلان (تغيير الصورة)
  Future<AdModel> updateAd({
    required int adId,
    required PickedFileData image,
  }) async {
    // استخدمنا postMultipart مع تمرير _method: PUT
    final response = await _apiService.postMultipart(
      endpoint: "admin/ads/$adId",
      fields: {'_method': 'PUT'},
      file: image,
      fileKey: "image",
    );

    return AdModel.fromJson(response['data']);
  }

  /// 4. تفعيل / تعطيل الإعلان
  Future<AdModel> toggleAdStatus({required int adId}) async {
    // استدعاء دالة التحديث
    final response = await _apiService.patch(
      "admin/ads/$adId/toggle-active",
      body: {}, // الـ Body فارغ بناءً على الباك إند
    );

    return AdModel.fromJson(response['data']);
  }

  /// 5. حذف الإعلان
  Future<String> deleteAd({required int adId}) async {
    final response = await _apiService.delete("admin/ads/$adId");
    return response['message'] ?? "تم حذف الإعلان بنجاح";
  }
}
