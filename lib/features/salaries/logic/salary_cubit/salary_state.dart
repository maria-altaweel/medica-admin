import 'package:medica_admin/features/salaries/data/models/salary_model.dart';

abstract class SalaryState {}

class SalaryInitial extends SalaryState {}

// جلب قائمة الرواتب
class GetSalariesLoading extends SalaryState {}

class GetSalariesSuccess extends SalaryState {
  final List<SalaryPayoutModel> salaries;
  GetSalariesSuccess(this.salaries);
}

class GetSalariesError extends SalaryState {
  final String message;
  GetSalariesError(this.message);
}

// جلب تفاصيل الراتب
class GetSalaryDetailsLoading extends SalaryState {}

class GetSalaryDetailsSuccess extends SalaryState {
  final SalaryPayoutModel salaryDetails;
  GetSalaryDetailsSuccess(this.salaryDetails);
}

class GetSalaryDetailsError extends SalaryState {
  final String message;
  GetSalaryDetailsError(this.message);
}

// توليد الرواتب
class GenerateSalariesLoading extends SalaryState {}

class GenerateSalariesSuccess extends SalaryState {
  final List<SalaryPayoutModel> generatedSalaries;
  GenerateSalariesSuccess(this.generatedSalaries);
}

class GenerateSalariesError extends SalaryState {
  final String message;
  GenerateSalariesError(this.message);
}

// اعتماد الراتب (Approve)
class ApproveSalaryLoading extends SalaryState {
  final int salaryId; // لمعرفة أي راتب يتم اعتماده حالياً لإظهار اللودينغ عليه
  ApproveSalaryLoading(this.salaryId);
}

class ApproveSalarySuccess extends SalaryState {
  final SalaryPayoutModel approvedSalary;
  ApproveSalarySuccess(this.approvedSalary);
}

class ApproveSalaryError extends SalaryState {
  final String message;
  ApproveSalaryError(this.message);
}
