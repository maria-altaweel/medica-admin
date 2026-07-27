import 'clinic_model.dart';

class ClinicDetailsModel {
  final int id;
  final String name;
  final String address;
  final String phone;
  final String emergencyPhone;
  final String? email;
  final String? logo;
  final String? bankAccount;
  final int doctorsCount;
  final dynamic averageRating;
  final List<SpecializationModel> specializations;

  ClinicDetailsModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.emergencyPhone,
    this.email,
    this.logo,
    this.bankAccount,
    required this.doctorsCount,

    this.averageRating,
    required this.specializations,
  });

  factory ClinicDetailsModel.fromJson(Map<String, dynamic> json) {
    return ClinicDetailsModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      emergencyPhone: json['emergency_phone'] ?? '',
      email: json['email'],
      logo: json['logo'],
      bankAccount: json['bank_account'],
      doctorsCount: json['doctors_count'] ?? 0,
      averageRating: json['average_rating'] ?? 0.0,
      specializations:
          (json['specializations'] as List?)
              ?.map((e) => SpecializationModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class SpecializationModel {
  final int id;
  final String name;
  final int doctorsCount;

  SpecializationModel({
    required this.id,
    required this.name,
    required this.doctorsCount,
  });

  factory SpecializationModel.fromJson(Map<String, dynamic> json) {
    return SpecializationModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      doctorsCount: json['doctors_count'] ?? 0,
    );
  }
}
