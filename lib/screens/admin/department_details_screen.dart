import 'package:flutter/material.dart';
import '../../services/api_services.dart';
import 'course_details_screen.dart';

class DepartmentDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> department;

  const DepartmentDetailsScreen({super.key, required this.department});

  @override
  State<DepartmentDetailsScreen> createState() => _DepartmentDetailsScreenState();
}

class _DepartmentDetailsScreenState extends State<DepartmentDetailsScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _allCourses = [];
  List<dynamic> _instructors = [];
  List<dynamic> _filteredCourses = [];
  String _selectedFilter = 'all'; // 'all', 'core', 'elective'
  bool _isLoading = true;

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
      final coursesResult = await _apiService.getAllCourses();
      final instructorsResult = await _apiService.getAllInstructors();

      if (coursesResult['status'] == 'success') {
        _allCourses = coursesResult['courses'] ?? [];
      }

      if (instructorsResult['status'] == 'success') {
        _instructors = instructorsResult['instructors'] ?? [];
      }

      _filterCourses();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Get department from course code (for matching)
  String _getDepartmentFromCourseCode(String courseCode) {
    if (courseCode.startsWith('CSE')) {
      return 'Computer and Systems Engineering';
    } else if (courseCode.startsWith('ECE')) {
      return 'Electronics and Communication Engineering';
    } else if (courseCode.startsWith('EPM')) {
      return 'Electrical Power and Machines Engineering';
    } else if (courseCode.startsWith('CES')) {
      return 'Structural Engineering';
    } else if (courseCode.startsWith('CEI')) {
      return 'Irrigation and Hydraulics Engineering';
    } else if (courseCode.startsWith('CEP')) {
      return 'Public Works Engineering';
    } else if (courseCode.startsWith('PHM')) {
      return 'Engineering Physics and Mathematics';
    } else if (courseCode.startsWith('MDP')) {
      return 'Design and Production Engineering';
    } else if (courseCode.startsWith('MEP')) {
      return 'Mechanical Power Engineering';
    } else if (courseCode.startsWith('MEA')) {
      return 'Automotive Engineering';
    } else if (courseCode.startsWith('MCT')) {
      return 'Mechatronics Engineering';
    } else if (courseCode.startsWith('ARC')) {
      return 'Architecture Engineering';
    } else if (courseCode.startsWith('UPL')) {
      return 'Urban Design and Planning';
    } else if (courseCode.startsWith('ASU')) {
      return 'University Requirements';
    } else if (courseCode.startsWith('ENG')) {
      return 'Faculty Requirements';
    } else {
      return 'General';
    }
  }

  void _filterCourses() {
    final departmentName = widget.department['name'];

    // Filter courses that belong to this department based on course code prefix
    List<dynamic> departmentCourses = _allCourses.where((course) {
      final courseCode = course['courseCode'] ?? '';
      final courseDepartment = _getDepartmentFromCourseCode(courseCode);
      return courseDepartment == departmentName;
    }).toList();

    // Apply additional filter based on selected filter type
    if (_selectedFilter == 'core') {
      _filteredCourses = departmentCourses.where((course) {
        return course['courseType'] == 'core';
      }).toList();
    } else if (_selectedFilter == 'elective') {
      _filteredCourses = departmentCourses.where((course) {
        return course['courseType'] == 'elective';
      }).toList();
    } else {
      // 'all' - show all courses for this department (including those with no type)
      _filteredCourses = departmentCourses;
    }
  }

  Color _getDepartmentColor(String department) {
    switch (department) {
      case 'Computer and Systems Engineering':
        return Colors.blue;
      case 'Electronics and Communication Engineering':
        return Colors.indigo;
      case 'Electrical Power and Machines Engineering':
        return Colors.orange;
      case 'Structural Engineering':
        return Colors.brown;
      case 'Irrigation and Hydraulics Engineering':
        return Colors.teal;
      case 'Public Works Engineering':
        return Colors.grey;
      case 'Engineering Physics and Mathematics':
        return Colors.purple;
      case 'Design and Production Engineering':
        return Colors.pink;
      case 'Mechanical Power Engineering':
        return Colors.red;
      case 'Automotive Engineering':
        return Colors.deepOrange;
      case 'Mechatronics Engineering':
        return Colors.cyan;
      case 'Architecture Engineering':
        return Colors.amber;
      case 'Urban Design and Planning':
        return Colors.lime;
      case 'University Requirements':
        return Colors.green;
      case 'Faculty Requirements':
        return Colors.lightGreen;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final departmentName = widget.department['name'];
    final departmentColor = _getDepartmentColor(departmentName);
    final unitHead = _instructors.firstWhere(
      (instructor) => instructor['userId'] == widget.department['unitHeadId'],
      orElse: () => null,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(departmentName),
        backgroundColor: departmentColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadData();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Department Info Card
                Card(
                  margin: const EdgeInsets.all(16),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: departmentColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.business, color: departmentColor, size: 32),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    departmentName,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'ID: ${widget.department['departmentId']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.person, color: Colors.grey[600], size: 20),
                            const SizedBox(width: 8),
                            Text(
                              unitHead != null
                                  ? 'Unit Head: ${unitHead['name']}'
                                  : 'No Unit Head Assigned',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Filter Buttons
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.grey[50],
                  child: Row(
                    children: [
                      Expanded(
                        child: FilterChip(
                          label: const Text('All Courses'),
                          selected: _selectedFilter == 'all',
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedFilter = 'all';
                              });
                              _filterCourses();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilterChip(
                          label: const Text('Core Courses'),
                          selected: _selectedFilter == 'core',
                          selectedColor: Colors.green[100],
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedFilter = 'core';
                              });
                              _filterCourses();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilterChip(
                          label: const Text('Elective Courses'),
                          selected: _selectedFilter == 'elective',
                          selectedColor: Colors.orange[100],
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedFilter = 'elective';
                              });
                              _filterCourses();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Courses List
                Expanded(
                  child: _filteredCourses.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.book_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _selectedFilter == 'all'
                                    ? 'No courses found for this department'
                                    : 'No $_selectedFilter courses for this department',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Courses are automatically assigned based on course code',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredCourses.length,
                            itemBuilder: (context, index) {
                              final course = _filteredCourses[index];
                              final courseType = course['courseType'];
                              final isCore = courseType == 'core';

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CourseDetailsScreen(course: course),
                                      ),
                                    );
                                    _loadData(); // Reload in case course was edited
                                  },
                                  child: ListTile(
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: courseType == null
                                            ? Colors.grey[100]
                                            : (isCore
                                                ? Colors.green[50]
                                                : Colors.orange[50]),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.book,
                                        color: courseType == null
                                            ? Colors.grey[600]
                                            : (isCore
                                                ? Colors.green[700]
                                                : Colors.orange[700]),
                                      ),
                                    ),
                                    title: Text(
                                      course['courseCode'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(course['title']),
                                        const SizedBox(height: 4),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 4,
                                          children: [
                                            if (courseType != null)
                                              Chip(
                                                label: Text(
                                                  courseType.toUpperCase(),
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                backgroundColor: isCore
                                                    ? Colors.green[50]
                                                    : Colors.orange[50],
                                                labelStyle: TextStyle(
                                                  color: isCore
                                                      ? Colors.green[700]
                                                      : Colors.orange[700],
                                                ),
                                              ),
                                            Chip(
                                              label: Text(
                                                '${course['credits']} Credits',
                                                style: const TextStyle(fontSize: 11),
                                              ),
                                              backgroundColor: Colors.blue[50],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
