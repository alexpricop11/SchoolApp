import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/dashboard/dashboard_controller.dart';
import '../../widgets/main_layout.dart';
import '../school/schools_page.dart';
import '../class/classes_page.dart';
import '../teacher/teachers_page.dart';
import '../student/students_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());
    final isMobile = MediaQuery.of(context).size.width < 800;

    return SafeArea(
      child: MainLayout(
        currentPage: 'dashboard',
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.indigo),
            );
          }
          if (controller.hasError.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage.value,
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => controller.refresh(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reîncearcă'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildStatCards(controller, isMobile),
                const SizedBox(height: 24),
                _buildCharts(controller, isMobile),
                const SizedBox(height: 24),
                _buildQuickModules(isMobile),
              ],
            ),
          );
        }),
      ),
    );
  }

  // Header Section
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard Modern',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('d MMMM yyyy', 'ro_RO').format(DateTime.now()),
              style: TextStyle(color: Colors.white.withOpacity(0.6)),
            ),
          ],
        ),
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.indigo,
          child: const Icon(Icons.admin_panel_settings, color: Colors.white),
        ),
      ],
    );
  }

  // Stat cards with gradients
  Widget _buildStatCards(DashboardController controller, bool isMobile) {
    final stats = controller.stats.value;
    if (stats == null) return const SizedBox();

    final cards = [
      _modernStatCard('Școli', stats.totalSchools, Icons.school, [
        Colors.blue,
        Colors.indigo,
      ]),
      _modernStatCard('Clase', stats.totalClasses, Icons.class_, [
        Colors.green,
        Colors.teal,
      ]),
      _modernStatCard('Elevi', stats.totalStudents, Icons.people, [
        Colors.purple,
        Colors.deepPurple,
      ]),
      _modernStatCard('Profesori', stats.totalTeachers, Icons.person, [
        Colors.orange,
        Colors.deepOrange,
      ]),
    ];

    return GridView.count(
      crossAxisCount: isMobile ? 2 : 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cards,
    );
  }

  Widget _modernStatCard(
    String label,
    int count,
    IconData icon,
    List<Color> gradient,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const Spacer(),
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7))),
        ],
      ),
    );
  }

  // Charts Section
  Widget _buildCharts(DashboardController controller, bool isMobile) {
    final stats = controller.stats.value;
    if (stats == null) return const SizedBox();

    return Column(
      children: [
        _barChartSection(stats, isMobile),
        const SizedBox(height: 16),
        _pieChartSection(stats, isMobile),
      ],
    );
  }

  Widget _barChartSection(stats, bool isMobile) {
    final classData = stats.classDistribution.take(5).toList();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribuție Elevi per Clasă',
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: isMobile ? 200 : 250,
            child: classData.isEmpty
                ? const Center(
                    child: Text(
                      'Nu există date',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      maxY:
                          classData
                              .map((e) => e.studentCount)
                              .reduce((a, b) => a > b ? a : b)
                              .toDouble() +
                          5,
                      barGroups: List.generate(
                        classData.length,
                        (i) => BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: classData[i].studentCount.toDouble(),
                              gradient: const LinearGradient(
                                colors: [Colors.purple, Colors.indigo],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              width: isMobile ? 16 : 20,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, meta) {
                              if (v.toInt() < classData.length) {
                                return Text(
                                  classData[v.toInt()].className,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (v, meta) {
                              return Text(
                                v.toInt().toString(),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (v) =>
                            FlLine(color: Colors.white.withOpacity(0.1)),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _pieChartSection(stats, bool isMobile) {
    final total = stats.schoolsStatus.active + stats.schoolsStatus.inactive;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status Școli',
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: isMobile ? 180 : 220,
            child: total == 0
                ? const Center(
                    child: Text(
                      'Nu există date',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: isMobile ? 40 : 50,
                            sections: [
                              PieChartSectionData(
                                value: stats.schoolsStatus.active.toDouble(),
                                color: Colors.green,
                                title:
                                    '${((stats.schoolsStatus.active / total) * 100).toStringAsFixed(0)}%',
                                radius: isMobile ? 40 : 50,
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              PieChartSectionData(
                                value: stats.schoolsStatus.inactive.toDouble(),
                                color: Colors.red,
                                title:
                                    '${((stats.schoolsStatus.inactive / total) * 100).toStringAsFixed(0)}%',
                                radius: isMobile ? 40 : 50,
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _legendItem(
                            'Active',
                            stats.schoolsStatus.active,
                            Colors.green,
                          ),
                          const SizedBox(height: 8),
                          _legendItem(
                            'Inactive',
                            stats.schoolsStatus.inactive,
                            Colors.red,
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: $count',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  // Quick Modules
  Widget _buildQuickModules(bool isMobile) {
    final modules = [
      {'icon': Icons.school, 'title': 'Școli', 'page': SchoolsPage()},
      {'icon': Icons.class_, 'title': 'Clase', 'page': ClassesPage()},
      {'icon': Icons.person, 'title': 'Profesori', 'page': TeachersPage()},
      {'icon': Icons.people, 'title': 'Elevi', 'page': StudentsPage()},
    ];

    return GridView.count(
      crossAxisCount: isMobile ? 2 : 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.3,
      children: modules.map((mod) {
        return GestureDetector(
          onTap: () => Get.to(() => mod['page'] as Widget),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(mod['icon'] as IconData, color: Colors.white, size: 28),
                const SizedBox(height: 8),
                Text(
                  mod['title'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
