import 'package:medica_admin/core/helpers/Image_Picker_helper.dart';

abstract class ClinicsEvent {}

class FetchClinicsEvent extends ClinicsEvent {}

class FetchClinicDetailsEvent extends ClinicsEvent {
  final int clinicId;
  FetchClinicDetailsEvent(this.clinicId);
}

class FetchClinicDoctorsEvent extends ClinicsEvent {
  final int clinicId;
  final int specializationId;
  FetchClinicDoctorsEvent({
    required this.clinicId,
    required this.specializationId,
  });
}

class AddClinicEvent extends ClinicsEvent {
  final String name;
  final String address;
  final String phone;
  final String emergencyPhone;
  final String? email;
  final String? bankAccount;
  final PickedFileData? logoFile; // 👈 تغيير النوع لـ PickedFileData?

  AddClinicEvent({
    required this.name,
    required this.address,
    required this.phone,
    required this.emergencyPhone,
    this.email,
    this.bankAccount,
    this.logoFile,
  });
}

class UpdateClinicEvent extends ClinicsEvent {
  final int clinicId;
  final String name;
  final String address;
  final String phone;
  final String emergencyPhone;
  final String? email;
  final String? bankAccount;
  final PickedFileData? logoFile; // 👈 تغيير النوع لـ PickedFileData?

  UpdateClinicEvent({
    required this.clinicId,
    required this.name,
    required this.address,
    required this.phone,
    required this.emergencyPhone,
    this.email,
    this.bankAccount,
    this.logoFile,
  });
}

class DeleteClinicEvent extends ClinicsEvent {
  final int clinicId;
  DeleteClinicEvent(this.clinicId);
}
