import 'package:flutter/material.dart';
import '../../services/api_services.dart';
import 'department_management_screen.dart';
import '../auth/university_login_page.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  List<dynamic> _pendingAccounts = [];
  List<dynamic> _allUsers = [];
  List<dynamic> _pendingProfileChanges = [];
  List<dynamic> _announcements = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load pending accounts
      final pendingResponse = await _apiService.getPendingAccounts();
      if (pendingResponse['status'] == 'success') {
        _pendingAccounts = pendingResponse['pendingAccounts'] ?? [];
      }

      // Load all users
      final usersResponse = await _apiService.getAllUsers();
      if (usersResponse['status'] == 'success') {
        _allUsers = usersResponse['users'] ?? [];
      }

      // Load pending profile changes
      final profileChangesResponse = await _apiService.getPendingProfileChanges();
      if (profileChangesResponse['status'] == 'success') {
        _pendingProfileChanges = profileChangesResponse['pendingChanges'] ?? [];
      }

      // Load announcements
      _announcements = await _apiService.getAllAnnouncements();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  List<dynamic> _filterUsers(List<dynamic> users) {
    if (_searchQuery.isEmpty) return users;
    return users.where((user) {
      final name = user['name']?.toString().toLowerCase() ?? '';
      final email = user['email']?.toString().toLowerCase() ?? '';
      final role = user['role']?.toString().toLowerCase() ?? '';
      final departmentName = user['departmentName']?.toString().toLowerCase() ?? '';
      final instructorType = user['instructorType']?.toString().toLowerCase() ?? '';
      final studentNames = user['studentNames']?.toString().toLowerCase() ?? '';
      return name.contains(_searchQuery) || 
             email.contains(_searchQuery) || 
             role.contains(_searchQuery) ||
             departmentName.contains(_searchQuery) ||
             instructorType.contains(_searchQuery) ||
             studentNames.contains(_searchQuery);
    }).toList();
  }

  List<dynamic> _filterProfileChanges(List<dynamic> changes) {
    if (_searchQuery.isEmpty) return changes;
    return changes.where((change) {
      final userName = change['userName']?.toString().toLowerCase() ?? '';
      final fieldName = change['fieldName']?.toString().toLowerCase() ?? '';
      final oldValue = change['oldValue']?.toString().toLowerCase() ?? '';
      final newValue = change['newValue']?.toString().toLowerCase() ?? '';
      return userName.contains(_searchQuery) || 
             fieldName.contains(_searchQuery) ||
             oldValue.contains(_searchQuery) ||
             newValue.contains(_searchQuery);
    }).toList();
  }

  List<dynamic> _filterAnnouncements(List<dynamic> announcements) {
    if (_searchQuery.isEmpty) return announcements;
    return announcements.where((announcement) {
      final title = announcement['title']?.toString().toLowerCase() ?? '';
      final content = announcement['content']?.toString().toLowerCase() ?? '';
      final type = announcement['announcementType']?.toString().toLowerCase() ?? '';
      return title.contains(_searchQuery) || 
             content.contains(_searchQuery) || 
             type.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            setState(() {
              _selectedTabIndex = -1;
              _searchController.clear();
              _onSearchChanged('');
            });
          },
          child: const Text('Admin Dashboard'),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Tab Cards
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTabCard(
                          'Pending Accounts',
                          Icons.pending_actions,
                          0,
                          _pendingAccounts.length,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTabCard(
                          'Profile Changes',
                          Icons.edit_note,
                          1,
                          _pendingProfileChanges.length,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTabCard(
                          'All Users',
                          Icons.people,
                          2,
                          _allUsers.length,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTabCard(
                          'Announcements',
                          Icons.announcement,
                          3,
                          _announcements.length,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTabCard(
                          'Create User',
                          Icons.person_add,
                          4,
                          -1, // No count for this tab
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTabCard(
                          'Departments',
                          Icons.business,
                          5,
                          -1, // -1 means no count display
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTabCard(
                          'Services',
                          Icons.settings,
                          6,
                          -1, // No count for this tab
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
    );
  }

  Widget _buildTabCard(String title, IconData icon, int index, int count) {
    final isSelected = _selectedTabIndex == index;
    final isServices = index == 6; // Services card
    
    return Card(
      elevation: isSelected ? 8 : 2,
      child: InkWell(
        onTap: isServices ? null : () {
          setState(() {
            _selectedTabIndex = index;
            _searchController.clear();
            _onSearchChanged('');
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 120, // Fixed height for all cards
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isServices 
                ? Colors.grey[200] 
                : (isSelected ? const Color(0xFF1E3A8A) : Colors.white),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
              Icon(
                icon,
                size: 32,
                color: isServices 
                    ? Colors.grey[600] 
                    : (isSelected ? Colors.white : const Color(0xFF1E3A8A)),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isServices 
                        ? Colors.grey[600] 
                        : (isSelected ? Colors.white : const Color(0xFF1E3A8A)),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              if (count >= 0)
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.green,
                  ),
                ),
                            ],
                          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_selectedTabIndex == -1) {
      return _buildDashboardOverview();
    }
    
    switch (_selectedTabIndex) {
      case 0:
        return _buildPendingAccountsTab();
      case 1:
        return _buildProfileChangesTab();
      case 2:
        return _buildAllUsersTab();
      case 3:
        return _buildAnnouncementsTab();
      case 4:
        return _buildCreateUserTab();
      case 5:
        return const DepartmentManagementScreen();
      case 6:
        return _buildServicesTab();
      default:
        return _buildDashboardOverview();
    }
  }

  Widget _buildDashboardOverview() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome to Admin Dashboard',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Manage your Learning Management System efficiently',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildOverviewCard(
                  'Pending Accounts',
                  Icons.pending_actions,
                  _pendingAccounts.length,
                  Colors.orange,
                ),
                _buildOverviewCard(
                  'Profile Changes',
                  Icons.edit_note,
                  _pendingProfileChanges.length,
                  Colors.blue,
                ),
                _buildOverviewCard(
                  'Total Users',
                  Icons.people,
                  _allUsers.length,
                  Colors.green,
                ),
                _buildOverviewCard(
                  'Announcements',
                  Icons.announcement,
                  _announcements.length,
                  Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(String title, IconData icon, int count, Color color) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingAccountsTab() {
    final filteredAccounts = _filterUsers(_pendingAccounts);
    
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search by name, email, or role...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        // Content
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredAccounts.length,
              itemBuilder: (context, index) {
                final account = filteredAccounts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF1E3A8A),
                      child: Text(
                        account['name']?.toString().substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(account['name'] ?? 'Unknown'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(account['email'] ?? 'No email'),
                        Text('Role: ${account['role']?.toString().toUpperCase() ?? 'UNKNOWN'}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => _approveAccount(account['userId']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => _rejectAccount(account['userId']),
                    ),
                  ],
                ),
              ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileChangesTab() {
    final filteredChanges = _filterProfileChanges(_pendingProfileChanges);
    
    return Column(
      children: [
        // Search Bar
            Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search by user name, field, or values...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        // Content
                  Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
                      child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredChanges.length,
                        itemBuilder: (context, index) {
                final change = filteredChanges[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              change['userName'] ?? 'Unknown User',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _formatDate(change['requestedAt']),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Field: ${change['fieldName']?.toString().toUpperCase() ?? 'UNKNOWN'}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Text('From: ${change['oldValue'] ?? 'N/A'}'),
                        Text('To: ${change['newValue'] ?? 'N/A'}'),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                            TextButton(
                              onPressed: () => _rejectProfileChange(change['changeId']),
                              child: const Text('Reject', style: TextStyle(color: Colors.red)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _approveProfileChange(change['changeId']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Approve'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
                                            ),
                                          ),
                                        ),
      ],
    );
  }

  Widget _buildAllUsersTab() {
    final filteredUsers = _filterUsers(_allUsers);
    
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search by name, email, or role...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
        // Content
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => _showUserManagementDialog(user),
                    borderRadius: BorderRadius.circular(8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getRoleColor(user['role']),
                        child: Text(
                          user['name']?.toString().substring(0, 1).toUpperCase() ?? 'U',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(user['name'] ?? 'Unknown'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user['email'] ?? 'No email'),
                          Text('Role: ${user['role']?.toString().toUpperCase() ?? 'UNKNOWN'}'),
                          if (user['role'] == 'instructor' && user['instructorType'] != null)
                            Text(
                              'Type: ${_getInstructorTypeDisplayName(user['instructorType'])}',
                              style: TextStyle(
                                color: _getInstructorTypeColor(user['instructorType']),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          if (user['role'] == 'student' && user['departmentName'] != null)
                            Text(
                              'Department: ${user['departmentName']}',
                              style: TextStyle(
                                color: _getDepartmentColor(user['departmentName']),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          if (user['role'] == 'parent' && user['studentNames'] != null)
                            Text(
                              'Student(s): ${user['studentNames']}',
                              style: const TextStyle(
                                color: Colors.indigo,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                      trailing: Text(
                        user['accountStatus']?.toString().toUpperCase() ?? 'UNKNOWN',
                        style: TextStyle(
                          color: _getStatusColor(user['accountStatus']),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
      ],
    );
  }

  Widget _buildAnnouncementsTab() {
    final filteredAnnouncements = _filterAnnouncements(_announcements);
    
    return Column(
      children: [
        // Header with Create Button
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search announcements...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _showCreateAnnouncementDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Create'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredAnnouncements.length,
              itemBuilder: (context, index) {
                final announcement = filteredAnnouncements[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                announcement['title'] ?? 'No Title',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getPriorityColor(announcement['priority']),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    announcement['priority']?.toString().toUpperCase() ?? 'MEDIUM',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getTypeColor(announcement['announcementType']),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    announcement['announcementType']?.toString().replaceAll('_', ' ').toUpperCase() ?? 'ALL USERS',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          announcement['content'] ?? 'No content',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Created: ${_formatDate(announcement['createdAt'])}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () => _showEditAnnouncementDialog(announcement),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                  onPressed: () => _deleteAnnouncement(announcement['announcementId']),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                          ),
                        ),
                      );
                    },
                ),
              ),
            ),
      ],
    );
  }

  // Helper methods
  Color _getRoleColor(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin': return Colors.red;
      case 'instructor': return Colors.blue;
      case 'student': return Colors.green;
      case 'parent': return Colors.orange;
      default: return Colors.grey;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active': return Colors.green;
      case 'pending': return Colors.orange;
      case 'rejected': return Colors.red;
      default: return Colors.grey;
    }
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'urgent': return Colors.red;
      case 'high': return Colors.orange;
      case 'medium': return Colors.blue;
      case 'low': return Colors.grey;
      default: return Colors.blue;
    }
  }

  Color _getTypeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'all_users': return Colors.purple;
      case 'students_only': return Colors.green;
      case 'instructors_only': return Colors.blue;
      case 'admins_only': return Colors.red;
      default: return Colors.purple;
    }
  }

  Color _getInstructorTypeColor(String? instructorType) {
    if (instructorType == null) return Colors.grey;
    
    switch (instructorType.toLowerCase()) {
      case 'professor':
        return Colors.purple;
      case 'ta':
      case 'teaching_assistant':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getInstructorTypeDisplayName(String? instructorType) {
    if (instructorType == null) return 'Unknown';
    
    switch (instructorType.toLowerCase()) {
      case 'professor':
        return 'Professor';
      case 'ta':
      case 'teaching_assistant':
        return 'Teaching Assistant';
      default:
        return instructorType.toUpperCase();
    }
  }

  Color _getDepartmentColor(String? departmentName) {
    if (departmentName == null) return Colors.grey;
    
    switch (departmentName.toLowerCase()) {
      case 'computer and systems engineering':
        return Colors.blue;
      case 'architecture engineering':
        return Colors.purple;
      case 'mechanical power engineering':
        return Colors.red;
      case 'electronics and communication engineering':
        return Colors.green;
      case 'engineering physics and mathematics':
        return Colors.orange;
      case 'design and production engineering':
        return Colors.teal;
      case 'automotive engineering':
        return Colors.indigo;
      case 'mechatronics engineering':
        return Colors.pink;
      case 'urban design and planning':
        return Colors.brown;
      case 'electrical power and machines engineering':
        return Colors.cyan;
      case 'structural engineering':
        return Colors.deepOrange;
      case 'irrigation and hydraulics engineering':
        return Colors.lightBlue;
      case 'public works engineering':
        return Colors.lightGreen;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(date.toString());
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  // Action methods
  Future<void> _approveAccount(dynamic userId) async {
    final result = await _apiService.approveAccount(userId is String ? int.parse(userId) : userId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'])),
    );
    if (result['status'] == 'success') {
      _loadData();
    }
  }

  Future<void> _rejectAccount(dynamic userId) async {
    final result = await _apiService.rejectAccount(userId is String ? int.parse(userId) : userId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'])),
    );
    if (result['status'] == 'success') {
      _loadData();
    }
  }

  Future<void> _approveProfileChange(int changeId) async {
    final result = await _apiService.approveProfileChange(changeId, 10); // Admin user ID
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'])),
    );
    if (result['status'] == 'success') {
      _loadData();
    }
  }

  Future<void> _rejectProfileChange(int changeId) async {
    final result = await _apiService.rejectProfileChange(changeId, 10); // Admin user ID
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'])),
    );
    if (result['status'] == 'success') {
      _loadData();
    }
  }

  Future<void> _showUserManagementDialog(Map<String, dynamic> user) async {
    final TextEditingController nameController = TextEditingController(text: user['name']?.toString() ?? '');
    final TextEditingController emailController = TextEditingController(text: user['email']?.toString() ?? '');
    final TextEditingController phoneController = TextEditingController(text: user['phone']?.toString() ?? '');
    final TextEditingController locationController = TextEditingController(text: user['location']?.toString() ?? '');
    final TextEditingController passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.7,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Manage User',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // User Info Display
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('User ID: ${user['userId']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('Role: ${user['role']?.toString().toUpperCase() ?? 'UNKNOWN'}'),
                                Text('Status: ${user['accountStatus']?.toString().toUpperCase() ?? 'UNKNOWN'}'),
                                if (user['instructorType'] != null)
                                  Text(
                                    'Type: ${_getInstructorTypeDisplayName(user['instructorType'])}',
                                    style: TextStyle(
                                      color: _getInstructorTypeColor(user['instructorType']),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Editable Fields
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Full Name', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: nameController,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Email', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: emailController,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Phone', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: phoneController,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: locationController,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Password Field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('New Password (optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                hintText: 'Leave empty to keep current password',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Official Mail (Read-only)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Official Mail (Read-only)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            TextField(
                              enabled: false,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                hintText: user['officialMail']?.toString() ?? 'No official mail',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Footer with buttons
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete User'),
                            content: Text('Are you sure you want to delete ${user['name']}? This action cannot be undone.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        
                        if (confirmed == true) {
                          final result = await _apiService.deleteUser(user['userId']);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result['message'])),
                          );
                          if (result['status'] == 'success') {
                            Navigator.of(context).pop();
                            _loadData();
                          }
                        }
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Delete User', style: TextStyle(color: Colors.red)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[50],
                        side: BorderSide(color: Colors.red[300]!),
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () async {
                            final updateData = {
                              'userId': user['userId'],
                              'name': nameController.text.trim(),
                              'email': emailController.text.trim(),
                              'phone': phoneController.text.trim(),
                              'location': locationController.text.trim(),
                              'role': user['role']?.toString() ?? 'student',
                            };

                            if (passwordController.text.trim().isNotEmpty) {
                              updateData['password'] = passwordController.text.trim();
                            }

                            final result = await _apiService.updateUser(updateData);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result['message'])),
                            );

                            if (result['status'] == 'success') {
                              Navigator.of(context).pop();
                              _loadData();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text('Update User', style: TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showCreateAnnouncementDialog() async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController contentController = TextEditingController();
    String selectedType = 'all_users';
    String selectedPriority = 'medium';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.7,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Create Announcement',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Title Field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Title', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: titleController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                hintText: 'Enter announcement title',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Content Field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Content', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: contentController,
                              maxLines: 8,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                hintText: 'Enter announcement content',
                                alignLabelWithHint: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Dropdowns Row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Target Audience', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    value: selectedType,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    ),
                                    items: const [
                                      DropdownMenuItem(value: 'all_users', child: Text('All Users')),
                                      DropdownMenuItem(value: 'students_only', child: Text('Students Only')),
                                      DropdownMenuItem(value: 'instructors_only', child: Text('Instructors Only')),
                                      DropdownMenuItem(value: 'admins_only', child: Text('Admins Only')),
                                    ],
                                    onChanged: (value) {
                                      setDialogState(() {
                                        selectedType = value!;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Priority', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    value: selectedPriority,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    ),
                                    items: const [
                                      DropdownMenuItem(value: 'low', child: Text('Low')),
                                      DropdownMenuItem(value: 'medium', child: Text('Medium')),
                                      DropdownMenuItem(value: 'high', child: Text('High')),
                                      DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                                    ],
                                    onChanged: (value) {
                                      setDialogState(() {
                                        selectedPriority = value!;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Info Box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info, color: Colors.blue),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Announcements will be visible to the selected audience immediately after creation.',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Footer with buttons
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Title is required')),
                          );
                          return;
                        }

                        if (contentController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Content is required')),
                          );
                          return;
                        }

                        final announcementData = {
                          'title': titleController.text.trim(),
                          'content': contentController.text.trim(),
                          'announcementType': selectedType,
                          'priority': selectedPriority,
                          'createdBy': '10', // Admin user ID
                        };

                        final result = await _apiService.createAnnouncement(announcementData);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result['message'])),
                        );

                        if (result['status'] == 'success') {
                          Navigator.of(context).pop();
                          _loadData();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Create Announcement', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showEditAnnouncementDialog(Map<String, dynamic> announcement) async {
    final TextEditingController titleController = TextEditingController(text: announcement['title']?.toString() ?? '');
    final TextEditingController contentController = TextEditingController(text: announcement['content']?.toString() ?? '');
    String selectedType = announcement['announcementType']?.toString() ?? 'all_users';
    String selectedPriority = announcement['priority']?.toString() ?? 'medium';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.7,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Edit Announcement',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Field
                        const Text('Title', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            hintText: 'Enter announcement title',
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Content Field
                        const Text('Content', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: TextField(
                            controller: contentController,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(12),
                              hintText: 'Enter announcement content',
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Target Audience and Priority
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Target Audience', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    value: selectedType,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    ),
                                    items: const [
                                      DropdownMenuItem(value: 'all_users', child: Text('All Users')),
                                      DropdownMenuItem(value: 'students_only', child: Text('Students Only')),
                                      DropdownMenuItem(value: 'instructors_only', child: Text('Instructors Only')),
                                      DropdownMenuItem(value: 'admins_only', child: Text('Admins Only')),
                                    ],
                                    onChanged: (value) {
                                      setDialogState(() {
                                        selectedType = value!;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Priority', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    value: selectedPriority,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    ),
                                    items: const [
                                      DropdownMenuItem(value: 'low', child: Text('Low')),
                                      DropdownMenuItem(value: 'medium', child: Text('Medium')),
                                      DropdownMenuItem(value: 'high', child: Text('High')),
                                      DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                                    ],
                                    onChanged: (value) {
                                      setDialogState(() {
                                        selectedPriority = value!;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Information Box
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info, color: Colors.blue[600], size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Changes will be visible to the selected audience immediately after saving.',
                                  style: TextStyle(color: Colors.blue[800], fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Footer with buttons
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.trim().isEmpty || contentController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill in all fields')),
                          );
                          return;
                        }

                        final updateData = {
                          'announcementId': announcement['announcementId'].toString(),
                          'title': titleController.text.trim(),
                          'content': contentController.text.trim(),
                          'announcementType': selectedType,
                          'priority': selectedPriority,
                        };

                        final result = await _apiService.updateAnnouncement(updateData);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result['message'])),
                        );

                        if (result['status'] == 'success') {
                          Navigator.of(context).pop();
                          _loadData();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Update Announcement', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteAnnouncement(int announcementId) async {
    final result = await _apiService.deleteAnnouncement(announcementId.toString());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'])),
    );
    if (result['status'] == 'success') {
      _loadData();
    }
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const UniversityLoginPage()),
      (route) => false,
    );
  }

  Widget _buildCreateUserTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.person_add, size: 24, color: Color(0xFF1E3A8A)),
              const SizedBox(width: 8),
              const Text(
                'Create New User',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Create User Form Card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'User Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Form Fields
                  _buildCreateUserForm(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateUserForm() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController officialMailController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController nationalIdController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController studentNationalIdController = TextEditingController();
    
    String selectedRole = 'student';
    String selectedInstructorType = 'professor';
    String selectedDepartment = '1'; // Default to first department
    List<Map<String, dynamic>> departments = [];
    
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            // Basic Information Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Full Name *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          hintText: 'Enter full name',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('National ID *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nationalIdController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          hintText: 'Enter national ID',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Email Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Email *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          hintText: 'Enter email address',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Official Mail *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: officialMailController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          hintText: 'Enter official mail',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Contact Information Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Phone', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: phoneController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          hintText: 'Enter phone number',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: locationController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          hintText: 'Enter location',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Role and Password Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Role *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'student', child: Text('Student')),
                          DropdownMenuItem(value: 'instructor', child: Text('Instructor')),
                          DropdownMenuItem(value: 'admin', child: Text('Admin')),
                          DropdownMenuItem(value: 'parent', child: Text('Parent')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedRole = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Password *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          hintText: 'Enter password',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Conditional Fields based on Role
            if (selectedRole == 'instructor') ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Instructor Type *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedInstructorType,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'professor', child: Text('Professor')),
                      DropdownMenuItem(value: 'ta', child: Text('Teaching Assistant')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedInstructorType = value!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
            
            if (selectedRole == 'parent') ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Student National ID *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: studentNationalIdController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      hintText: 'Enter student national ID',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter the national ID of the student you are the parent of',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
            
            if (selectedRole == 'student') ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Department *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  FutureBuilder<Map<String, dynamic>>(
                    future: _apiService.getAllDepartments(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!['status'] == 'success') {
                        departments = List<Map<String, dynamic>>.from(snapshot.data!['departments'] ?? []);
                        return DropdownButtonFormField<String>(
                          value: selectedDepartment,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          items: departments.map((dept) {
                            return DropdownMenuItem(
                              value: dept['departmentId'].toString(),
                              child: Text(dept['name']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedDepartment = value!;
                            });
                          },
                        );
                      } else {
                        return const TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Loading departments...',
                          ),
                          enabled: false,
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
            
            // Create Button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    // Validate required fields
                    if (nameController.text.trim().isEmpty ||
                        emailController.text.trim().isEmpty ||
                        officialMailController.text.trim().isEmpty ||
                        nationalIdController.text.trim().isEmpty ||
                        passwordController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill in all required fields')),
                      );
                      return;
                    }
                    
                    // Additional validation for parents
                    if (selectedRole == 'parent' && studentNationalIdController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Student National ID is required for parent accounts')),
                      );
                      return;
                    }
                    
                    // Prepare user data
                    final userData = {
                      'name': nameController.text.trim(),
                      'email': emailController.text.trim(),
                      'officialMail': officialMailController.text.trim(),
                      'phone': phoneController.text.trim(),
                      'location': locationController.text.trim(),
                      'nationalId': nationalIdController.text.trim(),
                      'password': passwordController.text.trim(),
                      'role': selectedRole,
                    };
                    
                    // Add role-specific data
                    if (selectedRole == 'instructor') {
                      userData['instructorType'] = selectedInstructorType;
                    } else if (selectedRole == 'student') {
                      userData['departmentId'] = selectedDepartment;
                    } else if (selectedRole == 'parent') {
                      userData['studentNationalId'] = studentNationalIdController.text.trim();
                    }
                    
                    try {
                      final result = await _apiService.createUser(userData);
                      
                      if (result['status'] == 'confirmation_required') {
                        // Show confirmation dialog for parent replacement
                        _showParentReplacementDialog(
                          context,
                          result['message'],
                          result['studentId'],
                          result['existingParentId'],
                          result['existingParentName'],
                          userData,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result['message'])),
                        );
                        
                        if (result['status'] == 'success') {
                          // Clear form
                          nameController.clear();
                          emailController.clear();
                          officialMailController.clear();
                          phoneController.clear();
                          locationController.clear();
                          nationalIdController.clear();
                          passwordController.clear();
                          studentNationalIdController.clear();
                          
                          // Refresh user list
                          _loadData();
                        }
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error creating user: $e')),
                      );
                    }
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text('Create User'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showParentReplacementDialog(
    BuildContext context,
    String message,
    int studentId,
    int existingParentId,
    String existingParentName,
    Map<String, dynamic> userData,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Parent Already Exists'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              const SizedBox(height: 16),
              const Text(
                'What would you like to do?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('• Replace existing parent ($existingParentName) with new parent'),
              const SizedBox(height: 4),
              Text('• Keep existing parent and cancel new parent creation'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                // Cancel parent creation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Parent creation cancelled - keeping existing parent')),
                );
              },
              child: const Text('Keep Existing Parent'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                try {
                  // Replace the existing parent
                  final replaceData = {
                    'studentId': studentId,
                    'existingParentId': existingParentId,
                    'newParentId': userData['userId'], // This will be set after user creation
                    'replaceParent': true,
                  };
                  
                  // First create the user, then replace the parent
                  final createResult = await _apiService.createUser(userData);
                  
                  if (createResult['status'] == 'success') {
                    replaceData['newParentId'] = createResult['userId'];
                    
                    final replaceResult = await _apiService.replaceParent(replaceData);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(replaceResult['message'])),
                    );
                    
                    if (replaceResult['status'] == 'success') {
                      // Refresh user list
                      _loadData();
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(createResult['message'])),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error replacing parent: $e')),
                  );
                }
              },
              child: const Text('Replace Parent'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildServicesTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.settings,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Services',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Services functionality coming soon...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}