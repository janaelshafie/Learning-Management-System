import 'package:flutter/material.dart';
import '../../services/api_services.dart';
import '../auth/university_login_page.dart';
import '../student/course_details_screen.dart';

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
  List<Map<String, dynamic>> _allCourses = [];        // courses taught
  List<Map<String, dynamic>> _officeHours = [];       // office hours slots
  int _studentsCount = 0;                             // total students
  int _pendingRequests = 0;                           // e.g. pending approvals

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInstructorData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInstructorData() async {
    setState(() => _isLoading = true);

    try {
      if (widget.userEmail == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No email provided. Please log in again.')),
        );
        setState(() => _isLoading = false);
        return;
      }

      final userResponse =
      await _apiService.getUserByEmail(widget.userEmail!);
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
        final instructorData =
        await _apiService.getInstructorData(_userData!['userId']);
        if (instructorData['status'] == 'success') {
          final data = instructorData['data'] ?? {};
          setState(() {
            _allCourses =
            List<Map<String, dynamic>>.from(data['courses'] ?? []);
            _studentsCount = data['studentsCount'] ?? 0;
            _pendingRequests = data['pendingRequests'] ?? 0;
            _officeHours =
            List<Map<String, dynamic>>.from(data['officeHours'] ?? []);
          });
        }
      } catch (e) {
        // If instructor data fails to load, continue with empty data
        print('Error loading instructor data: $e');
      }

      // Load announcements
      try {
        final announcementsList =
        await _apiService.getAnnouncementsForUserType('instructors_only');
        _announcements = announcementsList.isNotEmpty ? announcementsList : [];
      } catch (e) {
        // If announcements fail to load, continue with empty list
        print('Error loading announcements: $e');
        _announcements = [];
      }

      setState(() => _isLoading = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
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
          _buildNavItem(2, 'All Courses', Icons.menu_book),
          _buildNavItem(3, 'Manage Course', Icons.library_books),
          _buildNavItem(4, 'Office Hours', Icons.schedule),
          _buildNavItem(5, 'Services', Icons.settings),
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
            ? Text(
          title,
          style: const TextStyle(color: Colors.white),
        )
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
        return _buildManageCourse();
      case 4:
        return _buildOfficeHours();
      case 5:
        return _buildInstructorServices();
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
              Icon(Icons.dashboard,
                  size: 24, color: Color(0xFF1E3A8A)),
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
            ..._announcements
                .map((a) => _buildAnnouncementCard(a))
                .toList(),
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
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- PROFILE ----------

  Widget _buildInstructorProfile() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor:
                    const Color(0xFF1E3A8A).withOpacity(0.1),
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
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- ALL COURSES ----------

  Widget _buildAllCourses() {
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
          if (_allCourses.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No courses assigned yet',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            ..._allCourses.map(
                  (course) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.menu_book),
                  title: Text(
                    course['name']?.toString() ?? 'Course Name',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    course['code']?.toString() ?? '',
                  ),
                  trailing: Text(
                    '${course['students'] ?? 0} students',
                    style: const TextStyle(fontSize: 12),
                  ),
                  onTap: () => _navigateToCourseDetails(course),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ---------- MANAGE COURSE ----------

  Widget _buildManageCourse() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Manage Course',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Course management features (grading, materials, attendance) will be implemented here.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
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
          if (_officeHours.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No office hours scheduled yet',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            ..._officeHours.map(
                  (slot) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.schedule),
                  title: Text(
                    slot['day']?.toString() ?? 'Day',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${slot['from'] ?? ''} - ${slot['to'] ?? ''}',
                  ),
                  trailing: Text(
                    slot['location']?.toString() ?? '',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
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
                    children: [
                      _buildGradeUpload(),
                      _buildRequests(),
                    ],
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

  void _navigateToCourseDetails(Map<String, dynamic> course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailsScreen(course: course),
      ),
    );
  }

  Widget _buildAnnouncementCard(Map<String, dynamic> announcement) {
    Color priorityColor =
    _getPriorityColor(announcement['priority']?.toString() ?? 'medium');

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
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
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

