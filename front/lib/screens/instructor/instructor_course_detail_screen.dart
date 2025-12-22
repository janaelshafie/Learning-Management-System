import 'package:flutter/material.dart';

import '../../services/api_services.dart';
import 'instructor_room_booking.dart';

class InstructorCourseDetailScreen extends StatefulWidget {
  final int instructorId;
  final Map<String, dynamic> course;

  const InstructorCourseDetailScreen({
    super.key,
    required this.instructorId,
    required this.course,
  });

  @override
  State<InstructorCourseDetailScreen> createState() =>
      _InstructorCourseDetailScreenState();
}

class _InstructorCourseDetailScreenState
    extends State<InstructorCourseDetailScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  Map<String, dynamic>? _courseInfo;
  List<Map<String, dynamic>> _sections = [];

  @override
  void initState() {
    super.initState();
    _loadCourseDetail();
  }

  Future<void> _loadCourseDetail() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.getInstructorCourseDetail(
        widget.instructorId,
        widget.course['offeredCourseId'] as int,
      );
      if (response['status'] == 'success') {
        final data = response['data'] ?? {};
        setState(() {
          _courseInfo = Map<String, dynamic>.from(data['course'] ?? {});
          _sections = List<Map<String, dynamic>>.from(data['sections'] ?? []);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to load course'),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading course: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course['courseTitle']?.toString() ?? 'Course'),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadCourseDetail,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildCourseSummary(),
                  const SizedBox(height: 24),
                  ..._sections.map((section) => _buildSectionCard(section)),
                ],
              ),
            ),
    );
  }

  Widget _buildCourseSummary() {
    final info = _courseInfo ?? {};
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              info['courseTitle']?.toString() ?? 'Course',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${info['courseCode'] ?? ''} • ${info['semester'] ?? ''}',
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildSummaryChip(
                  'Credits',
                  info['credits']?.toString() ?? '0',
                ),
                _buildSummaryChip(
                  'Department',
                  info['departmentName']?.toString() ?? 'N/A',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(Map<String, dynamic> section) {
    final List<Map<String, dynamic>> students = List<Map<String, dynamic>>.from(
      section['students'] ?? [],
    );
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: ExpansionTile(
        title: Text('Section ${section['sectionNumber'] ?? ''}'),
        subtitle: Text(
          '${section['currentEnrollment'] ?? 0} / ${section['capacity'] ?? 0} students',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.meeting_room),
          tooltip: 'Book Room',
          onPressed: () {
            final offeredCourseId = widget.course['offeredCourseId'];
            final sectionId = section['sectionId'];
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InstructorRoomBookingScreen(
                  userId: widget.instructorId,
                  offeredCourseId: offeredCourseId is int
                      ? offeredCourseId
                      : int.tryParse(offeredCourseId?.toString() ?? ''),
                  sectionId: sectionId is int
                      ? sectionId
                      : int.tryParse(sectionId?.toString() ?? ''),
                  courseName: widget.course['courseTitle']?.toString(),
                  sectionNumber: section['sectionNumber']?.toString(),
                ),
              ),
            ).then((booked) {
              if (booked == true) {
                // Refresh course details if needed
                _loadCourseDetail();
              }
            });
          },
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.meeting_room),
                    label: const Text('Book Room for This Section'),
                    onPressed: () {
                      final offeredCourseId = widget.course['offeredCourseId'];
                      final sectionId = section['sectionId'];
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InstructorRoomBookingScreen(
                            userId: widget.instructorId,
                            offeredCourseId: offeredCourseId is int
                                ? offeredCourseId
                                : int.tryParse(
                                    offeredCourseId?.toString() ?? '',
                                  ),
                            sectionId: sectionId is int
                                ? sectionId
                                : int.tryParse(sectionId?.toString() ?? ''),
                            courseName: widget.course['courseTitle']
                                ?.toString(),
                            sectionNumber: section['sectionNumber']?.toString(),
                          ),
                        ),
                      ).then((booked) {
                        if (booked == true) {
                          _loadCourseDetail();
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          ...(students.isEmpty
              ? [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No students enrolled in this section.'),
                  ),
                ]
              : students.map(_buildStudentTile).toList()),
        ],
      ),
    );
  }

  Widget _buildStudentTile(Map<String, dynamic> student) {
    final grade = Map<String, dynamic>.from(student['grade'] ?? {});
    return ListTile(
      leading: const Icon(Icons.person),
      title: Text(student['name']?.toString() ?? 'Student'),
      subtitle: Text(student['email']?.toString() ?? 'N/A'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            (grade['finalLetterGrade']?.toString() ?? 'Pending').toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: () => _openGradeEditor(student),
            child: const Text('Manage Grades'),
          ),
        ],
      ),
    );
  }

  void _openGradeEditor(Map<String, dynamic> student) {
    final grade = Map<String, dynamic>.from(student['grade'] ?? {});
    final Map<String, TextEditingController> controllers = {
      'midterm': TextEditingController(
        text: _formatGradeValue(grade['midterm']),
      ),
      'project': TextEditingController(
        text: _formatGradeValue(grade['project']),
      ),
      'assignmentsTotal': TextEditingController(
        text: _formatGradeValue(grade['assignmentsTotal']),
      ),
      'quizzesTotal': TextEditingController(
        text: _formatGradeValue(grade['quizzesTotal']),
      ),
      'attendance': TextEditingController(
        text: _formatGradeValue(grade['attendance']),
      ),
      'finalExamMark': TextEditingController(
        text: _formatGradeValue(grade['finalExamMark']),
      ),
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    student['name']?.toString() ?? 'Student',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...controllers.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextField(
                    controller: entry.value,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: entry.key,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await _submitGradeUpdate(
                      student['enrollmentId'] as int,
                      controllers,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save Grades'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitGradeUpdate(
    int enrollmentId,
    Map<String, TextEditingController> controllers,
  ) async {
    final Map<String, dynamic> payload = {};
    controllers.forEach((key, controller) {
      final text = controller.text.trim();
      payload[key] = text.isEmpty ? null : double.tryParse(text);
    });

    final response = await _apiService.updateStudentGrade(
      enrollmentId,
      payload,
    );
    if (mounted) {
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Grades updated')));
        Navigator.of(context).pop();
        _loadCourseDetail();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Update failed')),
        );
      }
    }
  }

  String _formatGradeValue(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }
}
