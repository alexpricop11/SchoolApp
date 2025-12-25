import 'package:flutter/material.dart';
import '../models/teacher_models.dart';
import 'schedule_card.dart';
import 'lesson_card.dart';

typedef LessonTapCallback = void Function(Lesson lesson);
typedef VoidCallbackNoArgs = void Function();

class DashboardBody extends StatelessWidget {
  final List<Lesson> lessons;
  final LessonTapCallback onLessonTap;
  final VoidCallbackNoArgs onAllClassesPressed;

  const DashboardBody({
    Key? key,
    required this.lessons,
    required this.onLessonTap,
    required this.onAllClassesPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Prominent schedule card (first lesson)
          ScheduleCard(nextLesson: lessons.first),
          const SizedBox(height: 20),

          // Section title
          Text('Lecțiile de azi', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),

          // Today's lessons: performant list rendering
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lessons.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final lesson = lessons[i];
              return LessonCard(
                lesson: lesson,
                onTap: () => onLessonTap(lesson),
              );
            },
          ),

          const SizedBox(height: 20),

          // Button to All Classes
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAllClassesPressed,
              icon: const Icon(Icons.class_),
              label: const Text('Clasele mele'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
        ],
      ),
    );
  }
}

