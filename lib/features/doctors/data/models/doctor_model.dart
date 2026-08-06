class DoctorModel {
  final int id; // clinicDoctorId
  final int doctorId;
  final String doctorName;
  final String doctorPhone;
  final String specialization;
  final String status;
  final num consultationFee;
  final num? salaryPercentage;
  final bool isAvailable;
  final String? profile;

  DoctorModel({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.doctorPhone,
    required this.specialization,
    required this.status,
    required this.consultationFee,
    this.salaryPercentage,
    required this.isAvailable,
    this.profile,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] ?? 0,
      doctorId: json['doctor_id'] ?? 0,
      doctorName: json['doctor_name'] ?? '',
      doctorPhone: json['doctor_phone'] ?? '',
      specialization: json['specialization'] ?? '',
      status: json['status'] ?? 'pending',
      consultationFee: json['consultation_fee'] ?? 0,
      salaryPercentage: json['salary_percentage'],
      isAvailable: json['is_available'] == 1 || json['is_available'] == true,
      profile: json['profile'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'doctor_phone': doctorPhone,
      'specialization': specialization,
      'status': status,
      'consultation_fee': consultationFee,
      'salary_percentage': salaryPercentage,
      'is_available': isAvailable,
      'profile': profile,
    };
  }
}
