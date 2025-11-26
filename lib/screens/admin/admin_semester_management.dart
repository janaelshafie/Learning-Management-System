import 'package:flutter/material.dart';
import '../../services/api_services.dart';
import 'admin_semester_details_page.dart';

class AdminSemesterManagement extends StatefulWidget {
  const AdminSemesterManagement({super.key});

  @override
  State<AdminSemesterManagement> createState() =>
      _AdminSemesterManagementState();
}

class _AdminSemesterManagementState extends State<AdminSemesterManagement> {
  final ApiService _apiService = ApiService();
  List<dynamic> _semesters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSemesters();
  }

  Future<void> _loadSemesters() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.getSemesters();
      if (response['status'] == 'success') {
        setState(() {
          _semesters = response['semesters'] ?? [];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading semesters: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<dynamic> _getCurrentSemesters() {
    final now = DateTime.now();
    return _semesters.where((sem) {
      try {
        final startDate = DateTime.parse(sem['startDate']);
        final endDate = DateTime.parse(sem['endDate']);
        return now.isAfter(startDate) && now.isBefore(endDate);
      } catch (e) {
        return false;
      }
    }).toList();
  }

  List<dynamic> _getUpcomingSemesters() {
    final now = DateTime.now();
    return _semesters.where((sem) {
      try {
        final startDate = DateTime.parse(sem['startDate']);
        return now.isBefore(startDate);
      } catch (e) {
        return false;
      }
    }).toList();
  }

  List<dynamic> _getPastSemesters() {
    final now = DateTime.now();
    return _semesters.where((sem) {
      try {
        final endDate = DateTime.parse(sem['endDate']);
        return now.isAfter(endDate);
      } catch (e) {
        return false;
      }
    }).toList();
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

  void _showCreateSemesterDialog() {
    final nameController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;
    bool registrationOpen = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create Semester'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Semester Name (e.g., Fall 2024)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Start Date'),
                  subtitle: Text(
                    startDate == null
                        ? 'Select start date'
                        : _formatDate(startDate!.toIso8601String()),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        startDate = picked;
                      });
                    }
                  },
                ),
                ListTile(
                  title: const Text('End Date'),
                  subtitle: Text(
                    endDate == null
                        ? 'Select end date'
                        : _formatDate(endDate!.toIso8601String()),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: startDate ?? DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        endDate = picked;
                      });
                    }
                  },
                ),
                CheckboxListTile(
                  title: const Text('Registration Open'),
                  value: registrationOpen,
                  onChanged: (value) {
                    setDialogState(() {
                      registrationOpen = value ?? false;
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
              onPressed: (nameController.text.isEmpty ||
                      startDate == null ||
                      endDate == null)
                  ? null
                  : () async {
                      try {
                        final result = await _apiService.createSemester({
                          'name': nameController.text,
                          'startDate': startDate?.toIso8601String().split('T')[0] ?? '',
                          'endDate': endDate?.toIso8601String().split('T')[0] ?? '',
                          'registrationOpen': registrationOpen,
                        });

                        if (result['status'] == 'success') {
                          Navigator.of(context).pop();
                          _loadSemesters();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Semester created successfully'),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                result['message'] ?? 'Error creating semester',
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
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSemesterDialog(Map<String, dynamic> semester) {
    final nameController = TextEditingController(text: semester['name']);
    DateTime? startDate = DateTime.tryParse(semester['startDate']);
    DateTime? endDate = DateTime.tryParse(semester['endDate']);
    bool registrationOpen = semester['registrationOpen'] ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Semester'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Semester Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Start Date'),
                  subtitle: Text(
                    startDate == null
                        ? 'Select start date'
                        : _formatDate(startDate!.toIso8601String()),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        startDate = picked;
                      });
                    }
                  },
                ),
                ListTile(
                  title: const Text('End Date'),
                  subtitle: Text(
                    endDate == null
                        ? 'Select end date'
                        : _formatDate(endDate!.toIso8601String()),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: endDate ?? DateTime.now(),
                      firstDate: startDate ?? DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        endDate = picked;
                      });
                    }
                  },
                ),
                CheckboxListTile(
                  title: const Text('Registration Open'),
                  value: registrationOpen,
                  onChanged: (value) {
                    setDialogState(() {
                      registrationOpen = value ?? false;
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
              onPressed: (nameController.text.isEmpty ||
                      startDate == null ||
                      endDate == null)
                  ? null
                  : () async {
                      try {
                        final result = await _apiService.updateSemester({
                          'semesterId': semester['semesterId'].toString(),
                          'name': nameController.text,
                          'startDate': startDate?.toIso8601String().split('T')[0] ?? '',
                          'endDate': endDate?.toIso8601String().split('T')[0] ?? '',
                          'registrationOpen': registrationOpen,
                        });

                        if (result['status'] == 'success') {
                          Navigator.of(context).pop();
                          _loadSemesters();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Semester updated successfully'),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                result['message'] ?? 'Error updating semester',
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


  @override
  Widget build(BuildContext context) {
    final currentSemesters = _getCurrentSemesters();
    final upcomingSemesters = _getUpcomingSemesters();
    final pastSemesters = _getPastSemesters();

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
                  'Semester Management',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showCreateSemesterDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Semester'),
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
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        const TabBar(
                          labelColor: Color(0xFF1E3A8A),
                          unselectedLabelColor: Colors.grey,
                          tabs: [
                            Tab(text: 'Current & Upcoming'),
                            Tab(text: 'Semester Records'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              // Current & Upcoming Tab
                              SingleChildScrollView(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Current Semesters
                                    if (currentSemesters.isNotEmpty) ...[
                                      const Text(
                                        'Current Semesters',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ...currentSemesters.map((sem) =>
                                          _buildSemesterCard(sem, 'Current', true)),
                                      const SizedBox(height: 24),
                                    ],
                                    // Upcoming Semesters
                                    if (upcomingSemesters.isNotEmpty) ...[
                                      const Text(
                                        'Upcoming Semesters',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ...upcomingSemesters.map((sem) =>
                                          _buildSemesterCard(sem, 'Upcoming', true)),
                                    ],
                                    if (currentSemesters.isEmpty &&
                                        upcomingSemesters.isEmpty)
                                      const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(32),
                                          child: Text(
                                            'No current or upcoming semesters',
                                            style: TextStyle(color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              // Semester Records Tab
                              SingleChildScrollView(
                                padding: const EdgeInsets.all(24),
                                child: pastSemesters.isEmpty
                                    ? const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(32),
                                          child: Text(
                                            'No past semesters',
                                            style: TextStyle(color: Colors.grey),
                                          ),
                                        ),
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Past Semesters',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          ...pastSemesters.map((sem) =>
                                              _buildSemesterCard(sem, 'Past', false)),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterCard(
    Map<String, dynamic> semester,
    String status,
    bool editable,
  ) {
    final statusColor = status == 'Current'
        ? Colors.green
        : status == 'Upcoming'
            ? Colors.blue
            : Colors.grey;
    
    // Determine if it's read-only (past semesters are read-only)
    final isReadOnly = status == 'Past';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Navigate to details page for all semesters
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminSemesterDetailsPage(
                semester: semester,
                isReadOnly: isReadOnly,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      semester['name'] ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Duration: ${_formatDate(semester['startDate'])} to ${_formatDate(semester['endDate'])}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (editable && !isReadOnly) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _showEditSemesterDialog(semester),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}

