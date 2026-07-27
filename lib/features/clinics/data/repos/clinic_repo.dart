import 'dart:io';
import 'package:medica_admin/core/networking/api_service.dart';
import '../models/clinic_model.dart';
import '../models/clinic_details_model.dart';
import '../models/clinic_doctor_model.dart';

class ClinicsRepo {
  final ApiService _apiService;

  ClinicsRepo(this._apiService);

  // 1. جلب قائمة كل العيادات
  Future<List<ClinicModel>> getClinics() async {
    final response = await _apiService.get('admin/clinics');
    final List data = response['data'] ?? [];
    return data.map((json) => ClinicModel.fromJson(json)).toList();
  }

  // 2. جلب تفاصيل عيادة محددة والتخصصات المتاحة فيها
  Future<ClinicDetailsModel> getClinicDetails(int clinicId) async {
    final response = await _apiService.get('admin/clinics/$clinicId');
    return ClinicDetailsModel.fromJson(response['data']);
  }

  // 3. جلب الأطباء التابعين لتخصص محدد داخل عيادة
  Future<List<ClinicDoctorModel>> getClinicDoctorsBySpecialization({
    required int clinicId,
    required int specializationId,
  }) async {
    final response = await _apiService.get(
      'admin/clinics/$clinicId/doctors?specialization_id=$specializationId',
    );
    final List data = response['data'] ?? [];
    return data.map((json) => ClinicDoctorModel.fromJson(json)).toList();
  }

  // 4. إضافة عيادة جديدة (تستخدم Multipart لدعم رفع الصورة)
  Future<void> addClinic({
    required String name,
    required String address,
    required String phone,
    required String emergencyPhone,
    String? email,
    String? bankAccount,
    File? logoFile,
  }) async {
    final Map<String, String> fields = {
      'name': name,
      'address': address,
      'phone': phone,
      'emergency_phone': emergencyPhone,
      if (email != null && email.isNotEmpty) 'email': email,
      if (bankAccount != null && bankAccount.isNotEmpty)
        'bank_account': bankAccount,
    };

    await _apiService.postMultipart(
      endpoint: 'admin/clinics',
      fields: fields,
      file: logoFile,
      fileKey: 'logo',
    );
  }

  // 5. تعديل عيادة موجودة
  Future<void> updateClinic({
    required int clinicId,
    required String name,
    required String address,
    required String phone,
    required String emergencyPhone,
    String? email,
    String? bankAccount,
    File? logoFile,
  }) async {
    final Map<String, String> fields = {
      'name': name,
      'address': address,
      'phone': phone,
      'emergency_phone': emergencyPhone,
      'email': email ?? '',
      'bank_account': bankAccount ?? '',
      '_method': 'PUT', // لإعلام لارافيل بطلب التحديث من نوع Multipart
    };

    await _apiService.postMultipart(
      endpoint: 'admin/clinics/$clinicId',
      fields: fields,
      file: logoFile,
      fileKey: 'logo',
    );
  }

  // 6. حذف عيادة
  Future<void> deleteClinic(int clinicId) async {
    await _apiService.delete('admin/clinics/$clinicId');
  }
}
