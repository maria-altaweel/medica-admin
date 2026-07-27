class AdminModel {
  final String token;
  final dynamic
  user; // ممكن نخليه dynamic حالياً أو ننشئ كلاس للمستخدم إذا احتجنا بياناته

  AdminModel({required this.token, required this.user});

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(token: json['token'], user: json['user']);
  }
}
