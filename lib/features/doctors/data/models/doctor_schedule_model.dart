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
      id: json['id'] != null ? _parseInt(json['id']) : null,
      dayOfWeek: _parseInt(json['day_of_week']),
      startTime: _formatTime(json['start_time']),
      endTime: _formatTime(json['end_time']),
      // 👈 إذا كانت القيمة null من السيرفر، نعطيها افتراضياً true
      isActive: json['is_active'] == null
          ? true
          : (json['is_active'] == 1 || json['is_active'] == true),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // دالة تضمن إرجاع الوقت بفرمتة "HH:mm" حتى لو أرجعه السيرفر "HH:mm:ss"
  static String _formatTime(dynamic value) {
    if (value == null) return '';
    String timeStr = value.toString();
    if (timeStr.length >= 5) {
      return timeStr.substring(0, 5); // يأخذ أول 5 خانات فقط (08:00)
    }
    return timeStr;
  }

  Map<String, dynamic> toJson() {
    return {
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'is_active': isActive ? 1 : 0,
    };
  }
}
