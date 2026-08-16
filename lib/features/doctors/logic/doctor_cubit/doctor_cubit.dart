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

  // متغير البحث المحلي بالاسم أو رقم الهاتف
  String searchQuery = '';

  /// دالة تعطينا القائمة المفلترة فوراً للـ UI بناءً على البحث المحلي
  List<DoctorModel> get filteredDoctorsList {
    if (searchQuery.trim().isEmpty) return doctorsList;

    final query = searchQuery.trim().toLowerCase();
    return doctorsList.where((doctor) {
      final matchesName = doctor.doctorName.toLowerCase().contains(query);
      final matchesPhone = doctor.doctorPhone.toLowerCase().contains(query);
      return matchesName || matchesPhone;
    }).toList();
  }

  /// دالة تحديث نص البحث وإعادة بناء القائمة محلياً
  void setSearchQuery(String query) {
    searchQuery = query;
    emit(GetDoctorsSuccessState());
  }

  /// 1. جلب قائمة الأطباء الخاصة بالعيادة
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
      emit(ActionDoctorRequestSuccessState(message));
      // تحديث القوائم بعد إبلاغ الواجهة بالنجاح
      fetchDoctorRequests(clinicId);
      fetchDoctors(clinicId);
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
      emit(ActionDoctorRequestSuccessState(message));
      // تحديث قائمة الطلبات بعد إبلاغ الواجهة بالنجاح
      fetchDoctorRequests(clinicId);
      fetchDoctors(clinicId);
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
      emit(UpdateDoctorSuccessState(message));
      fetchDoctors(clinicId);
    } catch (e) {
      String errorMessage = "حدث خطأ غير متوقع، يرجى المحاولة مجدداً";

      final errorStr = e.toString().toLowerCase();

      // 1️⃣ أولاً: التحقق من أخطاء الإنترنت والاتصال
      if (errorStr.contains('socketexception') ||
          errorStr.contains('connection refused') ||
          errorStr.contains('network is unreachable') ||
          errorStr.contains('failed host lookup') ||
          errorStr.contains('timeout')) {
        errorMessage =
            "لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة والمحاولة مجدداً";
      }
      // 2️⃣ ثانياً: إذا كان الخطأ قادماً من الـ API (مثل DioException أو رسالة من الباك إند)
      else {
        // تنظيف النص وإزالة كلمة Exception إن وجدت
        String cleanError = e.toString().replaceAll("Exception: ", "").trim();

        // إذا كانت الرسالة عبارة عن خطأ تقني بحت من Dio ولا تفيد المستخدم، نعطيه رسالة بديلة لطيفة
        if (cleanError.isNotEmpty && !cleanError.contains("DioException")) {
          errorMessage =
              cleanError; // هنا ستظهر رسالة السيرفر الواضحة (إذا كانت مرسلة من الباك إند)
        } else {
          errorMessage = "حدث خطأ أثناء معالجة الطلب، يرجى المحاولة لاحقاً";
        }
      }

      // إرسال الخطأ الواضح للـ UI ليتم عرضه بـ Appsnackbar
      emit(UpdateDoctorErrorState(errorMessage));
    }
  }

  /// 6. إزالة الطبيب من العيادة
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

      // تعريب رسالة النجاح بشكل أنيق وواضح
      const arabicSuccessMessage = "تمت إزالة الطبيب من العيادة بنجاح ✅";

      emit(RemoveDoctorSuccessState(arabicSuccessMessage));

      // تحديث قائمة الأطباء
      fetchDoctors(clinicId);
    } catch (e) {
      String errorMessage = "حدث خطأ غير متوقع، يرجى المحاولة مجدداً";

      final errorStr = e.toString().toLowerCase();

      if (errorStr.contains('connection refused') ||
          errorStr.contains('network is unreachable') ||
          errorStr.contains('timeout')) {
        errorMessage =
            "لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة والمحاولة مجدداً";
      } else {
        String cleanError = e.toString().replaceAll("Exception: ", "").trim();

        if (cleanError.isNotEmpty && !cleanError.contains("DioException")) {
          errorMessage = cleanError; // رسالة الخطأ الواضحة إن وجدت من السيرفر
        } else {
          errorMessage = "فشل في إزالة الطبيب، يرجى المحاولة لاحقاً ❌";
        }
      }

      // إرسال الخطأ الواضح للـ UI ليتم عرضه بـ Appsnackbar
      emit(RemoveDoctorErrorState(errorMessage));
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
      emit(SetSchedulesSuccessState(message));
      // إعادة جلب الجدول المحدث
      fetchSchedules(clinicId: clinicId, clinicDoctorId: clinicDoctorId);
    } catch (e) {
      emit(SetSchedulesErrorState(e.toString().replaceAll("Exception: ", "")));
    }
  }
}
