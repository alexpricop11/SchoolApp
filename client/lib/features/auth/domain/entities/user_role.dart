enum UserRole { director, teacher, parent, student }

extension UserRoleExtension on UserRole {
  String get name {
    switch (this) {
      case UserRole.director:
        return 'director';
      case UserRole.teacher:
        return 'teacher';
      case UserRole.parent:
        return 'parent';
      case UserRole.student:
        return 'student';
    }
  }

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'director':
        return UserRole.director;
      case 'teacher':
        return UserRole.teacher;
      case 'parent':
        return UserRole.parent;
      case 'student':
        return UserRole.student;
      default:
        throw Exception('Rol necunoscut: $role');
    }
  }
}
