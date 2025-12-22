import 'package:flutter/material.dart';
import '../../services/api_services.dart';
import '../auth/university_login_page.dart';
import 'instructor_course_detail_screen.dart';
import 'instructor_room_booking.dart';
import 'instructor_room_schedule.dart';

class InstructorScreen extends StatefulWidget {
  final String? userEmail;

  const InstructorScreen({super.key, this.userEmail});

  @override
  State<InstructorScreen> createState() => _InstructorScreenState();
}

class _InstructorScreenState extends State<InstructorScreen>
    with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();

  late TabController _tabController;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isSidebarExpanded = true;
  int _selectedIndex = 0;

  // Example instructor data
  List<dynamic> _announcements = [];
  List<Map<String, dynamic>> _allCourses = []; // courses taught
  List<Map<String, dynamic>> _officeHours = []; // office hours slots
  int _studentsCount = 0; // total students
  int _pendingRequests = 0; // e.g. pending approvals
  String? _instructorType;
  List<Map<String, dynamic>> _adviseeStudents = [];
  List<Map<String, dynamic>> _pendingRegistrations = [];
  List<Map<String, dynamic>> _pendingDrops = [];
  bool _isLoadingRequests = false;

  final List<String> _daysOfWeek = const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  String? _selectedOfficeDay;
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  bool _isSavingOfficeHours = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedOfficeDay = _daysOfWeek.first;
    _loadInstructorData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadInstructorData() async {
    setState(() => _isLoading = true);

    try {
      if (widget.userEmail == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No email provided. Please log in again.'),
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      final userResponse = await _apiService.getUserByEmail(widget.userEmail!);
      if (userResponse['status'] != 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error loading user data: ${userResponse['message'] ?? 'Unknown error'}',
            ),
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      _userData = userResponse['data'];

      // Load instructor-specific data
      try {
        if (_userData == null || _userData!['userId'] == null) {
          print('Error: User data or userId is missing');
          setState(() => _isLoading = false);
          return;
        }
        final instructorData = await _apiService.getInstructorData(
          _userData!['userId'],
        );
        if (instructorData['status'] == 'success') {
          final data = instructorData['data'] ?? {};
          setState(() {
            _instructorType = data['instructorType']?.toString();
            _allCourses = List<Map<String, dynamic>>.from(
              data['courses'] ?? [],
            );
            _studentsCount = data['studentsCount'] ?? 0;
            _pendingRequests = data['pendingRequests'] ?? 0;
            final fetchedOfficeHours = List<Map<String, dynamic>>.from(
              data['officeHours'] ?? [],
            );
            _officeHours = fetchedOfficeHours
                .map(
                  (slot) => {
                    'day': slot['day']?.toString() ?? '',
                    'from': slot['from']?.toString() ?? '',
                    'to': slot['to']?.toString() ?? '',
                    'location': slot['location']?.toString() ?? '',
                  },
                )
                .toList();
            _adviseeStudents = List<Map<String, dynamic>>.from(
              data['advisees'] ?? [],
            );
          });
        }
      } catch (e) {
        // If instructor data fails to load, continue with empty data
        print('Error loading instructor data: $e');
      }

      // Load announcements
      try {
        final announcementsList = await _apiService.getAnnouncementsForUserType(
          'instructors_only',
        );
        _announcements = announcementsList.isNotEmpty ? announcementsList : [];
      } catch (e) {
        // If announcements fail to load, continue with empty list
        print('Error loading announcements: $e');
        _announcements = [];
      }

      setState(() => _isLoading = false);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      setState(() => _isLoading = false);
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
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _isSidebarExpanded ? 280 : 60,
                  child: _buildSidebar(),
                ),
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
          if (_isSidebarExpanded) ...[
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: const Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              _userData?['name']?.toString() ?? 'Instructor Name',
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
          _buildNavItem(0, 'Dashboard', Icons.dashboard),
          _buildNavItem(1, 'Profile', Icons.person),
          _buildNavItem(2, 'My Courses', Icons.menu_book),
          _buildNavItem(3, 'Office Hours', Icons.schedule),
          _buildNavItem(6, 'Book Room', Icons.meeting_room),
          _buildNavItem(7, 'Room Schedule', Icons.event_note),
          if (_isProfessor)
            _buildNavItem(4, 'Registration Requests', Icons.pending_actions),
          if (_isProfessor) _buildNavItem(5, 'Advisees', Icons.group),
          const Spacer(),
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

  Widget _buildNavItem(int index, String title, IconData icon) {
    final bool selected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: selected ? Colors.white.withOpacity(0.15) : Colors.transparent,
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
        return _buildInstructorDashboard();
      case 1:
        return _buildInstructorProfile();
      case 2:
        return _buildAllCourses();
      case 3:
        return _buildOfficeHours();
      case 4:
        return _isProfessor
            ? _buildRegistrationRequests()
            : _buildInstructorDashboard();
      case 5:
        return _isProfessor ? _buildAdvisees() : _buildInstructorDashboard();
      case 6:
        if (_userData?['userId'] != null) {
          final userId = _userData!['userId'];
          return InstructorRoomBookingScreen(
            userId: userId is int
                ? userId
                : int.tryParse(userId.toString()) ?? 0,
            isEmbedded: true,
          );
        }
        return const Center(child: Text('User data not available'));
      case 7:
        if (_userData?['userId'] != null) {
          final userId = _userData!['userId'];
          return InstructorRoomScheduleScreen(
            userId: userId is int
                ? userId
                : int.tryParse(userId.toString()) ?? 0,
            isEmbedded: true,
          );
        }
        return const Center(child: Text('User data not available'));
      default:
        return _buildInstructorDashboard();
    }
  }

  // ---------- DASHBOARD ----------

  Widget _buildInstructorDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.dashboard, size: 24, color: Color(0xFF1E3A8A)),
              SizedBox(width: 8),
              Text(
                'Instructor Dashboard',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildKPICard(
                  'COURSES TAUGHT',
                  '${_allCourses.length}',
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildKPICard(
                  'TOTAL STUDENTS',
                  '$_studentsCount',
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildKPICard(
                  'PENDING REQUESTS',
                  '$_pendingRequests',
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
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
            ..._announcements.map((a) => _buildAnnouncementCard(a)).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildKPICard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
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
        ],
      ),
    );
  }

  // ---------- PROFILE ----------

  Widget _buildInstructorProfile() {
    final bool isWide = MediaQuery.of(context).size.width > 1100;
    final String fullName = _userData?['name']?.toString() ?? 'Instructor';
    final String roleLabel = (_instructorType ?? 'Instructor').toUpperCase();
    final String officialEmail =
        _userData?['officialMail']?.toString() ?? 'N/A';
    final String personalEmail = _userData?['email']?.toString() ?? 'N/A';
    final String phone = _userData?['phone']?.toString() ?? 'N/A';
    final String address = _userData?['location']?.toString() ?? 'N/A';
    final int courseCount = _currentTeachingCourses().length;
    final int adviseeCount = _adviseeStudents.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInstructorHeader(
            fullName: fullName,
            roleLabel: roleLabel,
            courseCount: courseCount,
            studentCount: _studentsCount,
            adviseeCount: _isProfessor ? adviseeCount : null,
          ),
          const SizedBox(height: 24),
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
                      _buildOfficeHoursCard(),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: [
                      _buildScheduleCard(_currentTeachingCourses()),
                      const SizedBox(height: 24),
                      _buildMessagesCard(
                        _announcements
                            .map((a) => Map<String, dynamic>.from(a))
                            .toList(),
                      ),
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
            _buildOfficeHoursCard(),
            const SizedBox(height: 24),
            _buildScheduleCard(_currentTeachingCourses()),
            const SizedBox(height: 24),
            _buildMessagesCard(
              _announcements.map((a) => Map<String, dynamic>.from(a)).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInstructorHeader({
    required String fullName,
    required String roleLabel,
    required int courseCount,
    required int studentCount,
    int? adviseeCount,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.1),
            child: const Icon(Icons.person, size: 48, color: Color(0xFF1E3A8A)),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(roleLabel, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  children: [
                    _buildHeaderStat('Courses', '$courseCount'),
                    _buildHeaderStat('Students', '$studentCount'),
                    if (adviseeCount != null)
                      _buildHeaderStat('Advisees', '$adviseeCount'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildOfficeHoursCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Office Hours',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 12),
            if (_officeHours.isEmpty)
              const Text(
                'No office hours defined.',
                style: TextStyle(color: Colors.grey),
              )
            else
              ..._officeHours.map(
                (slot) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.schedule),
                  title: Text(slot['day']?.toString() ?? ''),
                  subtitle: Text(
                    '${slot['from'] ?? ''} - ${slot['to'] ?? ''} ${slot['location'] ?? ''}',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _currentTeachingCourses() {
    return _allCourses
        .where((course) => course['currentTerm'] == true)
        .cast<Map<String, dynamic>>()
        .toList();
  }

  Widget _buildContactInfoCard({
    required String officialEmail,
    required String personalEmail,
    required String phone,
    required String address,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.email, 'Official Email', officialEmail),
            _buildInfoRow(
              Icons.alternate_email,
              'Personal Email',
              personalEmail,
            ),
            _buildInfoRow(Icons.phone, 'Phone', phone),
            _buildInfoRow(Icons.location_on, 'Office Address', address),
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
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
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
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Current Semester Schedule',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
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
                    courses.isEmpty
                        ? 'No Courses'
                        : (courses.first['semester']?.toString() ?? 'Current'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (courses.isEmpty)
              const Text('No active courses this semester.')
            else
              ...courses.map(_buildScheduleRow),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => setState(() => _selectedIndex = 2),
              child: const Text('View Full Schedule & Locations'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Status legend: Approved = confirmed in your record. Pending = awaiting advisor/department approval.',
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleRow(Map<String, dynamic> course) {
    final String code =
        course['courseCode']?.toString() ?? course['code']?.toString() ?? '---';
    final String title =
        course['courseTitle']?.toString() ?? course['name']?.toString() ?? '';
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
      case 'in progress':
        return Colors.blue[700]!;
      default:
        return Colors.blueGrey;
    }
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
    final String? explicitStatus = course['status']?.toString();
    if (explicitStatus != null && explicitStatus.isNotEmpty) {
      return explicitStatus;
    }
    final String? grade = course['grade']?.toString();
    if (grade != null && grade.isNotEmpty && grade != 'N/A' && grade != '-') {
      return 'Approved';
    }
    return 'Pending';
  }

  Widget _buildMessagesCard(List<Map<String, dynamic>> announcements) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Messages & Notices',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 16),
            if (announcements.isEmpty)
              const Text('No recent announcements.')
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

  // ---------- ALL COURSES ----------

  Widget _buildAllCourses() {
    final currentCourses = _currentTeachingCourses();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'All Courses',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 16),
          if (currentCourses.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No courses scheduled for the current semester.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            ...currentCourses.map((course) {
              final String courseTitle =
                  course['courseTitle']?.toString() ??
                  course['name']?.toString() ??
                  'Course';
              final String courseCode =
                  course['courseCode']?.toString() ??
                  course['code']?.toString() ??
                  '';
              final String semester =
                  course['semester']?.toString() ?? 'Current Semester';
              final String department =
                  course['departmentName']?.toString() ?? 'Department';
              final int totalStudents = course['totalStudents'] ?? 0;
              final List<Map<String, dynamic>> sections =
                  List<Map<String, dynamic>>.from(course['sections'] ?? []);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.menu_book),
                        title: Text(
                          courseTitle,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('$courseCode • $semester • $department'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$totalStudents',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const Text(
                              'students',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        onTap: () => _openCourseDetail(course),
                      ),
                      if (sections.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: sections.map((section) {
                            final int enrolled =
                                section['currentEnrollment'] ?? 0;
                            final int capacity = section['capacity'] ?? 0;
                            return Chip(
                              label: Text(
                                'Section ${section['sectionNumber'] ?? ''} • $enrolled/$capacity',
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildAdvisees() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Advising Students',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 16),
          if (!_isProfessor)
            Text(
              'Only professors manage advisees.',
              style: TextStyle(color: Colors.grey[600]),
            )
          else if (_adviseeStudents.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No advisees assigned yet.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            ..._adviseeStudents.map(_buildAdviseeCard),
        ],
      ),
    );
  }

  Widget _buildAdviseeCard(Map<String, dynamic> student) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.person),
        title: Text(student['name']?.toString() ?? 'Student'),
        subtitle: Text(student['email']?.toString() ?? 'N/A'),
        trailing: Text(
          (student['status']?.toString() ?? 'pending').toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  bool get _isProfessor => (_instructorType ?? '').toLowerCase() == 'professor';

  // ---------- REGISTRATION REQUESTS ----------

  Future<void> _loadPendingRequests() async {
    if (!_isProfessor || _userData == null || _userData!['userId'] == null) {
      return;
    }

    setState(() => _isLoadingRequests = true);

    try {
      final response = await _apiService.getPendingRequests(
        _userData!['userId'],
      );
      if (response['status'] == 'success') {
        final data = response['data'] ?? {};
        setState(() {
          _pendingRegistrations = List<Map<String, dynamic>>.from(
            data['pendingRegistrations'] ?? [],
          );
          _pendingDrops = List<Map<String, dynamic>>.from(
            data['pendingDrops'] ?? [],
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message']?.toString() ?? 'Error loading requests',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading requests: $e')));
    } finally {
      setState(() => _isLoadingRequests = false);
    }
  }

  Future<void> _handleRequestAction(int enrollmentId, String action) async {
    if (!_isProfessor || _userData == null || _userData!['userId'] == null) {
      return;
    }

    try {
      final response = await _apiService.approveRequest(
        _userData!['userId'],
        enrollmentId,
        action,
      );

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message']?.toString() ??
                  'Request processed successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Reload requests
        await _loadPendingRequests();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message']?.toString() ?? 'Error processing request',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildRegistrationRequests() {
    if (!_isProfessor) {
      return const Center(
        child: Text('Only professors can view registration requests.'),
      );
    }

    // Load requests when this tab is first accessed
    if (_selectedIndex == 4 &&
        !_isLoadingRequests &&
        _pendingRegistrations.isEmpty &&
        _pendingDrops.isEmpty) {
      _loadPendingRequests();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Registration Requests',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadPendingRequests,
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingRequests)
            const Center(child: CircularProgressIndicator())
          else if (_pendingRegistrations.isEmpty && _pendingDrops.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No pending requests.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else ...[
            if (_pendingRegistrations.isNotEmpty) ...[
              const Text(
                'Pending Registrations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 12),
              ..._pendingRegistrations.map(
                (request) => _buildRequestCard(request, 'registration'),
              ),
              const SizedBox(height: 24),
            ],
            if (_pendingDrops.isNotEmpty) ...[
              const Text(
                'Pending Drop Requests',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 12),
              ..._pendingDrops.map(
                (request) => _buildRequestCard(request, 'drop'),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request, String requestType) {
    final String studentName = request['studentName']?.toString() ?? 'Unknown';
    final String studentUid = request['studentUid']?.toString() ?? 'N/A';
    final String courseCode = request['courseCode']?.toString() ?? '';
    final String courseTitle = request['courseTitle']?.toString() ?? '';
    final String sectionNumber = request['sectionNumber']?.toString() ?? '';
    final int enrollmentId = request['enrollmentId'] ?? 0;
    final int credits = request['credits'] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  requestType == 'registration'
                      ? Icons.add_circle
                      : Icons.remove_circle,
                  color: requestType == 'registration'
                      ? Colors.green
                      : Colors.red,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$courseCode - $courseTitle',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Student: $studentName ($studentUid)',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      Text(
                        'Section: $sectionNumber • Credits: $credits',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _handleRequestAction(enrollmentId, 'reject'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Reject'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () =>
                      _handleRequestAction(enrollmentId, 'approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Approve'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------- OFFICE HOURS ----------

  Widget _buildOfficeHours() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Office Hours',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Office Hour Slot',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Day',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedOfficeDay,
                          items: _daysOfWeek
                              .map(
                                (day) => DropdownMenuItem(
                                  value: day,
                                  child: Text(day),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedOfficeDay = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _startTimeController,
                          decoration: const InputDecoration(
                            labelText: 'From (e.g. 10:00 AM)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _endTimeController,
                          decoration: const InputDecoration(
                            labelText: 'To (e.g. 12:00 PM)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: _addOfficeHourSlot,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Slot'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_officeHours.isEmpty)
            Text(
              'No office hours saved yet.',
              style: TextStyle(color: Colors.grey[600]),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Office Hours',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 8),
                ..._officeHours.asMap().entries.map(
                  (entry) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.schedule),
                      title: Text(
                        entry.value['day']?.toString() ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${entry.value['from'] ?? ''} - ${entry.value['to'] ?? ''}'
                        '${entry.value['location'] != null && entry.value['location'].toString().isNotEmpty ? ' • ${entry.value['location']}' : ''}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeOfficeHourSlot(entry.key),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _isSavingOfficeHours ? null : _saveOfficeHours,
              icon: _isSavingOfficeHours
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(_isSavingOfficeHours ? 'Saving...' : 'Save Changes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addOfficeHourSlot() {
    if (_selectedOfficeDay == null ||
        _startTimeController.text.trim().isEmpty ||
        _endTimeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a day and provide start/end times.'),
        ),
      );
      return;
    }

    setState(() {
      _officeHours = List<Map<String, dynamic>>.from(_officeHours)
        ..add({
          'day': _selectedOfficeDay!,
          'from': _startTimeController.text.trim(),
          'to': _endTimeController.text.trim(),
          'location': _locationController.text.trim(),
        });
      _startTimeController.clear();
      _endTimeController.clear();
      _locationController.clear();
    });
  }

  void _removeOfficeHourSlot(int index) {
    setState(() {
      _officeHours = List<Map<String, dynamic>>.from(_officeHours)
        ..removeAt(index);
    });
  }

  Future<void> _saveOfficeHours() async {
    if (_userData == null || _userData!['userId'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User data missing. Please log in again.'),
        ),
      );
      return;
    }

    final slotsPayload = _officeHours
        .map(
          (slot) => {
            'day': slot['day'] ?? '',
            'from': slot['from'] ?? '',
            'to': slot['to'] ?? '',
            'location': slot['location'] ?? '',
          },
        )
        .toList();

    setState(() {
      _isSavingOfficeHours = true;
    });

    try {
      final instructorId = _userData!['userId'] as int;
      final result = await _apiService.updateInstructorOfficeHours(
        instructorId,
        slotsPayload,
      );

      if (result['status'] == 'success') {
        final updated =
            List<Map<String, dynamic>>.from(result['officeHours'] ?? [])
                .map(
                  (slot) => {
                    'day': slot['day']?.toString() ?? '',
                    'from': slot['from']?.toString() ?? '',
                    'to': slot['to']?.toString() ?? '',
                    'location': slot['location']?.toString() ?? '',
                  },
                )
                .toList();
        setState(() {
          _officeHours = updated;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Office hours updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update office hours: ${result['message'] ?? 'Unknown error'}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating office hours: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSavingOfficeHours = false;
        });
      }
    }
  }

  // ---------- SERVICES ----------

  Widget _buildInstructorServices() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Instructor Services',
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
                    Tab(text: 'Grade Upload'),
                    Tab(text: 'Requests'),
                  ],
                ),
                SizedBox(
                  height: 400,
                  child: TabBarView(
                    controller: _tabController,
                    children: [_buildGradeUpload(), _buildRequests()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeUpload() {
    return Center(
      child: Text(
        'Grade upload functionality will be implemented here.',
        style: TextStyle(color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildRequests() {
    return Center(
      child: Text(
        'Student requests (add/drop, recommendations) will be listed here.',
        style: TextStyle(color: Colors.grey[600]),
      ),
    );
  }

  // ---------- SHARED HELPERS ----------

  void _openCourseDetail(Map<String, dynamic> course) {
    final instructorId = _userData?['userId'];
    if (instructorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to determine instructor ID.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InstructorCourseDetailScreen(
          instructorId: instructorId is int
              ? instructorId
              : int.parse(instructorId.toString()),
          course: course,
        ),
      ),
    ).then((_) => _loadInstructorData());
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
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return 'Unknown Date';
    }
  }
}
