class DoctorScheduleModel {
  final int? id;
  final int dayOfWeek; // 0 to 6
  final String startTime; // "HH:mm"
  final String endTime; // "HH:mm"
  final bool isActive;

  DoctorScheduleModel({
    this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.isActive = true,
  });

  factory DoctorScheduleModel.fromJson(Map<String, dynamic> json) {
    return DoctorScheduleModel(
      id: json['id'],
      dayOfWeek: json['day_of_week'] ?? 0,
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'is_active': isActive,
    };
  }
}
