import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';

// Imports for the new structure
import '../../common/app_state.dart';
import '../../common/pdf_view_page.dart';
import '../home/my_home_page.dart';
import '../student/student_dashboard_screen.dart';
import '../instructor/instructor_dashboard_screen.dart';
import '../auth/university_login_page.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final List<Map<String, String>> sections = [
    {
      'title': 'Mechatronics',
      'image': 'assets/Mecha.jpg',
      'problemsPdf': 'assets/problems_mechatronics.pdf',
    },
    {
      'title': 'CESS',
      'image': 'assets/Cess.jpg',
      'problemsPdf': 'assets/problems_cess.pdf',
    },
    {
      'title': 'Energy',
      'image': 'assets/Energy.jpg',
      'problemsPdf': 'assets/problems_energy.pdf',
    },
    {
      'title': 'Civil',
      'image': 'assets/civil.jpg',
      'problemsPdf': 'assets/problems_civil.pdf',
    },
    {
      'title': 'Architecture',
      'image': 'assets/Architecture.jpg',
      'problemsPdf': 'assets/problems_architecture.pdf',
    },
  ];
  int _selectedIndex = 1;
  ScrollController _studentsScrollController = ScrollController();
  ScrollController _problemsScrollController = ScrollController();

  bool isDark = false;

  void scrollLeft(ScrollController controller, double screenWidth) {
    final offset = controller.offset - screenWidth * 0.5;
    controller.animateTo(
      offset < 0 ? 0 : offset,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void scrollRight(ScrollController controller, double screenWidth) {
    final maxScroll = controller.position.maxScrollExtent;
    final offset = controller.offset + screenWidth * 0.5;
    controller.animateTo(
      offset > maxScroll ? maxScroll : offset,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final primaryColor =
        isDark ? Colors.deepPurple.shade700 : Colors.blue.shade700;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final cardColor = isDark ? Colors.grey[900] : Colors.white;

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
            // Admin Card
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Todo Tasks: 4',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: textColor.withOpacity(0.7),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Done Tasks: 6',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: textColor.withOpacity(0.7),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Students Upload Cards Horizontal List
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: textColor),
                    onPressed: () =>
                        scrollLeft(_studentsScrollController, screenSize.width),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: screenSize.height * 0.45,
                      child: ListView.builder(
                        controller: _studentsScrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: sections.length,
                        itemBuilder: (context, index) {
                          final section = sections[index];
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
                                          section['image']!,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        section['title']!,
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
                                              'Students for section ${section['title']}: $rows',
                                            );
                                            // Add your processing logic here
                                          } else {
                                            print(
                                              "No file selected for section ${section['title']}",
                                            );
                                          }
                                        },
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            'Upload Students Excel',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
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
                    onPressed: () => scrollRight(
                      _studentsScrollController,
                      screenSize.width,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Problems Cards Horizontal List
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: CarouselSlider(
                items: sections.map((section) {
                  return Builder(
                    builder: (context) {
                      double screenHeight = MediaQuery.of(context).size.height;
                      double cardHeight =
                          screenHeight * 0.33; // about 33% of screen height
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PdfViewPage(
                                section['problemsPdf']!,
                              ), // your PDF viewer page
                            ),
                          );
                        },
                        child: Card(
                          color:
                              isDark ? Colors.grey.shade900 : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: SizedBox(
                            height: cardHeight,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  section['image']!,
                                  height:
                                      cardHeight * 0.5, // 50% of card height
                                  fit: BoxFit.cover,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  '${section['title']} Problems',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: textColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8),
                                ElevatedButton.icon(
                                  icon: Icon(Icons.picture_as_pdf),
                                  label: Text('View Problems PDF'),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PdfViewPage(
                                          section['problemsPdf']!,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(
                                      150,
                                      40,
                                    ), // width can be adjusted
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
                options: CarouselOptions(
                  height:
                      MediaQuery.of(context).size.height *
                          0.40, // adjust height for card + button
                  viewportFraction: 0.7,
                  autoPlay: false,
                  enlargeCenterPage: true,
                ),
              ),
            ),

            SizedBox(height: 24),

            // Instructors Administration Full Width Card
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Instructors Administration',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: Icon(Icons.picture_as_pdf),
                        label: Text('View Instructors PDF'),
                        onPressed: () {
                          //Navigator.push(
                          //context,
                          //MaterialPageRoute(
                          //builder: (context) => PdfViewPage(sections['problemsPdf']!),
                          //),
                          //);
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      ElevatedButton.icon(
                        icon: Icon(Icons.upload_file),
                        label: Text('Upload Instructors Excel'),
                        onPressed: () async {
                          FilePickerResult? result = await FilePicker.platform
                              .pickFiles(
                                  type: FileType.custom,
                                  allowedExtensions: ['xlsx']);
                          if (result != null) {
                            var bytes = result.files.first.bytes;
                            var excel = Excel.decodeBytes(bytes!);
                            var sheet = excel.tables.keys.first;
                            var rows = excel.tables[sheet]?.rows;
                            print('Instructors Excel uploaded: $rows');
                            // Add your processing logic here
                          } else {
                            print('No Instructors Excel file selected');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 24),
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