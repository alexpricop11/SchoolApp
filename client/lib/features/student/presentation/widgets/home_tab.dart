import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/student_dashboard_controller.dart';
import '../pages/homework_page.dart';
import '../pages/student_notifications_page.dart';

class HomeTab extends StatelessWidget {
  final StudentDashboardController controller;

  const HomeTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => controller.fetchStudentData(forceRefresh: true),
      color: Colors.blueAccent,
      backgroundColor: const Color(0xFF1A1F26),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: _buildNextLessonCard()),
          SliverToBoxAdapter(child: _buildHomeworkSection()),
          SliverToBoxAdapter(child: _buildWeeklyAgenda()),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: SafeArea(
        bottom: false,
        child: Obx(() {
          final student = controller.student.value;
          if (student == null) return const SizedBox(height: 60);

          final hour = DateTime.now().hour;
          final greetingKey = hour < 12
              ? 'greeting_morning'
              : hour < 18
                  ? 'greeting_afternoon'
                  : 'greeting_evening';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(greetingKey.tr, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(
                          student.username,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
                        onPressed: () => Get.to(() => StudentNotificationsPage(controller: controller)),
                      ),
                      if (controller.unreadNotifications > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                            child: Text(
                              '${controller.unreadNotifications}',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildNextLessonCard() {
    return Obx(() {
      final nextLesson = controller.nextLesson;
      final timeUntil = controller.getTimeUntilLesson(nextLesson);

      return GestureDetector(
        onTap: () => controller.currentIndex.value = 2, // Go to schedule
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667eea).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.schedule, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nextLesson != null ? 'next_lesson_title'.tr : 'no_lessons'.tr,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nextLesson != null
                          ? nextLesson.subjectName
                          : 'relax'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (nextLesson != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'in_time'.trParams({'time': timeUntil}),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              nextLesson.startTime,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (nextLesson.room != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'room_label'.trParams({'room': nextLesson.room!}),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 20),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHomeworkSection() {
    return Obx(() {
      final isLoading = controller.isLoadingHomework.value;
      final items = controller.homework.toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

      final upcoming = items.take(3).toList();

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 6, 16, 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F26),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.assignment_outlined, color: Colors.orangeAccent, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Teme pentru acasă',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () => Get.to(() => const HomeworkPage()),
                  child: const Text('Vezi toate'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Center(child: CircularProgressIndicator(color: Colors.orangeAccent)),
              )
            else if (upcoming.isEmpty)
              Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.grey[500]),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Nu ai teme de făcut.',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ),
                ],
              )
            else
              Column(
                children: upcoming
                    .map((h) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F1419),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.orangeAccent.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.assignment, color: Colors.orangeAccent, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        h.subjectName,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        h.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      DateFormat('dd MMM').format(h.dueDate),
                                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('HH:mm').format(h.dueDate),
                                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ),
          ],
        ),
      );
    });
  }

  /// Weekly agenda: schedule + homework + grades grouped per day (Mon–Fri)
  Widget _buildWeeklyAgenda() {
    return _WeeklyAgendaCard(controller: controller);
  }
}

class _WeeklyAgendaCard extends StatefulWidget {
  final StudentDashboardController controller;

  const _WeeklyAgendaCard({required this.controller});

  @override
  State<_WeeklyAgendaCard> createState() => _WeeklyAgendaCardState();
}

class _WeeklyAgendaCardState extends State<_WeeklyAgendaCard> {
  // 0..4 => Mon..Fri
  late int _dayIndex;
  final List<String> _dayKeys = const ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'];

  @override
  void initState() {
    super.initState();
    final weekday = DateTime.now().weekday;
    _dayIndex = weekday >= 1 && weekday <= 5 ? weekday - 1 : 0;
  }

  DateTime _dayDateFromIndex(int index) {
    final now = DateTime.now();
    // Monday of current week
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day).add(Duration(days: index));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F26),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Obx(() {
        final isLoading = widget.controller.isLoadingSchedule.value ||
            widget.controller.isLoadingHomework.value ||
            widget.controller.isLoadingGrades.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.event_note, color: Colors.blueAccent, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Agenda săptămânală',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () => widget.controller.currentIndex.value = 2,
                  child: const Text('Vezi orarul'),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Day selector
            SizedBox(
              height: 56,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, idx) {
                  final date = _dayDateFromIndex(idx);
                  final isSelected = idx == _dayIndex;
                  final isToday = DateTime.now().weekday - 1 == idx;

                  return InkWell(
                    onTap: () => setState(() => _dayIndex = idx),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 64,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isSelected ? null : const Color(0xFF0F1419),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isToday && !isSelected ? Colors.blueAccent : Colors.white10,
                          width: isToday && !isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _dayKeys[idx].tr.substring(0, 2).toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey[300],
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            DateFormat('dd').format(date),
                            style: TextStyle(
                              color: isSelected ? Colors.white70 : Colors.grey[500],
                              fontSize: 12,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
              )
            else
              _AgendaDayTimeline(
                controller: widget.controller,
                day: _dayDateFromIndex(_dayIndex),
                dayKey: _dayKeys[_dayIndex],
              ),
          ],
        );
      }),
    );
  }
}

