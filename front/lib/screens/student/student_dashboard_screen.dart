import 'package:flutter/material.dart';

import '../../services/api_services.dart';
import '../auth/university_login_page.dart';
import 'course_details_screen.dart';
import 'study_materials_screen.dart';
import 'student_messaging_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  final String? userEmail;

  const StudentDashboardScreen({super.key, this.userEmail});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen>
    with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  int _selectedIndex = 0;
  bool _isSidebarExpanded = true;
  List<dynamic> _pendingProfileChanges = [];

  // Real data from database
  double _cumulativeGPA = 0.0;
  int _completedCredits = 0;
  final int _totalCredits = 170; // Total credits needed for graduation
  String _departmentName = '';
  String _advisorName = 'N/A';
  String _advisorEmail = 'N/A';

  // Sample courses data
  List<Map<String, dynamic>> _courses = [];

  // Announcements data
  List<dynamic> _announcements = [];

  // Separate lists for current courses and academic records
  List<Map<String, dynamic>> _currentCourses = [];
  List<Map<String, dynamic>> _academicRecords = [];

  // Registration data
  bool _isRegistrationLoading = true;
  bool _registrationOpen = false;
  Map<String, dynamic>? _currentSemesterInfo;
  List<Map<String, dynamic>> _availableRegistrationCourses = [];
  List<Map<String, dynamic>> _asuRegistrationCourses = [];
  List<Map<String, dynamic>> _departmentRegistrationCourses = [];
  List<Map<String, dynamic>> _registeredCoursesForSemester = [];
  String? _registrationStatusMessage;
  Map<int, int> _selectedSectionsByCourse = {};
  Set<int> _selectedDropEnrollmentIds = {};
  bool _isSubmittingRegistrations = false;
  bool _isDroppingCourses = false;
  bool _showAvailableCourses = false;
  final TextEditingController _courseSearchController = TextEditingController();
  String _courseSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _courseSearchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('Loading user data for email: ${widget.userEmail}');

      // Get user data from backend using the logged-in user's email
      if (widget.userEmail != null) {
        print('Calling getUserByEmail with: ${widget.userEmail}');
        final userResponse = await _apiService.getUserByEmail(
          widget.userEmail!,
        );
        print('User response: $userResponse');

        if (userResponse['status'] == 'success') {
          print('User data retrieved successfully: ${userResponse['data']}');
          setState(() {
            _userData = userResponse['data'];
          });
        } else {
          // Show error if API fails
          print('Error loading user data: ${userResponse['message']}');
          setState(() {
            _userData = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error loading user data: ${userResponse['message'] ?? 'Unknown error'}',
              ),
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
      } else {
        // Show error if no email provided
        print('No email provided in widget');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No email provided. Please log in again.'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Load student course data from database
      if (_userData != null) {
        final studentId = _getStudentId();
        if (studentId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to determine student ID. Please relogin.'),
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }

        final studentDataResponse = await _apiService.getStudentData(studentId);
        if (studentDataResponse['status'] == 'success') {
          final studentData = studentDataResponse['data'];
          setState(() {
            _courses = List<Map<String, dynamic>>.from(
              studentData['courses'] ?? [],
            );
            _cumulativeGPA = (studentData['cumulativeGPA'] ?? 0.0).toDouble();
            _completedCredits = studentData['completedCredits'] ?? 0;
            _departmentName = studentData['departmentName'] ?? 'No Department';
            _advisorName = studentData['advisorName']?.toString() ?? 'N/A';
            _advisorEmail = studentData['advisorEmail']?.toString() ?? 'N/A';

            // Separate current courses from academic records
            _separateCoursesBySemester();
          });
        } else {
          // Show error if API fails
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error loading student data: ${studentDataResponse['message'] ?? 'Unknown error'}',
              ),
            ),
          );
        }

        // Load pending profile changes
        _pendingProfileChanges = await _apiService
            .getPendingProfileChangesForUser(_userData!['userId']);

        // Load announcements for students
        _announcements = await _apiService.getAnnouncementsForUserType(
          'students_only',
        );

        await _loadRegistrationData();
      } else {
        // No user data available
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No user data available. Please log in again.'),
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Exception in _loadUserData: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRegistrationData() async {
    if (_userData == null) return;
    final studentId = _getStudentId();
    if (studentId == null) return;

    if (mounted) {
      setState(() {
        _isRegistrationLoading = true;
      });
    }

    try {
      final response = await _apiService.getStudentRegistrationData(studentId);

      if (response['status'] == 'success') {
        final data = Map<String, dynamic>.from(
          response['data'] ?? <String, dynamic>{},
        );
        final List<Map<String, dynamic>> parsedCourses = _parseCourseList(
          data['courses'],
        );
        List<Map<String, dynamic>> parsedAsuCourses = _parseCourseList(
          data['asuCourses'],
        );
        List<Map<String, dynamic>> parsedDepartmentCourses = _parseCourseList(
          data['departmentCourses'],
        );

        if (parsedAsuCourses.isEmpty && parsedDepartmentCourses.isEmpty) {
          for (final course in parsedCourses) {
            final category = course['category']?.toString() ?? 'department';
            if (category == 'asu') {
              parsedAsuCourses.add(course);
            } else {
              parsedDepartmentCourses.add(course);
            }
          }
        }

        if (mounted) {
          setState(() {
            _registrationOpen = data['registrationOpen'] ?? false;
            _currentSemesterInfo = data['currentSemester'] != null
                ? Map<String, dynamic>.from(
                    data['currentSemester'] as Map<dynamic, dynamic>,
                  )
                : null;
            _availableRegistrationCourses = parsedCourses;
            _asuRegistrationCourses = parsedAsuCourses;
            _departmentRegistrationCourses = parsedDepartmentCourses;
            _registeredCoursesForSemester = _parseCourseList(
              data['registeredCourses'],
            );
            _registrationStatusMessage = response['message']?.toString();
            _selectedSectionsByCourse = {};
            _selectedDropEnrollmentIds.clear();
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response['message']?.toString() ??
                    'Error loading registration data',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading registration data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRegistrationLoading = false;
        });
      }
    }
  }

  int? _getStudentId() {
    final dynamic id = _userData?['userId'];
    if (id is int) return id;
    if (id is String) return int.tryParse(id);
    if (id is num) return id.toInt();
    return null;
  }

  void _toggleSectionSelection(int courseId, int sectionId, bool isSelected) {
    if (!_registrationOpen) return;
    setState(() {
      if (isSelected) {
        _selectedSectionsByCourse[courseId] = sectionId;
      } else {
        _selectedSectionsByCourse.remove(courseId);
      }
    });
  }

  void _toggleDropSelection(int enrollmentId, bool isSelected) {
    if (!_registrationOpen) return;
    setState(() {
      if (isSelected) {
        _selectedDropEnrollmentIds.add(enrollmentId);
      } else {
        _selectedDropEnrollmentIds.remove(enrollmentId);
      }
    });
  }

  Future<void> _submitSelectedRegistrations() async {
    if (!_registrationOpen) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration window is closed.')),
      );
      return;
    }

    final studentId = _getStudentId();
    if (studentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to determine student ID.')),
      );
      return;
    }

    if (_selectedSectionsByCourse.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select at least one course to register.'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmittingRegistrations = true;
    });

    final List<String> errors = [];
    int successCount = 0;

    try {
      for (final sectionId in _selectedSectionsByCourse.values) {
        final result = await _apiService.registerStudentForSection(
          studentId,
          sectionId,
        );
        if (result['status'] == 'success') {
          successCount++;
        } else {
          errors.add(
            result['message']?.toString() ??
                'Unable to register for section $sectionId',
          );
        }
      }

      if (errors.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              successCount > 1
                  ? 'Registration request submitted for $successCount courses. Awaiting advisor approval.'
                  : 'Registration request submitted. Awaiting advisor approval.',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errors.first)));
      }

      setState(() {
        _selectedSectionsByCourse.clear();
      });
      await _loadRegistrationData();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error registering courses: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingRegistrations = false;
        });
      }
    }
  }

  Future<void> _submitSelectedDrops() async {
    if (!_registrationOpen) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration window is closed.')),
      );
      return;
    }

    final studentId = _getStudentId();
    if (studentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to determine student ID.')),
      );
      return;
    }

    if (_selectedDropEnrollmentIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one course to drop.')),
      );
      return;
    }

    setState(() {
      _isDroppingCourses = true;
    });

    final List<String> errors = [];
    int successCount = 0;

    try {
      for (final enrollmentId in _selectedDropEnrollmentIds) {
        final result = await _apiService.dropStudentEnrollment(
          studentId,
          enrollmentId,
        );
        if (result['status'] == 'success') {
          successCount++;
        } else {
          errors.add(result['message']?.toString() ?? 'Unable to drop course.');
        }
      }

      if (errors.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              successCount > 1
                  ? 'Drop request submitted for $successCount courses. Awaiting advisor approval.'
                  : 'Drop request submitted. Awaiting advisor approval.',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errors.first)));
      }

      setState(() {
        _selectedDropEnrollmentIds.clear();
      });
      await _loadRegistrationData();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error dropping courses: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isDroppingCourses = false;
        });
      }
    }
  }

  void _separateCoursesBySemester() {
    _currentCourses = [];
    _academicRecords = [];

    final now = DateTime.now();

    for (var course in _courses) {
      bool isCurrentSemester = false;

      final String? semesterStartStr = course['semesterStartDate']?.toString();
      final String? semesterEndStr = course['semesterEndDate']?.toString();
      final DateTime? semesterStartDate = _parseDate(semesterStartStr);
      final DateTime? semesterEndDate = _parseDate(semesterEndStr);

      if (semesterStartDate != null && semesterEndDate != null) {
        final bool afterStart = !now.isBefore(semesterStartDate);
        final bool beforeEnd = !now.isAfter(semesterEndDate);
        isCurrentSemester = afterStart && beforeEnd;
      } else if (semesterEndDate != null) {
        isCurrentSemester = !now.isAfter(semesterEndDate);
      } else if (semesterStartDate != null) {
        isCurrentSemester = !now.isBefore(semesterStartDate);
      } else {
        // Fallback: treat courses without grades as ongoing.
        String? grade = course['grade']?.toString();
        isCurrentSemester =
            grade == null ||
            grade.isEmpty ||
            grade == '-' ||
            grade == 'I' ||
            grade == 'N/A';
      }

      if (isCurrentSemester) {
        _currentCourses.add(course);
      } else {
        _academicRecords.add(course);
      }
    }

    // Sort academic records by semester (most recent first)
    _academicRecords.sort((a, b) {
      String semesterA = a['semester']?.toString() ?? '';
      String semesterB = b['semester']?.toString() ?? '';
      return semesterB.compareTo(semesterA);
    });
  }

  DateTime? _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // Sidebar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _isSidebarExpanded ? 280 : 60,
                  child: _buildSidebar(),
                ),
                // Main Content
                Expanded(child: _buildMainContent()),
              ],
            ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      color: const Color(0xFF1E3A8A), // Dark blue
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Toggle Button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSidebarExpanded = !_isSidebarExpanded;
                  });
                },
                icon: Icon(
                  _isSidebarExpanded
                      ? Icons.arrow_back_ios
                      : Icons.arrow_forward_ios,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          // Profile Section
          if (_isSidebarExpanded) ...[
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: const Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              _userData?['name']?.toString() ?? 'Student Name',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
          ] else ...[
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: const Icon(Icons.person, size: 20, color: Colors.white),
            ),
            const SizedBox(height: 20),
          ],
          // Navigation Items
          _buildNavItem(0, 'Dashboard', Icons.dashboard, true),
          _buildNavItem(1, 'Profile', Icons.person, false),
          _buildNavItem(2, 'Courses', Icons.book, false),
          _buildNavItem(3, 'Study Materials', Icons.library_books, false),
          _buildNavItem(4, 'Academic Records', Icons.history_edu, false),
          _buildNavItem(5, 'Services', Icons.settings, false),
          _buildNavItem(6, 'Messages', Icons.message, false),
          const Spacer(),
          // Logout Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UniversityLoginPage(),
                    ),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: _isSidebarExpanded
                    ? const Text('Logout')
                    : const SizedBox(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String title, IconData icon, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: _isSidebarExpanded
            ? Text(title, style: const TextStyle(color: Colors.white))
            : null,
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildProfile();
      case 2:
        return _buildCourses();
      case 3:
        return _buildStudyMaterials();
      case 4:
        return _buildAcademicRecords();
      case 5:
        return _buildServices();
      case 6:
        final studentId = _getStudentId();
        if (_userData?['userId'] != null && studentId != null) {
          return StudentMessagingScreen(
            userId: _userData!['userId'],
            studentId: studentId,
          );
        }
        return const Center(child: Text('User data not available'));
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.dashboard, size: 24, color: Color(0xFF1E3A8A)),
              const SizedBox(width: 8),
              const Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Welcome to the Faculty SIS System',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          // Department Display
          if (_departmentName.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getDepartmentColor(_departmentName),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Department: $_departmentName',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const SizedBox(height: 24),

          // Announcements Section
          if (_announcements.isNotEmpty) ...[
            const Text(
              'Announcements',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 16),
            ...(_announcements
                .map((announcement) => _buildAnnouncementCard(announcement))
                .toList()),
            const SizedBox(height: 32),
          ],

          // KPI Cards
          Row(
            children: [
              Expanded(
                child: _buildKPICard(
                  'CUMULATIVE GPA',
                  _cumulativeGPA.toStringAsFixed(2),
                  _cumulativeGPA / 4.0,
                  '4.0',
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildKPICard(
                  'CREDIT HOURS',
                  '$_completedCredits',
                  _completedCredits / _totalCredits,
                  '$_totalCredits',
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Quick Access Cards
          const Text(
            'Quick Access',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildQuickAccessCard(
                'My Courses',
                Icons.book,
                () => setState(() => _selectedIndex = 2),
              ),
              _buildQuickAccessCard(
                'Study Materials',
                Icons.library_books,
                () => setState(() => _selectedIndex = 3),
              ),
              _buildQuickAccessCard(
                'Academic Records',
                Icons.history_edu,
                () => setState(() => _selectedIndex = 4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKPICard(
    String label,
    String value,
    double progress,
    String maxValue,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 6,
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.2),
              radius: 20,
              child: Text(
                maxValue,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCard(
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: const Color(0xFF1E3A8A)),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfile() {
    final bool isWide = MediaQuery.of(context).size.width > 1100;
    final String fullName = _userData?['name']?.toString() ?? 'Student';
    final String studentUid = _userData?['studentUid']?.toString() ?? 'N/A';
    final String major = _departmentName.isNotEmpty
        ? _departmentName
        : 'No Department';
    final String status =
        _userData?['accountStatus']?.toString().toUpperCase() ?? 'ACTIVE';
    final String officialEmail =
        _userData?['officialMail']?.toString() ?? 'N/A';
    final String personalEmail = _userData?['email']?.toString() ?? 'N/A';
    final String phone = _userData?['phone']?.toString() ?? 'N/A';
    final String address = _userData?['location']?.toString() ?? 'N/A';
    final String enrollmentDate =
        _userData?['createdAt']?.toString().split('T').first ?? 'N/A';
    final String gradDate =
        _userData?['expectedGraduation']?.toString() ?? 'N/A';
    final List<Map<String, dynamic>> scheduleCourses = _getScheduleCourses();
    final List<Map<String, dynamic>> latestAnnouncements = _announcements
        .take(3)
        .map((a) => Map<String, dynamic>.from(a))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TextButton.icon(
                onPressed: () => setState(() => _selectedIndex = 0),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Dashboard'),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showEditProfileDialog(),
                icon: const Icon(Icons.edit),
                label: const Text('Request Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildProfileHeader(
            fullName: fullName,
            studentUid: studentUid,
            major: major,
            status: status,
          ),
          const SizedBox(height: 24),
          if (_pendingProfileChanges.isNotEmpty) _buildPendingChangesBanner(),
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 520,
                  child: Column(
                    children: [
                      _buildContactInfoCard(
                        officialEmail: officialEmail,
                        personalEmail: personalEmail,
                        phone: phone,
                        address: address,
                      ),
                      const SizedBox(height: 24),
                      _buildAcademicDetailsCard(
                        advisorName: _advisorName,
                        advisorEmail: _advisorEmail,
                        enrollmentDate: enrollmentDate,
                        gradDate: gradDate,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: [
                      _buildScheduleCard(scheduleCourses),
                      const SizedBox(height: 24),
                      _buildMessagesCard(latestAnnouncements),
                    ],
                  ),
                ),
              ],
            )
          else ...[
            _buildContactInfoCard(
              officialEmail: officialEmail,
              personalEmail: personalEmail,
              phone: phone,
              address: address,
            ),
            const SizedBox(height: 24),
            _buildAcademicDetailsCard(
              advisorName: _advisorName,
              advisorEmail: _advisorEmail,
              enrollmentDate: enrollmentDate,
              gradDate: gradDate,
            ),
            const SizedBox(height: 24),
            _buildScheduleCard(scheduleCourses),
            const SizedBox(height: 24),
            _buildMessagesCard(latestAnnouncements),
          ],
        ],
      ),
    );
  }

  Widget _buildPendingChangesBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pending_actions, color: Colors.orange[700]),
              const SizedBox(width: 12),
              Text(
                'Profile Changes Pending Approval',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'You have ${_pendingProfileChanges.length} change(s) waiting for admin approval. Updates will appear once processed.',
            style: TextStyle(color: Colors.orange[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader({
    required String fullName,
    required String studentUid,
    required String major,
    required String status,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.1),
            child: const Icon(Icons.person, size: 48, color: Color(0xFF1E3A8A)),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'UID: $studentUid | $major',
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: status == 'ACTIVE'
                            ? Colors.green[100]
                            : Colors.orange[50],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: status == 'ACTIVE'
                              ? Colors.green[900]
                              : Colors.orange[900],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildMetricChip(
                      label: 'CGPA',
                      value: _cumulativeGPA.toStringAsFixed(2),
                    ),
                    const SizedBox(width: 12),
                    _buildMetricChip(
                      label: 'Credits',
                      value: '$_completedCredits',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoCard({
    required String officialEmail,
    required String personalEmail,
    required String phone,
    required String address,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.email, 'Official Email', officialEmail),
            _buildInfoRow(
              Icons.alternate_email,
              'Personal Email',
              personalEmail,
            ),
            _buildInfoRow(Icons.phone, 'Phone', phone),
            _buildInfoRow(Icons.location_on, 'Current Address', address),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1E3A8A)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(List<Map<String, dynamic>> courses) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Current Semester Schedule',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _currentCourses.isEmpty
                        ? 'Fall 2025'
                        : (_currentCourses.first['semester']?.toString() ??
                              'Current'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...courses.map(_buildScheduleRow),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => setState(() => _selectedIndex = 2),
              child: const Text('View Full Schedule & Locations'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Status legend: Approved = confirmed in your record. Pending = registration submitted and awaiting advisor approval. Drop Requested = drop request submitted and awaiting advisor approval.',
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleRow(Map<String, dynamic> course) {
    final String code =
        course['code']?.toString() ?? course['courseCode']?.toString() ?? '---';
    final String title =
        course['name']?.toString() ?? course['courseTitle']?.toString() ?? '';
    final String credits = course['credits'] != null
        ? course['credits'].toString()
        : '0';
    final String schedule = _formatScheduleText(course);
    final String status = _deriveCourseStatus(course);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(title, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          SizedBox(
            width: 70,
            child: Text(
              credits,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            width: 140,
            child: Text(
              schedule,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
          _buildStatusChip(status),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _statusColor(status).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: _statusColor(status),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green[700]!;
      case 'pending':
        return Colors.orange[800]!;
      case 'drop pending':
      case 'drop requested':
        return Colors.red[700]!;
      case 'in progress':
        return Colors.blue[700]!;
      default:
        return Colors.blueGrey;
    }
  }

  Widget _buildAcademicDetailsCard({
    required String advisorName,
    required String advisorEmail,
    required String enrollmentDate,
    required String gradDate,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Academic Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.school, 'Advisor', advisorName),
            if (advisorEmail != 'N/A')
              Padding(
                padding: const EdgeInsets.only(left: 40, bottom: 16),
                child: Text(
                  advisorEmail,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            _buildInfoRow(
              Icons.calendar_month,
              'Enrollment Date',
              enrollmentDate,
            ),
            _buildInfoRow(Icons.flag, 'Expected Graduation', gradDate),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesCard(List<Map<String, dynamic>> announcements) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Messages & Notices',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (announcements.isEmpty)
              const Text(
                'No recent announcements.',
                style: TextStyle(color: Colors.black54),
              )
            else
              ...announcements.map(
                (announcement) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    announcement['title']?.toString() ?? 'Announcement',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    announcement['content']?.toString() ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    announcement['createdAt']?.toString().split('T').first ??
                        '',
                    style: const TextStyle(color: Colors.black45, fontSize: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyMaterials() {
    return StudyMaterialsScreen(currentCourses: _currentCourses);
  }

  Widget _buildCourses() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Courses',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Current Semester Courses',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          // Course Statistics
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Current Courses',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Text(
                          '${_currentCourses.length}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Completed Credits',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Text(
                          '$_completedCredits',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Current GPA',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Text(
                          '$_cumulativeGPA',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Course List
          if (_currentCourses.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(Icons.book, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No courses for current semester',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._currentCourses.map(
              (course) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getGradeColor(
                      course['grade'],
                    ).withOpacity(0.2),
                    child: Text(
                      course['grade'],
                      style: TextStyle(
                        color: _getGradeColor(course['grade']),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    course['code'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course['name']),
                      Text(
                        '${course['credits']} Credits • ${course['semester']}',
                      ),
                    ],
                  ),
                  trailing: Text(
                    course['grade'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getGradeColor(course['grade']),
                    ),
                  ),
                  onTap: () => _navigateToCourseDetails(course),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAcademicRecords() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Academic Records',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Past Semesters & Grades',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          // Semester Stats
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Total Semesters',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Text(
                          '${_getUniqueSemesters().length}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Total Courses',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Text(
                          '${_academicRecords.length}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Credits Earned',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Text(
                          '$_completedCredits',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Academic Records List
          if (_academicRecords.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(Icons.history_edu, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No academic records yet',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._buildGroupedAcademicRecords(),
        ],
      ),
    );
  }

  List<Widget> _buildGroupedAcademicRecords() {
    // Group courses by semester
    Map<String, List<Map<String, dynamic>>> groupedRecords = {};
    for (var course in _academicRecords) {
      String semester = course['semester']?.toString() ?? 'Unknown';
      if (!groupedRecords.containsKey(semester)) {
        groupedRecords[semester] = [];
      }
      groupedRecords[semester]!.add(course);
    }

    List<Widget> widgets = [];
    groupedRecords.forEach((semester, courses) {
      // Semester Header
      widgets.add(
        Container(
          margin: const EdgeInsets.only(top: 24, bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.school, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                semester.toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Text(
                '${courses.length} course(s)',
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ),
      );

      // Courses in this semester
      widgets.addAll(
        courses.map(
          (course) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(
                backgroundColor: _getGradeColor(
                  course['grade'],
                ).withOpacity(0.2),
                child: Text(
                  course['grade'],
                  style: TextStyle(
                    color: _getGradeColor(course['grade']),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                course['code'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course['name']),
                  const SizedBox(height: 4),
                  Text(
                    '${course['credits']} Credits',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    course['grade'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getGradeColor(course['grade']),
                    ),
                  ),
                ],
              ),
              onTap: () => _navigateToCourseDetails(course),
            ),
          ),
        ),
      );
    });

    return widgets;
  }

  List<Map<String, dynamic>> _parseCourseList(dynamic rawList) {
    if (rawList == null) return [];
    if (rawList is List<dynamic>) {
      return rawList
          .map(
            (course) =>
                Map<String, dynamic>.from(course as Map<dynamic, dynamic>),
          )
          .toList();
    }
    return [];
  }

  List<Map<String, dynamic>> _filterCourses(
    List<Map<String, dynamic>> courses,
  ) {
    if (_courseSearchQuery.isEmpty) return courses;

    return courses.where((course) {
      final code = course['courseCode']?.toString().toLowerCase() ?? '';
      final title = course['courseTitle']?.toString().toLowerCase() ?? '';
      return code.contains(_courseSearchQuery) ||
          title.contains(_courseSearchQuery);
    }).toList();
  }

  List<String> _getUniqueSemesters() {
    return _academicRecords
        .map((course) => course['semester']?.toString() ?? '')
        .toSet()
        .toList();
  }

  void _navigateToCourseDetails(Map<String, dynamic> course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailsScreen(course: course),
      ),
    );
  }

  Widget _buildServices() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Student Services',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: Card(
              elevation: 4,
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF1E3A8A),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: const Color(0xFF1E3A8A),
                    tabs: const [
                      Tab(text: 'Course Registration'),
                      Tab(text: 'Fees'),
                    ],
                  ),
                  SizedBox(
                    height: 500,
                    child: TabBarView(
                      controller: _tabController,
                      children: [_buildCourseRegistration(), _buildFees()],
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

  Widget _buildCourseRegistration() {
    if (_isRegistrationLoading && _availableRegistrationCourses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_currentSemesterInfo == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'No active semester right now.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'You will be notified when the next semester becomes available for registration.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRegistrationBanner(),
          if (!_registrationOpen)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Registration is currently closed. You can review the available courses but cannot register until an admin re-opens the window.',
                style: TextStyle(color: Colors.red[700], fontSize: 13),
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: !_registrationOpen
                ? null
                : () {
                    setState(() {
                      _showAvailableCourses = !_showAvailableCourses;
                    });
                  },
            icon: Icon(
              _showAvailableCourses
                  ? Icons.keyboard_arrow_up
                  : Icons.add_circle_outline,
            ),
            label: Text(
              _showAvailableCourses
                  ? 'Hide Register Courses'
                  : 'Register Courses',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _registrationOpen
                  ? Colors.green[600]
                  : Colors.grey.shade400,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
          const SizedBox(height: 16),
          _buildRegisteredCoursesSection(),
          const SizedBox(height: 24),
          if (!_registrationOpen)
            _buildClosedRegistrationState()
          else
            _buildAvailableCoursesSection(),
        ],
      ),
    );
  }

  Widget _buildRegistrationBanner() {
    final bool isOpen = _registrationOpen;
    final String semesterName =
        _currentSemesterInfo?['name']?.toString() ?? 'Current Semester';
    final String startDate = _formatDate(
      _currentSemesterInfo?['startDate']?.toString(),
    );
    final String endDate = _formatDate(
      _currentSemesterInfo?['endDate']?.toString(),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOpen ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isOpen ? Colors.green : Colors.red),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isOpen ? Icons.check_circle : Icons.lock_clock,
                color: isOpen ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                isOpen ? 'Registration Open' : 'Registration Closed',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isOpen ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            semesterName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          Text(
            'Duration: $startDate → $endDate',
            style: const TextStyle(color: Colors.black54),
          ),
          if (_registrationStatusMessage != null &&
              _registrationStatusMessage!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _registrationStatusMessage!,
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRegisterSelectedButton() {
    final int selectedCount = _selectedSectionsByCourse.length;
    final bool hasSelection = selectedCount > 0;

    return ElevatedButton.icon(
      onPressed: (!hasSelection || _isSubmittingRegistrations)
          ? null
          : _submitSelectedRegistrations,
      icon: _isSubmittingRegistrations
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.check_circle_outline),
      label: Text(
        hasSelection
            ? 'Register Selected ($selectedCount)'
            : 'Select courses to register',
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
      ),
    );
  }

  Widget _buildClosedRegistrationState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueGrey.shade100),
      ),
      child: const Text(
        'Registration is closed. You can review your registered courses but cannot add or drop courses.',
        style: TextStyle(color: Colors.black87),
      ),
    );
  }

  Widget _buildRegisteredCoursesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'My Registered Courses',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            if (_registrationOpen)
              ElevatedButton.icon(
                onPressed:
                    (_selectedDropEnrollmentIds.isEmpty || _isDroppingCourses)
                    ? null
                    : _submitSelectedDrops,
                icon: _isDroppingCourses
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.remove_circle_outline),
                label: Text(
                  _selectedDropEnrollmentIds.isEmpty
                      ? 'Select courses to drop'
                      : 'Drop Selected (${_selectedDropEnrollmentIds.length})',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_registeredCoursesForSemester.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.info_outline, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text(
                  _registrationOpen
                      ? 'You have not registered for any courses this semester.'
                      : 'No registered courses were found for this semester.',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          )
        else
          ..._registeredCoursesForSemester
              .map(_buildRegisteredCourseCard)
              .toList(),
      ],
    );
  }

  Widget _buildAvailableCoursesSection() {
    if (!_showAvailableCourses) {
      return const SizedBox.shrink();
    }

    final filteredAsu = _filterCourses(_asuRegistrationCourses);
    final filteredDept = _filterCourses(_departmentRegistrationCourses);
    final hasCourses = filteredAsu.isNotEmpty || filteredDept.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _courseSearchController,
          onChanged: (value) {
            setState(() {
              _courseSearchQuery = value.trim().toLowerCase();
            });
          },
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: 'Search by course code or name...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        if (!hasCourses)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                Icon(Icons.info_outline, color: Colors.grey[400]),
                const SizedBox(height: 8),
                const Text(
                  'No matching courses found. Try a different search term.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else ...[
          if (filteredAsu.isNotEmpty) ...[
            const Text(
              'ASU University Requirements',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...filteredAsu.map(_buildRegistrationCourseCard),
            const SizedBox(height: 24),
          ],
          if (filteredDept.isNotEmpty) ...[
            const Text(
              'Department Courses',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...filteredDept.map(_buildRegistrationCourseCard),
          ],
          const SizedBox(height: 12),
          _buildRegisterSelectedButton(),
        ],
      ],
    );
  }

  Widget _buildRegistrationCourseCard(Map<String, dynamic> course) {
    final List<dynamic> sectionsDynamic = course['sections'] ?? [];
    final List<Map<String, dynamic>> sections = sectionsDynamic
        .map(
          (section) =>
              Map<String, dynamic>.from(section as Map<dynamic, dynamic>),
        )
        .toList();

    final bool alreadyRegistered = course['alreadyRegistered'] == true;
    final int courseId = (course['courseId'] as num).toInt();

    final bool isAlreadySelected = _selectedSectionsByCourse.containsKey(
      courseId,
    );

    return Card(
      color: alreadyRegistered || isAlreadySelected
          ? Colors.green.withOpacity(0.08)
          : Colors.white,
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course['courseCode']?.toString() ?? 'Course',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        course['courseTitle']?.toString() ?? 'Unknown course',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${course['credits'] ?? 0} Credits',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (course['courseType'] != null)
                  Chip(
                    avatar: const Icon(Icons.category, size: 16),
                    label: Text((course['courseType'] as String).toUpperCase()),
                  ),
                if (alreadyRegistered)
                  const Chip(
                    avatar: Icon(Icons.check, size: 16),
                    label: Text('Registered'),
                    backgroundColor: Color(0xFFE0F2F1),
                  )
                else if (isAlreadySelected)
                  const Chip(
                    avatar: Icon(Icons.hourglass_top, size: 16),
                    label: Text('Pending'),
                    backgroundColor: Color(0xFFBBDEFB),
                  ),
              ],
            ),
            if (course['eligibilityRequirements'] != null &&
                (course['eligibilityRequirements'] as String).isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Requirements: ${course['eligibilityRequirements']}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              'Sections',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 8),
            ...sections.map(
              (section) => _buildSectionRow(course, section, alreadyRegistered),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionRow(
    Map<String, dynamic> course,
    Map<String, dynamic> section,
    bool alreadyRegisteredForCourse,
  ) {
    final bool isFull = section['isFull'] == true;
    final bool studentEnrolled = section['studentEnrolled'] == true;
    final int sectionId = (section['sectionId'] as num).toInt();
    final int courseId = (course['courseId'] as num).toInt();

    final bool canRegister =
        _registrationOpen &&
        !isFull &&
        !studentEnrolled &&
        !alreadyRegisteredForCourse;

    final int capacity = section['capacity'] != null
        ? (section['capacity'] as num).toInt()
        : 0;
    final int current = section['currentEnrollment'] != null
        ? (section['currentEnrollment'] as num).toInt()
        : 0;
    final bool isSelected = _selectedSectionsByCourse[courseId] == sectionId;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Section ${section['sectionNumber'] ?? ''}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  capacity > 0
                      ? 'Seats: $current / $capacity'
                      : 'Enrolled students: $current',
                  style: TextStyle(
                    fontSize: 12,
                    color: isFull ? Colors.red : Colors.black54,
                  ),
                ),
                if (studentEnrolled || alreadyRegisteredForCourse || isFull)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      studentEnrolled
                          ? 'Already registered in this section.'
                          : alreadyRegisteredForCourse
                          ? 'You are already registered in another section.'
                          : 'Section is full.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Checkbox(
            value: isSelected,
            onChanged: canRegister
                ? (value) => _toggleSectionSelection(
                    courseId,
                    sectionId,
                    value ?? false,
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildRegisteredCourseCard(Map<String, dynamic> course) {
    final String? enrollmentStatus = course['enrollmentStatus']?.toString();
    final bool isPending = enrollmentStatus == 'pending';
    final bool isDropPending = enrollmentStatus == 'drop_pending';
    final bool isApproved =
        enrollmentStatus == 'approved' || enrollmentStatus == null;

    // Only allow dropping approved enrollments (not pending or drop_pending)
    final bool canDrop = _registrationOpen && isApproved;
    final int enrollmentId = (course['enrollmentId'] as num).toInt();
    final bool isSelected = _selectedDropEnrollmentIds.contains(enrollmentId);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${course['courseCode'] ?? ''} - ${course['courseTitle'] ?? ''}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (isPending || isDropPending)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isPending
                                ? Colors.orange[100]
                                : Colors.red[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isPending ? 'Pending' : 'Drop Requested',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isPending
                                  ? Colors.orange[800]
                                  : Colors.red[800],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Section ${course['sectionNumber'] ?? ''} • ${course['credits'] ?? 0} Credits',
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  if (isPending)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Registration requested - Waiting for advisor approval',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  if (isDropPending)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Drop requested - Waiting for advisor approval',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.red[700],
                        ),
                      ),
                    ),
                  if (course['courseType'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Chip(
                        label: Text(
                          (course['courseType'] as String).toUpperCase(),
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                ],
              ),
            ),
            if (_registrationOpen && isApproved)
              Checkbox(
                value: isSelected,
                onChanged: canDrop
                    ? (value) =>
                          _toggleDropSelection(enrollmentId, value ?? false)
                    : null,
              ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getScheduleCourses() {
    if (_currentCourses.isNotEmpty) return _currentCourses;
    return _courses.take(5).toList();
  }

  String _formatScheduleText(Map<String, dynamic> course) {
    if (course['schedule'] != null) {
      return course['schedule'].toString();
    }
    if (course['section'] != null) {
      return 'Section ${course['section']}';
    }
    if (course['semester'] != null) {
      return course['semester'].toString();
    }
    return 'TBA';
  }

  String _deriveCourseStatus(Map<String, dynamic> course) {
    // Check enrollmentStatus from backend first (for registration requests)
    final String? enrollmentStatus = course['enrollmentStatus']?.toString();
    if (enrollmentStatus != null) {
      if (enrollmentStatus == 'approved') {
        return 'Approved';
      } else if (enrollmentStatus == 'pending') {
        return 'Pending';
      } else if (enrollmentStatus == 'drop_pending') {
        return 'Drop Requested';
      }
    }

    // Fallback to explicit status field
    final String? explicitStatus = course['status']?.toString();
    if (explicitStatus != null && explicitStatus.isNotEmpty) {
      return explicitStatus;
    }

    // Check grade for completed courses
    final String? grade = course['grade']?.toString();
    if (grade != null && grade.isNotEmpty && grade != 'N/A' && grade != '-') {
      return 'Approved';
    }
    return 'Pending';
  }

  Widget _buildFees() {
    const double costPerCreditHour = 2500.0; // EGP per credit hour

    // Calculate current semester fees from registered courses
    int currentSemesterCredits = 0;
    for (var course in _registeredCoursesForSemester) {
      final credits = course['credits'];
      if (credits != null) {
        if (credits is int) {
          currentSemesterCredits += credits;
        } else if (credits is num) {
          currentSemesterCredits += credits.toInt();
        } else {
          currentSemesterCredits += int.tryParse(credits.toString()) ?? 0;
        }
      }
    }
    // Also add current courses if not in registered courses
    for (var course in _currentCourses) {
      final credits = course['credits'];
      if (credits != null) {
        if (credits is int) {
          currentSemesterCredits += credits;
        } else if (credits is num) {
          currentSemesterCredits += credits.toInt();
        } else {
          currentSemesterCredits += int.tryParse(credits.toString()) ?? 0;
        }
      }
    }
    double currentSemesterFees = currentSemesterCredits * costPerCreditHour;

    // Group past courses by semester
    Map<String, List<Map<String, dynamic>>> coursesBySemester = {};
    for (var course in _academicRecords) {
      final semester = course['semester']?.toString() ?? 'Unknown Semester';
      if (!coursesBySemester.containsKey(semester)) {
        coursesBySemester[semester] = [];
      }
      coursesBySemester[semester]!.add(course);
    }

    // Sort semesters (most recent first)
    List<String> sortedSemesters = coursesBySemester.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payment Notice
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'All fees must be paid at the university\'s financial office. Please bring your student ID.',
                        style: TextStyle(color: Colors.blue.shade700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Fee Rate Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.monetization_on, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Text(
                  'Fee Rate: ${costPerCreditHour.toStringAsFixed(0)} EGP per credit hour',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Current Semester Fees
          const Text(
            'Current Semester Fees',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_registeredCoursesForSemester.isEmpty &&
                      _currentCourses.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'No courses registered for current semester',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else ...[
                    // List current courses
                    ...(_registeredCoursesForSemester.isNotEmpty
                            ? _registeredCoursesForSemester
                            : _currentCourses)
                        .map((course) {
                          final courseName =
                              course['courseTitle']?.toString() ??
                              course['courseName']?.toString() ??
                              course['name']?.toString() ??
                              'Unknown Course';
                          final courseCode =
                              course['courseCode']?.toString() ?? '';
                          final credits = course['credits'] ?? 0;
                          final creditNum = credits is int
                              ? credits
                              : (credits is num
                                    ? credits.toInt()
                                    : int.tryParse(credits.toString()) ?? 0);
                          final courseFee = creditNum * costPerCreditHour;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        courseName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '$courseCode • $creditNum credit${creditNum == 1 ? '' : 's'}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${courseFee.toStringAsFixed(0)} EGP',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '$currentSemesterCredits credit${currentSemesterCredits == 1 ? '' : 's'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${currentSemesterFees.toStringAsFixed(0)} EGP',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Past Semesters Fees
          if (sortedSemesters.isNotEmpty) ...[
            const Text(
              'Past Semesters Fees',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 12),
            ...sortedSemesters.map((semester) {
              final courses = coursesBySemester[semester]!;
              int semesterCredits = 0;
              for (var course in courses) {
                final credits = course['credits'];
                if (credits != null) {
                  if (credits is int) {
                    semesterCredits += credits;
                  } else if (credits is num) {
                    semesterCredits += credits.toInt();
                  } else {
                    semesterCredits += int.tryParse(credits.toString()) ?? 0;
                  }
                }
              }
              double semesterFees = semesterCredits * costPerCreditHour;

              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  title: Text(
                    semester,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${courses.length} course${courses.length == 1 ? '' : 's'} • $semesterCredits credits',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${semesterFees.toStringAsFixed(0)} EGP',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.expand_more),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: courses.map((course) {
                          final courseName =
                              course['courseName']?.toString() ??
                              course['name']?.toString() ??
                              'Unknown Course';
                          final courseCode =
                              course['courseCode']?.toString() ?? '';
                          final credits = course['credits'] ?? 0;
                          final creditNum = credits is int
                              ? credits
                              : (credits is num
                                    ? credits.toInt()
                                    : int.tryParse(credits.toString()) ?? 0);
                          final courseFee = creditNum * costPerCreditHour;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(courseName),
                                      Text(
                                        '$courseCode • $creditNum credit${creditNum == 1 ? '' : 's'}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${courseFee.toStringAsFixed(0)} EGP',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
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

  Future<void> _showEditProfileDialog() async {
    final TextEditingController nameController = TextEditingController(
      text: _userData?['name']?.toString() ?? '',
    );
    final TextEditingController emailController = TextEditingController(
      text: _userData?['email']?.toString() ?? '',
    );
    final TextEditingController nationalIdController = TextEditingController(
      text: _userData?['nationalId']?.toString() ?? '',
    );
    final TextEditingController phoneController = TextEditingController(
      text: _userData?['phone']?.toString() ?? '',
    );
    final TextEditingController locationController = TextEditingController(
      text: _userData?['location']?.toString() ?? '',
    );
    final TextEditingController passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.7,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Form Fields in Grid Layout
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Full Name',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: nameController,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Personal Email',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: emailController,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'National ID',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: nationalIdController,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Phone Number',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: phoneController,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Location',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: locationController,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'New Password (Leave empty to keep current)',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: passwordController,
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Official Mail (Read-only)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Official Email (Cannot be changed)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              enabled: false,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.grey[200],
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                              controller: TextEditingController(
                                text:
                                    _userData?['officialMail']?.toString() ??
                                    '',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Info Box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info, color: Colors.blue),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Profile changes will be submitted for admin approval. Password changes are applied immediately.',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Footer with buttons
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Name cannot be empty'),
                            ),
                          );
                          return;
                        }

                        if (emailController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Email cannot be empty'),
                            ),
                          );
                          return;
                        }

                        if (nationalIdController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('National ID cannot be empty'),
                            ),
                          );
                          return;
                        }

                        try {
                          final updateData = {
                            'userId': _userData?['userId']?.toString() ?? '',
                            'name': nameController.text.trim(),
                            'email': emailController.text.trim(),
                            'nationalId': nationalIdController.text.trim(),
                            'phone': phoneController.text.trim(),
                            'location': locationController.text.trim(),
                            'role': _userData?['role']?.toString() ?? 'student',
                          };

                          if (passwordController.text.trim().isNotEmpty) {
                            updateData['password'] = passwordController.text
                                .trim();
                          }

                          final result = await _apiService.updateUser(
                            updateData,
                          );

                          if (result['status'] == 'success') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result['message'])),
                            );

                            // Don't update local data - student should see old data until admin approves
                            // Only refresh pending profile changes to show the notification
                            _pendingProfileChanges = await _apiService
                                .getPendingProfileChangesForUser(
                                  _userData!['userId'],
                                );
                            setState(() {});

                            Navigator.of(context).pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result['message'])),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error updating profile: $e'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard(Map<String, dynamic> announcement) {
    Color priorityColor = _getPriorityColor(
      announcement['priority']?.toString() ?? 'medium',
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: priorityColor.withOpacity(0.3), width: 2),
      ),
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
                    color: priorityColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    (announcement['priority']?.toString() ?? 'medium')
                        .toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(announcement['createdAt']?.toString()),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              announcement['title']?.toString() ?? 'No Title',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              announcement['content']?.toString() ?? 'No Content',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.blue;
      case 'low':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown Date';
    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown Date';
    }
  }

  Color _getDepartmentColor(String departmentName) {
    switch (departmentName.toLowerCase()) {
      case 'computer and systems engineering':
        return Colors.blue;
      case 'architecture engineering':
        return Colors.purple;
      case 'mechanical power engineering':
        return Colors.red;
      case 'electronics and communication engineering':
        return Colors.green;
      case 'engineering physics and mathematics':
        return Colors.orange;
      case 'design and production engineering':
        return Colors.teal;
      case 'automotive engineering':
        return Colors.indigo;
      case 'mechatronics engineering':
        return Colors.pink;
      case 'urban design and planning':
        return Colors.brown;
      case 'electrical power and machines engineering':
        return Colors.cyan;
      case 'structural engineering':
        return Colors.deepOrange;
      case 'irrigation and hydraulics engineering':
        return Colors.lightBlue;
      case 'public works engineering':
        return Colors.lightGreen;
      default:
        return Colors.grey;
    }
  }
}
