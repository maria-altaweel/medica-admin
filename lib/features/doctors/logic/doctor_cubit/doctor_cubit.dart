import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/features/doctors/data/models/doctor_model.dart';
import 'package:medica_admin/features/doctors/data/models/doctor_schedule_model.dart';
import 'package:medica_admin/features/doctors/data/repos/doctor_repo.dart';
import 'doctor_state.dart';

class DoctorCubit extends Cubit<DoctorState> {
  final DoctorRepository _doctorRepository;

  DoctorCubit(this._doctorRepository) : super(DoctorInitialState());

  List<DoctorModel> doctorsList = [];
  List<DoctorModel> requestsList = [];
  List<DoctorScheduleModel> schedulesList = [];

  /// 1. جلب قائمة الأطباء
  Future<void> fetchDoctors(int clinicId, {String? status}) async {
    emit(GetDoctorsLoadingState());
    try {
      doctorsList = await _doctorRepository.getDoctors(
        clinicId: clinicId,
        status: status,
      );
      emit(GetDoctorsSuccessState());
    } catch (e) {
      emit(GetDoctorsErrorState(e.toString().replaceAll("Exception: ", "")));
    }
  }

  /// 2. جلب طلبات الانضمام
  Future<void> fetchDoctorRequests(int clinicId) async {
    emit(GetDoctorRequestsLoadingState());
    try {
      requestsList = await _doctorRepository.getDoctorRequests(clinicId);
      emit(GetDoctorRequestsSuccessState());
    } catch (e) {
      emit(
        GetDoctorRequestsErrorState(e.toString().replaceAll("Exception: ", "")),
      );
    }
  }

  /// 3. قبول طلب الطبيب
  Future<void> acceptRequest({
    required int clinicId,
    required int clinicDoctorId,
  }) async {
    emit(ActionDoctorRequestLoadingState());
    try {
      final message = await _doctorRepository.acceptDoctorRequest(
        clinicId: clinicId,
        clinicDoctorId: clinicDoctorId,
      );
      // إعادة جلب القوائم لتحديث الواجهة فوراً
      await fetchDoctorRequests(clinicId);
      await fetchDoctors(clinicId);
      emit(ActionDoctorRequestSuccessState(message));
    } catch (e) {
      emit(
        ActionDoctorRequestErrorState(
          e.toString().replaceAll("Exception: ", ""),
        ),
      );
    }
  }

  /// 4. رفض طلب الطبيب
  Future<void> rejectRequest({
    required int clinicId,
    required int clinicDoctorId,
  }) async {
    emit(ActionDoctorRequestLoadingState());
    try {
      final message = await _doctorRepository.rejectDoctorRequest(
        clinicId: clinicId,
        clinicDoctorId: clinicDoctorId,
      );
      await fetchDoctorRequests(clinicId);
      emit(ActionDoctorRequestSuccessState(message));
    } catch (e) {
      emit(
        ActionDoctorRequestErrorState(
          e.toString().replaceAll("Exception: ", ""),
        ),
      );
    }
  }

  /// 5. تعديل بيانات الطبيب
  Future<void> updateDoctor({
    required int clinicId,
    required int clinicDoctorId,
    num? consultationFee,
    num? salaryPercentage,
    bool? isAvailable,
  }) async {
    emit(UpdateDoctorLoadingState());
    try {
      final message = await _doctorRepository.updateDoctor(
        clinicId: clinicId,
        clinicDoctorId: clinicDoctorId,
        consultationFee: consultationFee,
        salaryPercentage: salaryPercentage,
        isAvailable: isAvailable,
      );
      await fetchDoctors(clinicId);
      emit(UpdateDoctorSuccessState(message));
    } catch (e) {
      emit(UpdateDoctorErrorState(e.toString().replaceAll("Exception: ", "")));
    }
  }

  /// 6. إزالة الطبيب من العيادة
  Future<void> removeDoctor({
    required int clinicId,
    required int clinicDoctorId,
  }) async {
    emit(RemoveDoctorLoadingState());
    try {
      final message = await _doctorRepository.removeDoctor(
        clinicId: clinicId,
        clinicDoctorId: clinicDoctorId,
      );
      await fetchDoctors(clinicId);
      emit(RemoveDoctorSuccessState(message));
    } catch (e) {
      emit(RemoveDoctorErrorState(e.toString().replaceAll("Exception: ", "")));
    }
  }

  /// 7. جلب جدول المواعيد
  Future<void> fetchSchedules({
    required int clinicId,
    required int clinicDoctorId,
  }) async {
    emit(GetSchedulesLoadingState());
    try {
      schedulesList = await _doctorRepository.getDoctorSchedules(
        clinicId: clinicId,
        clinicDoctorId: clinicDoctorId,
      );
      emit(GetSchedulesSuccessState());
    } catch (e) {
      emit(GetSchedulesErrorState(e.toString().replaceAll("Exception: ", "")));
    }
  }

  /// 8. حفظ جدول المواعيد
  Future<void> setSchedules({
    required int clinicId,
    required int clinicDoctorId,
    required List<DoctorScheduleModel> schedules,
  }) async {
    emit(SetSchedulesLoadingState());
    try {
      final message = await _doctorRepository.setDoctorSchedules(
        clinicId: clinicId,
        clinicDoctorId: clinicDoctorId,
        schedules: schedules,
      );
      await fetchSchedules(clinicId: clinicId, clinicDoctorId: clinicDoctorId);
      emit(SetSchedulesSuccessState(message));
    } catch (e) {
      emit(SetSchedulesErrorState(e.toString().replaceAll("Exception: ", "")));
    }
  }
}
