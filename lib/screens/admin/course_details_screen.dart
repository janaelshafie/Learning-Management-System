import 'package:flutter/material.dart';
import '../../services/api_services.dart';

class CourseDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> course;

  const CourseDetailsScreen({super.key, required this.course});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _prerequisites = [];
  List<dynamic> _allCourses = [];
  bool _isLoadingPrerequisites = true;
  bool _isLoadingCourses = false;

  @override
  void initState() {
    super.initState();
    _loadPrerequisites();
    _loadAllCourses();
  }

  Future<void> _loadAllCourses() async {
    setState(() {
      _isLoadingCourses = true;
    });

    try {
      final result = await _apiService.getAllCourses();
      if (result['status'] == 'success') {
        setState(() {
          _allCourses = result['courses'] ?? [];
          _isLoadingCourses = false;
        });
      } else {
        setState(() {
          _allCourses = [];
          _isLoadingCourses = false;
        });
      }
    } catch (e) {
      setState(() {
        _allCourses = [];
        _isLoadingCourses = false;
      });
    }
  }

  Future<void> _loadPrerequisites() async {
    setState(() {
      _isLoadingPrerequisites = true;
    });

    try {
      final result = await _apiService.getCoursePrerequisites(widget.course['courseId']);
      if (result['status'] == 'success') {
        setState(() {
          _prerequisites = result['prerequisites'] ?? [];
          _isLoadingPrerequisites = false;
        });
      } else {
        setState(() {
          _prerequisites = [];
          _isLoadingPrerequisites = false;
        });
      }
    } catch (e) {
      setState(() {
        _prerequisites = [];
        _isLoadingPrerequisites = false;
      });
    }
  }

  String _getDepartmentFromCourseCode(String courseCode) {
    if (courseCode.startsWith('ASU')) return 'University Requirements';
    if (courseCode.startsWith('ENG')) return 'Faculty Requirements';
    if (courseCode.startsWith('ARC')) return 'Architecture Engineering';
    if (courseCode.startsWith('CEI')) return 'Irrigation and Hydraulics Engineering';
    if (courseCode.startsWith('CEP')) return 'Public Works Engineering';
    if (courseCode.startsWith('CES')) return 'Structural Engineering';
    if (courseCode.startsWith('CSE')) return 'Computer and Systems Engineering';
    if (courseCode.startsWith('ECE')) return 'Electronics and Communication Engineering';
    if (courseCode.startsWith('EPM')) return 'Electrical Power and Machines Engineering';
    if (courseCode.startsWith('MEA')) return 'Automotive Engineering';
    if (courseCode.startsWith('MCT')) return 'Mechatronics Engineering';
    if (courseCode.startsWith('MDP')) return 'Design and Production Engineering';
    if (courseCode.startsWith('MEP')) return 'Mechanical Power Engineering';
    if (courseCode.startsWith('PHM')) return 'Engineering Physics and Mathematics';
    if (courseCode.startsWith('UPL')) return 'Urban Design and Planning';
    return 'General';
  }

  Color _getDepartmentColor(String department) {
    if (department == 'University Requirements') return Colors.purple;
    if (department == 'Faculty Requirements') return Colors.blue;
    if (department.contains('Computer')) return Colors.green;
    if (department.contains('Architecture')) return Colors.orange;
    if (department.contains('Civil') || department.contains('Structural')) return Colors.brown;
    if (department.contains('Electrical') || department.contains('Electronics')) return Colors.amber;
    if (department.contains('Mechanical') || department.contains('Power')) return Colors.red;
    return Colors.grey;
  }

  Future<void> _showEditDialog() async {
    final courseCodeController = TextEditingController(text: widget.course['courseCode']);
    final titleController = TextEditingController(text: widget.course['title']);
    final descriptionController = TextEditingController(text: widget.course['description'] ?? '');
    final creditsController = TextEditingController(text: widget.course['credits'].toString());
    String? selectedCourseType = widget.course['courseType'];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Course'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: courseCodeController,
                  decoration: const InputDecoration(labelText: 'Course Code'),
                ),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                TextField(
                  controller: creditsController,
                  decoration: const InputDecoration(labelText: 'Credits'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCourseType,
                  decoration: const InputDecoration(labelText: 'Course Type (Optional)'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('None')),
                    DropdownMenuItem(value: 'core', child: Text('Core')),
                    DropdownMenuItem(value: 'elective', child: Text('Elective')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedCourseType = value;
                    });
                  },
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
                  'courseId': widget.course['courseId'].toString(),
                  'courseCode': courseCodeController.text.trim(),
                  'title': titleController.text.trim(),
                  'description': descriptionController.text.trim(),
                  'credits': creditsController.text.trim(),
                  'courseType': selectedCourseType ?? '',
                });

                Navigator.of(context).pop();

                if (result['status'] == 'success') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result['message'])),
                  );
                  // Update the course data
                  widget.course['courseCode'] = courseCodeController.text.trim();
                  widget.course['title'] = titleController.text.trim();
                  widget.course['description'] = descriptionController.text.trim();
                  widget.course['credits'] = int.parse(creditsController.text.trim());
                  widget.course['courseType'] = selectedCourseType;
                  setState(() {});
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

  Future<void> _showAddPrerequisiteDialog() async {
    if (_isLoadingCourses) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loading courses...')),
      );
      return;
    }

    // Filter out courses that are already prerequisites and the current course
    final currentCourseId = widget.course['courseId'];
    final existingPrereqIds = _prerequisites.map((p) => p['prereqCourseId']).toList();
    
    final availableCourses = _allCourses.where((course) {
      return course['courseId'] != currentCourseId &&
             !existingPrereqIds.contains(course['courseId']);
    }).toList();

    if (availableCourses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No available courses to add as prerequisite')),
      );
      return;
    }

    int? selectedCourseId;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Prerequisite'),
          content: SizedBox(
            width: double.maxFinite,
            child: availableCourses.isEmpty
                ? const Text('No available courses')
                : DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Select Prerequisite Course',
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
                      Navigator.of(context).pop();
                      await _addPrerequisite(selectedCourseId!);
                    },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addPrerequisite(int prereqCourseId) async {
    try {
      final result = await _apiService.addPrerequisite(
        widget.course['courseId'],
        prereqCourseId,
      );

      if (result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
        _loadPrerequisites();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Error adding prerequisite')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _removePrerequisite(int prereqCourseId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Prerequisite'),
        content: const Text('Are you sure you want to remove this prerequisite?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final result = await _apiService.removePrerequisite(
          widget.course['courseId'],
          prereqCourseId,
        );

        if (result['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'])),
          );
          _loadPrerequisites();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Error removing prerequisite')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Are you sure you want to delete ${widget.course['courseCode']}?'),
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
      final result = await _apiService.deleteCourse(widget.course['courseId']);
      
      if (result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
        Navigator.of(context).pop(true); // Return true to indicate deletion
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final department = _getDepartmentFromCourseCode(widget.course['courseCode']);
    final departmentColor = _getDepartmentColor(department);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course['courseCode']),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditDialog,
            tooltip: 'Edit Course',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _showDeleteConfirmation,
            tooltip: 'Delete Course',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Header Card
            Card(
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
                          child: Icon(Icons.book, color: departmentColor, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.course['courseCode'],
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.course['title'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(
                          label: Text('${widget.course['credits']} Credits'),
                          backgroundColor: Colors.blue[50],
                        ),
                        Chip(
                          label: Text(department),
                          backgroundColor: departmentColor.withOpacity(0.1),
                          labelStyle: TextStyle(color: departmentColor),
                        ),
                        if (widget.course['courseType'] != null)
                          Chip(
                            avatar: Icon(
                              widget.course['courseType'] == 'core'
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 18,
                              color: widget.course['courseType'] == 'core'
                                  ? Colors.green[700]
                                  : Colors.orange[700],
                            ),
                            label: Text(
                              widget.course['courseType'] == 'core' ? 'CORE' : 'ELECTIVE',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            backgroundColor: widget.course['courseType'] == 'core'
                                ? Colors.green[50]
                                : Colors.orange[50],
                            labelStyle: TextStyle(
                              color: widget.course['courseType'] == 'core'
                                  ? Colors.green[700]
                                  : Colors.orange[700],
                            ),
                          )
                        else
                          Chip(
                            label: const Text(
                              'NO TYPE',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            backgroundColor: Colors.grey[100],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Description Section
            if (widget.course['description'] != null &&
                widget.course['description'].toString().isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.description, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.course['description'],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              )
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.description, color: Colors.grey),
                      const SizedBox(width: 8),
                      const Text(
                        'No description available',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Prerequisites Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lock_outline, color: Colors.orange),
                            const SizedBox(width: 8),
                            const Text(
                              'Prerequisites',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          color: Colors.blue,
                          onPressed: _showAddPrerequisiteDialog,
                          tooltip: 'Add Prerequisite',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_isLoadingPrerequisites)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_prerequisites.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'No prerequisites required',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    else
                      ..._prerequisites.map((prereq) {
                        final prereqCourse = prereq['prereqCourse'];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          color: Colors.orange[50],
                          child: ListTile(
                            leading: Icon(Icons.arrow_forward, color: Colors.orange[700]),
                            title: Text(
                              prereqCourse?['courseCode'] ?? 'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              prereqCourse?['title'] ?? '',
                              style: const TextStyle(fontSize: 14),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _removePrerequisite(prereq['prereqCourseId']),
                              tooltip: 'Remove Prerequisite',
                            ),
                          ),
                        );
                      }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

