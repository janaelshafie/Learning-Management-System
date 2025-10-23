import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:agileprojects/api_services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',

      // No theme or darkTheme defined here, app uses system default style
      debugShowCheckedModeBanner: false,
      home: const UniversityLoginPage(),
    );
  }
}

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
    final primaryColor = isDarkMode
        ? Colors.deepPurple.shade700
        : Colors.blue.shade700;
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
                        color: isDarkMode ? Colors.grey.shade900 : Colors.white,
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

class PdfViewPage extends StatelessWidget {
  final String pdfAsset;
  PdfViewPage(this.pdfAsset);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to previous screen
          },
        ),
      ),
      body: SfPdfViewer.asset(pdfAsset),
    );
  }
}

bool isStudent = false;
bool isInstructor = false;
bool isAdmin = false;

class UniversityLoginPage extends StatefulWidget {
  const UniversityLoginPage({super.key});
  @override
  _UniversityLoginPageState createState() => _UniversityLoginPageState();
}

class _UniversityLoginPageState extends State<UniversityLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  final ApiService _apiService = ApiService();

  Future<void> _handleLogin() async {
    final email = _idController.text.trim();
    final password = _passwordController.text.trim();

    final result = await _apiService.login(email, password);

    if (result['status'] == 'success') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Login successful!')));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MyHomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Login failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7F43FF), Color(0xFFD12D69)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            double topSpacing = constraints.maxHeight * 0.12;
            double logoSize = constraints.maxWidth * 0.22;
            double inputWidth = constraints.maxWidth > 450
                ? 400
                : constraints.maxWidth * 0.85;

            return SingleChildScrollView(
              padding: EdgeInsets.only(top: topSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: logoSize / 2,
                      child: Image.asset(
                        'assets/Asu.jpg', // Use your logo path
                        fit: BoxFit.contain,
                        height: logoSize * 0.8,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    "University App",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 40),
                  // Use Form widget
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(
                          width: inputWidth,
                          child: TextFormField(
                            controller: _idController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "Email...",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your Email';
                              }
                              String email = value.trim().toLowerCase();
                              if (email.endsWith('@eng.asu.edu.eg')) {
                                isStudent = true;
                                isInstructor = false;
                                isAdmin = false;
                                return null;
                              }
                              if (email.endsWith('@prof.asu.edu.eg')) {
                                isInstructor = true;
                                isStudent = false;
                                isAdmin = false;
                                return null;
                              }
                              if (email.endsWith('@admin.asu.edu.eg')) {
                                isAdmin = true;
                                isStudent = false;
                                isInstructor = false;
                                return null;
                              }
                              isStudent = false;
                              isInstructor = false;
                              isAdmin = false;
                              return 'email must contain "@eng.asu.edu.eg" or "@prof.asu.edu.eg" or "@admin.asu.edu.eg"';
                            },
                          ),
                        ),
                        SizedBox(height: 18),
                        SizedBox(
                          width: inputWidth,
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "Password...",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 8) {
                                return 'Password must be at least 8 characters';
                              }
                              if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                return 'Password must contain at least one uppercase letter';
                              }
                              if (!RegExp(
                                r'[!@#\$%^&*(),.?":{}|<>]$',
                              ).hasMatch(value)) {
                                return 'Password must end with a special character';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 26),
                        SizedBox(
                          width: inputWidth,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(26),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              if (_formKey.currentState?.validate() == true) {
                                // If valid, proceed to login
                                _handleLogin();
                              }
                            },
                            child: Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 22),
                  TextButton(
                    onPressed: () {
                      // Handle forgot password
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.1),
                  TextButton(
                    onPressed: () {
                      // Handle registration logic or navigation
                    },
                    child: Text(
                      "Register",
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

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
    final primaryColor = isDark
        ? Colors.deepPurple.shade700
        : Colors.blue.shade700;
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

class InstructorScreen extends StatefulWidget {
  const InstructorScreen({super.key});

  @override
  State<InstructorScreen> createState() => _InstructorScreenState();
}

class _InstructorScreenState extends State<InstructorScreen> {
  bool isDark = false;
  int _selectedIndex = 1;
  bool isStudent = false; // Set properly

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

    final List<Map<String, dynamic>> courses = [
      {'title': 'Agile Software', 'image': 'assets/Ai.jpg', 'rating': 4.7},
      {
        'title': 'Software Engineering',
        'image': 'assets/Cybersecurity.jpg',
        'rating': 4.4,
      },
      {'title': 'CS101', 'image': 'assets/Parallel.jpg', 'rating': 4.2},
      {
        'title': 'Software Testing',
        'image': 'assets/DataScience.jpg',
        'rating': 4.6,
      },
    ];

    final primaryColor = isDark
        ? Colors.deepPurple.shade700
        : Colors.blue.shade700;
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
                                        borderRadius: BorderRadius.circular(12),
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
                                            var sheet = excel.tables.keys.first;
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
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            'Upload Grades Excel',
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
                                        borderRadius: BorderRadius.circular(10),
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
    final primaryColor = isDark
        ? Colors.deepPurple.shade700
        : Colors.blue.shade700;
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
                                        borderRadius: BorderRadius.circular(12),
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
                                            var sheet = excel.tables.keys.first;
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
                          color: isDark ? Colors.grey.shade900 : Colors.white,
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
                                allowedExtensions: ['xlsx'],
                              );
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
