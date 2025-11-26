import 'package:flutter/material.dart';
import '../../services/api_services.dart';

class AdminSemesterDetailsPage extends StatefulWidget {
  final Map<String, dynamic> semester;
  final bool isReadOnly;

  const AdminSemesterDetailsPage({
    super.key,
    required this.semester,
    required this.isReadOnly,
  });

  @override
  State<AdminSemesterDetailsPage> createState() =>
      _AdminSemesterDetailsPageState();
}

class _AdminSemesterDetailsPageState extends State<AdminSemesterDetailsPage> {
  final ApiService _apiService = ApiService();
  List<dynamic> _allDepartments = [];
  List<dynamic> _allCourses = [];
  List<dynamic> _allInstructors = [];
  List<dynamic> _offeredCourses = [];
  bool _isLoading = true;
  int? _selectedDepartmentId;
  int? _selectedCourseId;
  int? _selectedInstructorId;

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
      // Load departments
      final deptResponse = await _apiService.getAllDepartments();
      if (deptResponse['status'] == 'success') {
        _allDepartments = deptResponse['departments'] ?? [];
      }

      // Load all courses
      final coursesResponse = await _apiService.getAllCourses();
      if (coursesResponse['status'] == 'success') {
        _allCourses = coursesResponse['courses'] ?? [];
      }

      // Load instructors
      final instResponse = await _apiService.getAllInstructors();
      if (instResponse['status'] == 'success') {
        _allInstructors = instResponse['instructors'] ?? [];
      }

