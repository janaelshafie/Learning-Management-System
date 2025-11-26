import 'package:flutter/material.dart';
import '../../services/api_services.dart';
import '../../common/app_state.dart';

class AdminProfileChanges extends StatefulWidget {
  const AdminProfileChanges({super.key});

  @override
  State<AdminProfileChanges> createState() => _AdminProfileChangesState();
}

class _AdminProfileChangesState extends State<AdminProfileChanges> {
  final ApiService _apiService = ApiService();
  List<dynamic> _pendingChanges = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingChanges();
  }

  Future<void> _loadPendingChanges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.getPendingProfileChanges();
      if (response['status'] == 'success') {
        setState(() {
          _pendingChanges = response['pendingChanges'] ?? [];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile changes: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _approveChange(int changeId) async {
    try {
      final result = await _apiService.approveProfileChange(
        changeId,
        currentUserId,
      );
      if (result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile change approved')),
        );
        _loadPendingChanges();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Error approving change')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _rejectChange(int changeId) async {
    try {
      final result = await _apiService.rejectProfileChange(
        changeId,
        currentUserId,
      );
      if (result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile change dismissed')),
        );
        _loadPendingChanges();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Error dismissing change')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  String _formatTimeAgo(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hr${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} min${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
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
              'Profile Update Requests',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
          ),
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _pendingChanges.isEmpty
                    ? const Center(
                        child: Text(
                          'No pending profile changes',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: _pendingChanges.length,
                        itemBuilder: (context, index) {
                          final change = _pendingChanges[index];
                          final userName = change['userName'] ?? 'Unknown User';
                          final fieldName = change['fieldName'] ?? 'Unknown Field';
                          final oldValue = change['oldValue'] ?? '';
                          final newValue = change['newValue'] ?? '';
                          final requestDate = change['requestDate'] ?? 
                              change['createdAt'] ?? '';
                          final changeId = change['changeId'] ?? change['id'];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // User and timestamp
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        userName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '• ${_formatTimeAgo(requestDate)}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // Change description
                                  Text(
                                    'Requested change for field: $fieldName',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Old and new values
                                  Row(
                                    children: [
                                      // Old value
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.red[50],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Colors.red[200]!,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'OLD VALUE',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red[700],
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                oldValue,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Icon(
                                        Icons.arrow_forward,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 12),
                                      // New value
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.green[50],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Colors.green[200]!,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'NEW VALUE',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green[700],
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                newValue,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // Actions
                                  Row(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () => _approveChange(changeId),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF1E3A8A),
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Approve'),
                                      ),
                                      const SizedBox(width: 12),
                                      TextButton(
                                        onPressed: () => _rejectChange(changeId),
                                        child: const Text('Dismiss'),
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
        ],
      ),
    );
  }
}

