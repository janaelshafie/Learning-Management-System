import 'package:flutter/material.dart';
import '../../services/api_services.dart';

class AdminDepartmentCourseManagement extends StatefulWidget {
  final Map<String, dynamic> department;

  const AdminDepartmentCourseManagement({
    super.key,
    required this.department,
  });

  @override
  State<AdminDepartmentCourseManagement> createState() =>
      _AdminDepartmentCourseManagementState();
}

class _AdminDepartmentCourseManagementState
    extends State<AdminDepartmentCourseManagement> {
  final ApiService _apiService = ApiService();
  List<dynamic> _departmentCourses = [];
  List<dynamic> _allCourses = [];
  List<dynamic> _instructors = [];
  bool _isLoading = true;
  int? _selectedUnitHeadId;

  @override
  void initState() {
    super.initState();
    _selectedUnitHeadId = widget.department['unitHeadId'];
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load department courses by department code (from Course table)
      final deptCoursesResponse = await _apiService.getCoursesByDepartmentCode(
        widget.department['departmentId'],
      );
      if (deptCoursesResponse['status'] == 'success') {
        _departmentCourses = deptCoursesResponse['courses'] ?? [];
      }

      // Load all courses
      final allCoursesResponse = await _apiService.getAllCourses();
      if (allCoursesResponse['status'] == 'success') {
        _allCourses = allCoursesResponse['courses'] ?? [];
      }

      // Load instructors
      final instResponse = await _apiService.getAllInstructors();
      if (instResponse['status'] == 'success') {
        _instructors = instResponse['instructors'] ?? [];
      }
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

  Future<void> _addCourseToDepartment() async {
    // Filter out courses already in department
    final availableCourses = _allCourses.where((course) {
      return !_departmentCourses.any(
        (dc) => dc['courseId'] == course['courseId'],
      );
    }).toList();

    if (availableCourses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No available courses to add')),
      );
      return;
    }

    int? selectedCourseId;
    String selectedCourseType = 'core';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Course to Department'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int?>(
                decoration: const InputDecoration(
                  labelText: 'Select Course',
                  border: OutlineInputBorder(),
                ),
                items: availableCourses.map((course) {
                  return DropdownMenuItem<int?>(
                    value: course['courseId'],
                    child: Text(
                      '${course['courseCode']} - ${course['title']}',
                    ),
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
                decoration: const InputDecoration(
                  labelText: 'Course Type',
                  border: OutlineInputBorder(),
                ),
                value: selectedCourseType,
                items: const [
                  DropdownMenuItem(value: 'core', child: Text('Core')),
                  DropdownMenuItem(value: 'elective', child: Text('Elective')),
                ],
                onChanged: (value) {
                  setDialogState(() {
                    selectedCourseType = value ?? 'core';
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
              onPressed: selectedCourseId == null
                  ? null
                  : () async {
                      try {
                        final result = await _apiService.linkCourseToDepartment(
                          departmentId: widget.department['departmentId'],
                          courseId: selectedCourseId!,
                          courseType: selectedCourseType,
                        );

                        if (result['status'] == 'success') {
                          Navigator.of(context).pop();
                          _loadData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Course added to department'),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                result['message'] ?? 'Error adding course',
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
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _removeCourseFromDepartment(int courseId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Course'),
        content: const Text(
          'Are you sure you want to remove this course from the department?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final result = await _apiService.unlinkCourseFromDepartment(
        widget.department['departmentId'],
        courseId,
      );

      if (result['status'] == 'success') {
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course removed from department')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Error removing course'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _updateUnitHead() async {
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Update Head of Department'),
          content: DropdownButtonFormField<int?>(
            decoration: const InputDecoration(
              labelText: 'Head of Department',
              border: OutlineInputBorder(),
            ),
            value: _selectedUnitHeadId,
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('None'),
              ),
              ..._instructors.map(
                (inst) => DropdownMenuItem<int?>(
                  value: inst['userId'],
                  child: Text(inst['name'] ?? 'Unknown'),
                ),
              ),
            ],
            onChanged: (value) {
              setDialogState(() {
                _selectedUnitHeadId = value;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final result = await _apiService.updateDepartment({
                    'departmentId': widget.department['departmentId'].toString(),
                    'name': widget.department['name'],
                    'unitHeadId': _selectedUnitHeadId?.toString() ?? '',
                  });

                  if (result['status'] == 'success') {
                    Navigator.of(context).pop();
                    setState(() {
                      widget.department['unitHeadId'] = _selectedUnitHeadId;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Head of department updated'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          result['message'] ?? 'Error updating department',
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
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  String? _getUnitHeadName() {
    if (_selectedUnitHeadId == null) return null;
    try {
      final head = _instructors.firstWhere(
        (inst) => inst['userId'] == _selectedUnitHeadId,
        orElse: () => null,
      );
      return head?['name'];
    } catch (e) {
      return null;
    }
  }

  Future<void> _showEditCourseDialog(Map<String, dynamic> course) async {
    final courseCodeController = TextEditingController(
      text: course['courseCode'] ?? '',
    );
    final titleController = TextEditingController(
      text: course['title'] ?? '',
    );
    final creditsController = TextEditingController(
      text: course['credits']?.toString() ?? '',
    );
    final descriptionController = TextEditingController(
      text: course['description'] ?? '',
    );
    String selectedCourseType = course['courseType'] ?? 'core';
    List<dynamic> prerequisites = [];
    bool isLoadingPrereqs = true;

    // Load prerequisites
    try {
      final prereqResponse = await _apiService.getCoursePrerequisites(
        course['courseId'],
      );
      if (prereqResponse['status'] == 'success') {
        prerequisites = prereqResponse['prerequisites'] ?? [];
      }
      isLoadingPrereqs = false;
    } catch (e) {
      isLoadingPrereqs = false;
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit ${course['courseCode']}'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: courseCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Course Code *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.code),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Course Name *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: creditsController,
                    decoration: const InputDecoration(
                      labelText: 'Credit Hours *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.credit_card),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Course Type',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    value: selectedCourseType,
                    items: const [
                      DropdownMenuItem(value: 'core', child: Text('Core')),
                      DropdownMenuItem(value: 'elective', child: Text('Elective')),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        selectedCourseType = value ?? 'core';
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Prerequisites',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          // Show dialog to add prerequisite
                          int? selectedPrereqId;
                          final availableCourses = _allCourses.where((c) {
                            return c['courseId'] != course['courseId'] &&
                                !prerequisites.any((p) =>
                                    p['prereqCourseId'] == c['courseId']);
                          }).toList();

                          if (availableCourses.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No available courses to add as prerequisite'),
                              ),
                            );
                            return;
                          }

                          await showDialog(
                            context: context,
                            builder: (dialogContext) => StatefulBuilder(
                              builder: (dialogContext, setDialogState2) => AlertDialog(
                                title: const Text('Add Prerequisite'),
                                content: DropdownButtonFormField<int?>(
                                  decoration: const InputDecoration(
                                    labelText: 'Select Course',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: availableCourses.map((c) {
                                    return DropdownMenuItem<int?>(
                                      value: c['courseId'],
                                      child: Text(
                                        '${c['courseCode']} - ${c['title']}',
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setDialogState2(() {
                                      selectedPrereqId = value;
                                    });
                                  },
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(dialogContext).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: selectedPrereqId == null
                                        ? null
                                        : () async {
                                            try {
                                              final result =
                                                  await _apiService.addPrerequisite(
                                                course['courseId'],
                                                selectedPrereqId!,
                                              );
                                              if (result['status'] == 'success') {
                                                Navigator.of(dialogContext).pop();
                                                // Reload prerequisites
                                                final prereqResponse =
                                                    await _apiService
                                                        .getCoursePrerequisites(
                                                  course['courseId'],
                                                );
                                                if (prereqResponse['status'] ==
                                                    'success') {
                                                  setDialogState(() {
                                                    prerequisites = prereqResponse[
                                                            'prerequisites'] ??
                                                        [];
                                                  });
                                                }
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      result['message'] ??
                                                          'Error adding prerequisite',
                                                    ),
                                                  ),
                                                );
                                              }
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(content: Text('Error: $e')),
                                              );
                                            }
                                          },
                                    child: const Text('Add'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (isLoadingPrereqs)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (prerequisites.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'No prerequisites',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    ...prerequisites.map((prereq) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${prereq['prereqCourse']?['courseCode'] ?? ''} - ${prereq['prereqCourse']?['title'] ?? 'Unknown'}',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (confirmContext) => AlertDialog(
                                    title: const Text('Remove Prerequisite'),
                                    content: const Text(
                                      'Are you sure you want to remove this prerequisite?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(confirmContext).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.of(confirmContext).pop(true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        child: const Text('Remove'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirmed == true) {
                                  try {
                                    final result =
                                        await _apiService.removePrerequisite(
                                      course['courseId'],
                                      prereq['prereqCourseId'],
                                    );
                                    if (result['status'] == 'success') {
                                      // Reload prerequisites
                                      final prereqResponse =
                                          await _apiService.getCoursePrerequisites(
                                        course['courseId'],
                                      );
                                      if (prereqResponse['status'] == 'success') {
                                        setDialogState(() {
                                          prerequisites = prereqResponse[
                                                  'prerequisites'] ??
                                              [];
                                        });
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            result['message'] ??
                                                'Error removing prerequisite',
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e')),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (courseCodeController.text.isEmpty ||
                    titleController.text.isEmpty ||
                    creditsController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all required fields'),
                    ),
                  );
                  return;
                }

                try {
                  // Update the course itself
                  final courseUpdateResult = await _apiService.updateCourse({
                    'courseId': course['courseId'].toString(),
                    'courseCode': courseCodeController.text.trim(),
                    'title': titleController.text.trim(),
                    'description': descriptionController.text.trim(),
                    'credits': creditsController.text.trim(),
                  });

                  if (courseUpdateResult['status'] != 'success') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          courseUpdateResult['message'] ?? 'Error updating course',
                        ),
                      ),
                    );
                    return;
                  }

                  // Update the department course type if it changed
                  if (selectedCourseType != course['courseType']) {
                    await _apiService.unlinkCourseFromDepartment(
                      widget.department['departmentId'],
                      course['courseId'],
                    );
                    await _apiService.linkCourseToDepartment(
                      departmentId: widget.department['departmentId'],
                      courseId: course['courseId'],
                      courseType: selectedCourseType,
                    );
                  }

                  Navigator.of(context).pop();
                  _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Course updated successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCourseDetails(Map<String, dynamic> course) async {
    bool isLoadingPrerequisites = true;
    List<dynamic> prerequisites = [];

    // Load prerequisites
    try {
      final prereqResponse = await _apiService.getCoursePrerequisites(
        course['courseId'],
      );
      if (prereqResponse['status'] == 'success') {
        prerequisites = prereqResponse['prerequisites'] ?? [];
      }
      isLoadingPrerequisites = false;
    } catch (e) {
      isLoadingPrerequisites = false;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(course['courseCode'] ?? 'Course Details'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Course Title
                  Text(
                    course['title'] ?? 'No Title',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Course Type
                  Row(
                    children: [
                      const Text(
                        'Type: ',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: (course['courseType'] == 'core'
                                  ? Colors.green
                                  : Colors.orange)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          course['courseType'] == 'core' ? 'Core' : 'Elective',
                          style: TextStyle(
                            color: course['courseType'] == 'core'
                                ? Colors.green[700]
                                : Colors.orange[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Credit Hours
                  Text(
                    'Credit Hours: ${course['credits'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  // Description
                  if (course['description'] != null &&
                      course['description'].toString().isNotEmpty) ...[
                    const Text(
                      'Description:',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Prerequisites
                  const Text(
                    'Prerequisites:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isLoadingPrerequisites)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (prerequisites.isEmpty)
                    Text(
                      'No prerequisites',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else
                    ...prerequisites.map((prereq) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Text(
                          '${prereq['prereqCourse']?['courseCode'] ?? ''} - ${prereq['prereqCourse']?['title'] ?? 'Unknown'}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop(); // Close details dialog
                _showEditCourseDialog(course);
              },
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage ${widget.department['name']}'),
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
                  // Head of Department Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Head of Department',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getUnitHeadName() ?? 'Not Assigned',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _updateUnitHead,
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Change Head'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A8A),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Courses Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Department Courses',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _addCourseToDepartment,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Course'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_departmentCourses.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'No courses in this department',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ..._departmentCourses.map((course) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => _showCourseDetails(course),
                          child: ListTile(
                            title: Text(
                              '${course['courseCode']} - ${course['title']}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Credits: ${course['credits']}'),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (course['courseType'] == 'core'
                                            ? Colors.green
                                            : Colors.orange)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    course['courseType'] ?? 'Unknown',
                                    style: TextStyle(
                                      color: course['courseType'] == 'core'
                                          ? Colors.green[700]
                                          : Colors.orange[700],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.info_outline, color: Colors.blue),
                                  onPressed: () => _showCourseDetails(course),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeCourseFromDepartment(
                                    course['courseId'],
                                  ),
                                ),
                              ],
                            ),
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

