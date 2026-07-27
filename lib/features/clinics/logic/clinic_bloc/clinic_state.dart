import '../../data/models/clinic_model.dart';
import '../../data/models/clinic_details_model.dart';
import '../../data/models/clinic_doctor_model.dart';

abstract class ClinicsState {}

class ClinicsInitialState extends ClinicsState {}

class ClinicsLoadingState extends ClinicsState {}

class ClinicsSuccessState extends ClinicsState {
  final List<ClinicModel> clinics;
  ClinicsSuccessState(this.clinics);
}

class ClinicDetailsSuccessState extends ClinicsState {
  final ClinicDetailsModel clinicDetails;
  ClinicDetailsSuccessState(this.clinicDetails);
}

class ClinicDoctorsSuccessState extends ClinicsState {
  final List<ClinicDoctorModel> doctors;
  ClinicDoctorsSuccessState(this.doctors);
}

class ClinicActionSuccessState extends ClinicsState {
  final String message;
  ClinicActionSuccessState(this.message);
}

class ClinicsErrorState extends ClinicsState {
  final String errorMessage;
  ClinicsErrorState(this.errorMessage);
}
