import 'package:flutter/material.dart';
import '../../services/api_services.dart';
import 'admin_user_form_screen.dart';

class AdminUserManagement extends StatefulWidget {
  const AdminUserManagement({super.key});

  @override
  State<AdminUserManagement> createState() => _AdminUserManagementState();
}

class _AdminUserManagementState extends State<AdminUserManagement> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _users = [];
  List<dynamic> _filteredUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.getAllUsers();
      if (response['status'] == 'success') {
        setState(() {
          _users = response['users'] ?? [];
          _filteredUsers = _users;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading users: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _users;
      } else {
        _filteredUsers = _users.where((user) {
          final name = (user['name'] ?? '').toString().toLowerCase();
          final email = (user['email'] ?? '').toString().toLowerCase();
          final role = (user['role'] ?? '').toString().toLowerCase();
          return name.contains(query) ||
              email.contains(query) ||
              role.contains(query);
        }).toList();
      }
    });
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'student':
        return Colors.green;
      case 'professor':
      case 'instructor':
        return Colors.purple;
      case 'admin':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Future<void> _deleteUser(int userId, String userName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete $userName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final result = await _apiService.deleteUser(userId);
      if (result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User deleted successfully')),
        );
        _loadUsers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Error deleting user')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showAddUserDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminUserFormScreen(),
      ),
    ).then((success) {
      if (success == true) {
        _loadUsers();
      }
    });
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminUserFormScreen(user: user),
      ),
    ).then((success) {
      if (success == true) {
        _loadUsers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'User Management',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showAddUserDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add User'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          // Users Table
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? const Center(
                        child: Text(
                          'No users found',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: constraints.maxWidth,
                                ),
                                child: DataTable(
                                  columns: const [
                                    DataColumn(label: Text('Name')),
                                    DataColumn(label: Text('Role')),
                                    DataColumn(label: Text('Email')),
                                    DataColumn(label: Text('Status')),
                                    DataColumn(label: Text('Actions')),
                                  ],
                                  rows: _filteredUsers.map((user) {
                            final role = (user['role'] ?? 'Unknown').toString();
                            final status = (user['accountStatus'] ?? 'active')
                                .toString()
                                .toLowerCase();
                            return DataRow(
                              cells: [
                                DataCell(Text(user['name'] ?? 'Unknown')),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getRoleColor(role)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      role,
                                      style: TextStyle(
                                        color: _getRoleColor(role),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(Text(user['email'] ?? '')),
                                DataCell(
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: status == 'active'
                                              ? Colors.green
                                              : Colors.grey,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        status == 'active'
                                            ? 'Active'
                                            : status[0].toUpperCase() +
                                                status.substring(1),
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 20),
                                        color: Colors.blue,
                                        onPressed: () => _showEditUserDialog(user),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, size: 20),
                                        color: Colors.red,
                                        onPressed: () => _deleteUser(
                                          user['userId'],
                                          user['name'] ?? 'User',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

