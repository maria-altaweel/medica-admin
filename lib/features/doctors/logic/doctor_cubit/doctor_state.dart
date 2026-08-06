abstract class DoctorState {}

class DoctorInitialState extends DoctorState {}

// --- حالات جلب الأطباء ---
class GetDoctorsLoadingState extends DoctorState {}

class GetDoctorsSuccessState extends DoctorState {}

class GetDoctorsErrorState extends DoctorState {
  final String message;
  GetDoctorsErrorState(this.message);
}

// --- حالات جلب طلبات الانضمام ---
class GetDoctorRequestsLoadingState extends DoctorState {}

class GetDoctorRequestsSuccessState extends DoctorState {}

class GetDoctorRequestsErrorState extends DoctorState {
  final String message;
  GetDoctorRequestsErrorState(this.message);
}

// --- حالات قبول / رفض الطلب ---
class ActionDoctorRequestLoadingState extends DoctorState {}

class ActionDoctorRequestSuccessState extends DoctorState {
  final String message;
  ActionDoctorRequestSuccessState(this.message);
}

class ActionDoctorRequestErrorState extends DoctorState {
  final String message;
  ActionDoctorRequestErrorState(this.message);
}

// --- حالات تحديث بيانات الطبيب ---
class UpdateDoctorLoadingState extends DoctorState {}

class UpdateDoctorSuccessState extends DoctorState {
  final String message;
  UpdateDoctorSuccessState(this.message);
}

class UpdateDoctorErrorState extends DoctorState {
  final String message;
  UpdateDoctorErrorState(this.message);
}

// --- حالات إزالة الطبيب ---
class RemoveDoctorLoadingState extends DoctorState {}

class RemoveDoctorSuccessState extends DoctorState {
  final String message;
  RemoveDoctorSuccessState(this.message);
}

class RemoveDoctorErrorState extends DoctorState {
  final String message;
  RemoveDoctorErrorState(this.message);
}

// --- حالات جدول المواعيد ---
class GetSchedulesLoadingState extends DoctorState {}

class GetSchedulesSuccessState extends DoctorState {}

class GetSchedulesErrorState extends DoctorState {
  final String message;
  GetSchedulesErrorState(this.message);
}

class SetSchedulesLoadingState extends DoctorState {}

class SetSchedulesSuccessState extends DoctorState {
  final String message;
  SetSchedulesSuccessState(this.message);
}

class SetSchedulesErrorState extends DoctorState {
  final String message;
  SetSchedulesErrorState(this.message);
}
