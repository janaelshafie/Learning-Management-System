import 'package:flutter/material.dart';
import '../../services/api_services.dart';

class AdminAdvisorManagement extends StatefulWidget {
  const AdminAdvisorManagement({super.key});

  @override
  State<AdminAdvisorManagement> createState() => _AdminAdvisorManagementState();
}

class _AdminAdvisorManagementState extends State<AdminAdvisorManagement>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;

  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _advisors = [];
  List<Map<String, dynamic>> _departments = [];
  bool _isLoading = true;
  String _searchQuery = '';
  int? _filterDepartmentId;
  bool _filterNoAdvisor = false;

  // For bulk assignment
  Set<int> _selectedStudentIds = {};
  bool _isSelectMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _apiService.getStudentsWithAdvisors(),
        _apiService.getAdvisorsList(),
        _apiService.getAllDepartments(),
      ]);

      if (results[0]['status'] == 'success') {
        _students = List<Map<String, dynamic>>.from(
          results[0]['students'] ?? [],
        );
      }
      if (results[1]['status'] == 'success') {
        _advisors = List<Map<String, dynamic>>.from(
          results[1]['advisors'] ?? [],
        );
      }
      if (results[2]['status'] == 'success') {
        _departments = List<Map<String, dynamic>>.from(
          results[2]['departments'] ?? [],
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Map<String, dynamic>> get _filteredStudents {
    return _students.where((student) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final name = (student['name'] ?? '').toString().toLowerCase();
        final email = (student['email'] ?? '').toString().toLowerCase();
        final uid = (student['studentUid'] ?? '').toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        if (!name.contains(query) &&
            !email.contains(query) &&
            !uid.contains(query)) {
          return false;
        }
      }

      // Department filter
      if (_filterDepartmentId != null) {
        if (student['departmentId'] != _filterDepartmentId) {
          return false;
        }
      }

      // No advisor filter
      if (_filterNoAdvisor) {
        if (student['advisorId'] != null) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Future<void> _assignAdvisor(Map<String, dynamic> student) async {
    int? selectedAdvisorId = student['advisorId'];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Assign Advisor for ${student['name']}',
            overflow: TextOverflow.ellipsis,
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student: ${student['name']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Email: ${student['email']}',
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Department: ${student['departmentName'] ?? 'N/A'}',
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                DropdownButtonFormField<int?>(
                  decoration: const InputDecoration(
                    labelText: 'Select Advisor',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  value: selectedAdvisorId,
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('-- No Advisor --'),
                    ),
                    ..._advisors.map((advisor) {
                      return DropdownMenuItem<int?>(
                        value: advisor['userId'],
                        child: Text(
                          '${advisor['name']} (${advisor['instructorType'] ?? 'Instructor'}) - ${advisor['adviseeCount']} advisees',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedAdvisorId = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _performAssignment(student['userId'], selectedAdvisorId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
              ),
              child: const Text('Assign'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performAssignment(int studentId, int? advisorId) async {
    try {
      final response = await _apiService.assignAdvisor(studentId, advisorId);
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ?? 'Advisor assigned successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Error assigning advisor'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _bulkAssignAdvisor() async {
    if (_selectedStudentIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one student')),
      );
      return;
    }

    int? selectedAdvisorId;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Bulk Assign Advisor (${_selectedStudentIds.length} students)',
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Selected ${_selectedStudentIds.length} student(s)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int?>(
                  decoration: const InputDecoration(
                    labelText: 'Select Advisor',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  value: selectedAdvisorId,
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('-- Remove Advisor --'),
                    ),
                    ..._advisors.map((advisor) {
                      return DropdownMenuItem<int?>(
                        value: advisor['userId'],
                        child: Text(
                          '${advisor['name']} (${advisor['adviseeCount']} advisees)',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedAdvisorId = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _performBulkAssignment(selectedAdvisorId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
              ),
              child: const Text('Assign'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performBulkAssignment(int? advisorId) async {
    try {
      final response = await _apiService.assignAdvisorBulk(
        _selectedStudentIds.toList(),
        advisorId,
      );
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ?? 'Advisors assigned successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _selectedStudentIds.clear();
          _isSelectMode = false;
        });
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Error assigning advisor'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _assignByDepartment() async {
    int? selectedDepartmentId;
    int? selectedAdvisorId;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Assign Advisor by Department'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int?>(
                  decoration: const InputDecoration(
                    labelText: 'Select Department',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                  value: selectedDepartmentId,
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('-- Select Department --'),
                    ),
                    ..._departments.map((dept) {
                      return DropdownMenuItem<int?>(
                        value: dept['departmentId'],
                        child: Text(
                          dept['name'] ?? 'Unknown',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedDepartmentId = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int?>(
                  decoration: const InputDecoration(
                    labelText: 'Select Advisor',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  value: selectedAdvisorId,
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('-- Remove Advisor --'),
                    ),
                    ..._advisors.map((advisor) {
                      return DropdownMenuItem<int?>(
                        value: advisor['userId'],
                        child: Text(
                          '${advisor['name']} (${advisor['adviseeCount']} advisees)',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedAdvisorId = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'This will assign the selected advisor to ALL students in the chosen department.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedDepartmentId == null
                  ? null
                  : () async {
                      Navigator.pop(context);
                      await _performDepartmentAssignment(
                        selectedDepartmentId!,
                        selectedAdvisorId,
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
              ),
              child: const Text('Assign'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performDepartmentAssignment(
    int departmentId,
    int? advisorId,
  ) async {
    try {
      final response = await _apiService.assignAdvisorByDepartment(
        departmentId,
        advisorId,
      );
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ?? 'Advisors assigned successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Error assigning advisor'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.supervisor_account,
                      size: 32,
                      color: Color(0xFF1E3A8A),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Advisor Management',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: _loadData,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _assignByDepartment,
                      icon: const Icon(Icons.business, size: 18),
                      label: const Text('Assign by Dept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isSelectMode = !_isSelectMode;
                          if (!_isSelectMode) {
                            _selectedStudentIds.clear();
                          }
                        });
                      },
                      icon: Icon(
                        _isSelectMode ? Icons.close : Icons.checklist,
                        size: 18,
                      ),
                      label: Text(_isSelectMode ? 'Cancel' : 'Bulk Assign'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isSelectMode
                            ? Colors.grey
                            : const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                      ),
                    ),
                    if (_isSelectMode && _selectedStudentIds.isNotEmpty)
                      ElevatedButton.icon(
                        onPressed: _bulkAssignAdvisor,
                        icon: const Icon(Icons.check, size: 18),
                        label: Text('Assign (${_selectedStudentIds.length})'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFF1E3A8A),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: const Color(0xFF1E3A8A),
                  tabs: const [
                    Tab(text: 'Students', icon: Icon(Icons.school)),
                    Tab(text: 'Advisors', icon: Icon(Icons.person)),
                  ],
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [_buildStudentsTab(), _buildAdvisorsTab()],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsTab() {
    final filteredStudents = _filteredStudents;

    return Column(
      children: [
        // Filters
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search students...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<int?>(
                      decoration: InputDecoration(
                        labelText: 'Department',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                      ),
                      value: _filterDepartmentId,
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text(
                            'All Departments',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ..._departments.map((dept) {
                          return DropdownMenuItem<int?>(
                            value: dept['departmentId'],
                            child: Text(
                              dept['name'] ?? 'Unknown',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _filterDepartmentId = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  FilterChip(
                    label: const Text('No Advisor'),
                    selected: _filterNoAdvisor,
                    onSelected: (value) {
                      setState(() {
                        _filterNoAdvisor = value;
                      });
                    },
                    selectedColor: Colors.orange.shade100,
                  ),
                  const Spacer(),
                  if (_isSelectMode)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          if (_selectedStudentIds.length ==
                              filteredStudents.length) {
                            _selectedStudentIds.clear();
                          } else {
                            _selectedStudentIds = filteredStudents
                                .map((s) => s['userId'] as int)
                                .toSet();
                          }
                        });
                      },
                      child: Text(
                        _selectedStudentIds.length == filteredStudents.length
                            ? 'Deselect All'
                            : 'Select All',
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        // Stats
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                'Showing ${filteredStudents.length} of ${_students.length} students',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(width: 16),
              Text(
                '${_students.where((s) => s['advisorId'] == null).length} without advisor',
                style: TextStyle(color: Colors.orange[700]),
              ),
            ],
          ),
        ),
        // List
        Expanded(
          child: filteredStudents.isEmpty
              ? const Center(child: Text('No students found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredStudents.length,
                  itemBuilder: (context, index) {
                    final student = filteredStudents[index];
                    final hasAdvisor = student['advisorId'] != null;
                    final isSelected = _selectedStudentIds.contains(
                      student['userId'],
                    );

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: isSelected ? Colors.blue.shade50 : null,
                      child: ListTile(
                        leading: _isSelectMode
                            ? Checkbox(
                                value: isSelected,
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedStudentIds.add(
                                        student['userId'],
                                      );
                                    } else {
                                      _selectedStudentIds.remove(
                                        student['userId'],
                                      );
                                    }
                                  });
                                },
                              )
                            : CircleAvatar(
                                backgroundColor: hasAdvisor
                                    ? Colors.green.shade100
                                    : Colors.orange.shade100,
                                child: Icon(
                                  hasAdvisor ? Icons.check : Icons.warning,
                                  color: hasAdvisor
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                        title: Text(
                          student['name'] ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(student['email'] ?? ''),
                            Text(
                              'Department: ${student['departmentName'] ?? 'N/A'}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Text(
                              'Advisor: ${student['advisorName'] ?? 'Not Assigned'}',
                              style: TextStyle(
                                color: hasAdvisor
                                    ? Colors.green
                                    : Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => _assignAdvisor(student),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hasAdvisor
                                ? Colors.blue
                                : const Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                          ),
                          child: Text(hasAdvisor ? 'Change' : 'Assign'),
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAdvisorsTab() {
    return _advisors.isEmpty
        ? const Center(child: Text('No advisors found'))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _advisors.length,
            itemBuilder: (context, index) {
              final advisor = _advisors[index];
              final adviseeCount = advisor['adviseeCount'] ?? 0;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.1),
                    child: Text(
                      (advisor['name'] ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF1E3A8A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    advisor['name'] ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        advisor['email'] ?? '',
                        overflow: TextOverflow.ellipsis,
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Chip(
                            label: Text(
                              advisor['instructorType']
                                      ?.toString()
                                      .toUpperCase() ??
                                  'INSTRUCTOR',
                              style: const TextStyle(fontSize: 10),
                            ),
                            backgroundColor: Colors.blue.shade50,
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          Chip(
                            label: Text(
                              '$adviseeCount advisees',
                              style: const TextStyle(fontSize: 10),
                            ),
                            backgroundColor: adviseeCount > 0
                                ? Colors.green.shade50
                                : Colors.grey.shade200,
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ],
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Department: ${advisor['departmentName'] ?? 'Not assigned'}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          if (adviseeCount > 0) ...[
                            const Text(
                              'Advisees:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ..._students
                                .where(
                                  (s) => s['advisorId'] == advisor['userId'],
                                )
                                .map(
                                  (student) => Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16,
                                      bottom: 4,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.person,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '${student['name'] ?? 'Unknown'} - ${student['departmentName'] ?? 'N/A'}',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ] else
                            const Text(
                              'No advisees assigned yet',
                              style: TextStyle(color: Colors.grey),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
  }
}
