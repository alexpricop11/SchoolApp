import 'package:flutter/material.dart';
import '../models/teacher_models.dart';

class ScheduleCard extends StatelessWidget {
  final Lesson nextLesson;
  const ScheduleCard({Key? key, required this.nextLesson}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 6))],
      ),
      child: Row(
        children: [
          // time
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Următoarea lecție', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text(nextLesson.time, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(width: 20),
          // details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${nextLesson.schoolClass.name} • ${nextLesson.schoolClass.subject}', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Row(children: [const Icon(Icons.location_on, size: 16, color: Colors.grey), const SizedBox(width: 6), Text(nextLesson.room, style: Theme.of(context).textTheme.bodySmall)]),
                const SizedBox(height: 12),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                    child: Text(nextLesson.status, style: const TextStyle(color: Colors.greenAccent)),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

