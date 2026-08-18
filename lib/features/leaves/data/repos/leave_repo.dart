import 'package:medica_admin/core/networking/api_service.dart';
import 'package:medica_admin/features/leaves/data/models/leave_model.dart';

class LeaveRepository {
  final ApiService _apiService;

  LeaveRepository(this._apiService);

  /// 1. جلب قائمة طلبات الإجازة (Index)

  Future<List<LeaveModel>> getLeaveRequests({
    required int clinicId,
    String? status,
    int? clinicDoctorId,
    String? dateFrom,
    String? dateTo,
  }) async {
    String endpoint = "admin/clinics/$clinicId/leaves";

    // مطابقة الـ Parameters مع ما يستقبله الـ Request في الكونترولر
    final List<String> queryParams = [];
    if (status != null && status.isNotEmpty) queryParams.add("status=$status");
    if (clinicDoctorId != null)
      queryParams.add("clinic_doctor_id=$clinicDoctorId");
    if (dateFrom != null && dateFrom.isNotEmpty)
      queryParams.add("date_from=$dateFrom");
    if (dateTo != null && dateTo.isNotEmpty) queryParams.add("date_to=$dateTo");

    if (queryParams.isNotEmpty) {
      endpoint += "?" + queryParams.join("&");
    }

    final response = await _apiService.get(endpoint);
    // الكونترولر يرجع 'data' كمصفوفة
    final List data = response['data'] ?? [];
    return data.map((json) => LeaveModel.fromJson(json)).toList();
  }

  /// 2. جلب تفاصيل طلب إجازة (Show)

  Future<LeaveModel> getLeaveDetails({
    required int clinicId,
    required int id,
  }) async {
    final response = await _apiService.get(
      "admin/clinics/$clinicId/leave-requests/$id",
    );
    // الكونترولر يرجع 'data' ككائن واحد
    return LeaveModel.fromJson(response['data']);
  }

  /// 3. الموافقة على طلب الإجازة (Approve)

  Future<Map<String, dynamic>> approveLeaveRequest({
    required int clinicId,
    required int id,
  }) async {
    return await _apiService.put(
      "admin/clinics/$clinicId/leave-requests/$id/approve",
      body: {}, // الكونترولر لا يحتاج body خاص للموافقة
    );
  }

  /// 4. رفض طلب الإجازة (Reject)

  Future<Map<String, dynamic>> rejectLeaveRequest({
    required int clinicId,
    required int id,
  }) async {
    return await _apiService.put(
      "admin/clinics/$clinicId/leave-requests/$id/reject",
      body: {},
    );
  }
}