      // Load offered courses for all departments
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
    _offeredCourses = [];
    for (var dept in _allDepartments) {
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
            _offeredCourses.add(course);
          }
        }
      } catch (e) {
        // Continue with next department
      }
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
    if (_selectedDepartmentId == null || _selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select department and course')),
      );
      return;
    }

    try {
      final result = await _apiService.createOfferedCourse(
        _selectedCourseId!,
        widget.semester['semesterId'],
      );

      if (result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course opened successfully')),
        );
        _selectedDepartmentId = null;
        _selectedCourseId = null;
        await _loadOfferedCourses();
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Error opening course'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _assignInstructor(int offeredCourseId, int departmentId) async {
    if (_selectedInstructorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an instructor')),
      );
      return;
    }

    try {
      final result = await _apiService.assignInstructor(
        offeredCourseId,
        _selectedInstructorId!,
        departmentId,
      );

      if (result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Instructor assigned successfully')),
        );
        _selectedInstructorId = null;
        await _loadOfferedCourses();
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Error assigning instructor'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _toggleRegistration() async {
    try {
      final result = await _apiService.updateSemester({
        'semesterId': widget.semester['semesterId'].toString(),
        'name': widget.semester['name'],
        'startDate': widget.semester['startDate'],
        'endDate': widget.semester['endDate'],
        'registrationOpen': !(widget.semester['registrationOpen'] ?? false),
      });

      if (result['status'] == 'success') {
        widget.semester['registrationOpen'] =
            !(widget.semester['registrationOpen'] ?? false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.semester['registrationOpen']
                  ? 'Registration opened'
                  : 'Registration closed',
            ),
          ),
        );
        setState(() {});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _closeCourse(int offeredCourseId) async {
    try {
      final result = await _apiService.removeOfferedCourse(offeredCourseId);
      if (result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course closed successfully')),
        );
        await _loadOfferedCourses();
        setState(() {});
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

  void _showAssignInstructorDialog(Map<String, dynamic> course) {
    _selectedInstructorId = null;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Assign Instructor to ${course['courseCode'] ?? ''}'),
          content: SizedBox(
            width: double.maxFinite,
            child: DropdownButtonFormField<int>(
              value: _selectedInstructorId,
              decoration: const InputDecoration(
                labelText: 'Select Instructor',
                border: OutlineInputBorder(),
              ),
              items: _allInstructors.map((instructor) {
                return DropdownMenuItem<int>(
                  value: instructor['userId'],
                  child: Text(instructor['name'] ?? 'Unknown'),
                );
              }).toList(),
              onChanged: (value) {
                setDialogState(() {
                  _selectedInstructorId = value;
                });
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _selectedInstructorId == null
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      _assignInstructor(
                        course['offeredCourseId'],
                        course['departmentId'],
                      );
                    },
              child: const Text('Assign'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
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
                  // Semester Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.semester['name'] ?? 'Unknown',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E3A8A),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Start Date: ${_formatDate(widget.semester['startDate'])}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'End Date: ${_formatDate(widget.semester['endDate'])}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!widget.isReadOnly) ...[
                                ElevatedButton.icon(
                                  onPressed: _toggleRegistration,
                                  icon: Icon(
                                    widget.semester['registrationOpen'] == true
                                        ? Icons.lock
                                        : Icons.lock_open,
                                  ),
                                  label: Text(
                                    widget.semester['registrationOpen'] == true
                                        ? 'Close Registration'
                                        : 'Open Registration',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        widget.semester['registrationOpen'] == true
                                            ? Colors.orange
                                            : Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: (widget.semester['registrationOpen'] == true
                                      ? Colors.green
                                      : Colors.red)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Registration: ${widget.semester['registrationOpen'] == true ? 'Open' : 'Closed'}',
                              style: TextStyle(
                                color: widget.semester['registrationOpen'] == true
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Open New Course Section (only for current/upcoming)
                  if (!widget.isReadOnly) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Open New Course',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<int>(
                              value: _selectedDepartmentId,
                              decoration: const InputDecoration(
                                labelText: 'Select Department',
                                border: OutlineInputBorder(),
                              ),
                              items: _allDepartments.map((dept) {
                                return DropdownMenuItem<int>(
                                  value: dept['departmentId'],
                                  child: Text(dept['name'] ?? 'Unknown'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedDepartmentId = value;
                                  _selectedCourseId = null;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<int>(
                              value: _selectedCourseId,
                              decoration: const InputDecoration(
                                labelText: 'Select Course',
                                border: OutlineInputBorder(),
                              ),
                              items: _allCourses
                                  .where((course) {
                                    // Filter courses by selected department if needed
                                    return true;
                                  })
                                  .map((course) {
                                    return DropdownMenuItem<int>(
                                      value: course['courseId'],
                                      child: Text(
                                          '${course['courseCode'] ?? ''} - ${course['title'] ?? 'Unknown'}'),
                                    );
                                  }).toList(),
                              onChanged: _selectedDepartmentId == null
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _selectedCourseId = value;
                                      });
                                    },
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _openNewCourse,
                              icon: const Icon(Icons.add),
                              label: const Text('Open Course'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E3A8A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                  const SizedBox(height: 16),
                  if (_offeredCourses.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            'No courses offered in this semester',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ),
                    )
                  else
                    ..._offeredCourses.map((course) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${course['courseCode'] ?? ''} - ${course['title'] ?? 'Unknown'}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
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
                                  if (!widget.isReadOnly) ...[
                                    Row(
                                      children: [
                                        if (course['instructor'] == null)
                                          ElevatedButton.icon(
                                            onPressed: () =>
                                                _showAssignInstructorDialog(
                                                    course),
                                            icon: const Icon(Icons.person_add),
                                            label: const Text('Assign'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue,
                                              foregroundColor: Colors.white,
                                            ),
                                          )
                                        else
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.person,
                                                  size: 16,
                                                  color: Colors.green,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  course['instructor']['name'] ??
                                                      'Unknown',
                                                  style: const TextStyle(
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.red,
                                          ),
                                          onPressed: () => _closeCourse(
                                              course['offeredCourseId']),
                                          tooltip: 'Close Course',
                                        ),
                                      ],
                                    ),
                                  ] else ...[
                                    if (course['instructor'] != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.person,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              course['instructor']['name'] ??
                                                  'Unknown',
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    else
                                      Text(
                                        'No Instructor Assigned',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                  ],
                                ],
                              ),
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

