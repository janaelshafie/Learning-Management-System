import 'package:flutter/material.dart';
import '../../services/api_services.dart';
import 'admin_department_course_management.dart';

class AdminDepartmentManagement extends StatefulWidget {
  const AdminDepartmentManagement({super.key});

  @override
  State<AdminDepartmentManagement> createState() =>
      _AdminDepartmentManagementState();
}

class _AdminDepartmentManagementState extends State<AdminDepartmentManagement> {
  final ApiService _apiService = ApiService();
  List<dynamic> _departments = [];
  List<dynamic> _instructors = [];
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
      final deptResponse = await _apiService.getAllDepartments();
      if (deptResponse['status'] == 'success') {
        _departments = deptResponse['departments'] ?? [];
      }

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

  String? _getUnitHeadName(int? unitHeadId) {
    if (unitHeadId == null) return null;
    try {
      final head = _instructors.firstWhere(
        (inst) => inst['userId'] == unitHeadId,
        orElse: () => null,
      );
      return head?['name'];
    } catch (e) {
      return null;
    }
  }

  void _showNewDepartmentDialog() {
    final nameController = TextEditingController();
    int? selectedUnitHeadId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('New Department'),
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
              DropdownButtonFormField<int?>(
                decoration: const InputDecoration(
                  labelText: 'Head of Department (Optional)',
                  border: OutlineInputBorder(),
                ),
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
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a department name')),
                  );
                  return;
                }

                try {
                  final result = await _apiService.createDepartment({
                    'name': nameController.text,
                    'unitHeadId': selectedUnitHeadId?.toString() ?? '',
                  });

                  if (result['status'] == 'success') {
                    Navigator.of(context).pop();
                    _loadData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Department created successfully')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result['message'] ?? 'Error creating department')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Department Management',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showNewDepartmentDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('New Department'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Table
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _departments.isEmpty
                    ? const Center(
                        child: Text(
                          'No departments found',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Code')),
                            DataColumn(label: Text('Department Name')),
                            DataColumn(label: Text('Head of Department')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: _departments.map((dept) {
                            final code = dept['code'] ?? 
                                dept['name'].toString().substring(0, 2).toUpperCase();
                            final unitHeadName = _getUnitHeadName(dept['unitHeadId']);
                            return DataRow(
                              cells: [
                                DataCell(Text(code)),
                                DataCell(Text(dept['name'] ?? 'Unknown')),
                                DataCell(Text(
                                  unitHeadName ?? 'Not Assigned',
                                )),
                                DataCell(
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AdminDepartmentCourseManagement(
                                            department: dept,
                                          ),
                                        ),
                                      ).then((_) => _loadData());
                                    },
                                    child: const Text(
                                      'Manage',
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

