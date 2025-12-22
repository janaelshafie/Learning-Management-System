import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_services.dart';

class InstructorRoomScheduleScreen extends StatefulWidget {
  final int userId;
  final bool isEmbedded;

  const InstructorRoomScheduleScreen({
    super.key,
    required this.userId,
    this.isEmbedded = false,
  });

  @override
  State<InstructorRoomScheduleScreen> createState() =>
      _InstructorRoomScheduleScreenState();
}

class _InstructorRoomScheduleScreenState
    extends State<InstructorRoomScheduleScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _assignments = [];
  List<Map<String, dynamic>> _rooms = [];
  bool _isLoading = true;

  // Filters
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  int? _selectedRoomId;
  String _viewMode = 'list'; // 'list' or 'calendar'

  @override
  void initState() {
    super.initState();
    // Default to current week
    final now = DateTime.now();
    _filterStartDate = now.subtract(Duration(days: now.weekday - 1));
    _filterEndDate = _filterStartDate!.add(const Duration(days: 6));
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load rooms for filter dropdown
      final roomsResponse = await _apiService.getRooms();
      if (roomsResponse['status'] == 'success') {
        _rooms = List<Map<String, dynamic>>.from(roomsResponse['rooms'] ?? []);
      }

      // Load room assignments
      await _loadAssignments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadAssignments() async {
    try {
      final formatter = DateFormat('yyyy-MM-dd');
      final response = await _apiService.getRoomAssignments(
        startDate: _filterStartDate != null
            ? formatter.format(_filterStartDate!)
            : null,
        endDate: _filterEndDate != null
            ? formatter.format(_filterEndDate!)
            : null,
        roomId: _selectedRoomId,
      );

      if (response['status'] == 'success') {
        setState(() {
          _assignments = List<Map<String, dynamic>>.from(
            response['assignments'] ?? [],
          );
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Error loading assignments'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _filterStartDate != null && _filterEndDate != null
          ? DateTimeRange(start: _filterStartDate!, end: _filterEndDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _filterStartDate = picked.start;
        _filterEndDate = picked.end;
      });
      _loadAssignments();
    }
  }

  Color _getAssignmentTypeColor(String? type) {
    switch (type) {
      case 'course':
        return Colors.blue;
      case 'instructor':
        return Colors.green;
      case 'department':
        return Colors.orange;
      case 'event':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getAssignmentTypeLabel(String? type) {
    switch (type) {
      case 'course':
        return 'Course';
      case 'instructor':
        return 'Instructor';
      case 'department':
        return 'Department';
      case 'event':
        return 'Event';
      case 'class':
        return 'Class';
      default:
        return type ?? 'Other';
    }
  }

  String _formatDatetime(String? datetime) {
    if (datetime == null) return 'N/A';
    try {
      final dt = DateTime.parse(datetime.replaceAll(' ', 'T'));
      return DateFormat('MMM dd, yyyy HH:mm').format(dt);
    } catch (e) {
      return datetime;
    }
  }

  String _formatTimeOnly(String? datetime) {
    if (datetime == null) return 'N/A';
    try {
      final dt = DateTime.parse(datetime.replaceAll(' ', 'T'));
      return DateFormat('HH:mm').format(dt);
    } catch (e) {
      return datetime;
    }
  }

  String _formatDateOnly(String? datetime) {
    if (datetime == null) return 'N/A';
    try {
      final dt = DateTime.parse(datetime.replaceAll(' ', 'T'));
      return DateFormat('EEE, MMM dd').format(dt);
    } catch (e) {
      return datetime;
    }
  }

  Map<String, List<Map<String, dynamic>>> _groupAssignmentsByDate() {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var assignment in _assignments) {
      final dateKey = _formatDateOnly(assignment['startDatetime']);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(assignment);
    }

    // Sort each group by time
    for (var key in grouped.keys) {
      grouped[key]!.sort((a, b) {
        final timeA = a['startDatetime'] ?? '';
        final timeB = b['startDatetime'] ?? '';
        return timeA.compareTo(timeB);
      });
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    Widget buildContent() {
      return Column(
        children: [
          // Header with actions (only when embedded)
          if (widget.isEmbedded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Room Schedule',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _viewMode == 'list'
                              ? Icons.calendar_view_day
                              : Icons.list,
                        ),
                        tooltip: _viewMode == 'list'
                            ? 'Calendar View'
                            : 'List View',
                        onPressed: () {
                          setState(() {
                            _viewMode = _viewMode == 'list'
                                ? 'calendar'
                                : 'list';
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Refresh',
                        onPressed: () {
                          _loadAssignments();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.date_range),
                        label: Text(
                          _filterStartDate != null && _filterEndDate != null
                              ? '${DateFormat('MMM dd').format(_filterStartDate!)} - ${DateFormat('MMM dd').format(_filterEndDate!)}'
                              : 'Select Date Range',
                        ),
                        onPressed: _selectDateRange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        value: _selectedRoomId,
                        decoration: const InputDecoration(
                          labelText: 'Filter by Room',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        isExpanded: true,
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('All Rooms'),
                          ),
                          ..._rooms.map((room) {
                            return DropdownMenuItem<int?>(
                              value: room['roomId'],
                              child: Text(
                                '${room['building']} - ${room['roomName']}',
                              ),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedRoomId = value;
                          });
                          _loadAssignments();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Quick date filters
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        final now = DateTime.now();
                        setState(() {
                          _filterStartDate = now;
                          _filterEndDate = now;
                        });
                        _loadAssignments();
                      },
                      child: const Text('Today'),
                    ),
                    TextButton(
                      onPressed: () {
                        final now = DateTime.now();
                        setState(() {
                          _filterStartDate = now.subtract(
                            Duration(days: now.weekday - 1),
                          );
                          _filterEndDate = _filterStartDate!.add(
                            const Duration(days: 6),
                          );
                        });
                        _loadAssignments();
                      },
                      child: const Text('This Week'),
                    ),
                    TextButton(
                      onPressed: () {
                        final now = DateTime.now();
                        setState(() {
                          _filterStartDate = DateTime(now.year, now.month, 1);
                          _filterEndDate = DateTime(now.year, now.month + 1, 0);
                        });
                        _loadAssignments();
                      },
                      child: const Text('This Month'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _assignments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No room assignments found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'for the selected date range',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : _viewMode == 'list'
                ? _buildListView()
                : _buildGroupedView(),
          ),
        ],
      );
    }

    // If embedded in parent scaffold, don't wrap in another Scaffold
    if (widget.isEmbedded) {
      return SafeArea(child: buildContent());
    }

    // When navigated to directly, wrap in Scaffold with AppBar
    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Schedule'),
        actions: [
          IconButton(
            icon: Icon(
              _viewMode == 'list' ? Icons.calendar_view_day : Icons.list,
            ),
            tooltip: _viewMode == 'list' ? 'Calendar View' : 'List View',
            onPressed: () {
              setState(() {
                _viewMode = _viewMode == 'list' ? 'calendar' : 'list';
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              _loadAssignments();
            },
          ),
        ],
      ),
      body: buildContent(),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _assignments.length,
      itemBuilder: (context, index) {
        final assignment = _assignments[index];
        return _buildAssignmentCard(assignment);
      },
    );
  }

  Widget _buildGroupedView() {
    final grouped = _groupAssignmentsByDate();
    final sortedKeys = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final dateKey = sortedKeys[index];
        final dayAssignments = grouped[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Text(
                dateKey,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ),
            ...dayAssignments.map(
              (assignment) => _buildAssignmentCard(assignment),
            ),
            const Divider(),
          ],
        );
      },
    );
  }

  Widget _buildAssignmentCard(Map<String, dynamic> assignment) {
    final assignmentType =
        assignment['assignmentType'] ?? assignment['reservationType'];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getAssignmentTypeColor(assignmentType),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getAssignmentTypeLabel(assignmentType),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${assignment['building'] ?? 'N/A'} - ${assignment['roomName'] ?? 'Unknown'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${_formatTimeOnly(assignment['startDatetime'])} - ${_formatTimeOnly(assignment['endDatetime'])}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            if (_viewMode == 'list') ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateOnly(assignment['startDatetime']),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            if (assignment['purpose'] != null &&
                assignment['purpose'].toString().isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.description, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      assignment['purpose'],
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            if (assignment['courseName'] != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.school, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(
                    'Course: ${assignment['courseCode'] ?? ''} ${assignment['courseName']}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],
            if (assignment['instructorName'] != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    'Instructor: ${assignment['instructorName']}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],
            if (assignment['departmentName'] != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.business, size: 16, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    'Department: ${assignment['departmentName']}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],
            if (assignment['reservedByName'] != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Reserved by: ${assignment['reservedByName']}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
            if (assignment['roomType'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    assignment['roomType'] == 'lab'
                        ? Icons.science
                        : Icons.meeting_room,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_getRoomTypeDisplay(assignment['roomType'])} • Capacity: ${assignment['capacity'] ?? 'N/A'}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getRoomTypeDisplay(String type) {
    switch (type) {
      case 'classroom':
        return 'Classroom';
      case 'lab':
        return 'Laboratory';
      case 'office':
        return 'Office';
      case 'auditorium':
        return 'Auditorium';
      default:
        return type;
    }
  }
}
