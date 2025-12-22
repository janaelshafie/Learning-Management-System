import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_services.dart';

class AdminRoomReservationsApprovalScreen extends StatefulWidget {
  final int userId;

  const AdminRoomReservationsApprovalScreen({super.key, required this.userId});

  @override
  State<AdminRoomReservationsApprovalScreen> createState() => _AdminRoomReservationsApprovalScreenState();
}

class _AdminRoomReservationsApprovalScreenState extends State<AdminRoomReservationsApprovalScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _pendingReservations = [];
  bool _isLoading = true;
  Map<String, List<Map<String, dynamic>>> _conflicts = {};

  @override
  void initState() {
    super.initState();
    _loadPendingReservations();
  }

  Future<void> _loadPendingReservations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.getPendingReservations();

      if (response['status'] == 'success') {
        final reservations = List<Map<String, dynamic>>.from(response['reservations'] ?? []);
        
        // Group conflicts
        Map<String, List<Map<String, dynamic>>> conflictsMap = {};
        for (var reservation in reservations) {
          if (reservation['hasConflict'] == true) {
            final conflictKey = '${reservation['roomId']}_${reservation['startDatetime']}_${reservation['endDatetime']}';
            if (!conflictsMap.containsKey(conflictKey)) {
              conflictsMap[conflictKey] = [];
            }
            conflictsMap[conflictKey]!.add(reservation);
          }
        }

        setState(() {
          _pendingReservations = reservations;
          _conflicts = conflictsMap;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Error loading reservations')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _approveReservation(int reservationId) async {
    try {
      final response = await _apiService.updateReservationStatus(
        reservationId,
        'approved',
        approvedByUserId: widget.userId,
      );

      if (response['status'] == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reservation approved')),
          );
        }
        _loadPendingReservations();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Error approving reservation')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _rejectReservation(int reservationId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Reservation'),
        content: const Text('Are you sure you want to reject this reservation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await _apiService.updateReservationStatus(
          reservationId,
          'rejected',
          approvedByUserId: widget.userId,
        );

        if (response['status'] == 'success') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reservation rejected')),
            );
          }
          _loadPendingReservations();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response['message'] ?? 'Error rejecting reservation')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _handleConflict(List<Map<String, dynamic>> conflictingReservations) async {
    if (conflictingReservations.length < 2) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolve Conflict'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Multiple instructors requested the same room at the same time. Please select which reservation to approve:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...conflictingReservations.asMap().entries.map((entry) {
                final index = entry.key;
                final reservation = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text('Request ${index + 1}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Instructor: ${reservation['reservedByName'] ?? 'Unknown'}'),
                        Text('Room: ${reservation['roomName'] ?? 'Unknown'}'),
                        Text('Purpose: ${reservation['purpose'] ?? 'N/A'}'),
                        if (reservation['courseName'] != null)
                          Text('Course: ${reservation['courseName']}'),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Approve selected, reject others
                        _resolveConflict(reservation, conflictingReservations);
                      },
                      child: const Text('Approve'),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _resolveConflict(
    Map<String, dynamic> approvedReservation,
    List<Map<String, dynamic>> allConflictingReservations,
  ) async {
    // Approve the selected one
    await _approveReservation(approvedReservation['reservationId']);

    // Reject all others
    for (var reservation in allConflictingReservations) {
      if (reservation['reservationId'] != approvedReservation['reservationId']) {
        await _rejectReservation(reservation['reservationId']);
      }
    }
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Reservation Approvals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingReservations,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingReservations.isEmpty
              ? const Center(
                  child: Text('No pending reservations'),
                )
              : Column(
                  children: [
                    // Conflicts Banner
                    if (_conflicts.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        color: Colors.red[50],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.warning, color: Colors.red[700]),
                                const SizedBox(width: 8),
                                Text(
                                  '${_conflicts.length} Conflict(s) Detected',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[700],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Multiple instructors requested the same room at the same time. Please resolve conflicts below.',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    // Reservations List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _pendingReservations.length,
                        itemBuilder: (context, index) {
                          final reservation = _pendingReservations[index];
                          final hasConflict = reservation['hasConflict'] == true;
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: hasConflict ? Colors.red[50] : null,
                            child: ExpansionTile(
                              leading: Icon(
                                hasConflict ? Icons.warning : Icons.event,
                                color: hasConflict ? Colors.red : Colors.blue,
                              ),
                              title: Text(
                                '${reservation['roomName'] ?? 'Unknown Room'} - ${reservation['building'] ?? 'N/A'}',
                                style: TextStyle(
                                  fontWeight: hasConflict ? FontWeight.bold : FontWeight.normal,
                                  color: hasConflict ? Colors.red[700] : null,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Instructor: ${reservation['reservedByName'] ?? 'Unknown'}'),
                                  Text('Time: ${_formatDateTime(reservation['startDatetime'])} - ${_formatDateTime(reservation['endDatetime'])}'),
                                  if (hasConflict)
                                    Text(
                                      '⚠️ CONFLICT: ${reservation['conflictCount']} other request(s)',
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildDetailRow('Room Type', reservation['roomType'] ?? 'N/A'),
                                      _buildDetailRow('Purpose', reservation['purpose'] ?? 'N/A'),
                                      if (reservation['notes'] != null)
                                        _buildDetailRow('Notes', reservation['notes']),
                                      if (reservation['courseName'] != null)
                                        _buildDetailRow('Course', reservation['courseName']),
                                      _buildDetailRow('Requested At', _formatDateTime(reservation['requestedAt'])),
                                      const SizedBox(height: 16),
                                      if (hasConflict)
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            icon: const Icon(Icons.warning),
                                            label: const Text('Resolve Conflict'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                            ),
                                            onPressed: () {
                                              // Find all conflicting reservations
                                              final conflictKey = '${reservation['roomId']}_${reservation['startDatetime']}_${reservation['endDatetime']}';
                                              final conflicts = _conflicts[conflictKey] ?? [];
                                              _handleConflict(conflicts);
                                            },
                                          ),
                                        )
                                      else
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                icon: const Icon(Icons.check),
                                                label: const Text('Approve'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  foregroundColor: Colors.white,
                                                ),
                                                onPressed: () => _approveReservation(reservation['reservationId']),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                icon: const Icon(Icons.close),
                                                label: const Text('Reject'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  foregroundColor: Colors.white,
                                                ),
                                                onPressed: () => _rejectReservation(reservation['reservationId']),
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
