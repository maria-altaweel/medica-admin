class LeaveModel {
  final int id;
  final String? doctorName;
  final String? specialization;
  final int? clinicDoctorId;
  final String? unavailableDate;
  final String? reason;
  final String? status; // pending, approved, rejected
  final String? approvedBy;
  final String? createdAt;
  final String? updatedAt;

  LeaveModel({
    required this.id,
    this.doctorName,
    this.specialization,
    this.clinicDoctorId,
    this.unavailableDate,
    this.reason,
    this.status,
    this.approvedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    return LeaveModel(
      id: json['id'] ?? 0,
      doctorName: json['doctor_name'],
      specialization: json['specialization'],
      clinicDoctorId: json['clinic_doctor_id'],
      unavailableDate: json['unavailable_date'],
      reason: json['reason'],
      status: json['status'],
      approvedBy: json['approved_by'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor_name': doctorName,
      'specialization': specialization,
      'clinic_doctor_id': clinicDoctorId,
      'unavailable_date': unavailableDate,
      'reason': reason,
      'status': status,
      'approved_by': approvedBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
