import 'package:flutter/material.dart';

import '../models/teacher_models.dart';
import 'class_detail_page.dart';

class AllClassesPage extends StatelessWidget {
  final List<SchoolClass> classes;

  const AllClassesPage({Key? key, required this.classes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clasele mele'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.separated(
          itemCount: classes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final c = classes[i];
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ClassDetailPage(schoolClass: c),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.class_, color: Colors.white70, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.name,
                            style: const TextStyle(
                              color: Color(0xE6FFFFFF),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            c.subject,
                            style: const TextStyle(color: Color(0x99FFFFFF)),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${c.students.length} elevi',
                      style: const TextStyle(color: Color(0xE6FFFFFF)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
