import 'package:equatable/equatable.dart';

class Teacher extends Equatable {
  final String id;
  final String username;
  final String email;
  final String? subject;
  final bool isHomeroom;
  final bool isDirector;

  const Teacher({
    required this.id,
    required this.username,
    required this.email,
    this.subject,
    this.isHomeroom = false,
    this.isDirector = false,
  });

  @override
  List<Object?> get props => [id, username, email, subject, isHomeroom, isDirector];
}
