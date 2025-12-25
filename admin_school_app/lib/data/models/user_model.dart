import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  final String username;
  final String email;
  final String role;
  final bool isActive;
  final String userId;
  String accessToken;

  UserModel({
    required this.username,
    required this.email,
    required this.role,
    required this.isActive,
    required this.userId,
    required this.accessToken,
  }) : super(
         username: username,
         email: email,
         role: role,
         isActive: isActive,
         userId: userId,
         accessToken: accessToken,
       );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      isActive: json['is_active'] ?? false,
      userId: json['userId'] ?? '',
      accessToken: json['accessToken'] ?? '',
    );
  }
}
