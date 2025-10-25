import 'package:flutter/material.dart';
import '../../services/api_services.dart';

class DepartmentManagementScreen extends StatefulWidget {
  const DepartmentManagementScreen({super.key});

  @override
  State<DepartmentManagementScreen> createState() => _DepartmentManagementScreenState();
}

class _DepartmentManagementScreenState extends State<DepartmentManagementScreen> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  List<dynamic> _departments = [];
  List<dynamic> _courses = [];
  List<dynamic> _instructors = [];
  bool _isLoading = true;
  int _selectedTabIndex = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _filterDepartments(List<dynamic> departments, String query) {
    if (query.isEmpty) return departments;
    
    return departments.where((department) {
      final name = (department['name'] ?? '').toString().toLowerCase();
      final searchLower = query.toLowerCase();
      
      return name.contains(searchLower);
    }).toList();
  }

  List<dynamic> _filterCourses(List<dynamic> courses, String query) {
    if (query.isEmpty) return courses;
    
    return courses.where((course) {
      final courseCode = (course['courseCode'] ?? '').toString().toLowerCase();
      final title = (course['title'] ?? '').toString().toLowerCase();
      final description = (course['description'] ?? '').toString().toLowerCase();
      final department = _getDepartmentFromCourseCode(course['courseCode']).toLowerCase();
      final searchLower = query.toLowerCase();
      
      return courseCode.contains(searchLower) ||
             title.contains(searchLower) ||
             description.contains(searchLower) ||
             department.contains(searchLower);
    }).toList();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final departmentsResult = await _apiService.getAllDepartments();
      final coursesResult = await _apiService.getAllCourses();
      final instructorsResult = await _apiService.getAllInstructors();

      if (departmentsResult['status'] == 'success') {
        _departments = departmentsResult['departments'] ?? [];
      }

      if (coursesResult['status'] == 'success') {
        _courses = coursesResult['courses'] ?? [];
      }

      if (instructorsResult['status'] == 'success') {
        _instructors = instructorsResult['instructors'] ?? [];
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _showEditDepartmentDialog(Map<String, dynamic> department) async {
    final nameController = TextEditingController(text: department['name']);
    int? selectedUnitHeadId = department['unitHeadId'];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Department'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Department Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedUnitHeadId,
                decoration: const InputDecoration(
                  labelText: 'Unit Head (Optional)',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<int>(
                    value: null,
                    child: Text('No Unit Head'),
                  ),
                  ..._instructors.map((instructor) => DropdownMenuItem<int>(
                    value: instructor['userId'],
                    child: Text(instructor['name']),
                  )),
                ],
                onChanged: (value) {
                  setDialogState(() {
                    selectedUnitHeadId = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter department name')),
                  );
                  return;
                }

                final result = await _apiService.updateDepartment({
                  'departmentId': department['departmentId'].toString(),
                  'name': nameController.text.trim(),
                  'unitHeadId': selectedUnitHeadId?.toString(),
                });

                Navigator.of(context).pop();

                if (result['status'] == 'success') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result['message'])),
                  );
                  _loadData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result['message'])),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateDepartmentDialog() async {
    final nameController = TextEditingController();
    int? selectedUnitHeadId;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create Department'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Department Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedUnitHeadId,
                decoration: const InputDecoration(
                  labelText: 'Unit Head (Optional)',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<int>(
                    value: null,
                    child: Text('No Unit Head'),
                  ),
                  ..._instructors.map((instructor) => DropdownMenuItem<int>(
                    value: instructor['userId'],
                    child: Text(instructor['name']),
                  )),
                ],
                onChanged: (value) {
                  setDialogState(() {
                    selectedUnitHeadId = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter department name')),
                  );
                  return;
                }

                final result = await _apiService.createDepartment({
                  'name': nameController.text.trim(),
                  'unitHeadId': selectedUnitHeadId?.toString(),
                });

                Navigator.of(context).pop();

                if (result['status'] == 'success') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result['message'])),
                  );
                  _loadData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result['message'])),
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditCourseDialog(Map<String, dynamic> course) async {
    final courseCodeController = TextEditingController(text: course['courseCode']);
    final titleController = TextEditingController(text: course['title']);
    final descriptionController = TextEditingController(text: course['description'] ?? '');
    final creditsController = TextEditingController(text: course['credits'].toString());

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Course'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: courseCodeController,
              decoration: const InputDecoration(
                labelText: 'Course Code (e.g., CSE112)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Course Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: creditsController,
              decoration: const InputDecoration(
                labelText: 'Credits',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (courseCodeController.text.trim().isEmpty ||
                  titleController.text.trim().isEmpty ||
                  creditsController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all required fields')),
                );
                return;
              }

              final result = await _apiService.updateCourse({
                'courseId': course['courseId'].toString(),
                'courseCode': courseCodeController.text.trim(),
                'title': titleController.text.trim(),
                'description': descriptionController.text.trim(),
                'credits': creditsController.text.trim(),
              });

              Navigator.of(context).pop();

              if (result['status'] == 'success') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result['message'])),
                );
                _loadData();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result['message'])),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateCourseDialog() async {
    final courseCodeController = TextEditingController();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final creditsController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Course'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: courseCodeController,
              decoration: const InputDecoration(
                labelText: 'Course Code (e.g., CSE112)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Course Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: creditsController,
              decoration: const InputDecoration(
                labelText: 'Credits',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (courseCodeController.text.trim().isEmpty ||
                  titleController.text.trim().isEmpty ||
                  creditsController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all required fields')),
                );
                return;
              }

              final result = await _apiService.createCourse({
                'courseCode': courseCodeController.text.trim(),
                'title': titleController.text.trim(),
                'description': descriptionController.text.trim(),
                'credits': creditsController.text.trim(),
              });

              Navigator.of(context).pop();

              if (result['status'] == 'success') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result['message'])),
                );
                _loadData();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result['message'])),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDepartment(int departmentId, String departmentName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Department'),
        content: Text('Are you sure you want to delete department "$departmentName"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await _apiService.deleteDepartment(departmentId);
      
      if (result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    }
  }

  Future<void> _deleteCourse(int courseId, String courseCode) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Are you sure you want to delete course "$courseCode"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await _apiService.deleteCourse(courseId);
      
      if (result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
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
    } else if (courseCode.startsWith('MATH')) {
      return 'Mathematics';
    } else if (courseCode.startsWith('PHYS')) {
      return 'Physics';
    } else if (courseCode.startsWith('CHEM')) {
      return 'Chemistry';
    } else if (courseCode.startsWith('HIST')) {
      return 'History';
    } else {
      return 'General';
    }
  }

  Widget _buildDepartmentsTab() {
    final filteredDepartments = _filterDepartments(_departments, _searchQuery);
    
    return Column(
      children: [
        // Search Bar for Departments
        Container(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search departments by name...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
        ),
        // Content
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredDepartments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty ? 'No departments match your search' : 'No departments found',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(_searchQuery.isNotEmpty ? 'Try a different search term' : 'No departments in the system'),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredDepartments.length,
                        itemBuilder: (context, index) {
                          final department = filteredDepartments[index];
                          final unitHead = _instructors.firstWhere(
                            (instructor) => instructor['userId'] == department['unitHeadId'],
                            orElse: () => null,
                          );

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: const Icon(Icons.business, color: Colors.blue),
                              title: Text(
                                department['name'],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (unitHead != null)
                                    Text('Unit Head: ${unitHead['name']}')
                                  else
                                    const Text('No Unit Head Assigned'),
                                  Text('ID: ${department['departmentId']}'),
                                ],
                              ),
                              trailing: PopupMenuButton(
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, color: Colors.blue),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Delete'),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showEditDepartmentDialog(department);
                                  } else if (value == 'delete') {
                                    _deleteDepartment(department['departmentId'], department['name']);
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildCoursesTab() {
    final filteredCourses = _filterCourses(_courses, _searchQuery);
    
    return Column(
      children: [
        // Search Bar for Courses
        Container(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search courses by code, title, or department...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
        ),
        // Content
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredCourses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty ? 'No courses match your search' : 'No courses found',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(_searchQuery.isNotEmpty ? 'Try a different search term' : 'No courses in the system'),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredCourses.length,
                        itemBuilder: (context, index) {
                          final course = filteredCourses[index];
                          
                          // Determine department from course code
                          String department = _getDepartmentFromCourseCode(course['courseCode']);
                          Color departmentColor = _getDepartmentColor(department);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: departmentColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.book,
                                  color: departmentColor,
                                ),
                              ),
                              title: Text(
                                course['courseCode'],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    course['title'],
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: departmentColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: departmentColor,
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      department,
                                      style: TextStyle(
                                        color: departmentColor,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Credits: ${course['credits']}'),
                                  if (course['description'] != null && course['description'].toString().isNotEmpty)
                                    Text('Description: ${course['description']}'),
                                ],
                              ),
                              trailing: PopupMenuButton(
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, color: Colors.blue),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Delete'),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showEditCourseDialog(course);
                                  } else if (value == 'delete') {
                                    _deleteCourse(course['courseId'], course['courseCode']);
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Department Management'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.grey[100],
            child: TabBar(
              controller: TabController(length: 2, vsync: this, initialIndex: _selectedTabIndex),
              onTap: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              tabs: const [
                Tab(
                  icon: Icon(Icons.business),
                  text: 'Departments',
                ),
                Tab(
                  icon: Icon(Icons.book),
                  text: 'Courses',
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: TabController(length: 2, vsync: this, initialIndex: _selectedTabIndex),
              children: [
                _buildDepartmentsTab(),
                _buildCoursesTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedTabIndex == 0) {
            _showCreateDepartmentDialog();
          } else {
            _showCreateCourseDialog();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
