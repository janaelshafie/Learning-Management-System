import 'package:flutter/material.dart';
import '../../services/api_services.dart';
import '../../common/app_state.dart';

// For now, we'll create a wrapper that uses the quiz taking screen logic
// Since assignments use the same question/answer system, we can reuse the quiz screen
class AssignmentTakingScreen extends StatefulWidget {
  final Map<String, dynamic> assignment;
  final int? offeredCourseId;

  const AssignmentTakingScreen({
    super.key,
    required this.assignment,
    this.offeredCourseId,
  });

  @override
  State<AssignmentTakingScreen> createState() => _AssignmentTakingScreenState();
}

class _AssignmentTakingScreenState extends State<AssignmentTakingScreen> {
  // Reuse the QuizTakingScreen logic by passing assignment data with assessmentType
  @override
  Widget build(BuildContext context) {
    // Convert assignment to quiz-like format and use QuizTakingScreen
    // But we need to make QuizTakingScreen generic first
    // For now, we'll create a similar screen structure
    return _AssignmentTakingContent(
      assignment: widget.assignment,
      offeredCourseId: widget.offeredCourseId,
    );
  }
}

// Temporary solution: We'll make QuizTakingScreen generic in the next step
// For now, create a copy that works for assignments
class _AssignmentTakingContent extends StatefulWidget {
  final Map<String, dynamic> assignment;
  final int? offeredCourseId;

  const _AssignmentTakingContent({
    required this.assignment,
    this.offeredCourseId,
  });

  @override
  State<_AssignmentTakingContent> createState() => _AssignmentTakingContentState();
}

