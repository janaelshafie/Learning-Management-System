import 'package:flutter/material.dart';
import '../../services/api_services.dart';
import '../auth/university_login_page.dart';
import 'course_details_screen.dart';
import 'study_materials_screen.dart';

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

  // Sample courses data
  List<Map<String, dynamic>> _courses = [];

  // Announcements data
  List<dynamic> _announcements = [];

  // Separate lists for current courses and academic records
  List<Map<String, dynamic>> _currentCourses = [];
  List<Map<String, dynamic>> _academicRecords = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
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
        final studentDataResponse = await _apiService.getStudentData(
          _userData!['userId'],
        );
        if (studentDataResponse['status'] == 'success') {
          final studentData = studentDataResponse['data'];
          setState(() {
            _courses = List<Map<String, dynamic>>.from(
              studentData['courses'] ?? [],
            );
            _cumulativeGPA = (studentData['cumulativeGPA'] ?? 0.0).toDouble();
            _completedCredits = studentData['completedCredits'] ?? 0;
            _departmentName = studentData['departmentName'] ?? 'No Department';

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

  void _separateCoursesBySemester() {
    _currentCourses = [];
    _academicRecords = [];

    for (var course in _courses) {
      String semester = course['semester']?.toString() ?? '';
      String semesterLower = semester.toLowerCase();

      // Current semester detection
      bool isCurrentSemester = false;

      // Check for Fall 2024 (current semester)
      if (semesterLower.contains('fall 2024')) {
        isCurrentSemester = true;
      }
      // Spring 2024 is already past
      else if (semesterLower.contains('spring 2024')) {
        isCurrentSemester = false;
      }
      // Check for date patterns (2024-09 through 2024-12)
      else if (semesterLower.contains('2024-09') ||
          semesterLower.contains('2024-10') ||
          semesterLower.contains('2024-11') ||
          semesterLower.contains('2024-12')) {
        isCurrentSemester = true;
      } else if (semesterLower.contains('2024')) {
        // Check if it's a 2024 course without a completed grade
        String? grade = course['grade']?.toString();
        if (grade == null ||
            grade.isEmpty ||
            grade == '-' ||
            grade == 'I' ||
            grade == 'N/A') {
          // No grade yet = current ongoing course
          isCurrentSemester = true;
        } else {
          // Has a grade = past semester
          isCurrentSemester = false;
        }
      } else {
        // Any other year = past semester
        isCurrentSemester = false;
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

  void _loadMockCourseData() {
    setState(() {
      _courses = [
        {
          'code': 'CSE112',
          'name': 'Introduction to Programming',
          'credits': 3,
          'grade': 'A',
          'semester': 'Fall 2024',
        },
        {
          'code': 'MATH101',
          'name': 'Calculus I',
          'credits': 3,
          'grade': 'B+',
          'semester': 'Fall 2024',
        },
        {
          'code': 'PHYS101',
          'name': 'Physics I',
          'credits': 3,
          'grade': 'A-',
          'semester': 'Fall 2024',
        },
        {
          'code': 'ENG101',
          'name': 'English Composition',
          'credits': 2,
          'grade': 'A',
          'semester': 'Fall 2024',
        },
        {
          'code': 'CSE221',
          'name': 'Data Structures',
          'credits': 3,
          'grade': 'B',
          'semester': 'Spring 2024',
        },
        {
          'code': 'MATH102',
          'name': 'Calculus II',
          'credits': 3,
          'grade': 'B+',
          'semester': 'Spring 2024',
        },
      ];

      // Calculate GPA and credits from mock courses
      double totalPoints = 0.0;
      int totalCredits = 0;

      for (var course in _courses) {
        int credits = course['credits'] as int;
        String grade = course['grade'] as String;

        totalCredits += credits;
        totalPoints += credits * _getGradePoints(grade);
      }

      if (totalCredits > 0) {
        _cumulativeGPA = totalPoints / totalCredits;
        _completedCredits = totalCredits;
      }

      // Separate current courses from academic records
      _separateCoursesBySemester();
    });
  }

  double _getGradePoints(String grade) {
    switch (grade) {
      case 'A+':
        return 4.0;
      case 'A':
        return 4.0;
      case 'A-':
        return 3.7;
      case 'B+':
        return 3.3;
      case 'B':
        return 3.0;
      case 'B-':
        return 2.7;
      case 'C+':
        return 2.3;
      case 'C':
        return 2.0;
      case 'C-':
        return 1.7;
      case 'D+':
        return 1.3;
      case 'D':
        return 1.0;
      case 'F':
        return 0.0;
      default:
        return 0.0;
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Profile Information',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showEditProfileDialog(),
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Pending Changes Notification
          if (_pendingProfileChanges.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.pending_actions, color: Colors.orange[700]),
                      const SizedBox(width: 8),
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
                    'You have ${_pendingProfileChanges.length} profile change(s) waiting for admin approval. Changes will be applied once approved.',
                    style: TextStyle(fontSize: 14, color: Colors.orange[600]),
                  ),
                  const SizedBox(height: 8),
                  ..._pendingProfileChanges.map(
                    (change) => Padding(
                      padding: const EdgeInsets.only(left: 24, top: 4),
                      child: Text(
                        '• ${change['fieldName']?.toString().toUpperCase()}: "${change['oldValue']}" → "${change['newValue']}"',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[600],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.1),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildProfileField(
                    'Full Name',
                    _userData?['name']?.toString() ?? 'N/A',
                  ),
                  _buildProfileField(
                    'Email',
                    _userData?['email']?.toString() ?? 'N/A',
                  ),
                  _buildProfileField(
                    'Official Email',
                    _userData?['officialMail']?.toString() ?? 'N/A',
                  ),
                  _buildProfileField(
                    'Phone',
                    _userData?['phone']?.toString() ?? 'N/A',
                  ),
                  _buildProfileField(
                    'Location',
                    _userData?['location']?.toString() ?? 'N/A',
                  ),
                  _buildProfileField(
                    'National ID',
                    _userData?['nationalId']?.toString() ?? 'N/A',
                  ),
                  _buildProfileField(
                    'Status',
                    _userData?['accountStatus']?.toString().toUpperCase() ??
                        'N/A',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
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
          Card(
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
                  height: 400,
                  child: TabBarView(
                    controller: _tabController,
                    children: [_buildCourseRegistration(), _buildFees()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseRegistration() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Course Registration',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Course registration functionality will be implemented here.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Course registration feature coming soon!'),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Register for Courses'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFees() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Fees Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tuition Fees'),
                      Text(
                        '\$2,500',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Registration Fees'),
                      Text(
                        '\$100',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$2,600',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Payment feature coming soon!'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Pay Now'),
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
