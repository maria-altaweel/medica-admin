class AdModel {
  final int id;
  final int clinicId;
  final String? clinicName;
  final String? image;
  final bool isActive;
  final String createdAt;

  AdModel({
    required this.id,
    required this.clinicId,
    this.clinicName,
    this.image,
    required this.isActive,
    required this.createdAt,
  });

  // دالة لتحويل الـ JSON الجاي من الباك إند إلى Object
  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      id: json['id'],
      clinicId: json['clinic_id'],
      clinicName: json['clinic_name'],
      image: json['image'],
      // دعم كل الاحتمالات الممككنة القادمة من السيرفر (num, bool, String)
      isActive:
          json['is_active'] == 1 ||
          json['is_active'] == true ||
          json['is_active'] == '1' ||
          json['is_active'] == 'true',
      createdAt: json['created_at'] ?? '',
    );
  }

  // دالة copyWith لإنشاء نسخة جديدة معدلة فوراً
  AdModel copyWith({
    int? id,
    int? clinicId,
    String? clinicName,
    String? image,
    bool? isActive,
    String? createdAt,
  }) {
    return AdModel(
      id: id ?? this.id,
      clinicId: clinicId ?? this.clinicId,
      clinicName: clinicName ?? this.clinicName,
      image: image ?? this.image,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
