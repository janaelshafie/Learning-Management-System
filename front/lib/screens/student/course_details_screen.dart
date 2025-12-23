import 'package:flutter/material.dart';

class CourseDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> course;

  const CourseDetailsScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    // Extract marks data - if available
    Map<String, dynamic> marks = course['marks'] ?? {};

    // Get marks from database
    Object? midtermValue = marks['midterm'];
    Object? projectValue = marks['project'];
    Object? assignmentsValue = marks['assignments_total'];
    Object? quizzesValue = marks['quizzes_total'];
    Object? attendanceValue = marks['attendance'];
    String? finalLetterGrade = marks['final_letter_grade'];

    // Convert to double if available (null if field is null in DB)
    double? midterm = _convertToDouble(midtermValue);
    double? project = _convertToDouble(projectValue);
    double? assignmentsTotal = _convertToDouble(assignmentsValue);
    double? quizzesTotal = _convertToDouble(quizzesValue);
    double? attendance = _convertToDouble(attendanceValue);

    // Check if marks data exists in the database
    bool hasMarksData = marks.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(course['code'] ?? course['courseCode'] ?? 'Course Details'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Header
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E3A8A).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            course['code'] ?? course['courseCode'] ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.school,
                          size: 40,
                          color: const Color(0xFF1E3A8A).withOpacity(0.3),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      course['name'] ?? course['courseTitle'] ?? 'Course Name',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      course['description'] ?? 'No description available',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildInfoChip(
                            Icons.credit_card,
                            '${course['credits'] ?? 0} Credits'),
                        const SizedBox(width: 12),
                        _buildInfoChip(Icons.calendar_today,
                            course['semester'] ?? 'Unknown'),
                        if (course['grade'] != null) ...[
                          const SizedBox(width: 12),
                          _buildInfoChip(
                              Icons.grade, 'Grade: ${course['grade']}'),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Marks Section
            const Text(
              'Marks & Grades',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 16),

            if (!hasMarksData)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Marks not yet uploaded',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your instructor will upload marks once available',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else ...[
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Marks displayed next to each other
                      Row(
                        children: [
                          _buildMarkCard('Midterm', midterm, 20),
                          const SizedBox(width: 12),
                          _buildMarkCard('Project', project, 20),
                          const SizedBox(width: 12),
                          _buildMarkCard('Assignments', assignmentsTotal, 10),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildMarkCard('Quizzes', quizzesTotal, 5),
                          const SizedBox(width: 12),
                          _buildMarkCard('Attendance', attendance, 5),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Final Grade
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _getGradeColor(finalLetterGrade)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getGradeColor(finalLetterGrade),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Final Grade:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              finalLetterGrade ?? '-',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: _getGradeColor(finalLetterGrade),
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
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkCard(String label, double? value, int maxPoints) {
    String displayValue;
    if (value != null) {
      displayValue = '${value.toStringAsFixed(1)}/$maxPoints';
    } else {
      displayValue = '-/$maxPoints';
    }

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              displayValue,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getGradeColor(String? grade) {
    if (grade == null) return Colors.grey;

    switch (grade.toUpperCase()) {
      case 'A':
      case 'A+':
        return Colors.green;
      case 'A-':
      case 'B+':
        return Colors.lightGreen;
      case 'B':
        return Colors.orange;
      case 'B-':
      case 'C+':
        return Colors.deepOrange;
      case 'C':
      case 'C-':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Helper method to convert Object to double
  double? _convertToDouble(Object? value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
