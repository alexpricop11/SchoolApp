import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/secure_storage_service.dart';
import '../pages/dashboard/dashboard_page.dart';
import '../pages/school/schools_page.dart';
import '../pages/class/classes_page.dart';
import '../pages/teacher/teachers_page.dart';
import '../pages/student/students_page.dart';
import '../pages/admin_user/admin_users_page.dart';
import '../pages/auth/login_page.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final String currentPage;
  final Widget? floatingActionButton;

  const MainLayout({
    super.key,
    required this.child,
    this.currentPage = 'dashboard',
    this.floatingActionButton,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  Future<void> _handleLogout() async {
    await SecureStorageService.deleteToken();
    Get.offAll(() => const LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.05),
                  width: 1,
                ),
              ),
              child: widget.child,
            ),
          ),
        ],
      ),
      floatingActionButton: widget.floatingActionButton,
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1A1F3A),
            const Color(0xFF0A0E1A),
          ],
        ),
      ),
      child: Column(
        children: [
          _buildSidebarHeader(),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildMenuItem(
                  icon: Icons.dashboard_rounded,
                  title: 'Dashboard',
                  gradient: [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
                  isActive: widget.currentPage == 'dashboard',
                  onTap: () => Get.off(() => const DashboardPage()),
                ),
                const SizedBox(height: 8),
                _buildMenuItem(
                  icon: Icons.school_rounded,
                  title: 'Școli',
                  gradient: [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
                  isActive: widget.currentPage == 'schools',
                  onTap: () => Get.off(() => const SchoolsPage()),
                ),
                const SizedBox(height: 8),
                _buildMenuItem(
                  icon: Icons.class_rounded,
                  title: 'Clase',
                  gradient: [const Color(0xFF10B981), const Color(0xFF059669)],
                  isActive: widget.currentPage == 'classes',
                  onTap: () => Get.off(() => const ClassesPage()),
                ),
                const SizedBox(height: 8),
                _buildMenuItem(
                  icon: Icons.person_rounded,
                  title: 'Profesori',
                  gradient: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
                  isActive: widget.currentPage == 'teachers',
                  onTap: () => Get.off(() => const TeachersPage()),
                ),
                const SizedBox(height: 8),
                _buildMenuItem(
                  icon: Icons.people_rounded,
                  title: 'Elevi',
                  gradient: [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
                  isActive: widget.currentPage == 'students',
                  onTap: () => Get.off(() => const StudentsPage()),
                ),
                const SizedBox(height: 8),
                _buildMenuItem(
                  icon: Icons.manage_accounts_rounded,
                  title: 'Utilizatori',
                  gradient: [const Color(0xFFEC4899), const Color(0xFFDB2777)],
                  isActive: widget.currentPage == 'users',
                  onTap: () => Get.off(() => const AdminUsersPage()),
                ),
              ],
            ),
          ),
          const Divider(
            color: Colors.white12,
            height: 32,
            indent: 16,
            endIndent: 16,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildMenuItem(
              icon: Icons.logout_rounded,
              title: 'Deconectare',
              gradient: [const Color(0xFFEF4444), const Color(0xFFDC2626)],
              isActive: false,
              onTap: _handleLogout,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
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
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Admin Panel',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sistem Management',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required List<Color> gradient,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? Colors.white.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: isActive
                ? Border.all(
                    color: gradient[0].withOpacity(0.3),
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: isActive
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: gradient,
                        )
                      : null,
                  color: isActive ? null : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: gradient[0].withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  icon,
                  color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
                    fontSize: 15,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              if (isActive)
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}