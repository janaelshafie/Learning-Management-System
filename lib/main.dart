import 'package:flutter/material.dart';

// Import your new login page file
import 'screens/auth/university_login_page.dart';

// Import your api_services file (it's not used here, but was in your original main)
// If ApiService is not needed in main.dart or MyApp, you can remove this.
// But your original file had it.

// These imports are no longer needed in main.dart
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:excel/excel.dart';

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