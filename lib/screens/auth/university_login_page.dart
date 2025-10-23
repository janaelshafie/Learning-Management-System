import 'package:flutter/material.dart';

// Imports for the new structure
import '../../services/api_services.dart'; // For ApiService
import '../home/my_home_page.dart';      // For navigation to MyHomePage
import '../../common/app_state.dart';      // For global state variables

// Note: The global booleans (isStudent, isInstructor, isAdmin) are no longer
// defined here. They are imported from app_state.dart and are modified
// directly by the validator.

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
  // Future<void> _handleLogin() async {
  //   final email = _idController.text.trim();
  //   final password = _passwordController.text.trim();

  //   final result = await _apiService.login(email, password);

  //   if (result['status'] == 'success') {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text('Login successful!')));

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


//************************this is a dummy function for login********************************* */
// TEMPORARY FUNCTION FOR TESTING WITHOUT BACKEND
  Future<void> _handleLogin() async {
    // We comment out the real API call:
    // final email = _idController.text.trim();
    // final password = _passwordController.text.trim();
    // final result = await _apiService.login(email, password);

    // Instead, we just pretend the login is always successful
    final result = {'status': 'success'}; // FAKE SUCCESS!

    if (result['status'] == 'success') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Login successful! (Mocked)')));

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