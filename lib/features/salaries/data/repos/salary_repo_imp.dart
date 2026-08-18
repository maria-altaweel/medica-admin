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
    // بناء الرابط مع الـ Query Parameters يدوياً بما أن دالة get لا تدعمها
    String url = 'admin/salaries?';
    if (clinicId != null) url += 'clinic_id=$clinicId&';
    if (doctorId != null) url += 'doctor_id=$doctorId&';
    if (status != null) url += 'status=$status&';
    if (periodStart != null) url += 'period_start=$periodStart&';
    if (periodEnd != null) url += 'period_end=$periodEnd&';

    // إزالة آخر حرف '&' أو '?' إذا لم يكن هناك بارامترات
    if (url.endsWith('&') || url.endsWith('?')) {
      url = url.substring(0, url.length - 1);
    }

    final response = await _apiService.get(url);

    final List data = response['data'];
    return data.map((e) => SalaryPayoutModel.fromJson(e)).toList();
  }

  @override
  Future<SalaryPayoutModel> getSalaryDetails(int id) async {
    final response = await _apiService.get('admin/salaries/$id');
    final salaryData = response['data']['salary'];
    salaryData['breakdown'] = response['data']['breakdown'];
    salaryData['payments'] = response['data']['payments'];
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

    final List data = response['data'];
    return data.map((e) => SalaryPayoutModel.fromJson(e)).toList();
  }

  @override
  Future<SalaryPayoutModel> approveSalary(int id) async {
    final response = await _apiService.post('admin/salaries/$id/approve', {});
    return SalaryPayoutModel.fromJson(response['data']);
  }
}
