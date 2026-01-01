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
import '../admin_user/admin_users_page.dart';
import '../settings/settings_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());

    return MainLayout(
      currentPage: 'dashboard',
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
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
                      Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
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

              return RefreshIndicator(
                onRefresh: () => controller.refresh(),
                color: Colors.indigo,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(_getPadding(context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeSection(context),
                      SizedBox(height: _getSpacing(context)),
                      _buildStatsGrid(context, controller),
                      SizedBox(height: _getSpacing(context)),
                      _buildChartsSection(context, controller),
                      SizedBox(height: _getSpacing(context)),
                      _buildQuickAccessSection(context),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  double _getPadding(BuildContext context) {
    if (MediaQuery.of(context).size.width < 600) return 16;
    if (MediaQuery.of(context).size.width < 1200) return 24;
    return 32;
  }

  double _getSpacing(BuildContext context) {
    if (MediaQuery.of(context).size.width < 600) return 16;
    if (MediaQuery.of(context).size.width < 1200) return 24;
    return 32;
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 2;
    if (width < 1200) return 3;
    return 4;
  }

  Widget _buildHeader(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _getPadding(context),
        vertical: isMobile ? 16 : 24,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E1A),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.white.withOpacity(0.6),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('d MMMM yyyy', 'ro_RO').format(DateTime.now()),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Row(
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Prezentare generală sistem',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.white.withOpacity(0.6),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('d MMMM yyyy', 'ro_RO').format(DateTime.now()),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6366F1),
            Color(0xFF8B5CF6),
            Color(0xFFEC4899),
          ],
        ),
        borderRadius: BorderRadius.circular(isMobile ? 16 : 24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bun venit înapoi!',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Administrator',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Gestionează întregul sistem educațional dintr-un singur loc',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bun venit înapoi!',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Administrator',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Gestionează întregul sistem educațional dintr-un singur loc',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, DashboardController controller) {
    final stats = controller.stats.value;
    if (stats == null) return const SizedBox();

    final crossAxisCount = _getCrossAxisCount(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: isMobile ? 12 : 20,
      mainAxisSpacing: isMobile ? 12 : 20,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: isMobile ? 1.3 : 1.5,
      children: [
        _buildStatCard(
          icon: Icons.school,
          count: stats.totalSchools.toString(),
          label: 'Școli',
          gradient: [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
          isMobile: isMobile,
        ),
        _buildStatCard(
          icon: Icons.class_,
          count: stats.totalClasses.toString(),
          label: 'Clase',
          gradient: [const Color(0xFF10B981), const Color(0xFF059669)],
          isMobile: isMobile,
        ),
        _buildStatCard(
          icon: Icons.people,
          count: stats.totalStudents.toString(),
          label: 'Elevi',
          gradient: [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
          isMobile: isMobile,
        ),
        _buildStatCard(
          icon: Icons.person,
          count: stats.totalTeachers.toString(),
          label: 'Profesori',
          gradient: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
          isMobile: isMobile,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String count,
    required String label,
    required List<Color> gradient,
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 10 : 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradient,
              ),
              borderRadius: BorderRadius.circular(isMobile ? 12 : 14),
              boxShadow: [
                BoxShadow(
                  color: gradient[0].withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: isMobile ? 20 : 24),
          ),
          const Spacer(),
          Text(
            count,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 24 : 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? 2 : 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: isMobile ? 11 : 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection(BuildContext context, DashboardController controller) {
    final stats = controller.stats.value;
    if (stats == null) return const SizedBox();

    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width < 1200;

    if (isMobile) {
      return Column(
        children: [
          _buildClassDistributionChart(stats, isMobile),
          const SizedBox(height: 16),
          _buildSchoolsStatusChart(stats, isMobile),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: isTablet ? 1 : 2,
          child: _buildClassDistributionChart(stats, isMobile),
        ),
        SizedBox(width: isTablet ? 16 : 20),
        Expanded(
          child: _buildSchoolsStatusChart(stats, isMobile),
        ),
      ],
    );
  }

  Widget _buildClassDistributionChart(stats, bool isMobile) {
    final classData = stats.classDistribution.take(5).toList();

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribuție Elevi per Clasă',
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 24),
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
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (classData.map((e) => e.studentCount).reduce((a, b) => a > b ? a : b) + 5).toDouble(),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) => Colors.indigo,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${classData[groupIndex].className}\n${rod.toY.toInt()} elevi',
                              const TextStyle(color: Colors.white, fontSize: 12),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 && value.toInt() < classData.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    classData[value.toInt()].className,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: isMobile ? 10 : 11,
                                    ),
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
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 11,
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
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.white.withOpacity(0.1),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(
                        classData.length,
                        (index) => BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: classData[index].studentCount.toDouble(),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              width: isMobile ? 16 : 20,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchoolsStatusChart(stats, bool isMobile) {
    final total = stats.schoolsStatus.active + stats.schoolsStatus.inactive;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status Școli',
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 24),
          SizedBox(
            height: isMobile ? 200 : 250,
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
                                color: const Color(0xFF10B981),
                                value: stats.schoolsStatus.active.toDouble(),
                                title: '${((stats.schoolsStatus.active / total) * 100).toStringAsFixed(0)}%',
                                radius: isMobile ? 40 : 50,
                                titleStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              PieChartSectionData(
                                color: const Color(0xFFEF4444),
                                value: stats.schoolsStatus.inactive.toDouble(),
                                title: '${((stats.schoolsStatus.inactive / total) * 100).toStringAsFixed(0)}%',
                                radius: isMobile ? 40 : 50,
                                titleStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
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
                          _buildLegendItem('Active', stats.schoolsStatus.active, const Color(0xFF10B981)),
                          const SizedBox(height: 12),
                          _buildLegendItem('Inactive', stats.schoolsStatus.inactive, const Color(0xFFEF4444)),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, int count, Color color) {
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessSection(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final crossAxisCount = isMobile ? 2 : 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acces Rapid',
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: isMobile ? 12 : 20),
        GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: isMobile ? 12 : 20,
          mainAxisSpacing: isMobile ? 12 : 20,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: isMobile ? 1.1 : 1.3,
          children: [
            _buildModuleCard(
              icon: Icons.school_rounded,
              title: 'Școli',
              subtitle: 'Gestionare școli',
              gradient: [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
              onTap: () => Get.off(() => const SchoolsPage()),
              isMobile: isMobile,
            ),
            _buildModuleCard(
              icon: Icons.class_rounded,
              title: 'Clase',
              subtitle: 'Gestionare clase',
              gradient: [const Color(0xFF10B981), const Color(0xFF059669)],
              onTap: () => Get.off(() => const ClassesPage()),
              isMobile: isMobile,
            ),
            _buildModuleCard(
              icon: Icons.person_rounded,
              title: 'Profesori',
              subtitle: 'Gestionare profesori',
              gradient: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
              onTap: () => Get.off(() => const TeachersPage()),
              isMobile: isMobile,
            ),
            _buildModuleCard(
              icon: Icons.people_rounded,
              title: 'Elevi',
              subtitle: 'Gestionare elevi',
              gradient: [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
              onTap: () => Get.off(() => const StudentsPage()),
              isMobile: isMobile,
            ),
            _buildModuleCard(
              icon: Icons.manage_accounts_rounded,
              title: 'Utilizatori',
              subtitle: 'Gestionare utilizatori',
              gradient: [const Color(0xFFEC4899), const Color(0xFFDB2777)],
              onTap: () => Get.off(() => const AdminUsersPage()),
              isMobile: isMobile,
            ),
            _buildModuleCard(
              icon: Icons.settings_rounded,
              title: 'Setări',
              subtitle: 'Configurare sistem',
              gradient: [const Color(0xFF64748B), const Color(0xFF475569)],
              onTap: () => Get.off(() => const SettingsPage()),
              isMobile: isMobile,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModuleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required VoidCallback onTap,
    required bool isMobile,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F3A),
            borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
            border: Border.all(
              color: Colors.white.withOpacity(0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 10 : 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient,
                  ),
                  borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                  boxShadow: [
                    BoxShadow(
                      color: gradient[0].withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: isMobile ? 24 : 28),
              ),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: isMobile ? 2 : 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: isMobile ? 11 : 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}