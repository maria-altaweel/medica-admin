import 'package:medica_admin/features/salaries/data/models/salary_model.dart';

abstract class SalaryRepo {
  Future<List<SalaryPayoutModel>> getSalaries({
    int? clinicId,
    int? doctorId,
    String? status,
    String? periodStart,
    String? periodEnd,
  });

  Future<SalaryPayoutModel> getSalaryDetails(int id);

  Future<List<SalaryPayoutModel>> generateSalaries({
    required int clinicId,
    required String periodStart,
    required String periodEnd,
  });

  Future<SalaryPayoutModel> approveSalary(int id);
}
