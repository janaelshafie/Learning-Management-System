import 'package:flutter/material.dart';
import '../../services/api_services.dart';
import '../../common/app_state.dart';
import '../auth/university_login_page.dart';
import 'admin_dashboard_overview.dart';
import 'admin_user_management.dart';
import 'admin_pending_accounts.dart';
import 'admin_profile_changes.dart';
import 'admin_department_management.dart';
import 'admin_semester_management.dart';
import 'admin_announcements.dart';
import 'admin_room_management.dart';
import 'admin_room_reservations_approval.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  final ApiService _apiService = ApiService();
  int _selectedIndex = 0;
  String _adminName = 'Admin User';

  @override
  void initState() {
    super.initState();
    _loadAdminInfo();
  }

  Future<void> _loadAdminInfo() async {
    try {
      final userResponse = await _apiService.getAllUsers();
      if (userResponse['status'] == 'success') {
        final users = userResponse['users'] ?? [];
        final adminUser = users.firstWhere(
          (user) => user['userId'] == currentUserId,
          orElse: () => null,
        );
        if (adminUser != null) {
          setState(() {
            _adminName = adminUser['name'] ?? 'Admin User';
          });
        }
      }
    } catch (e) {
      // Ignore error, use default name
    }
  }

  Widget _getPage() {
    switch (_selectedIndex) {
      case 0:
        return const AdminDashboardOverview();
      case 1:
        return const AdminUserManagement();
      case 2:
        return const AdminPendingAccounts();
      case 3:
        return const AdminProfileChanges();
      case 4:
        return const AdminDepartmentManagement();
      case 5:
        return const AdminSemesterManagement();
      case 6:
        return const AdminAnnouncements();
      case 7:
        return AdminRoomManagementScreen(userId: currentUserId);
      case 8:
        return AdminRoomReservationsApprovalScreen(userId: currentUserId);
      default:
        return const AdminDashboardOverview();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: const Color(0xFF1E3A8A),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'LMS Admin',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'University Portal',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white24),
                // Navigation Menu
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _buildNavItem(
                        icon: Icons.dashboard,
                        title: 'Dashboard',
                        index: 0,
                      ),
                      _buildNavItem(
                        icon: Icons.people,
                        title: 'User Management',
                        index: 1,
                      ),
                      _buildNavItem(
                        icon: Icons.access_time,
                        title: 'Pending Accounts',
                        index: 2,
                      ),
                      _buildNavItem(
                        icon: Icons.description,
                        title: 'Profile Changes',
                        index: 3,
                      ),
                      _buildNavItem(
                        icon: Icons.business,
                        title: 'Departments',
                        index: 4,
                      ),
                      _buildNavItem(
                        icon: Icons.calendar_today,
                        title: 'Semesters',
                        index: 5,
                      ),
                      _buildNavItem(
                        icon: Icons.announcement,
                        title: 'Announcements',
                        index: 6,
                      ),
                      _buildNavItem(
                        icon: Icons.meeting_room,
                        title: 'Room Management',
                        index: 7,
                      ),
                      _buildNavItem(
                        icon: Icons.event_available,
                        title: 'Room Reservations',
                        index: 8,
                      ),
                    ],
                  ),
                ),
                // User Profile Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.2)),
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        child: Text(
                          _adminName.isNotEmpty
                              ? _adminName[0].toUpperCase()
                              : 'A',
                          style: const TextStyle(
                            color: Color(0xFF1E3A8A),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _adminName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const UniversityLoginPage(),
                              ),
                              (route) => false,
                            );
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: _getPage(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF1E3A8A) : Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFF1E3A8A) : Colors.white,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

