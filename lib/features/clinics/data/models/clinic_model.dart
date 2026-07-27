class ClinicModel {
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

  ClinicModel({
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
  });

  factory ClinicModel.fromJson(Map<String, dynamic> json) {
    return ClinicModel(
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
    );
  }
}