class _AssignmentTakingContentState extends State<_AssignmentTakingContent> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _showResults = false;
  bool _isAssignmentFinished = false;

  List<dynamic> _questions = [];
  Map<int, dynamic> _answers = {};
  Map<int, dynamic> _studentAnswers = {};

  @override
  void initState() {
    super.initState();
    _initializeAssignment();
  }

  Future<void> _initializeAssignment() async {
    await _checkDueDate();
    if (mounted) {
      await _loadQuestions();
      await _loadStudentAnswers();
    }
  }

  bool _isPastDueDate() {
    final dueDateStr = widget.assignment['dueDate']?.toString();
    if (dueDateStr == null || dueDateStr.isEmpty) return false;

    try {
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

  Future<void> _checkDueDate() async {
    if (_isPastDueDate()) {
      final assignmentId = widget.assignment['assignmentId'] as int;
      final studentId = currentUserId;
      if (studentId == 0) {
        Navigator.of(context).pop();
        return;
      }

      try {
        final response = await _apiService.getStudentAnswersForAssessment(
          studentId: studentId,
          assessmentType: 'assignment',
          assessmentId: assignmentId,
        );

        bool hasAnswers = false;
        if (response['status'] == 'success') {
          final answers = response['answers'] ?? [];
          hasAnswers = answers.isNotEmpty;
        }

        if (!hasAnswers) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Assignment is past due date. You cannot submit it anymore.'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                ),
              );
              Navigator.of(context).pop();
            }
          });
        }
      } catch (e) {
        print('Error checking answers: $e');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    }
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);
    try {
      final assignmentId = widget.assignment['assignmentId'] as int;
      final response = await _apiService.getQuestionsForAssessment(
        assessmentType: 'assignment',
        assessmentId: assignmentId,
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
      final assignmentId = widget.assignment['assignmentId'] as int;
      final studentId = currentUserId;
      if (studentId == 0) return;

      final response = await _apiService.getStudentAnswersForAssessment(
        studentId: studentId,
        assessmentType: 'assignment',
        assessmentId: assignmentId,
      );

      if (mounted && response['status'] == 'success') {
        final answers = response['answers'] ?? [];
        final answersMap = <int, dynamic>{};
        for (var answer in answers) {
          final questionId = answer['questionId'] as int?;
          if (questionId != null) {
            answersMap[questionId] = answer;
          }
        }
        bool allGraded = false;
        if (answersMap.isNotEmpty) {
          allGraded = answersMap.values.every((answer) => answer['grade'] != null);
        }

        setState(() {
          _studentAnswers = answersMap;
          if (answersMap.isNotEmpty) {
            _showResults = allGraded || _isAssignmentFinished;
          }
        });
      }
    } catch (e) {
      print('Error loading student answers: $e');
    }
  }

  Future<void> _submitAnswer(int questionId, String questionType, dynamic answer) async {
    final studentId = currentUserId;
    if (studentId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    try {
      Map<String, dynamic>? result;
      if (questionType == 'MCQ') {
        result = await _apiService.submitAnswer(
          studentId: studentId,
          questionId: questionId,
          questionType: questionType,
          selectedOption: answer,
        );
      } else {
        result = await _apiService.submitAnswer(
          studentId: studentId,
          questionId: questionId,
          questionType: questionType,
          answer: answer.toString(),
        );
      }

      if (mounted) {
        if (result['status'] == 'success') {
          setState(() {
            _answers[questionId] = answer;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Answer saved'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Error saving answer'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.assignment['title'] ?? 'Assignment'),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _questions.isEmpty
              ? const Center(child: Text('No questions available'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (_showResults) ...[
                      _buildTotalGradeCard(),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                    ] else ...[
                      Text(
                        widget.assignment['description'] ?? '',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                    ],
                    ..._questions.asMap().entries.map((entry) {
                      final index = entry.key;
                      final question = entry.value as Map<String, dynamic>;
                      return _buildQuestionCard(question, index + 1);
                    }),
                    if (!_showResults) ...[
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting || _isAssignmentFinished
                              ? null
                              : () async {
                                  setState(() {
                                    _isAssignmentFinished = true;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Assignment submitted successfully. You can view results once it is graded.'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  await Future.delayed(const Duration(milliseconds: 500));
                                  if (mounted) {
                                    Navigator.of(context).pop();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(_isAssignmentFinished ? 'Assignment Finished' : 'Submit Assignment'),
                        ),
                      ),
                    ],
                  ],
                ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question, int questionNumber) {
    final questionId = question['questionId'] as int;
    final questionType = question['questionType'] ?? '';
    final questionText = question['questionText'] ?? '';
    final studentAnswer = _studentAnswers[questionId];
    final isGraded = studentAnswer != null && studentAnswer['grade'] != null;

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
                if (isGraded) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Grade: ${studentAnswer['grade']} / ${question['maxMarks'] ?? 0}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Q$questionNumber: $questionText',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_showResults)
              _buildResultsView(question, studentAnswer)
            else if (!_isAssignmentFinished)
              _buildAnswerInput(question, questionId, false)
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'Assignment submitted. Waiting for grading.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              ),
            if (isGraded && studentAnswer['feedback'] != null && studentAnswer['feedback'].toString().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Instructor Feedback:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(studentAnswer['feedback'].toString()),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerInput(Map<String, dynamic> question, int questionId, bool isDisabled) {
    final questionType = question['questionType'] ?? '';
    final currentAnswer = _answers[questionId] ?? _studentAnswers[questionId]?['selectedOption'] ?? 
                          _studentAnswers[questionId]?['answer'];

    if (questionType == 'MCQ') {
      final options = question['options'] as List? ?? [];
      return Column(
        children: options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value.toString();
          final isSelected = currentAnswer?.toString() == index.toString() || 
                           currentAnswer?.toString() == option;
          return RadioListTile<int>(
            title: Text(option),
            value: index,
            groupValue: isSelected ? index : null,
            onChanged: isDisabled ? null : (value) {
              if (value != null) {
                setState(() {
                  _answers[questionId] = value;
                });
                _submitAnswer(questionId, questionType, value);
              }
            },
          );
        }).toList(),
      );
    } else if (questionType == 'TRUE_FALSE') {
      final currentBoolAnswer = currentAnswer?.toString().toLowerCase() == 'true';
      return Column(
        children: [
          RadioListTile<bool>(
            title: const Text('True'),
            value: true,
            groupValue: currentBoolAnswer ? true : null,
            onChanged: isDisabled ? null : (value) {
              if (value != null) {
                setState(() {
                  _answers[questionId] = 'true';
                });
                _submitAnswer(questionId, questionType, 'true');
              }
            },
          ),
          RadioListTile<bool>(
            title: const Text('False'),
            value: false,
            groupValue: currentBoolAnswer == false ? false : null,
            onChanged: isDisabled ? null : (value) {
              if (value != null) {
                setState(() {
                  _answers[questionId] = 'false';
                });
                _submitAnswer(questionId, questionType, 'false');
              }
            },
          ),
        ],
      );
    } else if (questionType == 'SHORT_TEXT') {
      final controller = TextEditingController(text: currentAnswer?.toString() ?? '');
      return TextField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'Your Answer',
          border: OutlineInputBorder(),
          hintText: 'Type your answer here...',
        ),
        maxLines: 3,
        enabled: !isDisabled,
        onChanged: isDisabled ? null : (value) {
          setState(() {
            _answers[questionId] = value;
          });
          Future.delayed(const Duration(seconds: 2), () {
            if (_answers[questionId] == value) {
              _submitAnswer(questionId, questionType, value);
            }
          });
        },
      );
    }

    return const SizedBox();
  }

  Widget _buildTotalGradeCard() {
    double totalGrade = 0.0;
    double maxGrade = 0.0;

    for (var question in _questions) {
      final questionId = question['questionId'] as int;
      final studentAnswer = _studentAnswers[questionId];
      final maxMarks = (question['maxMarks'] as num?)?.toDouble() ?? 0.0;
      maxGrade += maxMarks;
      if (studentAnswer != null && studentAnswer['grade'] != null) {
        totalGrade += (studentAnswer['grade'] as num).toDouble();
      }
    }

    return Card(
      color: const Color(0xFF1E3A8A),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star, color: Colors.white, size: 32),
            const SizedBox(width: 16),
            Column(
              children: [
                const Text(
                  'Your Grade',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$totalGrade / $maxGrade',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsView(Map<String, dynamic> question, Map<String, dynamic>? studentAnswer) {
    if (studentAnswer == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('No answer submitted'),
      );
    }

    final questionType = question['questionType'] ?? '';
    final studentAnswerText = _getStudentAnswerText(studentAnswer, questionType, question);
    final correctAnswerText = _getCorrectAnswerText(question, questionType);
    final isCorrect = _isAnswerCorrect(question, studentAnswer, questionType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isCorrect ? Colors.green[50] : Colors.red[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isCorrect ? Colors.green : Colors.red,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    color: isCorrect ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Your Answer:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isCorrect ? Colors.green[900] : Colors.red[900],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                studentAnswerText.isEmpty ? 'No answer' : studentAnswerText,
                style: TextStyle(
                  fontSize: 16,
                  color: isCorrect ? Colors.green[900] : Colors.red[900],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'Correct Answer:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                correctAnswerText.isEmpty ? 'N/A' : correctAnswerText,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getStudentAnswerText(Map<String, dynamic> answer, String questionType, Map<String, dynamic> question) {
    if (questionType == 'MCQ') {
      final selectedIndex = answer['selectedOption']?.toString();
      if (selectedIndex != null && question['options'] != null) {
        final options = question['options'] as List;
        final index = int.tryParse(selectedIndex);
        if (index != null && index >= 0 && index < options.length) {
          return options[index].toString();
        }
      }
      return selectedIndex?.toString() ?? 'No answer';
    } else if (questionType == 'TRUE_FALSE' || questionType == 'SHORT_TEXT') {
      return answer['answer']?.toString() ?? 'No answer';
    }
    return 'No answer';
  }

  String _getCorrectAnswerText(Map<String, dynamic> question, String questionType) {
    final correctAnswer = question['correctAnswer']?.toString();
    if (correctAnswer == null || correctAnswer.isEmpty) return '';

    if (questionType == 'MCQ') {
      if (question['options'] != null) {
        final options = question['options'] as List;
        final index = int.tryParse(correctAnswer);
        if (index != null && index >= 0 && index < options.length) {
          return options[index].toString();
        }
      }
      return correctAnswer;
    } else if (questionType == 'TRUE_FALSE' || questionType == 'SHORT_TEXT') {
      return correctAnswer;
    }
    return correctAnswer;
  }

  bool _isAnswerCorrect(Map<String, dynamic> question, Map<String, dynamic> studentAnswer, String questionType) {
    if (questionType == 'MCQ') {
      final correctIndex = question['correctAnswer']?.toString() ?? '';
      final selectedIndex = studentAnswer['selectedOption']?.toString() ?? '';
      return correctIndex == selectedIndex;
    } else if (questionType == 'TRUE_FALSE') {
      final correct = question['correctAnswer']?.toString().toLowerCase() ?? '';
      final answer = studentAnswer['answer']?.toString().toLowerCase() ?? '';
      return correct == answer;
    }
    return studentAnswer['grade'] != null && 
           (studentAnswer['grade'] as num?)?.toDouble() == (question['maxMarks'] as num?)?.toDouble();
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
}
