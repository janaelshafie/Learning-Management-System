import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/api_services.dart';
import '../../common/app_state.dart';
import 'quiz_question_management_screen.dart';
import 'assignment_file_management_screen.dart';

class InstructorCourseManagementScreen extends StatefulWidget {
  final Map<String, dynamic> course;
  final int instructorId;

  const InstructorCourseManagementScreen({
    super.key,
    required this.course,
    required this.instructorId,
  });

  @override
  State<InstructorCourseManagementScreen> createState() =>
      _InstructorCourseManagementScreenState();
}

class _InstructorCourseManagementScreenState
    extends State<InstructorCourseManagementScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;
  bool _isLoading = true;
  int? _offeredCourseId;

  // Materials
  List<dynamic> _materials = [];
  bool _isUploadingMaterial = false;

  // Announcements
  List<dynamic> _announcements = [];
  bool _isCreatingAnnouncement = false;

  // Quizzes/Assignments
  List<dynamic> _quizzes = [];
  List<dynamic> _assignments = [];
  bool _isCreatingQuiz = false;
  bool _isCreatingAssignment = false;

  // Grade Configuration
  Map<String, double?> _gradeComponents = {};
  List<dynamic> _availableComponents = [];
  List<Map<String, dynamic>> _customComponents = []; // Custom components added by instructor
  bool _isLoadingConfig = false;
  bool _isSavingConfig = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
      print('Course object keys: ${widget.course.keys.toList()}');
      print('Course object: $widget.course');
      
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
            semesterId is int ? semesterId : (semesterId != null ? int.parse(semesterId.toString()) : null) ?? 5,
          );
          print('Retrieved offeredCourseId from API: $_offeredCourseId');
        } else {
          print('ERROR: courseId is null, cannot lookup offeredCourseId');
        }
      }

      if (_offeredCourseId != null) {
        await Future.wait([
          _loadMaterials(),
          _loadAnnouncements(),
          _loadQuizzesAndAssignments(),
          _loadGradeConfig(),
        ]);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Course ID not found. Please go back and try again.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading course data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMaterials() async {
    if (_offeredCourseId == null) return;

    try {
      final materials = await _apiService.getCourseMaterials(_offeredCourseId!);
      if (mounted) {
        setState(() {
          _materials = materials;
        });
      }
    } catch (e) {
      print('Error loading materials: $e');
    }
  }

  Future<void> _loadAnnouncements() async {
    if (_offeredCourseId == null) return;

    try {
      final announcements = await _apiService.getCourseAnnouncements(_offeredCourseId!);
      if (mounted) {
        setState(() {
          _announcements = announcements;
        });
      }
    } catch (e) {
      print('Error loading announcements: $e');
    }
  }

  Future<void> _loadQuizzesAndAssignments() async {
    if (_offeredCourseId == null) return;

    try {
      final quizzesResponse = await _apiService.getCourseQuizzes(_offeredCourseId!);
      final assignmentsResponse = await _apiService.getCourseAssignments(_offeredCourseId!);
      
      if (mounted) {
        setState(() {
          _quizzes = quizzesResponse;
          _assignments = assignmentsResponse;
        });
      }
    } catch (e) {
      print('Error loading quizzes and assignments: $e');
      if (mounted) {
        setState(() {
          _quizzes = [];
          _assignments = [];
        });
      }
    }
  }

  Future<void> _loadGradeConfig() async {
    if (_offeredCourseId == null) return;
    
    setState(() => _isLoadingConfig = true);
    try {
      final response = await _apiService.getGradeComponentConfig(_offeredCourseId!);
      if (mounted && response['status'] == 'success') {
        final savedComponents = Map<String, double?>.from(
          response['components'] ?? {},
        );
        final available = List<dynamic>.from(
          response['availableComponents'] ?? [],
        );
        
        // Identify custom components (ones not in available list)
        // Include all keys from savedComponents, even if value is null (disabled)
        final availableNames = available.map((a) => a['name']?.toString()).toSet();
        final customComps = <Map<String, dynamic>>[];
        
        // First, add enabled custom components from savedComponents
        savedComponents.forEach((name, maxValue) {
          if (!availableNames.contains(name)) {
            customComps.add({
              'name': name,
              'displayName': _formatDisplayName(name),
              'maxValue': maxValue,
            });
          }
        });
        
        // Preserve any custom components from current list that aren't in saved components
        // This keeps disabled custom components visible
        for (final existingCustom in _customComponents) {
          final existingName = existingCustom['name'] as String;
          if (!availableNames.contains(existingName) &&
              !customComps.any((c) => c['name'] == existingName)) {
            // Keep disabled custom component in list (it wasn't saved because it was disabled)
            customComps.add({
              'name': existingName,
              'displayName': existingCustom['displayName'] ?? _formatDisplayName(existingName),
              'maxValue': savedComponents[existingName] ?? existingCustom['maxValue'],
            });
            // Ensure the key exists in savedComponents (set to null if not enabled)
            if (!savedComponents.containsKey(existingName)) {
              savedComponents[existingName] = null;
            }
          }
        }
        
        setState(() {
          _gradeComponents = savedComponents;
          _availableComponents = available;
          _customComponents = customComps;
          _isLoadingConfig = false;
        });
      } else {
        if (mounted) {
          setState(() => _isLoadingConfig = false);
        }
      }
    } catch (e) {
      print('Error loading grade config: $e');
      if (mounted) {
        setState(() => _isLoadingConfig = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          widget.course['courseTitle']?.toString() ??
              widget.course['courseCode']?.toString() ??
              'Course Management',
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Materials', icon: Icon(Icons.folder)),
            Tab(text: 'Announcements', icon: Icon(Icons.announcement)),
            Tab(text: 'Quizzes & Assignments', icon: Icon(Icons.assignment)),
            Tab(text: 'Grade Config', icon: Icon(Icons.grade)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadCourseData,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMaterialsTab(),
                  _buildAnnouncementsTab(),
                  _buildQuizzesAssignmentsTab(),
                  _buildGradeConfigTab(),
                ],
              ),
            ),
    );
  }

  // ========== MATERIALS TAB ==========
  Widget _buildMaterialsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _isUploadingMaterial ? null : _uploadMaterial,
            icon: _isUploadingMaterial
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.upload_file),
            label: Text(_isUploadingMaterial ? 'Uploading...' : 'Upload Material'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
        Expanded(
          child: _materials.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No materials uploaded yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteMaterial(material),
                              tooltip: 'Delete',
                            ),
                          ],
                        ),
                        onTap: () => _viewMaterial(material),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _uploadMaterial() async {
    if (_offeredCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course ID not found')),
      );
      return;
    }

    try {
      // For web, we need withData: true to get bytes
      // For mobile/desktop, we can get path
      final pickResult = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx'],
        allowMultiple: false,
        withData: true, // This ensures bytes are available on web
      );

      if (pickResult == null || pickResult.files.isEmpty) return;

      final file = pickResult.files.first;
      
      setState(() {
        _isUploadingMaterial = true;
      });

      // Upload file using API - handle web (bytes) and mobile/desktop (path)
      Map<String, dynamic> uploadResult;
      
      // Check for bytes first (web), then path (mobile/desktop)
      if (file.bytes != null && file.bytes!.isNotEmpty) {
        // Web: use bytes (preferred when available)
        uploadResult = await _apiService.uploadCourseMaterialFromBytes(
          offeredCourseId: _offeredCourseId!,
          fileBytes: file.bytes!,
          fileName: file.name,
          instructorId: widget.instructorId,
          title: file.name,
        );
      } else if (file.path != null && file.path!.isNotEmpty) {
        // Mobile/Desktop: use file path
        uploadResult = await _apiService.uploadCourseMaterial(
          offeredCourseId: _offeredCourseId!,
          filePath: file.path!,
          fileName: file.name,
          instructorId: widget.instructorId,
          title: file.name,
        );
      } else {
        if (mounted) {
          setState(() {
            _isUploadingMaterial = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File data not available. Please try selecting the file again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (mounted) {
        setState(() {
          _isUploadingMaterial = false;
        });

        if (uploadResult['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File uploaded successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadMaterials(); // Reload materials list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(uploadResult['message'] ?? 'Error uploading file'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingMaterial = false;
        });
        
        String errorMessage = 'Error selecting file: $e';
        
        // Handle web-specific error messages
        if (e.toString().contains('path') && e.toString().contains('null')) {
          errorMessage = 'Please try uploading again. If the error persists, try a different browser or file.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _deleteMaterial(Map<String, dynamic> material) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Material'),
        content: Text('Are you sure you want to delete "${material['title'] ?? material['fileName']}"?'),
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
      final result = await _apiService.deleteCourseMaterial(material['materialId']);
      if (mounted) {
        if (result['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Material deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadMaterials();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Error deleting material'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _viewMaterial(Map<String, dynamic> material) async {
    // TODO: Implement material viewing/downloading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Material viewing will be implemented.')),
    );
  }

  // ========== ANNOUNCEMENTS TAB ==========
  Widget _buildAnnouncementsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _isCreatingAnnouncement ? null : _showCreateAnnouncementDialog,
            icon: const Icon(Icons.add),
            label: const Text('Create Announcement'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
        Expanded(
          child: _announcements.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.announcement_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No announcements yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
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
                                Expanded(
                                  child: Container(
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
                                ),
                                const Spacer(),
                                Text(
                                  _formatDate(announcement['createdAt']?.toString()),
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                  onPressed: () => _deleteAnnouncement(announcement),
                                  tooltip: 'Delete',
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
                ),
        ),
      ],
    );
  }

  Future<void> _showCreateAnnouncementDialog() async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Announcement'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
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
              if (titleController.text.trim().isEmpty ||
                  contentController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in all fields')),
                );
                return;
              }

              Navigator.of(context).pop();
              await _createAnnouncement(
                titleController.text.trim(),
                contentController.text.trim(),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _createAnnouncement(String title, String content) async {
    if (_offeredCourseId == null || currentUserId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course ID or User ID not found')),
      );
      return;
    }

    setState(() {
      _isCreatingAnnouncement = true;
    });

    try {
      final result = await _apiService.createCourseAnnouncement(
        offeredCourseId: _offeredCourseId!,
        authorUserId: currentUserId,
        title: title,
        content: content,
      );

      if (mounted) {
        setState(() {
          _isCreatingAnnouncement = false;
        });

        if (result['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Announcement created successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadAnnouncements();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Error creating announcement'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating announcement: $e')),
        );
        setState(() {
          _isCreatingAnnouncement = false;
        });
      }
    }
  }

  Future<void> _deleteAnnouncement(Map<String, dynamic> announcement) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Announcement'),
        content: Text('Are you sure you want to delete "${announcement['title']}"?'),
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
      final result = await _apiService.deleteCourseAnnouncement(announcement['announcementId']);
      if (mounted) {
        if (result['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Announcement deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadAnnouncements();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Error deleting announcement'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // ========== QUIZZES & ASSIGNMENTS TAB ==========
  Widget _buildQuizzesAssignmentsTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              tabs: [
                Tab(text: 'Quizzes', icon: Icon(Icons.quiz)),
                Tab(text: 'Assignments', icon: Icon(Icons.assignment)),
              ],
            ),
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _isCreatingQuiz ? null : _showCreateQuizDialog,
            icon: const Icon(Icons.add),
            label: const Text('Create Quiz'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
        Expanded(
          child: _quizzes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.quiz_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No quizzes created yet',
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
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      child: ListTile(
                        leading: const Icon(Icons.quiz, color: Colors.blue),
                        title: Text(quiz['title'] ?? 'Untitled Quiz'),
                        subtitle: Text(
                          'Due: ${_formatDate(quiz['dueDate']?.toString())}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteQuiz(quiz),
                        ),
                        onTap: () => _viewQuiz(quiz),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAssignmentsList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _isCreatingAssignment ? null : _showCreateAssignmentDialog,
            icon: const Icon(Icons.add),
            label: const Text('Create Assignment'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
        Expanded(
          child: _assignments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No assignments created yet',
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
                        leading: const Icon(Icons.assignment, color: Colors.orange),
                        title: Text(assignment['title'] ?? 'Untitled Assignment'),
                        subtitle: Text(
                          'Due: ${_formatDate(assignment['dueDate']?.toString())}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteAssignment(assignment),
                        ),
                        onTap: () => _viewAssignment(assignment),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _showCreateQuizDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create Quiz'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text(
                      selectedDate == null
                          ? 'Select Due Date'
                          : 'Due Date: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: Text(
                      selectedTime == null
                          ? 'Select Due Time'
                          : 'Due Time: ${selectedTime!.format(context)}',
                    ),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          selectedTime = picked;
                        });
                      }
                    },
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
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a title')),
                  );
                  return;
                }
                if (selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a due date')),
                  );
                  return;
                }

                Navigator.of(context).pop();
                await _createQuiz(
                  titleController.text.trim(),
                  descriptionController.text.trim(),
                  selectedDate!,
                  selectedTime,
                );
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateAssignmentDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create Assignment'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text(
                      selectedDate == null
                          ? 'Select Due Date'
                          : 'Due Date: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: Text(
                      selectedTime == null
                          ? 'Select Due Time'
                          : 'Due Time: ${selectedTime!.format(context)}',
                    ),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          selectedTime = picked;
                        });
                      }
                    },
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
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a title')),
                  );
                  return;
                }
                if (selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a due date')),
                  );
                  return;
                }

                Navigator.of(context).pop();
                await _createAssignment(
                  titleController.text.trim(),
                  descriptionController.text.trim(),
                  selectedDate!,
                  selectedTime,
                );
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createQuiz(String title, String description, DateTime dueDate, TimeOfDay? dueTime) async {
    if (_offeredCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course ID not found')),
      );
      return;
    }

    setState(() {
      _isCreatingQuiz = true;
    });

    try {
      // Combine date and time for due date
      DateTime dueDateTime = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        dueTime?.hour ?? 23,
        dueTime?.minute ?? 59,
      );

      final dueDateStr = '${dueDateTime.year}-${dueDateTime.month.toString().padLeft(2, '0')}-${dueDateTime.day.toString().padLeft(2, '0')} ${dueDateTime.hour.toString().padLeft(2, '0')}:${dueDateTime.minute.toString().padLeft(2, '0')}:00';

      final result = await _apiService.createQuiz(
        offeredCourseId: _offeredCourseId!,
        title: title,
        description: description.isEmpty ? null : description,
        dueDate: dueDateStr,
        instructorId: widget.instructorId,
      );

      if (mounted) {
        setState(() {
          _isCreatingQuiz = false;
        });

        if (result['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quiz created successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadQuizzesAndAssignments();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Error creating quiz'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating quiz: $e')),
        );
        setState(() {
          _isCreatingQuiz = false;
        });
      }
    }
  }

  Future<void> _createAssignment(String title, String description, DateTime dueDate, TimeOfDay? dueTime) async {
    if (_offeredCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course ID not found')),
      );
      return;
    }

    setState(() {
      _isCreatingAssignment = true;
    });

    try {
      // Combine date and time for due date
      DateTime dueDateTime = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        dueTime?.hour ?? 23,
        dueTime?.minute ?? 59,
      );

      final dueDateStr = '${dueDateTime.year}-${dueDateTime.month.toString().padLeft(2, '0')}-${dueDateTime.day.toString().padLeft(2, '0')} ${dueDateTime.hour.toString().padLeft(2, '0')}:${dueDateTime.minute.toString().padLeft(2, '0')}:00';

      final result = await _apiService.createAssignment(
        offeredCourseId: _offeredCourseId!,
        title: title,
        description: description.isEmpty ? null : description,
        dueDate: dueDateStr,
        instructorId: widget.instructorId,
      );

      if (mounted) {
        setState(() {
          _isCreatingAssignment = false;
        });

        if (result['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Assignment created successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadQuizzesAndAssignments();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Error creating assignment'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating assignment: $e')),
        );
        setState(() {
          _isCreatingAssignment = false;
        });
      }
    }
  }

  Future<void> _deleteQuiz(Map<String, dynamic> quiz) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Quiz'),
        content: Text('Are you sure you want to delete "${quiz['title']}"?'),
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
      final result = await _apiService.deleteQuiz(quiz['quizId']);
      if (mounted) {
        if (result['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quiz deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadQuizzesAndAssignments();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Error deleting quiz'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteAssignment(Map<String, dynamic> assignment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Assignment'),
        content: Text('Are you sure you want to delete "${assignment['title']}"?'),
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
      final result = await _apiService.deleteAssignment(assignment['assignmentId']);
      if (mounted) {
        if (result['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Assignment deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadQuizzesAndAssignments();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Error deleting assignment'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _viewQuiz(Map<String, dynamic> quiz) async {
    // Navigate to quiz question management screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizQuestionManagementScreen(
          quiz: quiz,
          instructorId: widget.instructorId,
        ),
      ),
    ).then((_) => _loadQuizzesAndAssignments());
  }

  Future<void> _viewAssignment(Map<String, dynamic> assignment) async {
    // Check if assignment has questions - if yes, use question management; if no, use file management
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

      if (hasQuestions) {
        // Navigate to question management screen (reusing quiz screen logic)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizQuestionManagementScreen(
              quiz: assignment, // Pass assignment as 'quiz' parameter (it's generic now)
              instructorId: widget.instructorId,
              assessmentType: 'assignment', // Specify it's an assignment
            ),
          ),
        ).then((_) => _loadQuizzesAndAssignments());
      } else {
        // Navigate to file management screen (for file-based assignments)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AssignmentFileManagementScreen(
              assignment: assignment,
              instructorId: widget.instructorId,
            ),
          ),
        ).then((_) => _loadQuizzesAndAssignments());
      }
    } catch (e) {
      // On error, default to file management screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AssignmentFileManagementScreen(
            assignment: assignment,
            instructorId: widget.instructorId,
          ),
        ),
      ).then((_) => _loadQuizzesAndAssignments());
    }
  }

  // ========== GRADE CONFIGURATION TAB ==========
  Widget _buildGradeConfigTab() {
    if (_isLoadingConfig) {
      return const Center(child: CircularProgressIndicator());
    }

    // Calculate total
    double total = _gradeComponents.values
        .where((v) => v != null)
        .fold(0.0, (sum, val) => sum + (val ?? 0.0));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Grade Component Configuration',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Configure which grade components your course uses. '
                    'You can add custom components and set max values for each. Total must not exceed 100.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Current Total: ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: total > 100 ? Colors.red : Colors.green,
                        ),
                      ),
                      Text(
                        '${total.toStringAsFixed(1)} / 100',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: total > 100 ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showAddComponentDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Custom Component'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          // Show custom components first (even if disabled)
          ..._customComponents.map((component) {
            final name = component['name'] as String;
            final savedMaxValue = component['maxValue'] as double?;
            // Use current value if enabled, otherwise use saved max value
            final currentValue = _gradeComponents[name];
            final maxValue = currentValue ?? savedMaxValue ?? 0.0;
            return _buildComponentCard(
              name,
              maxValue,
              true, // isCustom
              displayName: component['displayName'] as String?,
            );
          }),
          // Show available components from database
          ..._availableComponents.map((component) {
            // Backend returns attribute name directly (e.g., "midterm", "assignments_total")
            final attributeName = component['name']?.toString() ?? '';
            final defaultMax = (component['maxValue'] as num?)?.toDouble();
            final currentValue = _gradeComponents[attributeName];
            
            // Create display name from attribute name
            String getDisplayName(String attrName) {
              final map = {
                'midterm': 'Midterm',
                'project': 'Project',
                'assignments_total': 'Assignments Total',
                'quizzes_total': 'Quizzes Total',
                'attendance': 'Attendance',
                'final_exam_mark': 'Final Exam',
                'lab_grade': 'Lab Grade',
                'presentation_grade': 'Presentation',
                'participation': 'Participation',
              };
              return map[attrName] ?? attrName.replaceAll('_', ' ').split(' ').map((word) => 
                word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1)
              ).join(' ');
            }
            
            final displayName = getDisplayName(attributeName);
            final maxValue = defaultMax ?? 0.0;

            return _buildComponentCard(
              attributeName,
              currentValue ?? maxValue,
              false, // isCustom
              displayName: displayName,
              description: component['description']?.toString(),
            );
          }).toList(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSavingConfig ? null : _saveGradeConfig,
              style: ElevatedButton.styleFrom(
                backgroundColor: total > 100
                    ? Colors.grey
                    : const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSavingConfig
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Save Configuration',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentCard(
    String attributeName,
    double? maxValue,
    bool isCustom, {
    String? displayName,
    String? description,
  }) {
    final currentValue = _gradeComponents[attributeName];
    final isEnabled = currentValue != null;
    final value = currentValue ?? 0.0; // Non-null value when enabled
    
    // Create display name if not provided
    final finalDisplayName = displayName ?? _formatDisplayName(attributeName);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        finalDisplayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isCustom) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Custom',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (description != null && description.isNotEmpty)
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            Checkbox(
              value: isEnabled,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _gradeComponents[attributeName] = maxValue ?? 0.0;
                  } else {
                    // Set to null but keep in customComponents list so it can be re-enabled
                    _gradeComponents[attributeName] = null;
                  }
                });
              },
            ),
            if (isEnabled)
              SizedBox(
                width: 100,
                child: TextField(
                  key: ValueKey('$attributeName-${value.toStringAsFixed(1)}'), // Force rebuild on value change
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  controller: TextEditingController(
                    text: value.toStringAsFixed(1),
                  ),
                  enabled: true,
                  decoration: const InputDecoration(
                    labelText: 'Max',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    final num = double.tryParse(value);
                    if (num != null && num >= 0) {
                      setState(() {
                        _gradeComponents[attributeName] = num;
                      });
                    }
                  },
                ),
              ),
            if (isCustom)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _gradeComponents.remove(attributeName);
                    _customComponents.removeWhere(
                      (c) => c['name'] == attributeName,
                    );
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  String _formatDisplayName(String attributeName) {
    final map = {
      'midterm': 'Midterm',
      'project': 'Project',
      'assignments_total': 'Assignments Total',
      'quizzes_total': 'Quizzes Total',
      'attendance': 'Attendance',
      'final_exam_mark': 'Final Exam',
      'lab_grade': 'Lab Grade',
      'presentation_grade': 'Presentation',
      'participation': 'Participation',
    };
    return map[attributeName] ?? 
        attributeName.replaceAll('_', ' ').split(' ').map((word) => 
          word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1)
        ).join(' ');
  }

  void _showAddComponentDialog() {
    final nameController = TextEditingController();
    final maxValueController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Component'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Component Name',
                hintText: 'e.g., Presentation, Lab Work',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: maxValueController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Max Value',
                hintText: 'e.g., 10, 20',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final maxValueStr = maxValueController.text.trim();
              
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a component name')),
                );
                return;
              }
              
              final maxValue = double.tryParse(maxValueStr);
              if (maxValue == null || maxValue <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid max value')),
                );
                return;
              }
              
              // Convert name to attribute format (lowercase with underscores)
              final attributeName = name.toLowerCase().replaceAll(' ', '_');
              
              // Check if component exists in _customComponents or _gradeComponents
              final existingCustomIndex = _customComponents.indexWhere(
                (c) => c['name'] == attributeName,
              );
              final existsInGradeComponents = _gradeComponents.containsKey(attributeName);
              final isCurrentlyEnabled = existsInGradeComponents && 
                                         _gradeComponents[attributeName] != null;
              
              // If it exists and is enabled, show error
              if (isCurrentlyEnabled) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Component already exists and is enabled. Please uncheck it first if you want to modify it.')),
                );
                return;
              }
              
              // If it exists but is disabled (or in custom list but not in gradeComponents), re-enable it
              if (existingCustomIndex >= 0 || existsInGradeComponents) {
                setState(() {
                  _gradeComponents[attributeName] = maxValue;
                  if (existingCustomIndex >= 0) {
                    // Update existing custom component
                    _customComponents[existingCustomIndex]['maxValue'] = maxValue;
                    _customComponents[existingCustomIndex]['displayName'] = name;
                  } else {
                    // Add to custom components list
                    _customComponents.add({
                      'name': attributeName,
                      'displayName': name,
                      'maxValue': maxValue,
                    });
                  }
                });
                Navigator.of(context).pop();
                return;
              }
              
              setState(() {
                _customComponents.add({
                  'name': attributeName,
                  'displayName': name,
                  'maxValue': maxValue,
                });
                _gradeComponents[attributeName] = maxValue;
              });
              
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveGradeConfig() async {
    if (_offeredCourseId == null) return;

    // Calculate total
    double total = _gradeComponents.values
        .where((v) => v != null)
        .fold(0.0, (sum, val) => sum + (val ?? 0.0));

    if (total > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Total marks cannot exceed 100'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSavingConfig = true);
    try {
      // Only send enabled components (non-null) to backend
      // Disabled custom components stay in _customComponents list locally
      final enabledComponents = Map<String, double?>.fromEntries(
        _gradeComponents.entries.where((e) => e.value != null),
      );
      
      final response = await _apiService.configureGradeComponents(
        _offeredCourseId!,
        enabledComponents,
      );
      if (mounted) {
        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Grade configuration saved successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to save configuration'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingConfig = false);
      }
    }
  }

  // ========== HELPER METHODS ==========
  Widget _getMaterialIcon(String type) {
    IconData icon;
    Color color;

    switch (type.toLowerCase()) {
      case 'pdf':
        icon = Icons.picture_as_pdf;
        color = Colors.red;
        break;
      case 'doc':
      case 'docx':
        icon = Icons.description;
        color = Colors.blue;
        break;
      case 'ppt':
      case 'pptx':
        icon = Icons.slideshow;
        color = Colors.orange;
        break;
      case 'xls':
      case 'xlsx':
        icon = Icons.table_chart;
        color = Colors.green;
        break;
      default:
        icon = Icons.insert_drive_file;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 30),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Unknown Date';
    try {
      // Handle both "yyyy-MM-dd HH:mm:ss" and "yyyy-MM-ddTHH:mm:ss" formats
      String normalized = dateString.replaceAll('T', ' ');
      if (normalized.contains('.')) {
        normalized = normalized.substring(0, normalized.indexOf('.'));
      }
      final date = DateTime.parse(normalized);
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown Date';
    }
  }
}

