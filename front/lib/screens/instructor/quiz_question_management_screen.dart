import 'package:flutter/material.dart';
import '../../services/api_services.dart';
import 'assignment_file_management_screen.dart';

class QuizQuestionManagementScreen extends StatefulWidget {
  final Map<String, dynamic> quiz; // Can be quiz or assignment
  final int instructorId;
  final String assessmentType; // 'quiz' or 'assignment'

  const QuizQuestionManagementScreen({
    super.key,
    required this.quiz,
    required this.instructorId,
    this.assessmentType = 'quiz', // Default to 'quiz' for backward compatibility
  });

  @override
  State<QuizQuestionManagementScreen> createState() =>
      _QuizQuestionManagementScreenState();
}

class _QuizQuestionManagementScreenState
    extends State<QuizQuestionManagementScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;
  bool _isLoading = true;
  
  List<dynamic> _questions = [];
  List<dynamic> _studentAnswers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadQuestions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);
    try {
      final assessmentId = widget.quiz[widget.assessmentType == 'quiz' ? 'quizId' : 'assignmentId'] as int;
      final response = await _apiService.getQuestionsForAssessment(
        assessmentType: widget.assessmentType,
        assessmentId: assessmentId,
      );
      
      if (mounted) {
        if (response['status'] == 'success') {
          setState(() {
            _questions = response['questions'] ?? [];
            _isLoading = false;
          });
        } else {
          setState(() {
            _questions = [];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading questions: $e')),
        );
      }
    }
  }

  Future<void> _loadStudentAnswers() async {
    try {
      final assessmentId = widget.quiz[widget.assessmentType == 'quiz' ? 'quizId' : 'assignmentId'] as int;
      final response = await _apiService.getAnswersForAssessment(
        assessmentType: widget.assessmentType,
        assessmentId: assessmentId,
      );
      
      if (mounted && response['status'] == 'success') {
        setState(() {
          _studentAnswers = response['answers'] ?? [];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading answers: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz['title'] ?? '${widget.assessmentType == 'quiz' ? 'Quiz' : 'Assignment'} Questions'),
        backgroundColor: const Color(0xFF1E3A8A),
        actions: widget.assessmentType == 'assignment' ? [
          // Add button to switch to file-based mode
          IconButton(
            icon: const Icon(Icons.description),
            tooltip: 'Upload Question File',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AssignmentFileManagementScreen(
                    assignment: widget.quiz,
                    instructorId: widget.instructorId,
                  ),
                ),
              ).then((_) => Navigator.pop(context)); // Pop question screen after navigating
            },
          ),
        ] : null,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.normal,
          ),
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Questions', icon: Icon(Icons.quiz, size: 24)),
            Tab(text: 'Student Answers', icon: Icon(Icons.grading, size: 24)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildQuestionsTab(),
                _buildAnswersTab(),
              ],
            ),
    );
  }

  Widget _buildQuestionsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () => _showAddQuestionDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Question'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
        Expanded(
          child: _questions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.quiz_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No questions added yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    final question = _questions[index];
                    return _buildQuestionCard(question, index);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question, int index) {
    final questionType = question['questionType'] ?? '';
    final questionText = question['questionText'] ?? '';
    final maxMarks = question['maxMarks'] ?? 0.0;

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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getQuestionTypeColor(questionType),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    questionType,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${maxMarks} marks',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _showEditQuestionDialog(question),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => _deleteQuestion(question),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Q${index + 1}: $questionText',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (questionType == 'MCQ' && question['options'] != null) ...[
              const SizedBox(height: 8),
              ...(question['options'] as List).asMap().entries.map((entry) {
                final optionIndex = entry.key;
                final option = entry.value;
                final isCorrect = question['correctAnswer'] != null &&
                    question['correctAnswer'].toString() == optionIndex.toString();
                return Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Row(
                    children: [
                      Text(
                        '${String.fromCharCode(65 + optionIndex)}. ',
                        style: TextStyle(
                          fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                          color: isCorrect ? Colors.green : Colors.black,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          option.toString(),
                          style: TextStyle(
                            fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                            color: isCorrect ? Colors.green : Colors.black,
                          ),
                        ),
                      ),
                      if (isCorrect)
                        const Icon(Icons.check_circle, color: Colors.green, size: 16),
                    ],
                  ),
                );
              }),
            ] else if (questionType == 'TRUE_FALSE') ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  'Correct Answer: ${question['correctAnswer'] ?? 'N/A'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ] else if (questionType == 'SHORT_TEXT') ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  'Expected Answer: ${question['correctAnswer'] ?? 'N/A'}',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getQuestionTypeColor(String type) {
    switch (type) {
      case 'MCQ':
        return Colors.blue;
      case 'TRUE_FALSE':
        return Colors.orange;
      case 'SHORT_TEXT':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildAnswersTab() {
    // Extract unique student IDs from answers
    final studentIds = <int>{};
    final studentAnswerMap = <int, List<dynamic>>{}; // studentId -> list of answers
    
    for (var answer in _studentAnswers) {
      final studentId = answer['studentId'] as int?;
      if (studentId != null) {
        studentIds.add(studentId);
        if (!studentAnswerMap.containsKey(studentId)) {
          studentAnswerMap[studentId] = [];
        }
        studentAnswerMap[studentId]!.add(answer);
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () {
              _loadStudentAnswers();
              _loadQuestions();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh Answers'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: studentIds.isEmpty
              ? const Center(
                  child: Text('No student answers submitted yet'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: studentIds.length,
                  itemBuilder: (context, index) {
                    final studentId = studentIds.elementAt(index);
                    final studentAnswers = studentAnswerMap[studentId] ?? [];
                    final gradedCount = studentAnswers.where((ans) => ans['grade'] != null).length;
                    final totalCount = studentAnswers.length;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      child: ListTile(
                        leading: const Icon(Icons.person, color: Colors.blue),
                        title: Text(
                          'Student ID: $studentId',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Answered: $totalCount question(s) | Graded: $gradedCount/$totalCount',
                        ),
                        trailing: gradedCount < totalCount
                            ? const Icon(Icons.warning, color: Colors.orange)
                            : const Icon(Icons.check_circle, color: Colors.green),
                        onTap: () => _showStudentAnswers(studentId, studentAnswers),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _showStudentAnswers(int studentId, List<dynamic> studentAnswers) async {
    // Auto-grade MCQ and TRUE_FALSE questions first
    await _autoGradeAnswers(studentAnswers);

    // Reload answers to get updated grades
    await _loadStudentAnswers();

    // Show dialog with all questions and student's answers
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Get updated answers
          final updatedAnswerMap = <int, dynamic>{};
          for (var ans in _studentAnswers) {
            if (ans['studentId'] == studentId) {
              final questionId = ans['questionId'] as int?;
              if (questionId != null) {
                updatedAnswerMap[questionId] = ans;
              }
            }
          }

          return Dialog(
            insetPadding: const EdgeInsets.all(16),
            child: Container(
              width: double.maxFinite,
              constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
              child: Column(
                children: [
                  AppBar(
                    title: Text('Student ID: $studentId'),
                    automaticallyImplyLeading: false,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: _questions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final question = entry.value as Map<String, dynamic>;
                        final questionId = question['questionId'] as int;
                        final answer = updatedAnswerMap[questionId];
                        return _buildStudentQuestionAnswerCard(question, index + 1, answer, setDialogState);
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStudentQuestionAnswerCard(Map<String, dynamic> question, int questionNumber, dynamic answer, StateSetter? setDialogState) {
    final questionType = question['questionType'] ?? '';
    final correctAnswer = question['correctAnswer'];
    final grade = answer?['grade'];
    final feedback = answer?['feedback'];
    
    String studentAnswerText = 'No answer submitted';
    if (answer != null) {
      if (questionType == 'MCQ') {
        final selectedIndex = answer['selectedOption'];
        if (selectedIndex != null && question['options'] != null) {
          final options = question['options'] as List;
          final index = int.tryParse(selectedIndex.toString());
          if (index != null && index >= 0 && index < options.length) {
            studentAnswerText = options[index].toString();
          } else {
            studentAnswerText = 'Option $selectedIndex';
          }
        }
      } else if (questionType == 'TRUE_FALSE' || questionType == 'SHORT_TEXT') {
        studentAnswerText = answer['answer']?.toString() ?? 'No answer';
      }
    }

    String correctAnswerText = 'N/A';
    if (correctAnswer != null) {
      if (questionType == 'MCQ' && question['options'] != null) {
        final options = question['options'] as List;
        final index = int.tryParse(correctAnswer.toString());
        if (index != null && index >= 0 && index < options.length) {
          correctAnswerText = options[index].toString();
        } else {
          correctAnswerText = correctAnswer.toString();
        }
      } else {
        correctAnswerText = correctAnswer.toString();
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getQuestionTypeColor(questionType),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    questionType,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (grade != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Grade: $grade / ${question['maxMarks'] ?? 0}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Not Graded',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Q$questionNumber: ${question['questionText'] ?? ''}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Student's Answer
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Student\'s Answer:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(studentAnswerText),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Correct Answer
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Correct Answer:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    correctAnswerText,
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),
            if (feedback != null && feedback.toString().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Feedback:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(feedback.toString()),
                  ],
                ),
              ),
            ],
            if (answer != null && grade == null && questionType == 'SHORT_TEXT') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await _gradeAnswerWithRightWrong(answer, question, true);
                        if (setDialogState != null && mounted) {
                          await _loadStudentAnswers();
                          setDialogState(() {}); // Refresh the dialog
                        }
                      },
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text('Right Answer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await _gradeAnswerWithRightWrong(answer, question, false);
                        if (setDialogState != null && mounted) {
                          // Reload answers to get updated grades
                          await _loadStudentAnswers();
                          setDialogState(() {}); // Refresh the dialog - will rebuild with updated answers
                        }
                      },
                      icon: const Icon(Icons.close, color: Colors.white),
                      label: const Text('Wrong Answer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStudentAnswerCard(Map<String, dynamic> answer, Map<String, dynamic> question) {
    final questionType = question['questionType'] ?? '';
    final studentAnswer = _getStudentAnswerText(answer, questionType);
    final grade = answer['grade'];
    final feedback = answer['feedback'];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Student ID: ${answer['studentId']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (grade != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Grade: $grade',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  const Text(
                    'Not Graded',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Answer: $studentAnswer'),
            if (feedback != null && feedback.toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Feedback: $feedback',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700],
                ),
              ),
            ],
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _showGradeAnswerDialog(answer, question),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Grade Answer'),
            ),
          ],
        ),
      ),
    );
  }

  String _getStudentAnswerText(Map<String, dynamic> answer, String questionType) {
    if (questionType == 'MCQ') {
      return answer['selectedOption']?.toString() ?? 'No answer';
    } else if (questionType == 'TRUE_FALSE') {
      return answer['answer']?.toString() ?? 'No answer';
    } else if (questionType == 'SHORT_TEXT') {
      return answer['answer']?.toString() ?? 'No answer';
    }
    return 'No answer';
  }

  Future<void> _showAddQuestionDialog() async {
    String? selectedType;
    final questionTextController = TextEditingController();
    final maxMarksController = TextEditingController(text: '1.0');
    final correctAnswerController = TextEditingController();
    final List<TextEditingController> optionControllers = [];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Question'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Question Type',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedType,
                    items: const [
                      DropdownMenuItem(value: 'MCQ', child: Text('MCQ')),
                      DropdownMenuItem(value: 'TRUE_FALSE', child: Text('True/False')),
                      DropdownMenuItem(value: 'SHORT_TEXT', child: Text('Complete/Fill in Blank')),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        selectedType = value;
                        if (value == 'MCQ') {
                          optionControllers.clear();
                          for (int i = 0; i < 4; i++) {
                            optionControllers.add(TextEditingController());
                          }
                        } else {
                          optionControllers.clear();
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: questionTextController,
                    decoration: const InputDecoration(
                      labelText: 'Question Text',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: maxMarksController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Max Marks',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (selectedType == 'MCQ') ...[
                    const SizedBox(height: 16),
                    const Text('Options:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...optionControllers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final controller = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            labelText: 'Option ${String.fromCharCode(65 + index)}',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    TextField(
                      controller: correctAnswerController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Correct Answer (Index: 0, 1, 2, 3...)',
                        border: OutlineInputBorder(),
                        hintText: 'Enter the index of the correct option',
                      ),
                    ),
                  ] else if (selectedType == 'TRUE_FALSE') ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Correct Answer',
                        border: OutlineInputBorder(),
                      ),
                      value: correctAnswerController.text.isEmpty ? null : correctAnswerController.text,
                      items: const [
                        DropdownMenuItem(value: 'true', child: Text('True')),
                        DropdownMenuItem(value: 'false', child: Text('False')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          correctAnswerController.text = value;
                        }
                      },
                    ),
                  ] else if (selectedType == 'SHORT_TEXT') ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: correctAnswerController,
                      decoration: const InputDecoration(
                        labelText: 'Expected Answer (Optional)',
                        border: OutlineInputBorder(),
                        hintText: 'Expected answer for reference',
                      ),
                    ),
                  ],
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
                if (selectedType == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a question type')),
                  );
                  return;
                }
                if (questionTextController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter question text')),
                  );
                  return;
                }

                if (selectedType == 'MCQ') {
                  final options = optionControllers
                      .map((c) => c.text.trim())
                      .where((text) => text.isNotEmpty)
                      .toList();
                  if (options.length < 2) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter at least 2 options')),
                    );
                    return;
                  }
                  if (correctAnswerController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter correct answer index')),
                    );
                    return;
                  }
                } else if (selectedType == 'TRUE_FALSE') {
                  if (correctAnswerController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select correct answer')),
                    );
                    return;
                  }
                }

                Navigator.of(context).pop();
                await _createQuestion(
                  selectedType!,
                  questionTextController.text.trim(),
                  double.tryParse(maxMarksController.text) ?? 1.0,
                  optionControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList(),
                  correctAnswerController.text.trim(),
                );
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createQuestion(
    String questionType,
    String questionText,
    double maxMarks,
    List<String> options,
    String correctAnswer,
  ) async {
    try {
      final assessmentId = widget.quiz[widget.assessmentType == 'quiz' ? 'quizId' : 'assignmentId'] as int;
      final questionOrder = _questions.length;

      Map<String, dynamic>? result;
      
      if (questionType == 'MCQ') {
        result = await _apiService.createQuestion(
          assessmentType: widget.assessmentType,
          assessmentId: assessmentId,
          questionText: questionText,
          questionType: questionType,
          questionOrder: questionOrder,
          maxMarks: maxMarks,
          options: options,
          correctAnswer: int.tryParse(correctAnswer) ?? 0,
        );
      } else {
        result = await _apiService.createQuestion(
          assessmentType: widget.assessmentType,
          assessmentId: assessmentId,
          questionText: questionText,
          questionType: questionType,
          questionOrder: questionOrder,
          maxMarks: maxMarks,
          correctAnswer: questionType == 'TRUE_FALSE' ? correctAnswer : correctAnswer,
        );
      }

      if (mounted) {
        if (result['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Question added successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadQuestions();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Error adding question'),
                backgroundColor: Colors.red,
              ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _showEditQuestionDialog(Map<String, dynamic> question) async {
    // Similar to add dialog but pre-filled
    // For brevity, implementing delete first, edit can be added similarly
    _showAddQuestionDialog(); // TODO: Implement proper edit dialog
  }

  Future<void> _deleteQuestion(Map<String, dynamic> question) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Question'),
        content: const Text('Are you sure you want to delete this question?'),
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
      try {
        final result = await _apiService.deleteQuestion(question['questionId'] as int);
        if (mounted) {
          if (result['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Question deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
            _loadQuestions();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Error deleting question'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _gradeAnswerWithRightWrong(Map<String, dynamic> answer, Map<String, dynamic> question, bool isCorrect) async {
    final questionType = question['questionType'] ?? '';
    final maxMarks = (question['maxMarks'] as num?)?.toDouble() ?? 0.0;
    final studentAnswerId = answer['studentAnswerId'] as int;

    double grade;
    if (isCorrect) {
      grade = maxMarks; // Full marks for correct answer
    } else {
      grade = 0.0; // Zero for wrong answer
    }

    // Auto-grade MCQ and True/False questions (should already be graded, but just in case)
    if (questionType == 'MCQ' || questionType == 'TRUE_FALSE') {
      // Check if student answer matches correct answer
      final correctAnswer = question['correctAnswer']?.toString();
      bool isAutoCorrect = false;

      if (questionType == 'MCQ') {
        final selectedOption = answer['selectedOption']?.toString();
        isAutoCorrect = selectedOption == correctAnswer;
      } else if (questionType == 'TRUE_FALSE') {
        final studentAnswer = answer['answer']?.toString().toLowerCase();
        isAutoCorrect = studentAnswer == correctAnswer?.toLowerCase();
      }

      // Use auto-graded result
      grade = isAutoCorrect ? maxMarks : 0.0;
    }

    await _saveGrade(studentAnswerId, grade, null);
  }

  Future<void> _saveGrade(int studentAnswerId, double grade, String? feedback) async {
    try {
      final result = await _apiService.gradeAnswer(
        studentAnswerId: studentAnswerId,
        grade: grade,
        feedback: feedback,
      );

      if (mounted) {
        if (result['status'] == 'success') {
          // Don't show snackbar for auto-grading to avoid spam
          await _loadStudentAnswers();
          await _loadQuestions();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Error grading answer'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _autoGradeAnswers(List<dynamic> studentAnswers) async {
    for (var answer in studentAnswers) {
      final questionId = answer['questionId'] as int?;
      if (questionId == null || answer['grade'] != null) continue; // Skip if already graded

      // Find the question
      final question = _questions.firstWhere(
        (q) => q['questionId'] == questionId,
        orElse: () => {},
      );

      if (question.isEmpty) continue;

      final questionType = question['questionType'] ?? '';
      if (questionType != 'MCQ' && questionType != 'TRUE_FALSE') continue;

      final maxMarks = (question['maxMarks'] as num?)?.toDouble() ?? 0.0;
      final correctAnswer = question['correctAnswer']?.toString();
      bool isCorrect = false;

      if (questionType == 'MCQ') {
        final selectedOption = answer['selectedOption']?.toString();
        isCorrect = selectedOption == correctAnswer;
      } else if (questionType == 'TRUE_FALSE') {
        final studentAnswer = answer['answer']?.toString().toLowerCase();
        isCorrect = studentAnswer == correctAnswer?.toLowerCase();
      }

      final grade = isCorrect ? maxMarks : 0.0;
      await _saveGrade(answer['studentAnswerId'] as int, grade, null);
    }
  }

  Future<List<dynamic>> _loadStudentAnswersForDialog(int studentId) async {
    try {
      final assessmentId = widget.quiz[widget.assessmentType == 'quiz' ? 'quizId' : 'assignmentId'] as int;
      final response = await _apiService.getAnswersForAssessment(
        assessmentType: widget.assessmentType,
        assessmentId: assessmentId,
      );
      if (response['status'] == 'success') {
        final allAnswers = response['answers'] ?? [];
        return allAnswers.where((ans) => ans['studentId'] == studentId).toList();
      }
    } catch (e) {
      print('Error loading answers: $e');
    }
    return [];
  }

  Future<void> _showGradeAnswerDialog(Map<String, dynamic>? answer, Map<String, dynamic> question) async {
    if (answer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No answer found to grade')),
      );
      return;
    }
    
    final gradeController = TextEditingController(
      text: answer['grade']?.toString() ?? '',
    );
    final feedbackController = TextEditingController(
      text: answer['feedback']?.toString() ?? '',
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Grade Answer'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Question: ${question['questionText']}'),
                const SizedBox(height: 16),
                Text('Student Answer: ${_getStudentAnswerText(answer, question['questionType'] ?? '')}'),
                const SizedBox(height: 16),
                TextField(
                  controller: gradeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Grade (Max: ${question['maxMarks'] ?? 0})',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: feedbackController,
                  decoration: const InputDecoration(
                    labelText: 'Feedback (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
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
              final grade = double.tryParse(gradeController.text);
              if (grade == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid grade')),
                );
                return;
              }

              Navigator.of(context).pop();
              await _gradeAnswer(
                answer['studentAnswerId'] as int,
                grade,
                feedbackController.text.trim(),
              );
            },
            child: const Text('Save Grade'),
          ),
        ],
      ),
    );
  }

  Future<void> _gradeAnswer(int studentAnswerId, double grade, String feedback) async {
    try {
      final result = await _apiService.gradeAnswer(
        studentAnswerId: studentAnswerId,
        grade: grade,
        feedback: feedback.isEmpty ? null : feedback,
      );

      if (mounted) {
        if (result['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Answer graded successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
          await _loadStudentAnswers();
          await _loadQuestions();
          // Close the student answers dialog and reload to show updated grades
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Error grading answer'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

