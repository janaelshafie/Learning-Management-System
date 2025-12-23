import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_services.dart';
import 'quiz_question_management_screen.dart';

class AssignmentFileManagementScreen extends StatefulWidget {
  final Map<String, dynamic> assignment;
  final int instructorId;

  const AssignmentFileManagementScreen({
    super.key,
    required this.assignment,
    required this.instructorId,
  });

  @override
  State<AssignmentFileManagementScreen> createState() =>
      _AssignmentFileManagementScreenState();
}

class _AssignmentFileManagementScreenState
    extends State<AssignmentFileManagementScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;
  bool _isLoading = true;
  bool _isUploadingQuestionFile = false;

  Map<String, dynamic>? _questionFileInfo;
  List<dynamic> _submissions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAssignmentData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAssignmentData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _loadQuestionFileInfo(),
      _loadSubmissions(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _loadQuestionFileInfo() async {
    try {
      final assignmentId = widget.assignment['assignmentId'] as int;
      final response = await _apiService.getAssignmentQuestionFileInfo(assignmentId);
      if (mounted && response['status'] == 'success') {
        setState(() {
          _questionFileInfo = response;
        });
      } else {
        setState(() {
          _questionFileInfo = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _questionFileInfo = null;
        });
      }
    }
  }

  Future<void> _loadSubmissions() async {
    try {
      final assignmentId = widget.assignment['assignmentId'] as int;
      final response = await _apiService.getAssignmentSubmissions(assignmentId);
      
      if (mounted && response['status'] == 'success') {
        setState(() {
          _submissions = response['submissions'] ?? [];
        });
      } else {
        setState(() {
          _submissions = [];
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _submissions = [];
        });
      }
    }
  }

  Future<void> _uploadQuestionFile() async {
    try {
      final pickResult = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
        allowMultiple: false,
        withData: true, // For web compatibility
      );

      if (pickResult == null || pickResult.files.isEmpty) return;

      final file = pickResult.files.first;
      final assignmentId = widget.assignment['assignmentId'] as int;

      setState(() => _isUploadingQuestionFile = true);

      Map<String, dynamic>? result;

      // Check if we have bytes (web) or path (mobile/desktop)
      if (file.bytes != null) {
        result = await _apiService.uploadAssignmentQuestionFileFromBytes(
          assignmentId: assignmentId,
          fileBytes: file.bytes!,
          fileName: file.name,
        );
      } else if (file.path != null) {
        result = await _apiService.uploadAssignmentQuestionFile(
          assignmentId: assignmentId,
          filePath: file.path!,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to read file')),
          );
        }
        return;
      }

      if (mounted) {
        setState(() => _isUploadingQuestionFile = false);

        if (result['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Question file uploaded successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadQuestionFileInfo();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Error uploading file'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingQuestionFile = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _downloadQuestionFile() async {
    try {
      final assignmentId = widget.assignment['assignmentId'] as int;
      final url = await _apiService.downloadAssignmentQuestionFile(assignmentId);
      if (url != null && await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to download file')),
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

  Future<void> _deleteQuestionFile() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Question File'),
        content: const Text('Are you sure you want to delete this question file? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final assignmentId = widget.assignment['assignmentId'] as int;
      final result = await _apiService.deleteAssignmentQuestionFile(assignmentId);

      if (mounted) {
        if (result['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Question file deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadQuestionFileInfo();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Error deleting file'),
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

  Future<void> _downloadSubmissionFile(int submissionId) async {
    try {
      final url = await _apiService.downloadAssignmentAnswerFile(submissionId);
      if (url != null && await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to download file')),
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

  Future<void> _gradeSubmission(int submissionId, double grade, String? feedback) async {
    try {
      final result = await _apiService.gradeAssignmentSubmission(
        submissionId: submissionId,
        grade: grade,
        feedback: feedback,
      );

      if (mounted) {
        if (result['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Submission graded successfully'),
              backgroundColor: Colors.green,
            ),
          );
          await _loadSubmissions();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Error grading submission'),
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

  Future<void> _showGradeDialog(Map<String, dynamic> submission) async {
    final gradeController = TextEditingController(
      text: submission['grade']?.toString() ?? '',
    );
    final feedbackController = TextEditingController(
      text: submission['feedback']?.toString() ?? '',
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Grade Submission - ${submission['studentName'] ?? 'Student ${submission['studentId']}'}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: gradeController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Grade',
                  border: OutlineInputBorder(),
                  hintText: 'Enter grade (0-100)',
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
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final gradeStr = gradeController.text.trim();
              if (gradeStr.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a grade')),
                );
                return;
              }

              final grade = double.tryParse(gradeStr);
              if (grade == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid grade format')),
                );
                return;
              }

              Navigator.of(context).pop();
              await _gradeSubmission(
                submission['submissionId'] as int,
                grade,
                feedbackController.text.trim().isEmpty
                    ? null
                    : feedbackController.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save Grade'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.assignment['title'] ?? 'Assignment Management'),
        backgroundColor: const Color(0xFF1E3A8A),
        actions: [
          // Add button to switch to question-based mode
          IconButton(
            icon: const Icon(Icons.quiz, color: Colors.white),
            tooltip: 'Add Questions (MCQ, etc.)',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizQuestionManagementScreen(
                    quiz: widget.assignment,
                    instructorId: widget.instructorId,
                    assessmentType: 'assignment',
                  ),
                ),
              ).then((_) => Navigator.pop(context)); // Pop file screen after navigating
            },
          ),
        ],
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
            Tab(text: 'Question File', icon: Icon(Icons.description, size: 24)),
            Tab(text: 'Submissions', icon: Icon(Icons.folder_shared, size: 24)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildQuestionFileTab(),
                _buildSubmissionsTab(),
              ],
            ),
    );
  }

  Widget _buildQuestionFileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Assignment Question File',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_questionFileInfo == null) ...[
                    const Text('No question file uploaded yet.'),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isUploadingQuestionFile ? null : _uploadQuestionFile,
                        icon: _isUploadingQuestionFile
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.upload_file),
                        label: Text(_isUploadingQuestionFile
                            ? 'Uploading...'
                            : 'Upload Question File'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ] else ...[
                    ListTile(
                      leading: const Icon(Icons.description, size: 48, color: Colors.blue),
                      title: Text(
                        _questionFileInfo!['fileName'] ?? 'Question File',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Size: ${_formatFileSize(_questionFileInfo!['fileSize']?.toString() ?? '0')}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.download, color: Colors.blue),
                            onPressed: _downloadQuestionFile,
                            tooltip: 'Download',
                          ),
                          IconButton(
                            icon: const Icon(Icons.upload_file, color: Colors.orange),
                            onPressed: _isUploadingQuestionFile ? null : _uploadQuestionFile,
                            tooltip: 'Replace File',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteQuestionFile(),
                            tooltip: 'Delete File',
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionsTab() {
    return RefreshIndicator(
      onRefresh: _loadSubmissions,
      child: _submissions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_shared_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No submissions yet',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _submissions.length,
              itemBuilder: (context, index) {
                final submission = _submissions[index];
                final isGraded = submission['grade'] != null;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('S${submission['studentId']?.toString() ?? '?'}'),
                    ),
                    title: Text('${submission['studentName'] ?? 'Student ${submission['studentId']}'} (${submission['studentId']})'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (submission['submittedAt'] != null)
                          Text('Submitted: ${_formatDate(submission['submittedAt'].toString())}'),
                        if (submission['fileName'] != null)
                          Text('File: ${submission['fileName']}'),
                        if (isGraded) ...[
                          Text(
                            'Grade: ${submission['grade']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          if (submission['feedback'] != null)
                            Text(
                              'Feedback: ${submission['feedback']}',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                        ] else
                          const Text(
                            'Not graded yet',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.orange,
                            ),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.download, color: Colors.blue),
                          onPressed: () => _downloadSubmissionFile(
                            submission['submissionId'] as int,
                          ),
                          tooltip: 'Download Answer File',
                        ),
                        IconButton(
                          icon: const Icon(Icons.grade, color: Colors.green),
                          onPressed: () => _showGradeDialog(submission),
                          tooltip: isGraded ? 'Update Grade' : 'Grade',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final normalizedDate = dateStr.replaceAll('T', ' ').trim();
      final parts = normalizedDate.split(' ');
      if (parts.isEmpty) return dateStr;

      final dateParts = parts[0].split('-');
      if (dateParts.length == 3) {
        String timePart = '';
        if (parts.length > 1) {
          final timeParts = parts[1].split(':');
          if (timeParts.length >= 2) {
            timePart = ' ${timeParts[0]}:${timeParts[1]}';
          }
        }
        return '${dateParts[2]}/${dateParts[1]}/${dateParts[0]}$timePart';
      }
      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }

  String _formatFileSize(String sizeStr) {
    try {
      final size = int.parse(sizeStr);
      if (size < 1024) return '$size B';
      if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(2)} KB';
      return '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';
    } catch (e) {
      return sizeStr;
    }
  }
}

