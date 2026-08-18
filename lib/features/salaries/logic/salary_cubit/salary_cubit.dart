import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/features/salaries/data/models/salary_model.dart';
import 'package:medica_admin/features/salaries/data/repos/salary_repo.dart';
import 'salary_state.dart';

class SalaryCubit extends Cubit<SalaryState> {
  final SalaryRepo _salaryRepo;

  SalaryCubit(this._salaryRepo) : super(SalaryInitial());

  List<SalaryPayoutModel> salariesList = [];

  Future<void> getSalaries({
    int? clinicId,
    int? doctorId,
    String? status,
    String? periodStart,
    String? periodEnd,
  }) async {
    if (!isClosed) emit(GetSalariesLoading());
    try {
      salariesList = await _salaryRepo.getSalaries(
        clinicId: clinicId,
        doctorId: doctorId,
        status: status,
        periodStart: periodStart,
        periodEnd: periodEnd,
      );
      if (!isClosed) emit(GetSalariesSuccess(salariesList));
    } catch (e) {
      if (!isClosed) emit(GetSalariesError(e.toString()));
    }
  }

  Future<void> getSalaryDetails(int id) async {
    if (!isClosed) emit(GetSalaryDetailsLoading());
    try {
      final salaryDetails = await _salaryRepo.getSalaryDetails(id);
      if (!isClosed) emit(GetSalaryDetailsSuccess(salaryDetails));
    } catch (e) {
      if (!isClosed) emit(GetSalaryDetailsError(e.toString()));
    }
  }

  Future<void> generateSalaries({
    required int clinicId,
    required String periodStart,
    required String periodEnd,
  }) async {
    if (!isClosed) emit(GenerateSalariesLoading());
    try {
      final generatedSalaries = await _salaryRepo.generateSalaries(
        clinicId: clinicId,
        periodStart: periodStart,
        periodEnd: periodEnd,
      );
      if (!isClosed) emit(GenerateSalariesSuccess(generatedSalaries));
    } catch (e) {
      if (!isClosed) emit(GenerateSalariesError(e.toString()));
    }
  }

  Future<void> approveSalary(int id) async {
    if (!isClosed) emit(ApproveSalaryLoading(id));
    try {
      final approvedSalary = await _salaryRepo.approveSalary(id);

      // تحديث القائمة محلياً
      final index = salariesList.indexWhere((element) => element.id == id);
      if (index != -1) {
        salariesList[index] = approvedSalary;
      }

      if (!isClosed) {
        // إرسال حالة النجاح
        emit(ApproveSalarySuccess(approvedSalary));
        // هنا السر: إعادة جلب التفاصيل فوراً لتحديث الواجهة وعرض الحالة الجديدة "معتمد"
        getSalaryDetails(id);
      }
    } catch (e) {
      if (!isClosed) emit(ApproveSalaryError(e.toString()));
    }
  }
}
