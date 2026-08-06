class SecretaryModel {
  final int id;
  final int userId;
  final String firstName;
  final String lastName;
  final String phone;
  final bool isActive;
  final String status;
  final String? profile;
  final String createdAt;

  SecretaryModel({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.isActive,
    required this.status,
    this.profile,
    required this.createdAt,
  });

  factory SecretaryModel.fromJson(Map<String, dynamic> json) {
    return SecretaryModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phone: json['phone'] ?? '',
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      status: json['status'] ?? 'active',
      profile: json['profile'],
      createdAt: json['created_at'] ?? '',
    );
  }
  String get fullName => '$firstName $lastName';
}