class _AgendaDayTimeline extends StatelessWidget {
  final StudentDashboardController controller;
  final DateTime day;
  final String dayKey;

  const _AgendaDayTimeline({
    required this.controller,
    required this.day,
    required this.dayKey,
  });

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final schedules = controller.getScheduleForDay(dayKey);

    // Homework due on selected day
    final homeworksBySubject = <String, List<dynamic>>{};
    for (final h in controller.homework.where((h) => _sameDay(h.dueDate, day))) {
      homeworksBySubject.putIfAbsent(h.subjectName, () => []).add(h);
    }

    // Grades created on selected day, grouped by subject
    final gradesBySubject = <String, List<dynamic>>{};
    for (final g in controller.grades.where((g) => _sameDay(g.createdAt, day))) {
      gradesBySubject.putIfAbsent(g.subjectName, () => []).add(g);
    }

    // Attendance on selected day, grouped by subject
    final attendanceBySubject = <String, dynamic>{};
    for (final a in controller.attendance.where((a) => _sameDay(a.attendanceDate, day))) {
      // Keep last status if multiple
      attendanceBySubject[a.subjectName] = a;
    }

    final items = <Widget>[];

    // Render schedule as the base (agenda style)
    for (final s in schedules) {
      final subject = s.subjectName;
      final hwList = (homeworksBySubject[subject] ?? []).cast<dynamic>();
      final grList = (gradesBySubject[subject] ?? []).cast<dynamic>();
      final att = attendanceBySubject[subject];

      final hwText = hwList.isNotEmpty ? 'Temă: ${hwList.first.title}' : null;
      final gradeText = grList.isNotEmpty ? 'Notă: ${grList.last.value}' : null;
      String? attText;
      Color? attColor;
      if (att != null) {
        final status = (att.status ?? '').toString();
        if (status == 'absent') {
          attText = 'Absent';
          attColor = const Color(0xFFEF4444);
        } else {
          attText = 'Prezent';
          attColor = const Color(0xFF10B981);
        }
      }

      final extraParts = <String>[];
      if (hwText != null) extraParts.add(hwText);
      if (gradeText != null) extraParts.add(gradeText);

      items.add(_AgendaItem(
        color: const Color(0xFF3B82F6),
        icon: Icons.menu_book,
        title: subject,
        // Only time here; no room
        subtitle: '${s.startTime} - ${s.endTime}${extraParts.isNotEmpty ? "\n${extraParts.join(' • ')}" : ''}',
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Ora ${s.periodNumber}', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
            if (attText != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: attColor!.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: attColor.withOpacity(0.35)),
                  ),
                  child: Text(attText, style: TextStyle(color: attColor, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ),
          ],
        ),
      ));
    }

    // Also show homework that doesn't match a schedule subject that day (optional)
    final scheduledSubjects = schedules.map((s) => s.subjectName).toSet();
    final orphanHomework = controller.homework.where((h) => _sameDay(h.dueDate, day) && !scheduledSubjects.contains(h.subjectName)).toList();
    for (final hw in orphanHomework) {
      items.add(_AgendaItem(
        color: const Color(0xFFF59E0B),
        icon: Icons.assignment,
        title: hw.subjectName,
        subtitle: 'Temă: ${hw.title}',
        trailing: Text(DateFormat('HH:mm').format(hw.dueDate), style: TextStyle(color: Colors.grey[400], fontSize: 12)),
      ));
    }

    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1419),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Icon(Icons.inbox_outlined, color: Colors.grey[600]),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Nimic planificat pentru ziua asta.',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: items
          .map((w) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: w,
              ))
          .toList(),
    );
  }
}

class _AgendaItem extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _AgendaItem({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1419),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(subtitle, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
