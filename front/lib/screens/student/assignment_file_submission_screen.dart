import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_services.dart';
import '../../common/app_state.dart';

class AssignmentFileSubmissionScreen extends StatefulWidget {
  final Map<String, dynamic> assignment;
  final int? offeredCourseId;

  const AssignmentFileSubmissionScreen({
    super.key,
    required this.assignment,
    this.offeredCourseId,
  });

  @override
  State<AssignmentFileSubmissionScreen> createState() =>
      _AssignmentFileSubmissionScreenState();
}

class _AssignmentFileSubmissionScreenState
    extends State<AssignmentFileSubmissionScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  bool _isUploading = false;

  Map<String, dynamic>? _questionFileInfo;
  Map<String, dynamic>? _mySubmission;

  @override
  void initState() {
    super.initState();
    _loadAssignmentData();
  }

  Future<void> _loadAssignmentData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _loadQuestionFileInfo(),
      _loadMySubmission(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _loadQuestionFileInfo() async {
    try {
      final assignmentId = widget.assignment['assignmentId'] as int;
      final response = await _apiService.getAssignmentQuestionFileInfo(assignmentId);
      if (mounted) {
        if (response['status'] == 'success') {
          setState(() {
            _questionFileInfo = response;
          });
        } else {
          setState(() {
            _questionFileInfo = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _questionFileInfo = null;
        });
      }
    }
  }

  Future<void> _loadMySubmission() async {
    try {
      final assignmentId = widget.assignment['assignmentId'] as int;
      final studentId = currentUserId;
      if (studentId == 0) return;

      final response = await _apiService.getStudentAssignmentSubmission(
        assignmentId: assignmentId,
        studentId: studentId,
      );

      if (mounted) {
        if (response['status'] == 'success') {
          setState(() {
            _mySubmission = response['submission'];
          });
        } else {
          setState(() {
            _mySubmission = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _mySubmission = null;
        });
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

  Future<void> _uploadAnswerFile() async {
    // Check due date
    if (_isPastDueDate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Assignment is past due date. You cannot submit anymore.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
      final studentId = currentUserId;
      if (studentId == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      setState(() => _isUploading = true);

      Map<String, dynamic>? result;

      // Check if we have bytes (web) or path (mobile/desktop)
      if (file.bytes != null) {
        result = await _apiService.submitAssignmentAnswerFileFromBytes(
          assignmentId: assignmentId,
          studentId: studentId,
          fileBytes: file.bytes!,
          fileName: file.name,
        );
      } else if (file.path != null) {
        result = await _apiService.submitAssignmentAnswerFile(
          assignmentId: assignmentId,
          studentId: studentId,
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
        setState(() => _isUploading = false);

        if (result['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Answer file submitted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadMySubmission();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Error submitting file'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _downloadMyAnswerFile() async {
    if (_mySubmission == null) return;

    try {
      final submissionId = _mySubmission!['submissionId'] as int;
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
      return false;
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Assignment Info
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.assignment['title'] ?? 'Assignment',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (widget.assignment['description'] != null)
                            Text(widget.assignment['description']),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16),
                              const SizedBox(width: 8),
                              Text('Due: ${_formatDate(widget.assignment['dueDate']?.toString() ?? '')}'),
                            ],
                          ),
                          if (_isPastDueDate()) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.warning, color: Colors.red, size: 16),
                                  SizedBox(width: 8),
                                  Text(
                                    'Past Due Date',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Question File Section
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Question File',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_questionFileInfo == null)
                            const Text('Question file not available')
                          else
                            ListTile(
                              leading: const Icon(Icons.description, size: 48, color: Colors.blue),
                              title: Text(
                                _questionFileInfo!['fileName'] ?? 'Question File',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'Size: ${_formatFileSize(_questionFileInfo!['fileSize']?.toString() ?? '0')}',
                              ),
                              trailing: ElevatedButton.icon(
                                onPressed: _downloadQuestionFile,
                                icon: const Icon(Icons.download),
                                label: const Text('Download'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E3A8A),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // My Submission Section
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'My Submission',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_mySubmission == null) ...[
                            const Text('No submission yet.'),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _isUploading || _isPastDueDate()
                                    ? null
                                    : _uploadAnswerFile,
                                icon: _isUploading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.upload_file),
                                label: Text(_isUploading
                                    ? 'Uploading...'
                                    : 'Upload Answer File'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E3A8A),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                          ] else ...[
                            ListTile(
                              leading: const Icon(Icons.upload_file, size: 48, color: Colors.green),
                              title: Text(
                                _mySubmission!['fileName'] ?? 'Answer File',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Submitted: ${_formatDate(_mySubmission!['submittedAt']?.toString() ?? '')}',
                                  ),
                                  if (_mySubmission!['grade'] != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Grade: ${_mySubmission!['grade']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (_mySubmission!['feedback'] != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Feedback: ${_mySubmission!['feedback']}',
                                        style: TextStyle(color: Colors.grey[700]),
                                      ),
                                    ],
                                  ] else
                                    const Text(
                                      'Grading in progress...',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.orange,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.download, color: Colors.blue),
                                onPressed: _downloadMyAnswerFile,
                                tooltip: 'Download My Answer',
                              ),
                            ),
                            if (!_isPastDueDate()) ...[
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: _isUploading ? null : _uploadAnswerFile,
                                  icon: _isUploading
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Icon(Icons.upload_file),
                                  label: const Text('Replace Submission'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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

