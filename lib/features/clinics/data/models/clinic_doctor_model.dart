class ClinicDoctorModel {
  final int id;
  final String name;
  final String specialization;
  final dynamic rating;
  final String? profile;
  final dynamic consultationFee;

  ClinicDoctorModel({
    required this.id,
    required this.name,
    required this.specialization,
    this.rating,
    this.profile,
    this.consultationFee,
  });

  factory ClinicDoctorModel.fromJson(Map<String, dynamic> json) {
    return ClinicDoctorModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      specialization: json['specialization'] ?? '',
      rating: json['rating'] ?? 0.0,
      profile: json['profile'],
      consultationFee: json['consultation_fee'],
    );
  }
}
