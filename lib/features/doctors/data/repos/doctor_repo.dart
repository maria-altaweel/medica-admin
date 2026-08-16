import 'package:medica_admin/core/networking/api_service.dart';
import 'package:medica_admin/features/doctors/data/models/doctor_model.dart';
import 'package:medica_admin/features/doctors/data/models/doctor_schedule_model.dart';

class DoctorRepository {
  final ApiService _apiService;

  DoctorRepository(this._apiService);

  /// 1. جلب قائمة الأطباء في عيادة معينة (مع الفلترة بالحالة فقط من السيرفر)
  Future<List<DoctorModel>> getDoctors({
    required int clinicId,
    String? status,
  }) async {
    String endpoint = "admin/clinics/$clinicId/doctors/list";

    if (status != null && status.isNotEmpty) {
      endpoint += "?status=$status";
    }

    final response = await _apiService.get(endpoint);
    final List data = response['data'] ?? [];
    return data.map((json) => DoctorModel.fromJson(json)).toList();
  }

  /// 2. جلب طلبات الانضمام المعلقة (Pending Requests)
  Future<List<DoctorModel>> getDoctorRequests(int clinicId) async {
    final response = await _apiService.get(
      "admin/clinics/$clinicId/doctors/requests",
    );
    final List data = response['data'] ?? [];
    return data.map((json) => DoctorModel.fromJson(json)).toList();
  }

  /// 3. قبول طلب انضمام طبيب
  Future<String> acceptDoctorRequest({
    required int clinicId,
    required int clinicDoctorId,
  }) async {
    // تم تغيير post إلى put وتمرير الـ body كـ Named Parameter
    final response = await _apiService.put(
      "admin/clinics/$clinicId/doctors/$clinicDoctorId/accept",
      body: {},
    );
    return response['message'] ?? "تم قبول طلب الطبيب بنجاح";
  }

  /// 4. رفض طلب انضمام طبيب
  Future<String> rejectDoctorRequest({
    required int clinicId,
    required int clinicDoctorId,
  }) async {
    // تم تغيير post إلى put وتمرير الـ body كـ Named Parameter
    final response = await _apiService.put(
      "admin/clinics/$clinicId/doctors/$clinicDoctorId/reject",
      body: {},
    );
    return response['message'] ?? "تم رفض طلب الطبيب";
  }

  /// 5. تعديل بيانات الطبيب (سعر الكشفية، نسبة الراتب، التوفر)
  Future<String> updateDoctor({
    required int clinicId,
    required int clinicDoctorId,
    num? consultationFee,
    num? salaryPercentage,
    bool? isAvailable,
  }) async {
    final Map<String, dynamic> body = {};
    if (consultationFee != null) body['consultation_fee'] = consultationFee;
    if (salaryPercentage != null) body['salary_percentage'] = salaryPercentage;
    if (isAvailable != null) body['is_available'] = isAvailable;
    print('🚀 Sending Update Body: $body');

    final response = await _apiService.put(
      "admin/clinics/$clinicId/doctors/$clinicDoctorId",
      body: body,
    );
    return response['message'] ?? "تم تحديث بيانات الطبيب بنجاح";
  }

  /// 6. إزالة / حذف الطبيب من العيادة
  Future<String> removeDoctor({
    required int clinicId,
    required int clinicDoctorId,
  }) async {
    final response = await _apiService.delete(
      "admin/clinics/$clinicId/doctors/$clinicDoctorId",
    );
    return response['message'] ?? "تمت إزالة الطبيب من العيادة بنجاح";
  }

  /// 7. جلب جدول عمل الطبيب
  Future<List<DoctorScheduleModel>> getDoctorSchedules({
    required int clinicId,
    required int clinicDoctorId,
  }) async {
    final response = await _apiService.get(
      "admin/clinics/$clinicId/doctors/$clinicDoctorId/schedules",
    );
    final List data = response['data'] ?? [];
    return data.map((json) => DoctorScheduleModel.fromJson(json)).toList();
  }

  /// 8. حفظ/تحديث جدول عمل الطبيب بالكامل
  /// 8. حفظ/تحديث جدول عمل الطبيب بالكامل
  Future<String> setDoctorSchedules({
    required int clinicId,
    required int clinicDoctorId,
    required List<DoctorScheduleModel> schedules,
  }) async {
    final body = {'schedules': schedules.map((s) => s.toJson()).toList()};
    final response = await _apiService.put(
      "admin/clinics/$clinicId/doctors/$clinicDoctorId/schedules",
      body: body,
    );
    return response['message'] ?? "تم تحديث جدول العمل بنجاح";
  }
}
