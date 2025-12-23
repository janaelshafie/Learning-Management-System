import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_services.dart';
import '../../common/app_state.dart';
import 'quiz_taking_screen.dart';
import 'assignment_file_submission_screen.dart';
import 'assignment_taking_screen.dart';

class StudyMaterialsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> currentCourses;

  const StudyMaterialsScreen({super.key, required this.currentCourses});

  @override
  State<StudyMaterialsScreen> createState() => _StudyMaterialsScreenState();
}

class _StudyMaterialsScreenState extends State<StudyMaterialsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Study Materials'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: widget.currentCourses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No courses for current semester',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.currentCourses.length,
              itemBuilder: (context, index) {
                final course = widget.currentCourses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  child: InkWell(
                    onTap: () => _navigateToCourseMaterials(context, course),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E3A8A).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.book,
                              color: Color(0xFF1E3A8A),
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  course['code'] ?? 'N/A',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  course['name'] ?? 'Course Name',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      size: 14,
                                      color: Colors.grey[500],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      course['instructor'] ?? 'Instructor',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 20,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _navigateToCourseMaterials(
    BuildContext context,
    Map<String, dynamic> course,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseMaterialsScreen(course: course),
      ),
    );
  }
}

class CourseMaterialsScreen extends StatefulWidget {
  final Map<String, dynamic> course;

  const CourseMaterialsScreen({super.key, required this.course});

  @override
  State<CourseMaterialsScreen> createState() => _CourseMaterialsScreenState();
}

