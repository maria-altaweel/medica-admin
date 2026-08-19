import 'package:medica_admin/core/networking/api_service.dart';
import 'package:medica_admin/features/salaries/data/models/salary_model.dart';
import 'package:medica_admin/features/salaries/data/repos/salary_repo.dart';

class SalaryRepoImpl implements SalaryRepo {
  final ApiService _apiService;

  SalaryRepoImpl(this._apiService);

  @override
  Future<List<SalaryPayoutModel>> getSalaries({
    int? clinicId,
    int? doctorId,
    String? status,
    String? periodStart,
    String? periodEnd,
  }) async {
    String url = 'admin/salaries?';
    if (clinicId != null) url += 'clinic_id=$clinicId&';
    if (doctorId != null) url += 'doctor_id=$doctorId&';
    if (status != null) url += 'status=$status&';
    if (periodStart != null) url += 'period_start=$periodStart&';
    if (periodEnd != null) url += 'period_end=$periodEnd&';

    if (url.endsWith('&') || url.endsWith('?')) {
      url = url.substring(0, url.length - 1);
    }

    final response = await _apiService.get(url);

    // التعديل هنا: حماية ضد الـ null إذا جاءت القائمة فارغة
    final List data = response['data'] ?? [];
    return data.map((e) => SalaryPayoutModel.fromJson(e)).toList();
  }

  @override
  Future<SalaryPayoutModel> getSalaryDetails(int id) async {
    final response = await _apiService.get('admin/salaries/$id');
    final responseData = response['data'] ?? {};
    final salaryData = responseData['salary'] ?? responseData;

    if (responseData['breakdown'] != null) {
      salaryData['breakdown'] = responseData['breakdown'];
    }
    if (responseData['payments'] != null) {
      salaryData['payments'] = responseData['payments'];
    }

    return SalaryPayoutModel.fromJson(salaryData);
  }

  @override
  Future<List<SalaryPayoutModel>> generateSalaries({
    required int clinicId,
    required String periodStart,
    required String periodEnd,
  }) async {
    final response = await _apiService.post('admin/salaries/generate', {
      'clinic_id': clinicId,
      'period_start': periodStart,
      'period_end': periodEnd,
    });

    final List data = response['data'] ?? [];
    return data.map((e) => SalaryPayoutModel.fromJson(e)).toList();
  }

  @override
  Future<SalaryPayoutModel> approveSalary(int id) async {
    // إرسال الطلب بالطريقة الصحيحة للرابط
    final response = await _apiService.post('admin/salaries/$id/approve', {});

    // التقاط الـ data المختصرة التي يرسلها الباك إند عند الاعتماد
    final responseData = response['data'] ?? response;
    return SalaryPayoutModel.fromJson(responseData);
  }
}
