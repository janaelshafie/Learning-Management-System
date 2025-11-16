import 'package:flutter/material.dart';
import '../../services/api_services.dart';

class DepartmentCourseManagementScreen extends StatefulWidget {
  const DepartmentCourseManagementScreen({super.key});

  @override
  State<DepartmentCourseManagementScreen> createState() => _DepartmentCourseManagementScreenState();
}

class _DepartmentCourseManagementScreenState extends State<DepartmentCourseManagementScreen> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  List<dynamic> _departments = [];
  List<dynamic> _courses = [];
  List<dynamic> _departmentCourses = [];
  int? _selectedDepartmentId;
  String _selectedFilter = 'all'; // 'all', 'core', 'elective'
  bool _isLoading = true;
  bool _isLoadingCourses = false;

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
      final deptResult = await _apiService.getAllDepartments();
      final courseResult = await _apiService.getAllCourses();

      if (deptResult['status'] == 'success' && courseResult['status'] == 'success') {
        setState(() {
          _departments = deptResult['departments'] ?? [];
          _courses = courseResult['courses'] ?? [];
          _isLoading = false;
        });

        if (_departments.isNotEmpty && _selectedDepartmentId == null) {
          _selectedDepartmentId = _departments[0]['departmentId'];
          _loadDepartmentCourses();
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  Future<void> _loadDepartmentCourses() async {
    if (_selectedDepartmentId == null) return;

    setState(() {
      _isLoadingCourses = true;
    });

    try {
      Map<String, dynamic> result;
      if (_selectedFilter == 'core') {
        result = await _apiService.getCoreCourses(_selectedDepartmentId!);
      } else if (_selectedFilter == 'elective') {
        result = await _apiService.getElectiveCourses(_selectedDepartmentId!);
      } else {
        result = await _apiService.getDepartmentCourses(_selectedDepartmentId!);
      }

      if (result['status'] == 'success') {
        setState(() {
          _departmentCourses = result['courses'] ?? [];
          _isLoadingCourses = false;
        });
      } else {
        setState(() {
          _departmentCourses = [];
          _isLoadingCourses = false;
        });
      }
    } catch (e) {
      setState(() {
        _departmentCourses = [];
        _isLoadingCourses = false;
      });
    }
  }

  Future<void> _showLinkCourseDialog() async {
    if (_selectedDepartmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a department first')),
      );
      return;
    }

    // Get courses not already linked to this department
    final linkedCourseIds = _departmentCourses.map((dc) => dc['courseId']).toList();
    final availableCourses = _courses.where((course) {
      return !linkedCourseIds.contains(course['courseId']);
    }).toList();

    if (availableCourses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All courses are already linked to this department')),
      );
      return;
    }

    int? selectedCourseId;
    String? selectedCourseType;
    final capacityController = TextEditingController();
    final eligibilityController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Link Course to Department'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Select Course',
                    border: OutlineInputBorder(),
                  ),
                  items: availableCourses.map((course) {
                    return DropdownMenuItem<int>(
                      value: course['courseId'],
                      child: Text('${course['courseCode']} - ${course['title']}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedCourseId = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCourseType,
                  decoration: const InputDecoration(
                    labelText: 'Course Type *',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'core', child: Text('Core')),
                    DropdownMenuItem(value: 'elective', child: Text('Elective')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedCourseType = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: capacityController,
                  decoration: const InputDecoration(
                    labelText: 'Capacity (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: eligibilityController,
                  decoration: const InputDecoration(
                    labelText: 'Eligibility Requirements (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedCourseId == null || selectedCourseType == null
                  ? null
                  : () async {
                      Navigator.of(context).pop();
                      await _linkCourse(
                        selectedCourseId!,
                        selectedCourseType!,
                        capacityController.text.trim().isEmpty
                            ? null
                            : int.tryParse(capacityController.text.trim()),
                        eligibilityController.text.trim().isEmpty
                            ? null
                            : eligibilityController.text.trim(),
                      );
                    },
              child: const Text('Link'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _linkCourse(int courseId, String courseType, int? capacity, String? eligibility) async {
    try {
      final result = await _apiService.linkCourseToDepartment(
        departmentId: _selectedDepartmentId!,
        courseId: courseId,
        courseType: courseType,
        capacity: capacity,
        eligibilityRequirements: eligibility,
      );

      if (result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
        _loadDepartmentCourses();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Error linking course')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _unlinkCourse(int courseId, String courseCode) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unlink Course'),
        content: Text('Are you sure you want to unlink $courseCode from this department?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Unlink'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final result = await _apiService.unlinkCourseFromDepartment(
          _selectedDepartmentId!,
          courseId,
        );

        if (result['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'])),
          );
          _loadDepartmentCourses();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Error unlinking course')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Department-Course Management'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadData();
              if (_selectedDepartmentId != null) {
                _loadDepartmentCourses();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // Left Sidebar - Department Selection
                Container(
                  width: 250,
                  color: Colors.grey[100],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Select Department',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _departments.length,
                          itemBuilder: (context, index) {
                            final dept = _departments[index];
                            final isSelected = _selectedDepartmentId == dept['departmentId'];

                            return ListTile(
                              selected: isSelected,
                              selectedTileColor: Colors.blue[50],
                              leading: const Icon(Icons.business),
                              title: Text(
                                dept['name'],
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  _selectedDepartmentId = dept['departmentId'];
                                  _selectedFilter = 'all';
                                });
                                _loadDepartmentCourses();
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Main Content
                Expanded(
                  child: _selectedDepartmentId == null
                      ? const Center(
                          child: Text('Please select a department'),
                        )
                      : Column(
                          children: [
                            // Filter Buttons
                            Container(
                              padding: const EdgeInsets.all(16),
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
                                          _loadDepartmentCourses();
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
                                          _loadDepartmentCourses();
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
                                          _loadDepartmentCourses();
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Courses List
                            Expanded(
                              child: _isLoadingCourses
                                  ? const Center(child: CircularProgressIndicator())
                                  : _departmentCourses.isEmpty
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
                                                    ? 'No courses linked to this department'
                                                    : 'No $_selectedFilter courses for this department',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              const Text('Click the + button to link a course'),
                                            ],
                                          ),
                                        )
                                      : RefreshIndicator(
                                          onRefresh: _loadDepartmentCourses,
                                          child: ListView.builder(
                                            padding: const EdgeInsets.all(16),
                                            itemCount: _departmentCourses.length,
                                            itemBuilder: (context, index) {
                                              final dc = _departmentCourses[index];
                                              final course = _courses.firstWhere(
                                                (c) => c['courseId'] == dc['courseId'],
                                                orElse: () => null,
                                              );

                                              if (course == null) return const SizedBox();

                                              final courseType = dc['courseType'];
                                              final isCore = courseType == 'core';

                                              return Card(
                                                margin: const EdgeInsets.only(bottom: 12),
                                                child: ListTile(
                                                  leading: Container(
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: isCore
                                                          ? Colors.green[50]
                                                          : Colors.orange[50],
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Icon(
                                                      Icons.book,
                                                      color: isCore
                                                          ? Colors.green[700]
                                                          : Colors.orange[700],
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
                                                          if (dc['capacity'] != null)
                                                            Chip(
                                                              label: Text(
                                                                'Capacity: ${dc['capacity']}',
                                                                style: const TextStyle(fontSize: 11),
                                                              ),
                                                              backgroundColor: Colors.blue[50],
                                                            ),
                                                        ],
                                                      ),
                                                      if (dc['eligibilityRequirements'] != null &&
                                                          dc['eligibilityRequirements'].toString().isNotEmpty)
                                                        Padding(
                                                          padding: const EdgeInsets.only(top: 4),
                                                          child: Text(
                                                            'Eligibility: ${dc['eligibilityRequirements']}',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Colors.grey[700],
                                                              fontStyle: FontStyle.italic,
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                  trailing: IconButton(
                                                    icon: const Icon(Icons.link_off, color: Colors.red),
                                                    onPressed: () => _unlinkCourse(
                                                      course['courseId'],
                                                      course['courseCode'],
                                                    ),
                                                    tooltip: 'Unlink Course',
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
      floatingActionButton: _selectedDepartmentId != null
          ? FloatingActionButton(
              onPressed: _showLinkCourseDialog,
              child: const Icon(Icons.add),
              tooltip: 'Link Course to Department',
            )
          : null,
    );
  }
}

