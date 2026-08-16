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
      id: _parseNum(json['id']).toInt(),
      doctorId: _parseNum(json['doctor_id']).toInt(),
      doctorName: json['doctor_name'] ?? '',
      doctorPhone: json['doctor_phone'] ?? '',
      specialization: json['specialization'] ?? '',
      status: json['status'] ?? 'pending',
      consultationFee: _parseNum(json['consultation_fee']),
      salaryPercentage: json['salary_percentage'] != null
          ? _parseNum(json['salary_percentage'])
          : null,
      isAvailable: json['is_available'] == 1 || json['is_available'] == true,
      profile: json['profile'],
    );
  }

  // دالة مساعدة لتحويل أي قيمة (String أو int أو double) إلى num بأمان تام
  static num _parseNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0;
    return 0;
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
