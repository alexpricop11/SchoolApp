import 'package:flutter/material.dart';

class Student {
  final int id;
  final String name;
  String status; // "present", "absent", "late"
  double average;

  Student({
    required this.id,
    required this.name,
    required this.status,
    required this.average,
  });
}

class ClassPage extends StatefulWidget {
  final String className;
  final String subject;
  final int totalStudents;
  final VoidCallback onStartLesson;

  const ClassPage({
    super.key,
    required this.className,
    required this.subject,
    required this.totalStudents,
    required this.onStartLesson,
  });

  @override
  State<ClassPage> createState() => _ClassPageState();
}

class _ClassPageState extends State<ClassPage> {
  final TextEditingController searchController = TextEditingController();

  final List<Student> students = [
    Student(id: 1, name: "Andrei Ionescu", status: "present", average: 9.5),
    Student(id: 2, name: "Elena Marin", status: "present", average: 8.7),
    Student(id: 3, name: "Mihai Georgescu", status: "absent", average: 7.8),
    Student(id: 4, name: "Ana Dumitrescu", status: "present", average: 9.2),
    Student(id: 5, name: "Ion Popa", status: "present", average: 8.1),
    Student(id: 6, name: "Maria Stanciu", status: "late", average: 8.9),
    Student(id: 7, name: "Alexandru Radu", status: "present", average: 7.5),
    Student(id: 8, name: "Diana Constantin", status: "present", average: 9.8),
  ];

  String filter = "";

  @override
  Widget build(BuildContext context) {
    final filteredStudents = students
        .where((s) => s.name.toLowerCase().contains(filter.toLowerCase()))
        .toList();

    final presentCount = students.where((s) => s.status == "present").length;
    final absentCount = students.where((s) => s.status == "absent").length;
    final lateCount = students.where((s) => s.status == "late").length;

    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        appBar: AppBar(
          title: Text("${widget.className} - ${widget.subject}"),
          backgroundColor: Colors.black87,
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Caută elev...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    filter = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount;
                    double width = constraints.maxWidth;

                    if (width >= 1200) {
                      crossAxisCount = 4;
                    } else if (width >= 800) {
                      crossAxisCount = 3;
                    } else if (width >= 600) {
                      crossAxisCount = 2;
                    } else {
                      crossAxisCount = 1;
                    }

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 5 / 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                      ),
                      itemCount: filteredStudents.length,
                      itemBuilder: (context, index) {
                        final s = filteredStudents[index];
                        return _buildStudentCard(s);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              // Summary Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statCard("Prezenți", presentCount, Colors.greenAccent),
                  _statCard("Absenți", absentCount, Colors.redAccent),
                  _statCard("Întârziati", lateCount, Colors.orangeAccent),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCard(Student s) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.deepPurpleAccent,
                      child: Text(
                        s.name.split(" ").map((e) => e[0]).take(2).join(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 6,
                        backgroundColor: s.status == "present"
                            ? Colors.greenAccent
                            : s.status == "absent"
                            ? Colors.redAccent
                            : Colors.orangeAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Media: ${s.average}",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Quick Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _addGrade(s),
                  icon: const Icon(Icons.star, size: 16),
                  label: const Text("Notă", style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.greenAccent,
                    elevation: 0,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _addAbsence(s),
                  icon: const Icon(Icons.person_off, size: 16),
                  label: const Text("Absență", style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.redAccent,
                    elevation: 0,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _sendMessage(s),
                  icon: const Icon(Icons.message, size: 16),
                  label: const Text("", style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.blueAccent,
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addGrade(Student s) {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text("Adaugă notă pentru ${s.name}"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "Introdu nota"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Anulează"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  s.average = double.tryParse(controller.text) ?? s.average;
                });
                Navigator.pop(context);
              },
              child: const Text("Salvează"),
            ),
          ],
        );
      },
    );
  }

  void _addAbsence(Student s) {
    setState(() {
      s.status = "absent";
    });
  }

  void _sendMessage(Student s) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Trimite mesaj către ${s.name}")));
  }

  Widget _statCard(String label, int value, Color color) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                "$value",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: color,
                ),
              ),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
