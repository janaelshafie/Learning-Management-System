import 'package:flutter/material.dart';

// Imports for the new structure
import '../../services/api_services.dart'; // For ApiService
import '../../common/app_state.dart'; // For global state variables
import '../home/my_home_page.dart'; // For navigation to MyHomePage
import '../student/student_dashboard_screen.dart'; // For student dashboard
// TODO: Uncomment when instructor dashboard is implemented
// import '../instructor/instructor_dashboard_screen.dart'; // For instructor dashboard
import 'signup_screen.dart'; // For signup screen navigation
import '../admin/admin_dashboard_screen.dart'; // For admin dashboard

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
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
      }
      // TODO: Uncomment when instructor dashboard is implemented
      // else if (result['role'] == 'instructor') {
      //   isInstructor = true;
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(builder: (_) => const InstructorScreen()),
      //   );
      // }
      else if (result['role'] == 'instructor') {
        // Instructor dashboard is not implemented yet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Instructor dashboard is not implemented yet. Please contact the administrator.',
            ),
            duration: Duration(seconds: 4),
            backgroundColor: Colors.orange,
          ),
        );
        // Don't navigate, stay on login page
        return;
      } else if (result['role'] == 'student') {
        isStudent = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => StudentDashboardScreen(userEmail: email),
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
            double topSpacing = constraints.maxHeight * 0.08;
            double logoSize = constraints.maxWidth * 0.18;
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
                  SizedBox(height: 20),
                  Text(
                    "University App",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 30),
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
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 15),
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
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 20),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                      );
                    },
                    child: Text(
                      "Don't have an account? Sign Up",
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
