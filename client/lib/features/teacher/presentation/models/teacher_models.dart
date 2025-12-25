import 'package:flutter/material.dart';

class Student {
  final String id;
  final String name;
  final String? status;

  var absences;

  int? grade;

  Student({required this.id, required this.name, this.status});
}

class SchoolClass {
  final String id;
  final String name;
  final String subject;
  final List<Student> students;

  SchoolClass({
    required this.id,
    required this.name,
    required this.subject,
    required this.students,
  });
}

class Lesson {
  final String time;
  final SchoolClass schoolClass;
  final String room;
  final String status;

  Lesson({
    required this.time,
    required this.schoolClass,
    required this.room,
    required this.status,
  });
}

// Mock data (kept here so widgets can import models without circular deps)
final List<SchoolClass> mockClasses = [
  SchoolClass(
    id: 'c10a',
    name: '10A',
    subject: 'Matematică',
    students: [
      Student(id: 's1', name: 'Ion Popescu'),
      Student(id: 's2', name: 'Maria Ionescu'),
      Student(id: 's3', name: 'Andrei Georgescu'),
    ],
  ),
  SchoolClass(
    id: 'c11b',
    name: '11B',
    subject: 'Fizică',
    students: [
      Student(id: 's4', name: 'Ana Marinescu'),
      Student(id: 's5', name: 'Vlad Petrescu'),
    ],
  ),
  SchoolClass(
    id: 'c9a',
    name: '9A',
    subject: 'Engleză',
    students: [
      Student(id: 's6', name: 'Ioana Radu'),
      Student(id: 's7', name: 'Cristi Dinu'),
    ],
  ),
];

final List<Lesson> mockLessonsToday = [
  Lesson(
    time: '08:00',
    schoolClass: mockClasses[0],
    room: 'Rm 201',
    status: 'În desfășurare',
  ),
  Lesson(
    time: '09:30',
    schoolClass: mockClasses[1],
    room: 'Rm 110',
    status: 'Urmează',
  ),
  Lesson(
    time: '11:00',
    schoolClass: mockClasses[2],
    room: 'Rm 102',
    status: 'Urmează',
  ),
];
