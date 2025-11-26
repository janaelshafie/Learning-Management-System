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
  int _pendingRequests = 0;
  int _activeSemesters = 0;
  int _departments = 0;
  List<dynamic> _announcements = [];

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

      // Load pending accounts
      final pendingResponse = await _apiService.getPendingAccounts();
      if (pendingResponse['status'] == 'success') {
        _pendingRequests = (pendingResponse['pendingAccounts'] ?? []).length;
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

      // Load announcements
      _announcements = await _apiService.getAllAnnouncements();
      _announcements = _announcements.take(3).toList(); // Show only first 3

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
                          icon: Icons.pending_actions,
                          value: _pendingRequests.toString(),
                          label: 'Pending Requests',
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
                  // System Notices
                  const Text(
                    'System Notices',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_announcements.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: const Text(
                        'No system notices at this time.',
                        style: TextStyle(color: Colors.blue),
                      ),
                    )
                  else
                    ..._announcements.map((announcement) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: InkWell(
                          onTap: () {
                            // Could navigate to announcement details
                          },
                          child: Text(
                            announcement['title'] ?? announcement['content'] ?? 'No title',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
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
}

