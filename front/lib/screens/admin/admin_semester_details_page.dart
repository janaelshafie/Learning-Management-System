import 'package:flutter/material.dart';
import '../../services/api_services.dart';

class AdminSemesterDetailsPage extends StatefulWidget {
  final Map<String, dynamic> semester;
  final bool isReadOnly;

  const AdminSemesterDetailsPage({
    super.key,
    required this.semester,
    this.isReadOnly = false,
  });

  @override
  State<AdminSemesterDetailsPage> createState() =>
      _AdminSemesterDetailsPageState();
}

class _AdminSemesterDetailsPageState extends State<AdminSemesterDetailsPage> {
  final ApiService _apiService = ApiService();
  List<dynamic> _allOfferedCourses = [];
  List<dynamic> _departments = [];
  List<dynamic> _allCourses = [];
  bool _isLoading = true;
  bool _registrationOpen = false;

  @override
  void initState() {
    super.initState();
    _registrationOpen = widget.semester['registrationOpen'] ?? false;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load departments
      final deptResponse = await _apiService.getAllDepartments();
      if (deptResponse['status'] == 'success') {
        _departments = deptResponse['departments'] ?? [];
      }

      // Load all courses
      final coursesResponse = await _apiService.getAllCourses();
      if (coursesResponse['status'] == 'success') {
        _allCourses = coursesResponse['courses'] ?? [];
      }

      // Load offered courses for each department
      await _loadOfferedCourses();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadOfferedCourses() async {
    List<dynamic> newOfferedCourses = [];
    for (var dept in _departments) {
      try {
        final offeredResponse = await _apiService.getOfferedCourses(
          widget.semester['semesterId'],
          dept['departmentId'],
        );
        if (offeredResponse['status'] == 'success') {
          final courses = offeredResponse['offeredCourses'] ?? [];
          for (var course in courses) {
            course['departmentName'] = dept['name'];
            course['departmentId'] = dept['departmentId'];
            newOfferedCourses.add(course);
          }
        }
      } catch (e) {
        // Continue with next department
      }
    }
    if (mounted) {
      setState(() {
        _allOfferedCourses = newOfferedCourses;
      });
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

  Future<void> _openNewCourse() async {
    if (widget.isReadOnly) return;

    // Get courses not yet offered in this semester
    final offeredCourseIds = _allOfferedCourses
        .map((oc) => oc['courseId'] as int?)
        .where((id) => id != null)
        .toSet();

    final availableCourses = _allCourses.where((course) {
      return !offeredCourseIds.contains(course['courseId']);
    }).toList();

    if (availableCourses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No available courses to open')),
      );
      return;
    }

    int? selectedCourseId;
    int? selectedDepartmentId;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Open New Course'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int?>(
                  decoration: const InputDecoration(
                    labelText: 'Select Department',
                    border: OutlineInputBorder(),
                  ),
                  items: _departments.map((dept) {
                    return DropdownMenuItem<int?>(
                      value: dept['departmentId'],
                      child: Text(dept['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedDepartmentId = value;
                      selectedCourseId = null; // Reset course selection
                    });
                  },
                ),
                if (selectedDepartmentId != null) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int?>(
                    decoration: const InputDecoration(
                      labelText: 'Select Course',
                      border: OutlineInputBorder(),
                    ),
                    items: availableCourses
                        .where((course) {
                          // Filter courses by department if possible
                          return true; // For now, show all courses
                        })
                        .map((course) {
                      return DropdownMenuItem<int?>(
                        value: course['courseId'],
                        child: Text(
                          '${course['courseCode'] ?? ''} - ${course['title'] ?? 'Unknown'}',
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedCourseId = value;
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: (selectedCourseId == null ||
                      selectedDepartmentId == null)
                  ? null
                  : () async {
                      try {
                        final result = await _apiService.createOfferedCourse(
                          selectedCourseId!,
                          widget.semester['semesterId'],
                        );

                        if (result['status'] == 'success') {
                          Navigator.of(context).pop();
                          // Reload offered courses to show the newly opened course
                          await _loadOfferedCourses();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Course opened successfully'),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                result['message'] ?? 'Error opening course',
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
              child: const Text('Open Course'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleRegistration() async {
    if (widget.isReadOnly) return;

    setState(() {
      _registrationOpen = !_registrationOpen;
    });

    try {
      final result = await _apiService.updateSemester({
        'semesterId': widget.semester['semesterId'].toString(),
        'name': widget.semester['name'],
        'startDate': widget.semester['startDate'],
        'endDate': widget.semester['endDate'],
        'registrationOpen': _registrationOpen,
      });

      if (result['status'] != 'success') {
        setState(() {
          _registrationOpen = !_registrationOpen; // Revert on error
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Error updating registration status',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _registrationOpen
                  ? 'Registration opened'
                  : 'Registration closed',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _registrationOpen = !_registrationOpen; // Revert on error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _assignInstructor(Map<String, dynamic> offeredCourse) async {
    if (widget.isReadOnly) return;

    final departmentId = offeredCourse['departmentId'];
    if (departmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Department information missing')),
      );
      return;
    }

    // Load instructors for the department
    List<dynamic> instructors = [];
    try {
      final instResponse =
          await _apiService.getInstructorsByDepartment(departmentId);
      if (instResponse['status'] == 'success') {
        instructors = instResponse['instructors'] ?? [];
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading instructors: $e')),
      );
      return;
    }

    if (instructors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No instructors available for this department'),
        ),
      );
      return;
    }

    int? selectedInstructorId;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Assign Instructor'),
          content: DropdownButtonFormField<int?>(
            decoration: const InputDecoration(
              labelText: 'Select Instructor',
              border: OutlineInputBorder(),
            ),
            items: instructors.map((instructor) {
              return DropdownMenuItem<int?>(
                value: instructor['instructorId'],
                child: Text(
                  instructor['name'] ?? 'Unknown Instructor',
                ),
              );
            }).toList(),
            onChanged: (value) {
              setDialogState(() {
                selectedInstructorId = value;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedInstructorId == null
                  ? null
                  : () async {
                      try {
                        final result = await _apiService.assignInstructor(
                          offeredCourse['offeredCourseId'],
                          selectedInstructorId!,
                          departmentId,
                        );

                        if (result['status'] == 'success') {
                          Navigator.of(context).pop();
                          _loadOfferedCourses();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Instructor assigned successfully'),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                result['message'] ??
                                    'Error assigning instructor',
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
              child: const Text('Assign'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _closeCourse(Map<String, dynamic> offeredCourse) async {
    if (widget.isReadOnly) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close Course'),
        content: const Text(
          'Are you sure you want to close this course? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Close Course'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final result = await _apiService.removeOfferedCourse(
        offeredCourse['offeredCourseId'],
      );

      if (result['status'] == 'success') {
        _loadOfferedCourses();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course closed successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Error closing course'),
          ),
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
        title: Text(widget.semester['name'] ?? 'Semester Details'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Semester Information Card
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.semester['name'] ?? 'Unknown Semester',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E3A8A),
                                ),
                              ),
                              if (!widget.isReadOnly)
                                Switch(
                                  value: _registrationOpen,
                                  onChanged: (_) => _toggleRegistration(),
                                  activeColor: Colors.green,
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Start Date: ${_formatDate(widget.semester['startDate'])}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'End Date: ${_formatDate(widget.semester['endDate'])}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text(
                                'Registration: ',
                                style: TextStyle(fontSize: 16),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _registrationOpen
                                      ? Colors.green[100]
                                      : Colors.red[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _registrationOpen ? 'Open' : 'Closed',
                                  style: TextStyle(
                                    color: _registrationOpen
                                        ? Colors.green[800]
                                        : Colors.red[800],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Action Button (only for editable)
                  if (!widget.isReadOnly) ...[
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _openNewCourse,
                          icon: const Icon(Icons.add),
                          label: const Text('Open New Course'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                  // Offered Courses Section
                  const Text(
                    'Offered Courses',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_allOfferedCourses.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            'No courses offered in this semester',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    ..._allOfferedCourses.map((course) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${course['courseCode'] ?? ''} - ${course['title'] ?? 'Unknown'}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Department: ${course['departmentName'] ?? 'Unknown'}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Credits: ${course['credits'] ?? 'N/A'}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!widget.isReadOnly)
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'assign') {
                                          _assignInstructor(course);
                                        } else if (value == 'close') {
                                          _closeCourse(course);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'assign',
                                          child: Row(
                                            children: [
                                              Icon(Icons.person_add,
                                                  size: 20),
                                              SizedBox(width: 8),
                                              Text('Assign Instructor'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'close',
                                          child: Row(
                                            children: [
                                              Icon(Icons.close, size: 20),
                                              SizedBox(width: 8),
                                              Text('Close Course'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              if (course['instructor'] != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Instructor: ${course['instructor']['name'] ?? 'Unknown'}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.blue[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ] else if (!widget.isReadOnly) ...[
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: () => _assignInstructor(course),
                                  icon: const Icon(Icons.person_add, size: 16),
                                  label: const Text('Assign Instructor'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.blue,
                                  ),
                                ),
                              ] else ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Instructor: Not Assigned',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
    );
  }
}

