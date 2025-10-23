import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

// Imports for the new structure
import '../../common/pdf_view_page.dart';     // For PdfViewPage
import '../../common/app_state.dart';       // For global state variables
import '../student/student_dashboard_screen.dart'; // For DashboardScreen
import '../instructor/instructor_dashboard_screen.dart'; // For InstructorScreen
import '../admin/admin_dashboard_screen.dart';   // For AdminScreen
import '../auth/university_login_page.dart';  // For UniversityLoginPage

// Note: The PdfViewPage class is no longer here.
// It is imported from common/pdf_view_page.dart

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isDarkMode = false; // Dark mode flag here in home page
  int _selectedIndex = 0;
  final ScrollController _coursesScrollController = ScrollController();

  @override
  void dispose() {
    _coursesScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final schedules = [
      {
        'title': 'Midterms Schedule',
        'pdf': 'assets/Midterm_Schedule.pdf',
        'image': 'assets/Midterm.jpg',
      },
      {
        'title': 'Courses Schedule',
        'pdf': 'assets/CourseSchedule.pdf',
        'image': 'assets/Course.jpg',
      },
      {
        'title': 'Finals Schedule',
        'pdf': 'assets/Final_Schedule.pdf',
        'image': 'assets/Finals.jpg',
      },
    ];

    final courses = [
      {
        'title': 'Parallel and distributed Algo',
        'image': 'assets/Parallel.jpg',
      },
      {'title': 'Big Data Analytics', 'image': 'assets/BigData.jpg'},
      {'title': 'AI Fundamentals', 'image': 'assets/Ai.jpg'},
      {'title': 'Cyber Security', 'image': 'assets/Cybersecurity.jpg'},
      {'title': 'Data Science', 'image': 'assets/DataScience.jpg'},
    ];

    final screenSize = MediaQuery.of(context).size;

    // Define colors here based on isDarkMode
    final primaryColor =
        isDarkMode ? Colors.deepPurple.shade700 : Colors.blue.shade700;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/Asu.jpg', // Your logo path
            fit: BoxFit.fill,
            height: screenSize.height * 0.1,
          ),
        ),
        title: Text(
          'University portal',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            overflow: TextOverflow.ellipsis,
            letterSpacing: 1.2,
            color: textColor,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.sunny : Icons.brightness_2,
              color: textColor,
            ),
            onPressed: () {
              setState(() {
                isDarkMode = !isDarkMode;
              });
            },
            tooltip: isDarkMode ? 'Light Mode' : 'Dark Mode',
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              height: 0.2 * screenSize.height,
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'About the University\n\n'
                'Established in 1839, the University has a rich history of academic excellence and innovation , graduating hundreds of special engineers for egypt and worldwide. '
                'Dedicated to fostering knowledge, research, and community engagement for nearly 2 centuries.',
                style: TextStyle(
                  color: Colors.white, // text on primary container is white
                  fontSize: 16,
                  height: 1.4,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 0.15 * screenSize.height,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: textColor),
                    onPressed: () {
                      _coursesScrollController.animateTo(
                        _coursesScrollController.offset -
                            (0.25 * screenSize.width + 16),
                        duration: Duration(milliseconds: 350),
                        curve: Curves.ease,
                      );
                    },
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: _coursesScrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 0.25 * screenSize.width,
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          child: Card(
                            color: isDarkMode
                                ? Colors.grey.shade900
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                    child: Image.asset(
                                      courses[index]['image']!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Container(
                                  color: primaryColor,
                                  padding: EdgeInsets.all(12),
                                  child: Text(
                                    courses[index]['title']!,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios, color: textColor),
                    onPressed: () {
                      _coursesScrollController.animateTo(
                        _coursesScrollController.offset +
                            (0.25 * screenSize.width + 16),
                        duration: Duration(milliseconds: 350),
                        curve: Curves.ease,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 0.05 * screenSize.height)),
          SliverToBoxAdapter(
            child: CarouselSlider(
              items: schedules.map((schedule) {
                return Builder(
                  builder: (context) {
                    double screenHeight = MediaQuery.of(context).size.height;
                    double cardHeight =
                        screenHeight * 0.27; // ~27% of screen height
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PdfViewPage(schedule['pdf']!),
                          ),
                        );
                      },
                      child: Card(
                        color:
                            isDarkMode ? Colors.grey.shade900 : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: SizedBox(
                          height: cardHeight,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                schedule['image']!,
                                height: cardHeight * 0.5, // 50% of card
                                fit: BoxFit.cover,
                              ),
                              SizedBox(height: 12),
                              Text(
                                schedule['title']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
              // Add other necessary CarouselSlider parameters (such as height, viewportFraction, etc.)
              options: CarouselOptions(
                height:
                    MediaQuery.of(context).size.height *
                        0.33, // constrain slider height
                viewportFraction: 0.7, // adjust as needed
                autoPlay: false,
                enlargeCenterPage: true,
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
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
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