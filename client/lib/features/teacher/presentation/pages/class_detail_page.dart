import 'package:flutter/material.dart';
import '../models/teacher_models.dart';

class ClassDetailPage extends StatelessWidget {
  final SchoolClass schoolClass;

  const ClassDetailPage({Key? key, required this.schoolClass})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${schoolClass.name} — ${schoolClass.subject}'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.separated(
          itemCount: schoolClass.students.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final s = schoolClass.students[i];
            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              color: Theme.of(context).cardColor,
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.deepPurpleAccent,
                      child: Text(
                        s.name.split(' ').map((p) => p[0]).take(2).join(),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.name,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Note: ${s.grade ?? "-"}  •  Absente: ${s.absences ?? 0}',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            _showGradeDialog(context, s);
                          },
                          icon: const Icon(Icons.edit, color: Colors.greenAccent),
                          tooltip: 'Adaugă/Modifică notă',
                        ),
                        IconButton(
                          onPressed: () {
                            _incrementAbsence(s);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Absență adăugată pentru ${s.name}'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          icon: const Icon(Icons.event_busy,
                              color: Colors.redAccent),
                          tooltip: 'Adaugă absență',
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showGradeDialog(BuildContext context, Student s) {
    final controller = TextEditingController(text: s.grade?.toString() ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nota pentru ${s.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Introdu nota',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Anulează'),
          ),
          TextButton(
            onPressed: () {
              s.grade = int.tryParse(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Salvează'),
          ),
        ],
      ),
    );
  }

  void _incrementAbsence(Student s) {
    s.absences = (s.absences ?? 0) + 1;
  }
}
