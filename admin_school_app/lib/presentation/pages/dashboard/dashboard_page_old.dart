import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../widgets/main_layout.dart';
import '../school/schools_page.dart';
import '../class/classes_page.dart';
import '../teacher/teachers_page.dart';
import '../student/students_page.dart';
import '../admin_user/admin_users_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentPage: 'dashboard',
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeSection(),
                  const SizedBox(height: 32),
                  _buildStatsGrid(),
                  const SizedBox(height: 32),
                  _buildQuickAccessSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E1A),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
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

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(32),
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
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Row(
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

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 4,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          icon: Icons.school,
          count: '12',
          label: 'Școli',
          gradient: [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
        ),
        _buildStatCard(
          icon: Icons.class_,
          count: '48',
          label: 'Clase',
          gradient: [const Color(0xFF10B981), const Color(0xFF059669)],
        ),
        _buildStatCard(
          icon: Icons.people,
          count: '847',
          label: 'Elevi',
          gradient: [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
        ),
        _buildStatCard(
          icon: Icons.person,
          count: '64',
          label: 'Profesori',
          gradient: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String count,
    required String label,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(20),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradient,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: gradient[0].withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const Spacer(),
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acces Rapid',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.3,
          children: [
            _buildModuleCard(
              icon: Icons.school_rounded,
              title: 'Școli',
              subtitle: 'Gestionare școli',
              gradient: [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
              onTap: () => Get.off(() => const SchoolsPage()),
            ),
            _buildModuleCard(
              icon: Icons.class_rounded,
              title: 'Clase',
              subtitle: 'Gestionare clase',
              gradient: [const Color(0xFF10B981), const Color(0xFF059669)],
              onTap: () => Get.off(() => const ClassesPage()),
            ),
            _buildModuleCard(
              icon: Icons.person_rounded,
              title: 'Profesori',
              subtitle: 'Gestionare profesori',
              gradient: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
              onTap: () => Get.off(() => const TeachersPage()),
            ),
            _buildModuleCard(
              icon: Icons.people_rounded,
              title: 'Elevi',
              subtitle: 'Gestionare elevi',
              gradient: [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
              onTap: () => Get.off(() => const StudentsPage()),
            ),
            _buildModuleCard(
              icon: Icons.manage_accounts_rounded,
              title: 'Utilizatori',
              subtitle: 'Gestionare utilizatori',
              gradient: [const Color(0xFFEC4899), const Color(0xFFDB2777)],
              onTap: () => Get.off(() => const AdminUsersPage()),
            ),
            _buildModuleCard(
              icon: Icons.settings_rounded,
              title: 'Setări',
              subtitle: 'Configurare sistem',
              gradient: [const Color(0xFF64748B), const Color(0xFF475569)],
              onTap: () {},
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
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F3A),
            borderRadius: BorderRadius.circular(20),
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
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: gradient[0].withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}