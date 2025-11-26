import 'package:flutter/material.dart';
import '../../services/api_services.dart';

class CourseOfferingsManagementScreen extends StatefulWidget {
  const CourseOfferingsManagementScreen({super.key});

  @override
  _CourseOfferingsManagementScreenState createState() =>
      _CourseOfferingsManagementScreenState();
}

class _CourseOfferingsManagementScreenState
    extends State<CourseOfferingsManagementScreen> {
  final ApiService _apiService = ApiService();

  List<dynamic> _departments = [];
  List<dynamic> _semesters = [];
  List<dynamic> _courses = [];
  List<dynamic> _instructors = [];
  List<dynamic> _offeredCourses = [];

  int? _selectedDepartmentId;
  int? _selectedSemesterId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load departments
      final deptResponse = await _apiService.getDepartments();
      if (deptResponse['status'] == 'success') {
        _departments = deptResponse['departments'] ?? [];
        if (_departments.isNotEmpty) {
          _selectedDepartmentId = _departments[0]['departmentId'];
        }
      }

      // Load semesters
      final semResponse = await _apiService.getSemesters();
      if (semResponse['status'] == 'success') {
        _semesters = semResponse['semesters'] ?? [];
        if (_semesters.isNotEmpty) {
          _selectedSemesterId = _semesters[0]['semesterId'];
        }
      }

      setState(() {
        _isLoading = false;
      });

      // Load courses and offered courses once we have selections
      if (_selectedDepartmentId != null && _selectedSemesterId != null) {
        _loadCoursesAndOfferings();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
    }
  }

  Future<void> _loadCoursesAndOfferings() async {
    if (_selectedDepartmentId == null || _selectedSemesterId == null) return;

    try {
      // Load courses for department
      final coursesResponse = await _apiService.getCoursesByDepartment(
        _selectedDepartmentId!,
      );
      if (coursesResponse['status'] == 'success') {
        _courses = coursesResponse['courses'] ?? [];
      }

      // Load instructors for department
      final instResponse = await _apiService.getInstructorsByDepartment(
        _selectedDepartmentId!,
      );
      if (instResponse['status'] == 'success') {
        _instructors = instResponse['instructors'] ?? [];
      }

      // Load offered courses for semester and department
      final offResponse = await _apiService.getOfferedCourses(
        _selectedSemesterId!,
        _selectedDepartmentId!,
      );
      if (offResponse['status'] == 'success') {
        _offeredCourses = offResponse['offeredCourses'] ?? [];
      }

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading courses: $e')));
    }
  }

  Future<void> _openCourse(Map<String, dynamic> course) async {
    try {
      final result = await _apiService.createOfferedCourse(
        course['courseId'],
        _selectedSemesterId!,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'])));

      if (result['status'] == 'success') {
        _loadCoursesAndOfferings();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error opening course: $e')));
    }
  }

  Future<void> _assignInstructor(
    int offeredCourseId,
    Map<String, dynamic> instructor,
  ) async {
    try {
      final result = await _apiService.assignInstructor(
        offeredCourseId,
        instructor['instructorId'],
        _selectedDepartmentId!,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'])));

      if (result['status'] == 'success') {
        _loadCoursesAndOfferings();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error assigning instructor: $e')));
    }
  }

  Future<void> _closeCourse(int offeredCourseId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close Course'),
        content: const Text(
          'Are you sure you want to close this course offering?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Close Course',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final result = await _apiService.removeOfferedCourse(offeredCourseId);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'])));

      if (result['status'] == 'success') {
        _loadCoursesAndOfferings();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error closing course: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with filters
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Course Offerings Management',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  // Department Selector
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Department',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: _selectedDepartmentId,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          items: _departments
                              .map(
                                (dept) => DropdownMenuItem<int>(
                                  value: dept['departmentId'],
                                  child: Text(dept['name']),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedDepartmentId = value;
                            });
                            _loadCoursesAndOfferings();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Semester Selector
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Semester',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: _selectedSemesterId,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          items: _semesters
                              .map(
                                (sem) => DropdownMenuItem<int>(
                                  value: sem['semesterId'],
                                  child: Text(sem['name']),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSemesterId = value;
                            });
                            _loadCoursesAndOfferings();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(),
        // Main content
        if (_isLoading)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  // Tab Bar
                  TabBar(
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add),
                            const SizedBox(width: 8),
                            Text('Available Courses (${_courses.length})'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.school),
                            const SizedBox(width: 8),
                            Text('Open Courses (${_offeredCourses.length})'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Tab Content
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Available Courses Tab
                        _buildAvailableCoursesTab(),
                        // Open Courses Tab
                        _buildOpenCoursesTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAvailableCoursesTab() {
    if (_courses.isEmpty) {
      return Center(
        child: Text(
          'No courses available for this department',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _courses.length,
      itemBuilder: (context, index) {
        final course = _courses[index];
        final isAlreadyOffered = _offeredCourses.any(
          (oc) => oc['courseId'] == course['courseId'],
        );

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                            course['courseCode'] ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            course['title'] ?? 'No Title',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Credits: ${course['credits']}, Type: ${course['courseType']}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: isAlreadyOffered
                          ? null
                          : () => _openCourse(course),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAlreadyOffered
                            ? Colors.grey
                            : const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(isAlreadyOffered ? 'Already Open' : 'Open'),
                    ),
                  ],
                ),
                if (course['description'] != null &&
                    course['description'].isNotEmpty)
                  Column(
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        course['description'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOpenCoursesTab() {
    if (_offeredCourses.isEmpty) {
      return Center(
        child: Text(
          'No courses are currently open for this semester',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _offeredCourses.length,
      itemBuilder: (context, index) {
        final course = _offeredCourses[index];
        final instructor = course['instructor'];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                            course['courseCode'] ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            course['title'] ?? 'No Title',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Credits: ${course['credits']}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => _closeCourse(course['offeredCourseId']),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Instructor Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Assigned Instructor',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (instructor != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              instructor['name'] ?? 'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              instructor['email'] ?? 'No email',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Type: ${instructor['instructorType'] ?? 'Unknown'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    '✓ Dept',
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  _showInstructorSelectionDialog(course),
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text('Change Instructor'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'No instructor assigned',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  _showInstructorSelectionDialog(course),
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Assign Instructor'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showInstructorSelectionDialog(
    Map<String, dynamic> course,
  ) async {
    if (_instructors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No instructors available for this department'),
        ),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Instructor'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _instructors.length,
            itemBuilder: (context, index) {
              final instructor = _instructors[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF1E3A8A),
                  child: Text(
                    instructor['name']?.substring(0, 1).toUpperCase() ?? 'I',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(instructor['name']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      instructor['email'],
                      style: const TextStyle(fontSize: 12),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Type: ${instructor['instructorType']}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '✓ Department',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _assignInstructor(course['offeredCourseId'], instructor);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
