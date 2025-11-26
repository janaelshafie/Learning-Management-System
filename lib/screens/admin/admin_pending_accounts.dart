import 'package:flutter/material.dart';
import '../../services/api_services.dart';

class AdminPendingAccounts extends StatefulWidget {
  const AdminPendingAccounts({super.key});

  @override
  State<AdminPendingAccounts> createState() => _AdminPendingAccountsState();
}

class _AdminPendingAccountsState extends State<AdminPendingAccounts> {
  final ApiService _apiService = ApiService();
  List<dynamic> _pendingAccounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingAccounts();
  }

  Future<void> _loadPendingAccounts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.getPendingAccounts();
      if (response['status'] == 'success') {
        setState(() {
          _pendingAccounts = response['pendingAccounts'] ?? [];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading pending accounts: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _approveAccount(int userId) async {
    try {
      final result = await _apiService.approveAccount(userId);
      if (result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account approved successfully')),
        );
        _loadPendingAccounts();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Error approving account')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _rejectAccount(int userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Account'),
        content: const Text('Are you sure you want to reject this account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final result = await _apiService.rejectAccount(userId);
      if (result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account rejected')),
        );
        _loadPendingAccounts();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Error rejecting account')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
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
            child: const Text(
              'Pending Approvals',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
          ),
          // Table
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _pendingAccounts.isEmpty
                    ? const Center(
                        child: Text(
                          'No pending accounts',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Name')),
                            DataColumn(label: Text('Type')),
                            DataColumn(label: Text('Email')),
                            DataColumn(label: Text('Request Date')),
                            DataColumn(label: Text('Action')),
                          ],
                          rows: _pendingAccounts.map((account) {
                            final type = (account['role'] ?? 'Unknown').toString();
                            final requestDate = account['createdAt'] ?? 
                                account['registrationDate'] ?? 
                                '';
                            return DataRow(
                              cells: [
                                DataCell(Text(account['name'] ?? 'Unknown')),
                                DataCell(Text(type)),
                                DataCell(Text(account['email'] ?? '')),
                                DataCell(Text(_formatDate(requestDate))),
                                DataCell(
                                  Row(
                                    children: [
                                      TextButton.icon(
                                        onPressed: () => _approveAccount(
                                          account['userId'],
                                        ),
                                        icon: const Icon(
                                          Icons.check,
                                          size: 18,
                                          color: Colors.green,
                                        ),
                                        label: const Text(
                                          'Approve',
                                          style: TextStyle(color: Colors.green),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      TextButton.icon(
                                        onPressed: () => _rejectAccount(
                                          account['userId'],
                                        ),
                                        icon: const Icon(
                                          Icons.close,
                                          size: 18,
                                          color: Colors.red,
                                        ),
                                        label: const Text(
                                          'Reject',
                                          style: TextStyle(color: Colors.red),
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
        ],
      ),
    );
  }
}

