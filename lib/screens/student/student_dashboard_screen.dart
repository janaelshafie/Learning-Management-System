import 'package:flutter/material.dart';

// Imports for the new structure
import '../../common/app_state.dart';
import '../home/my_home_page.dart';
import '../instructor/instructor_dashboard_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../auth/university_login_page.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isDark = false;
  int _selectedIndex = 1;
  Widget buildCard({
    required Color color,
    required String value,
    required String label,
    required double progress,
    required String progressText,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: EdgeInsets.all(16),
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
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
              SizedBox(height: 16),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white24,
                color: Colors.white,
                minHeight: 5,
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: CircleAvatar(
              backgroundColor: Colors.blueGrey,
              radius: 20,
              child: Text(
                progressText,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        isDark ? Colors.deepPurple.shade700 : Colors.blue.shade700;
    final Cardscolor = isDark ? Colors.orange : Colors.indigo;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: TextStyle(color: textColor, fontSize: 24),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Welcome to the Faculty SIS System',
              style: TextStyle(color: textColor, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.sunny : Icons.brightness_2,
              color: textColor,
            ),
            onPressed: () {
              setState(() {
                isDark = !isDark;
              });
            },
            tooltip: isDark ? 'Light Mode' : 'Dark Mode',
          ),
        ],
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                buildCard(
                  color: Cardscolor,
                  value: '3.01',
                  label: 'CUMULATIVE GPA',
                  progress: 3.01 / 4.0,
                  progressText: '2',
                ),
                buildCard(
                  color: Cardscolor,
                  value: '6',
                  label: 'TRAINING WEEKS',
                  progress: 6 / 12,
                  progressText: '12',
                ),
                buildCard(
                  color: Cardscolor,
                  value: '116',
                  label: 'CREDIT HOURS',
                  progress: 116 / 170,
                  progressText: '170',
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 0.1 * screenSize.height)),
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundImage: AssetImage(
                          'assets/Profile.jpg',
                        ), // Replace with actual image URL or asset
                      ),
                      SizedBox(width: 16),
                      Text(
                        'Mohamed al gazar',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Current GPA',
                    style: TextStyle(color: textColor, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '3.01',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Divider(color: textColor, height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Highest Semester',
                            style: TextStyle(color: textColor, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            '3.39 - Spring 2025',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Worst Semester',
                            style: TextStyle(color: textColor, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            '2.92 - Fall 2024',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => MyHomePage()),
              );
              break;
            case 1:
              if (isStudent) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => DashboardScreen()),
                );
              } else if (isInstructor) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => InstructorScreen()),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => AdminScreen()),
                );
              }
              break;

            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => UniversityLoginPage()),
              );
              break;
            case 3:
              // To be implemented
              break;
            default:
              break;
          }
        },
        backgroundColor: isDark ? Colors.black : Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: textColor.withOpacity(0.7),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_outlined, size: 28),
            label: 'Profile',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.login), label: 'Login'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
        ],
      ),
    );
  }
}