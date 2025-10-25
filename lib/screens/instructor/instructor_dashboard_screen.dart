import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';

// Imports for the new structure
import '../../common/app_state.dart';
import '../home/my_home_page.dart';
import '../student/student_dashboard_screen.dart';
import '../auth/university_login_page.dart';

class InstructorScreen extends StatefulWidget {
  const InstructorScreen({super.key});

  @override
  State<InstructorScreen> createState() => _InstructorScreenState();
}

class _InstructorScreenState extends State<InstructorScreen> {
  bool isDark = false;
  int _selectedIndex = 1;
  // bool isStudent = false; // This is a global, so it's commented out

  final ScrollController _gradesScrollController = ScrollController();
  final ScrollController _ratingsScrollController = ScrollController();

  @override
  void dispose() {
    _gradesScrollController.dispose();
    _ratingsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    final List<Map<String, dynamic>> courses = [];

    final primaryColor =
        isDark ? Colors.deepPurple.shade700 : Colors.blue.shade700;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final cardColor = isDark ? Colors.grey[900] : Colors.white;

    void scrollLeft(ScrollController controller) {
      final offset = controller.offset - screenSize.width * 0.5;
      controller.animateTo(
        offset < 0 ? 0 : offset,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    void scrollRight(ScrollController controller) {
      final maxScroll = controller.position.maxScrollExtent;
      final offset = controller.offset + screenSize.width * 0.5;
      controller.animateTo(
        offset > maxScroll ? maxScroll : offset,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                'Dashboard',
                style: TextStyle(color: textColor, fontSize: 24),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Flexible(
              child: Text(
                'Welcome to the Faculty SIS System',
                style: TextStyle(color: textColor, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
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
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 16),
          children: [
            // Instructor Card
            Card(
              color: cardColor,
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/Profile.jpg',
                        height: screenSize.height * 0.13,
                        width: screenSize.height * 0.13,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mohamed Al Gazar',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Avg Instructor Rating: 4.5',
                            style: TextStyle(
                              fontSize: 18,
                              color: textColor.withOpacity(0.7),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 32),

            // Grades Cards Horizontal List with Arrows
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: textColor),
                    onPressed: () => scrollLeft(_gradesScrollController),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: screenSize.height * 0.45,
                      child: ListView.builder(
                        controller: _gradesScrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: courses.length,
                        itemBuilder: (context, index) {
                          final course = courses[index];
                          return Container(
                            width: screenSize.width * 0.5,
                            margin: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Card(
                              color: cardColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 6,
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        child: Image.asset(
                                          course['image'],
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        course['title'],
                                        style: TextStyle(
                                          fontSize: 22,
                                          color: textColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Expanded(
                                      flex: 2,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          FilePickerResult? result =
                                              await FilePicker.platform
                                                  .pickFiles(
                                            type: FileType.custom,
                                            allowedExtensions: ['xlsx'],
                                          );
                                          if (result != null) {
                                            var bytes =
                                                result.files.first.bytes;
                                            var excel = Excel.decodeBytes(
                                              bytes!,
                                            );
                                            var sheet =
                                                excel.tables.keys.first;
                                            var rows =
                                                excel.tables[sheet]?.rows;
                                            print(
                                              'Grades for ${course['title']}: $rows',
                                            );
                                          } else {
                                            print(
                                              "No file selected for ${course['title']}",
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: Size(
                                            double.infinity,
                                            40,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            'Upload Grades Excel',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios, color: textColor),
                    onPressed: () => scrollRight(_gradesScrollController),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Ratings Cards Horizontal List with Arrows
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: textColor),
                    onPressed: () => scrollLeft(_ratingsScrollController),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: screenSize.height * 0.35,
                      child: ListView.builder(
                        controller: _ratingsScrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: courses.length,
                        itemBuilder: (context, index) {
                          final course = courses[index];
                          return Container(
                            width: screenSize.width * 0.4,
                            margin: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Card(
                              color: cardColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 7,
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        child: Image.asset(
                                          course['image'],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        course['title'],
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Rating: ${course['rating']}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: textColor.withOpacity(0.7),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios, color: textColor),
                    onPressed: () => scrollRight(_ratingsScrollController),
                  ),
                ],
              ),
            ),
          ],
        ),
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
                  MaterialPageRoute(builder: (_) => const StudentDashboardScreen()),
                );
              } else if (isInstructor) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => InstructorScreen()),
                );
              } else {
                // Admin users should go to admin dashboard
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Admin users should login through the login page')),
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
        backgroundColor: backgroundColor,
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