class _CourseMaterialsScreenState extends State<CourseMaterialsScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;
  bool _isLoading = true;
  List<dynamic> _announcements = [];
  List<dynamic> _materials = [];
  List<dynamic> _quizzes = [];
  List<dynamic> _assignments = [];
  int? _offeredCourseId;
  Map<int, Map<String, dynamic>> _quizSubmissionStatus = {}; // quizId -> {hasAnswers: bool, allGraded: bool}

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCourseData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCourseData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Debug: Print course object keys to see what's available
      print('Study Materials - Course object keys: ${widget.course.keys.toList()}');
      print('Study Materials - Course object: ${widget.course}');
      
      // First, check if offeredCourseId is already in the course object
      if (widget.course['offeredCourseId'] != null) {
        _offeredCourseId = widget.course['offeredCourseId'] is int
            ? widget.course['offeredCourseId']
            : int.tryParse(widget.course['offeredCourseId'].toString());
        print('Found offeredCourseId in course object: $_offeredCourseId');
      } else {
        // If not present, try to get it using courseId and semesterId
        final courseId = widget.course['courseId'] ?? widget.course['course_id'];
        final semesterId = widget.course['semesterId'] ?? widget.course['semester_id'];
        
        print('Looking up offeredCourseId with courseId: $courseId, semesterId: $semesterId');

        if (courseId != null) {
          _offeredCourseId = await _apiService.getOfferedCourseId(
            courseId is int ? courseId : int.parse(courseId.toString()),
            semesterId is int
                ? semesterId
                : (semesterId != null ? int.parse(semesterId.toString()) : null) ?? 1,
          );
          print('Retrieved offeredCourseId from API: $_offeredCourseId');
        } else {
          print('ERROR: courseId is null, cannot lookup offeredCourseId');
        }
      }

      if (_offeredCourseId != null) {
        // Load announcements, materials, quizzes, and assignments
        final results = await Future.wait([
          _apiService.getCourseAnnouncements(_offeredCourseId!),
          _apiService.getCourseMaterials(_offeredCourseId!),
          _apiService.getCourseQuizzes(_offeredCourseId!),
          _apiService.getCourseAssignments(_offeredCourseId!),
        ]);

        print('Loaded ${results[0].length} announcements, ${results[1].length} materials, ${results[2].length} quizzes, ${results[3].length} assignments');

        // Check submission status for each quiz
        final quizzes = results[2];
        await _loadQuizSubmissionStatus(quizzes);

        setState(() {
          _announcements = results[0];
          _materials = results[1];
          _quizzes = quizzes;
          _assignments = results[3];
          _isLoading = false;
        });
      } else {
        print('ERROR: offeredCourseId is null after lookup');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not find course information. Please try again.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading course data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading course data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadQuizSubmissionStatus(List<dynamic> quizzes) async {
    final studentId = currentUserId;
    if (studentId == 0) return;

    final statusMap = <int, Map<String, dynamic>>{};

    for (var quiz in quizzes) {
      final quizId = quiz['quizId'] as int?;
      if (quizId == null) continue;

      try {
        // Get questions for this quiz
        final questionsResponse = await _apiService.getQuestionsForAssessment(
          assessmentType: 'quiz',
          assessmentId: quizId,
        );

        // Get student answers for this quiz
        final answersResponse = await _apiService.getStudentAnswersForAssessment(
          studentId: studentId,
          assessmentType: 'quiz',
          assessmentId: quizId,
        );

        bool hasAnswers = false;
        bool allGraded = false; // Default to false - can't be graded if no answers

        if (answersResponse['status'] == 'success') {
          final answers = answersResponse['answers'] ?? [];
          hasAnswers = answers.isNotEmpty;

          if (hasAnswers && questionsResponse['status'] == 'success') {
            final questions = questionsResponse['questions'] ?? [];
            if (questions.isNotEmpty) {
              final questionIds = questions.map((q) => q['questionId'] as int?).where((id) => id != null).toSet();
              
              // Only check grading status if there are answers
              allGraded = true; // Start with true, set to false if any answer is not graded
              
              // Check if all answered questions are graded
              for (var answer in answers) {
                final questionId = answer['questionId'] as int?;
                if (questionId != null && questionIds.contains(questionId)) {
                  if (answer['grade'] == null) {
                    allGraded = false;
                    break;
                  }
                }
              }
            }
          }
        }

        statusMap[quizId] = {
          'hasAnswers': hasAnswers,
          'allGraded': allGraded,
        };
      } catch (e) {
        print('Error loading submission status for quiz $quizId: $e');
        // Default to allowing access if error
        statusMap[quizId] = {
          'hasAnswers': false,
          'allGraded': false,
        };
      }
    }

    setState(() {
      _quizSubmissionStatus = statusMap;
    });
  }

  bool _isQuizPastDue(Map<String, dynamic> quiz) {
    final dueDateStr = quiz['dueDate']?.toString();
    if (dueDateStr == null || dueDateStr.isEmpty) return false;

    try {
      // Parse due date (format: "yyyy-MM-dd HH:mm:ss" or "yyyy-MM-ddTHH:mm:ss")
      final normalizedDate = dueDateStr.replaceAll('T', ' ').trim();
      final parts = normalizedDate.split(' ');
      if (parts.isEmpty) return false;

      final dateParts = parts[0].split('-');
      if (dateParts.length != 3) return false;

      int hour = 23, minute = 59, second = 59;
      if (parts.length > 1) {
        final timeParts = parts[1].split(':');
        if (timeParts.length >= 2) {
          hour = int.tryParse(timeParts[0]) ?? 23;
          minute = int.tryParse(timeParts[1]) ?? 59;
          if (timeParts.length >= 3) {
            second = int.tryParse(timeParts[2]) ?? 59;
          }
        }
      }

      final dueDate = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        hour,
        minute,
        second,
      );

      return DateTime.now().isAfter(dueDate);
    } catch (e) {
      print('Error parsing due date: $e');
      return false;
    }
  }

  bool _canAccessQuiz(Map<String, dynamic> quiz) {
    final quizId = quiz['quizId'] as int?;
    if (quizId == null) return true;

    final status = _quizSubmissionStatus[quizId];
    final hasAnswers = status?['hasAnswers'] as bool? ?? false;

    // Check if quiz is past due date
    if (_isQuizPastDue(quiz)) {
      // If past due and not submitted, cannot access at all
      if (!hasAnswers) {
        return false;
      }
      // If past due and submitted, can only access if graded (to view results)
      final allGraded = status?['allGraded'] as bool? ?? false;
      return allGraded;
    }

    if (status == null) return true; // If status not loaded yet, allow access

    final allGraded = status['allGraded'] as bool? ?? false;

    // Can access if:
    // 1. Haven't submitted answers yet (can take quiz)
    // 2. OR all answers are graded (can view results)
    return !hasAnswers || allGraded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(widget.course['code'] ?? 'Course Materials'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.folder), text: 'Materials'),
            Tab(icon: Icon(Icons.announcement), text: 'Announcements'),
            Tab(icon: Icon(Icons.assignment), text: 'Quizzes & Assignments'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMaterialsTab(),
                _buildAnnouncementsTab(),
                _buildQuizzesAssignmentsTab(),
              ],
            ),
    );
  }

  Widget _buildAnnouncementsTab() {
    if (_announcements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.announcement_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No announcements yet',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _announcements.length,
      itemBuilder: (context, index) {
        final announcement = _announcements[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A8A).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Announcement',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF1E3A8A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDate(announcement['createdAt']?.toString()),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  announcement['title'] ?? 'No Title',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  announcement['content'] ?? 'No Content',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMaterialsTab() {
    if (_materials.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No course materials uploaded yet',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _materials.length,
      itemBuilder: (context, index) {
        final material = _materials[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: ListTile(
            leading: _getMaterialIcon(material['type']?.toString() ?? 'file'),
            title: Text(
              material['title'] ?? material['fileName'] ?? 'Untitled',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (material['type'] != null)
                  Text(
                    material['type'].toString().toUpperCase(),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                if (material['uploadedAt'] != null)
                  Text(
                    _formatDate(material['uploadedAt'].toString()),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.download),
              onPressed: () => _downloadMaterial(material),
            ),
            onTap: () => _openMaterial(material),
          ),
        );
      },
    );
  }

  Widget _getMaterialIcon(String? type) {
    switch (type?.toLowerCase() ?? 'file') {
      case 'pdf':
        return const Icon(Icons.picture_as_pdf, color: Colors.red, size: 32);
      case 'doc':
      case 'docx':
        return const Icon(Icons.description, color: Colors.blue, size: 32);
      case 'ppt':
      case 'pptx':
        return const Icon(Icons.slideshow, color: Colors.orange, size: 32);
      case 'xls':
      case 'xlsx':
        return const Icon(Icons.table_chart, color: Colors.green, size: 32);
      default:
        return const Icon(Icons.insert_drive_file, color: Colors.grey, size: 32);
    }
  }

  Future<void> _downloadMaterial(Map<String, dynamic> material) async {
    final materialId = material['materialId'];
    if (materialId == null) return;

    try {
      final downloadUrl =
          'http://localhost:8080/api/course/materials/download/$materialId';
      final uri = Uri.parse(downloadUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open download link'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openMaterial(Map<String, dynamic> material) async {
    await _downloadMaterial(material);
  }

  // ========== QUIZZES & ASSIGNMENTS TAB ==========
  Widget _buildQuizzesAssignmentsTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            labelColor: Color(0xFF1E3A8A),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF1E3A8A),
            tabs: [
              Tab(text: 'Quizzes'),
              Tab(text: 'Assignments'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildQuizzesList(),
                _buildAssignmentsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizzesList() {
    return _quizzes.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.quiz_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No quizzes available yet',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _quizzes.length,
            itemBuilder: (context, index) {
              final quiz = _quizzes[index];
              final isPastDue = _isQuizPastDue(quiz);
              final status = _quizSubmissionStatus[quiz['quizId']];
              final isSubmitted = status?['hasAnswers'] == true;
              // Only show as graded if student submitted AND all answers are graded
              final isGraded = (status?['hasAnswers'] == true) && (status?['allGraded'] == true);
              final canAccess = _canAccessQuiz(quiz);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                color: canAccess ? null : Colors.grey[200],
                child: ListTile(
                  leading: Icon(
                    Icons.quiz,
                    color: canAccess ? const Color(0xFF1E3A8A) : Colors.grey,
                  ),
                  title: Text(
                    quiz['title'] ?? 'Untitled Quiz',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: canAccess ? null : Colors.grey[600],
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (quiz['description'] != null)
                        Text(
                          quiz['description'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      const SizedBox(height: 4),
                      if (quiz['dueDate'] != null)
                        Text(
                          'Due: ${_formatDate(quiz['dueDate'].toString())}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      if (quiz['maxGrade'] != null)
                        Text(
                          'Max Grade: ${quiz['maxGrade']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      if (isPastDue && !isGraded) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Past Due Date',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.red[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ] else if (isSubmitted && !isGraded) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Submitted - Waiting for grading',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ] else if (isGraded) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Graded - View Results',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  onTap: canAccess
                      ? () => _showQuizDetails(quiz)
                      : () {
                          String message = 'Quiz is submitted and waiting for instructor grading. You can view results once it is graded.';
                          if (isPastDue) {
                            message = 'Quiz is past due date. You can only view results once it is graded.';
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(message),
                              backgroundColor: isPastDue ? Colors.red : Colors.orange,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        },
                ),
              );
            },
          );
  }

  Widget _buildAssignmentsList() {
    return _assignments.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_outlined,
                    size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No assignments available yet',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _assignments.length,
            itemBuilder: (context, index) {
              final assignment = _assignments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.assignment,
                      color: Color(0xFF1E3A8A)),
                  title: Text(
                    assignment['title'] ?? 'Untitled Assignment',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (assignment['description'] != null)
                        Text(
                          assignment['description'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      const SizedBox(height: 4),
                      if (assignment['dueDate'] != null)
                        Text(
                          'Due: ${_formatDate(assignment['dueDate'].toString())}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      if (assignment['maxGrade'] != null)
                        Text(
                          'Max Grade: ${assignment['maxGrade']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                  onTap: () => _showAssignmentDetails(assignment),
                ),
              );
            },
          );
  }

  void _showQuizDetails(Map<String, dynamic> quiz) {
    // Navigate to quiz taking screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizTakingScreen(
          quiz: quiz,
          offeredCourseId: _offeredCourseId,
        ),
      ),
    ).then((_) => _loadCourseData());
  }

  Future<void> _showAssignmentDetails(Map<String, dynamic> assignment) async {
    // Check if assignment has questions - if yes, use question screen; if no, use file screen
    try {
      final assignmentId = assignment['assignmentId'] as int;
      final questionsResponse = await _apiService.getQuestionsForAssessment(
        assessmentType: 'assignment',
        assessmentId: assignmentId,
      );

      bool hasQuestions = false;
      if (questionsResponse['status'] == 'success') {
        final questions = questionsResponse['questions'] ?? [];
        hasQuestions = questions.isNotEmpty;
      }

      // Also check if assignment has a question file
      final questionFileResponse = await _apiService.getAssignmentQuestionFileInfo(assignmentId);
      bool hasQuestionFile = questionFileResponse['status'] == 'success';

      if (hasQuestions) {
        // Navigate to assignment taking screen (question-based, reusing quiz logic)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AssignmentTakingScreen(
              assignment: assignment,
              offeredCourseId: _offeredCourseId,
            ),
          ),
        ).then((_) => _loadCourseData());
      } else if (hasQuestionFile) {
        // Navigate to file submission screen (for file-based assignments)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AssignmentFileSubmissionScreen(
              assignment: assignment,
              offeredCourseId: _offeredCourseId,
            ),
          ),
        ).then((_) => _loadCourseData());
      } else {
        // No questions and no file - show message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Assignment not configured yet. Please contact your instructor.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      // On error, try file submission screen as fallback
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AssignmentFileSubmissionScreen(
            assignment: assignment,
            offeredCourseId: _offeredCourseId,
          ),
        ),
      ).then((_) => _loadCourseData());
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Unknown date';
    try {
      final dateTime = DateTime.parse(dateString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}
