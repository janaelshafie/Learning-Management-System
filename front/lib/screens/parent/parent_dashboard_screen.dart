import 'package:flutter/material.dart';
import '../../services/api_services.dart';
import '../auth/university_login_page.dart';
import 'parent_messaging_screen.dart';

class ParentDashboardScreen extends StatefulWidget {
  final String? userEmail;

  const ParentDashboardScreen({super.key, this.userEmail});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen>
    with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  int _selectedIndex = 0;
  bool _isSidebarExpanded = true;

  // Students data
  List<Map<String, dynamic>> _students = [];
  int? _selectedStudentId;
  Map<String, dynamic>? _selectedStudentData;

  // Academic records for selected student
  List<Map<String, dynamic>> _academicRecords = [];
  double _selectedStudentGPA = 0.0;

  // Current courses for selected student
  List<Map<String, dynamic>> _currentCourses = [];
  Map<String, dynamic>? _currentSemesterInfo;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
      if (widget.userEmail != null) {
        final userResponse = await _apiService.getUserByEmail(widget.userEmail!);
        
        if (userResponse['status'] == 'success') {
          setState(() {
            _userData = userResponse['data'];
          });
          
          // Load students for this parent
          if (_userData?['userId'] != null) {
            await _loadStudents(_userData!['userId']);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading user data: ${userResponse['message'] ?? 'Unknown error'}'),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStudents(int parentId) async {
    try {
      final response = await _apiService.getParentStudents(parentId);
      
      if (response['status'] == 'success') {
        setState(() {
          _students = List<Map<String, dynamic>>.from(response['students'] ?? []);
          if (_students.isNotEmpty && _selectedStudentId == null) {
            _selectedStudentId = _students[0]['studentId'];
            _selectedStudentData = _students[0];
            _loadStudentDetails(_selectedStudentId!);
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Error loading students')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading students: $e')),
      );
    }
  }

  Future<void> _loadStudentDetails(int studentId) async {
    // Find student data
    final student = _students.firstWhere(
      (s) => s['studentId'] == studentId,
      orElse: () => {},
    );
    
    setState(() {
      _selectedStudentId = studentId;
      _selectedStudentData = student;
    });

    // Load academic records and current courses in parallel
    await Future.wait([
      _loadAcademicRecords(studentId),
      _loadCurrentCourses(studentId),
    ]);
  }

  Future<void> _loadAcademicRecords(int studentId) async {
    try {
      final response = await _apiService.getStudentAcademicRecords(studentId);
      
      if (response['status'] == 'success') {
        final data = response['data'];
        setState(() {
          _academicRecords = List<Map<String, dynamic>>.from(data['courses'] ?? []);
          _selectedStudentGPA = (data['cumulativeGpa'] ?? 0.0).toDouble();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Error loading academic records')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading academic records: $e')),
      );
    }
  }

  Future<void> _loadCurrentCourses(int studentId) async {
    try {
      final response = await _apiService.getStudentCurrentCourses(studentId);
      
      if (response['status'] == 'success') {
        setState(() {
          _currentCourses = List<Map<String, dynamic>>.from(response['courses'] ?? []);
          _currentSemesterInfo = response['currentSemester'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Error loading current courses')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading current courses: $e')),
      );
    }
  }

  Color _getGradeColor(String? grade) {
    if (grade == null || grade == 'N/A' || grade.isEmpty) {
      return Colors.grey;
    }
    switch (grade.toUpperCase()) {
      case 'A+':
      case 'A':
      case 'A-':
        return Colors.green;
      case 'B+':
      case 'B':
      case 'B-':
        return Colors.greenAccent;
      case 'C+':
      case 'C':
      case 'C-':
        return Colors.blue;
      case 'D+':
      case 'D':
        return Colors.deepOrange;
      case 'F':
        return Colors.red;
      default:
        return Colors.grey;
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
      color: const Color(0xFF1E3A8A),
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
              backgroundColor: Colors.blueGrey,
              child: const Icon(Icons.family_restroom, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              _userData?['name']?.toString() ?? 'Parent',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _userData?['email']?.toString() ?? '',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
                overflow: TextOverflow.ellipsis
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            const Divider(color: Colors.white30),
            const SizedBox(height: 16),
            Text(
              'My Students: ${_students.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Expanded(
            child: _isSidebarExpanded
                ? ListView.builder(
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      final isSelected = student['studentId'] == _selectedStudentId;
                      return InkWell(
                        onTap: () => _loadStudentDetails(student['studentId']),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 2)
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student['name']?.toString() ?? 'Unknown',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                student['studentUid']?.toString() ?? '',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : ListView.builder(
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      final isSelected = student['studentId'] == _selectedStudentId;
                      return IconButton(
                        onPressed: () => _loadStudentDetails(student['studentId']),
                        icon: Icon(
                          Icons.person,
                          color: isSelected ? Colors.blue : Colors.white70,
                        ),
                        tooltip: student['name']?.toString() ?? 'Student',
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
          // Logout Button
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.black),
            title: _isSidebarExpanded
                ? const Text(
                    'Logout',
                    style: TextStyle(color: Colors.orangeAccent,
                      fontWeight:FontWeight.bold,
                      overflow: TextOverflow.ellipsis


                    ),

                  )
                : null,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const UniversityLoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.family_restroom, size: 64, color: Colors.brown),
            const SizedBox(height: 16),
            Text(
              'No students found',
              style: TextStyle(color: Colors.grey[600], fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Please contact administration if you believe this is an error.',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_selectedStudentId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _buildNavigationTabs(),
        Expanded(
          child: switch (_selectedIndex) {
            0 => _buildDashboard(),
            1 => _buildAcademicRecords(),
            2 => _buildCurrentCourses(),
            3 => _buildMessages(),
            _ => _buildDashboard(),
          },
        ),
      ],
    );
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
                  color: Colors.orange,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Selected Student Info
          if (_selectedStudentData != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.1),
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedStudentData!['name']?.toString() ?? 'Unknown',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Student UID: ${_selectedStudentData!['studentUid'] ?? 'N/A'}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              Text(
                                'Department: ${_selectedStudentData!['departmentName'] ?? 'N/A'}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cumulative GPA',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.deepPurple,
                              overflow: TextOverflow.ellipsis,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedStudentGPA.toStringAsFixed(2),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
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
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Courses',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_currentCourses.length}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
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
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Academic Records',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_academicRecords.length}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
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
          Row(
            children: [
              const Icon(Icons.school, size: 24, color: Color(0xFF1E3A8A)),
              const SizedBox(width: 8),
              const Text(
                'Academic Records',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
          if (_selectedStudentData != null) ...[
            const SizedBox(height: 8),
            Text(
              'Student: ${_selectedStudentData!['name']}',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
          const SizedBox(height: 24),
          if (_academicRecords.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(Icons.school, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No academic records available',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._academicRecords.map(
              (record) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getGradeColor(record['grade']?.toString())
                        .withOpacity(0.2),
                    child: Text(
                      record['grade']?.toString() ?? 'N/A',
                      style: TextStyle(
                        color: _getGradeColor(record['grade']?.toString()),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    record['code']?.toString() ?? 'N/A',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(record['name']?.toString() ?? 'N/A'),
                      Text(
                        '${record['credits']} Credits • ${record['semester']} • Section ${record['section']}',
                      ),
                    ],
                  ),
                  trailing: Text(
                    record['grade']?.toString() ?? 'N/A',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getGradeColor(record['grade']?.toString()),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCurrentCourses() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.book, size: 24, color: Color(0xFF1E3A8A)),
              const SizedBox(width: 8),
              const Text(
                'Current Semester Courses',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
          if (_selectedStudentData != null) ...[
            const SizedBox(height: 8),
            Text(
              'Student: ${_selectedStudentData!['name']}',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
          if (_currentSemesterInfo != null) ...[
            const SizedBox(height: 8),
            Text(
              'Semester: ${_currentSemesterInfo!['name']}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
          const SizedBox(height: 24),
          if (_currentCourses.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(Icons.book, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No courses registered for current semester',
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
                    backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.1),
                    child: const Icon(Icons.book, color: Color(0xFF1E3A8A)),
                  ),
                  title: Text(
                    course['courseCode']?.toString() ?? 'N/A',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course['courseTitle']?.toString() ?? 'N/A'),
                      Text(
                        '${course['credits']} Credits • Section ${course['sectionNumber']}',
                      ),
                      if (course['enrollmentStatus'] != null)
                        Chip(
                          label: Text(
                            course['enrollmentStatus'].toString().toUpperCase(),
                            style: const TextStyle(fontSize: 10),
                          ),
                          backgroundColor: course['enrollmentStatus'] == 'approved'
                              ? Colors.green[100]
                              : Colors.orange[100],
                        ),
                    ],
                  ),
                  trailing: course['grade'] != null && course['grade'] != 'N/A'
                      ? Text(
                          course['grade']?.toString() ?? 'N/A',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _getGradeColor(course['grade']?.toString()),
                          ),
                        )
                      : const Text('In Progress'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavigationTabs() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        labelColor: const Color(0xFF1E3A8A),
        unselectedLabelColor: Colors.grey,
        indicatorColor: const Color(0xFF1E3A8A),
        tabs: const [
          Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
          Tab(icon: Icon(Icons.school), text: 'Academic Records'),
          Tab(icon: Icon(Icons.book), text: 'Current Courses'),
          Tab(icon: Icon(Icons.message), text: 'Messages'),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    if (_userData?['userId'] == null) {
      return const Center(child: Text('User data not available'));
    }
    return ParentMessagingScreen(
      userId: _userData!['userId'],
      students: _students,
    );
  }
}
