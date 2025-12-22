import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

// Imports for the new structure
import '../../services/api_services.dart'; // For ApiService
import '../../common/app_state.dart'; // For global state variables
import '../home/my_home_page.dart'; // For navigation to MyHomePage
import '../student/student_dashboard_screen.dart'; // For student dashboard
import '../instructor/Instructor_screen.dart'; // For instructor dashboard
import '../parent/parent_dashboard_screen.dart'; // For parent dashboard
import 'signup_screen.dart'; // For signup screen navigation
import '../admin/admin_main_screen.dart'; // For admin dashboard

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

  ////************************this is the real function for login********************************* */
  Future<void> _handleLogin() async {
    final email = _idController.text.trim();
    final password = _passwordController.text.trim();

    final result = await _apiService.login(email, password);

    if (result['status'] == 'success') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Login successful!')));

      // Set global role flags
      isStudent = false;
      isInstructor = false;
      isAdmin = false;
      currentUserId = result['userId'] ?? 0; // Store the current user ID

      if (result['role'] == 'admin') {
        isAdmin = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminMainScreen()),
        );
      } else if (result['role'] == 'instructor') {
        isInstructor = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => InstructorScreen(userEmail: email)),
        );
      } else if (result['role'] == 'student') {
        isStudent = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => StudentDashboardScreen(userEmail: email),
          ),
        );
      } else if (result['role'] == 'parent') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ParentDashboardScreen(userEmail: email),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MyHomePage()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Login failed')),
      );
    }
  }

  //************************this is a dummy function for login********************************* */
  // TEMPORARY FUNCTION FOR TESTING WITHOUT BACKEND
  // Future<void> _handleLogin() async {
  //   // We comment out the real API call:
  //   // final email = _idController.text.trim();
  //   // final password = _passwordController.text.trim();
  //   // final result = await _apiService.login(email, password);

  //   // Instead, we just pretend the login is always successful
  //   final result = {'status': 'success'}; // FAKE SUCCESS!

  //   if (result['status'] == 'success') {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text('Login successful! (Mocked)')));

  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (_) => MyHomePage()),
  //     );
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(result['message'] ?? 'Login failed')),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1200;

    return Scaffold(
      body: isDesktop
          ? Row(
              children: [
                // Left side - White background with smaller login form
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.white,
                    child: Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(80),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 480),
                          child: _buildLoginCard(context),
                        ),
                      ),
                    ),
                  ),
                ),
                // Right side - Background image with text and blur effect
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/ASU_home.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Dark overlay on top of image for contrast
                        Container(color: Colors.black.withOpacity(0.5)),
                        // Learning Management System text - more prominent
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Learning',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 64,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      offset: Offset(3, 3),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Management',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 64,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      offset: Offset(3, 3),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'System',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 64,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      offset: Offset(3, 3),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 24),
                              Container(
                                height: 4,
                                width: 120,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Container(
              color: Colors.white,
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 400),
                    child: _buildLoginCard(context),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ASU Logo - larger, no blue box
        Image.asset(
          'assets/Asu.jpg',
          height: 100,
          width: 100,
          fit: BoxFit.contain,
        ),
        SizedBox(height: 12),

        // ASU ENG text
        Text(
          'ASU ENG',
          style: TextStyle(
            color: Color(0xFF1B3A7D),
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 32),

        // Login heading
        Text(
          'Log In',
          style: TextStyle(
            color: Color(0xFF1B3A7D),
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Welcome back',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 28),

        // Login form
        Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Email field
              Text(
                'Email ID',
                style: TextStyle(
                  color: Color(0xFF1B3A7D),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _idController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: Colors.black, fontSize: 15),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFF5F7FA),
                  hintText: 'Enter your email',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFF1B3A7D), width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: Colors.grey[500],
                    size: 22,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Password field
              Text(
                'Password',
                style: TextStyle(
                  color: Color(0xFF1B3A7D),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: TextStyle(color: Colors.black, fontSize: 15),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFF5F7FA),
                  hintText: 'Enter your password',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFF1B3A7D), width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: Colors.grey[500],
                    size: 22,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey[500],
                      size: 22,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),

              // Forgot password link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Handle forgot password
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                  ),
                  child: Text(
                    'Forgot password?',
                    style: TextStyle(
                      color: Color(0xFF1B3A7D),
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Login button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1B3A7D),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                    shadowColor: Color(0xFF1B3A7D).withOpacity(0.3),
                  ),
                  onPressed: () {
                    if (_formKey.currentState?.validate() == true) {
                      _handleLogin();
                    }
                  },
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 18),

              // Signup link
              Center(
                child: RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    children: [
                      TextSpan(
                        text: 'Sign up',
                        style: TextStyle(
                          color: Color(0xFF1B3A7D),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignupScreen(),
                              ),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
