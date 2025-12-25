import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  final List<Map<String, String>> notes = const [
    {"subject": "Matematică", "value": "9", "type": "Test"},
    {"subject": "Română", "value": "10", "type": "Examen"},
    {"subject": "Engleză", "value": "8", "type": "Temă"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('notes_page_title'.tr)),
      backgroundColor: const Color(0xFF121212),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1C20),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${note["subject"]} - ${note["value"]}",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(note["type"]!,
                        style: const TextStyle(color: Colors.white70)),
                  ],
                ),
                const Icon(Icons.grade, color: Colors.white54),
              ],
            ),
          );
        },
      ),
    );
  }
}
