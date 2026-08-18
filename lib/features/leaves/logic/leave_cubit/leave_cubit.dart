import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/features/leaves/data/models/leave_model.dart';
import 'package:medica_admin/features/leaves/data/repos/leave_repo.dart';

part 'leave_state.dart';

class LeaveCubit extends Cubit<LeaveState> {
  final LeaveRepository _leaveRepository;

  LeaveCubit(this._leaveRepository) : super(LeaveInitial());

  /// 1. جلب قائمة الإجازات مع دعم الفلاتر القادمة من الـ UI
  Future<void> getLeaveRequests({
    required int clinicId,
    String? status,
    int? clinicDoctorId,
    String? dateFrom,
    String? dateTo,
  }) async {
    emit(LeavesLoading());
    try {
      final leaves = await _leaveRepository.getLeaveRequests(
        clinicId: clinicId,
        status: status,
        clinicDoctorId: clinicDoctorId,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
      emit(LeavesLoaded(leaves));
    } catch (e) {
      emit(LeaveError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  /// 2. جلب تفاصيل طلب إجازة واحد
  Future<void> getLeaveDetails({required int clinicId, required int id}) async {
    emit(LeavesLoading());
    try {
      final leave = await _leaveRepository.getLeaveDetails(
        clinicId: clinicId,
        id: id,
      );
      emit(LeaveDetailsLoaded(leave));
    } catch (e) {
      emit(LeaveError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  /// 3. الموافقة على طلب الإجازة
  Future<void> approveLeave({
    required int clinicId,
    required int id,
    required Function() onSuccess,
  }) async {
    emit(LeaveActionLoading());
    try {
      final response = await _leaveRepository.approveLeaveRequest(
        clinicId: clinicId,
        id: id,
      );
      final message =
          response['message'] ?? "تمت الموافقة على طلب الإجازة بنجاح";
      emit(LeaveActionSuccess(message));
      onSuccess(); // لتحديث القائمة في الواجهة فوراً
    } catch (e) {
      emit(LeaveError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  /// 4. رفض طلب الإجازة
  Future<void> rejectLeave({
    required int clinicId,
    required int id,
    required Function() onSuccess,
  }) async {
    emit(LeaveActionLoading());
    try {
      final response = await _leaveRepository.rejectLeaveRequest(
        clinicId: clinicId,
        id: id,
      );
      final message = response['message'] ?? "تم رفض طلب الإجازة";
      emit(LeaveActionSuccess(message));
      onSuccess(); // لتحديث القائمة في الواجهة فوراً
    } catch (e) {
      emit(LeaveError(e.toString().replaceAll("Exception: ", "")));
    }
  }
}
