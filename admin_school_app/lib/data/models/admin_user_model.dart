import '../../domain/entities/admin_user_entity.dart';

class AdminUserModel extends AdminUserEntity {
  AdminUserModel({
    super.id,
    required super.username,
    required super.email,
    required super.role,
    super.isActivated = false,
    super.schoolId,
    super.createdAt,
    super.updatedAt,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['id']?.toString(),
      username: json['username'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      isActivated: json['is_activated'] as bool? ?? false,
      schoolId: json['school_id']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'username': username,
      'email': email,
      'role': role,
      'is_activated': isActivated,
      if (schoolId != null) 'school_id': schoolId,
    };
  }
}