class UserModel {
  final int userId;
  final String email;
  final String fullName;
  // Các trường có thể null (như avatar_url) thì thêm dấu ?
  final String? avatarUrl;

  UserModel({
    required this.userId,
    required this.email,
    required this.fullName,
    this.avatarUrl,
  });

  // Hàm chuyển đổi từ chuỗi JSON của Node.js thành Object Dart
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'],
      email: json['email'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
    );
  }
}
