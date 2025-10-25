import 'package:flutter/material.dart';
import '../../services/api_services.dart';

class AdminApprovalScreen extends StatefulWidget {
  const AdminApprovalScreen({super.key});

  @override
  _AdminApprovalScreenState createState() => _AdminApprovalScreenState();
}

class _AdminApprovalScreenState extends State<AdminApprovalScreen> {
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
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to load pending accounts')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _approveAccount(int userId) async {
    try {
      final response = await _apiService.approveAccount(userId);
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account approved successfully')),
        );
        _loadPendingAccounts(); // Refresh the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to approve account')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _rejectAccount(int userId) async {
    try {
      final response = await _apiService.rejectAccount(userId);
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account rejected successfully')),
        );
        _loadPendingAccounts(); // Refresh the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to reject account')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Account Approvals'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingAccounts.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: 64, color: Colors.green),
                      SizedBox(height: 16),
                      Text(
                        'No pending accounts',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('All accounts have been processed'),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPendingAccounts,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _pendingAccounts.length,
                    itemBuilder: (context, index) {
                      final account = _pendingAccounts[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      account['name'] ?? 'Unknown',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      account['role']?.toUpperCase() ?? 'UNKNOWN',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Email: ${account['email'] ?? 'N/A'}'),
                              Text('Official Mail: ${account['officialMail'] ?? 'N/A'}'),
                              Text('National ID: ${account['nationalId'] ?? 'N/A'}'),
                              if (account['phone'] != null && account['phone'].isNotEmpty)
                                Text('Phone: ${account['phone']}'),
                              if (account['location'] != null && account['location'].isNotEmpty)
                                Text('Location: ${account['location']}'),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () => _rejectAccount(account['userId']),
                                    child: const Text(
                                      'Reject',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () => _approveAccount(account['userId']),
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
    );
  }
}
