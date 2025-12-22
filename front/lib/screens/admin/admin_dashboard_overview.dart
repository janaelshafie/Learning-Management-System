import 'package:flutter/material.dart';
import '../../services/api_services.dart';

class AdminDashboardOverview extends StatefulWidget {
  const AdminDashboardOverview({super.key});

  @override
  State<AdminDashboardOverview> createState() => _AdminDashboardOverviewState();
}

class _AdminDashboardOverviewState extends State<AdminDashboardOverview> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  int _totalUsers = 0;
  int _pendingProfileChanges = 0;
  int _activeSemesters = 0;
  int _departments = 0;
  List<dynamic> _pendingAccounts = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load users
      final usersResponse = await _apiService.getAllUsers();
      if (usersResponse['status'] == 'success') {
        _totalUsers = (usersResponse['users'] ?? []).length;
      }

      // Load pending accounts (for reminders)
      final pendingResponse = await _apiService.getPendingAccounts();
      if (pendingResponse['status'] == 'success') {
        _pendingAccounts = pendingResponse['pendingAccounts'] ?? [];
      }

      // Load pending profile changes
      final profileChangesResponse = await _apiService.getPendingProfileChanges();
      if (profileChangesResponse['status'] == 'success') {
        _pendingProfileChanges = (profileChangesResponse['pendingChanges'] ?? []).length;
      }

      // Load semesters
      final semestersResponse = await _apiService.getSemesters();
      if (semestersResponse['status'] == 'success') {
        final semesters = semestersResponse['semesters'] ?? [];
        final now = DateTime.now();
        _activeSemesters = semesters.where((sem) {
          final startDate = DateTime.parse(sem['startDate']);
          final endDate = DateTime.parse(sem['endDate']);
          return now.isAfter(startDate) && now.isBefore(endDate);
        }).length;
      }

      // Load departments
      final deptResponse = await _apiService.getAllDepartments();
      if (deptResponse['status'] == 'success') {
        _departments = (deptResponse['departments'] ?? []).length;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F6FA),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dashboard Overview',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Overview Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildOverviewCard(
                          icon: Icons.people,
                          value: _totalUsers.toString(),
                          label: 'Total Users',
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildOverviewCard(
                          icon: Icons.edit_note,
                          value: _pendingProfileChanges.toString(),
                          label: 'Updating Profile',
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildOverviewCard(
                          icon: Icons.calendar_today,
                          value: _activeSemesters.toString(),
                          label: 'Active Semesters',
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildOverviewCard(
                          icon: Icons.business,
                          value: _departments.toString(),
                          label: 'Departments',
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Pending User Reminders
                  const Text(
                    'Reminders',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPendingUsersReminder(),
                ],
              ),
            ),
    );
  }

  Widget _buildOverviewCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingUsersReminder() {
    if (_pendingAccounts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: const Text(
          'No user pending your acceptance right now.',
          style: TextStyle(color: Colors.blue),
        ),
      );
    }

    // Count users by role
    int studentsCount = 0;
    int parentsCount = 0;
    int instructorsCount = 0;
    int adminsCount = 0;

    for (var account in _pendingAccounts) {
      final role = account['role']?.toString().toLowerCase() ?? '';
      if (role == 'student') {
        studentsCount++;
      } else if (role == 'parent') {
        parentsCount++;
      } else if (role == 'instructor') {
        instructorsCount++;
      } else if (role == 'admin') {
        adminsCount++;
      }
    }

    // Build message
    List<String> parts = [];
    if (studentsCount > 0) {
      parts.add('$studentsCount student${studentsCount > 1 ? 's' : ''}');
    }
    if (parentsCount > 0) {
      parts.add('$parentsCount parent${parentsCount > 1 ? 's' : ''}');
    }
    if (instructorsCount > 0) {
      parts.add('$instructorsCount instructor${instructorsCount > 1 ? 's' : ''}');
    }
    if (adminsCount > 0) {
      parts.add('$adminsCount admin${adminsCount > 1 ? 's' : ''}');
    }

    String message = '';
    if (parts.length == 1) {
      message = '${parts[0]} pending created accounts and waiting for you.';
    } else if (parts.length == 2) {
      message = '${parts[0]} and ${parts[1]} pending created accounts and waiting for you.';
    } else {
      message = '${parts.sublist(0, parts.length - 1).join(', ')}, and ${parts.last} pending created accounts and waiting for you.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.person_add_alt_1, color: Colors.orange[700], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.orange[900],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

