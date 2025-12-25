import 'package:flutter/material.dart';
import '../models/teacher_models.dart';

class LessonCard extends StatelessWidget {
  final Lesson lesson;
  final VoidCallback? onTap;
  const LessonCard({Key? key, required this.lesson, this.onTap}) : super(key: key);

  Color _statusColor(String status) {
    switch (status) {
      case 'În desfășurare':
        return Colors.greenAccent;
      case 'Urmează':
        return Colors.blueAccent;
      case 'Finalizată':
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(lesson.status);
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            Container(width: 56, height: 56, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.schedule, color: Colors.white70)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(lesson.time, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                Text('${lesson.schoolClass.name} • ${lesson.schoolClass.subject}', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 6),
                Row(children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(12)), child: Text(lesson.status, style: TextStyle(color: statusColor))),
                  const SizedBox(width: 8),
                  Text(lesson.room, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54)),
                ]),
              ]),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ]),
        ),
      ),
    );
  }
}

