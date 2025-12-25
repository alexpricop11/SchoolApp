import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeworkPage extends StatelessWidget {
  const HomeworkPage({super.key});

  final List<Map<String, String>> homeworks = const [
    {"subject": "Matematică", "task": "Tema 5"},
    {"subject": "Română", "task": "Eseu"},
    {"subject": "Engleză", "task": "Pagina 42-45"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('homework_page_title'.tr)),
      backgroundColor: const Color(0xFF121212),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: homeworks.length,
        itemBuilder: (context, index) {
          final hw = homeworks[index];
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
                    Text(hw["subject"]!,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(hw["task"]!,
                        style: const TextStyle(color: Colors.white70)),
                  ],
                ),
                const Icon(Icons.chevron_right, color: Colors.white54),
              ],
            ),
          );
        },
      ),
    );
  }
}
