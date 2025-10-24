// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agileprojects/main.dart';

void main() {
  testWidgets('MyHomePage smoke test and interaction test', (WidgetTester tester) async {
    // Build MyHomePage widget
    await tester.pumpWidget(MaterialApp(home: MyHomePage()));

    // Verify initial UI elements
    expect(find.text('University portal'), findsOneWidget);
    expect(find.byIcon(Icons.brightness_2), findsOneWidget); // Initially dark mode off, shows moon icon

    // Tap the dark mode toggle icon to switch to dark mode
    await tester.tap(find.byIcon(Icons.brightness_2));
    await tester.pumpAndSettle();

    // Check if icon changed to sun indicating dark mode is on
    expect(find.byIcon(Icons.sunny), findsOneWidget);

    // Scroll courses list to the right
    final coursesListFinder = find.byType(ListView);
    expect(coursesListFinder, findsOneWidget);
    await tester.drag(coursesListFinder, const Offset(-300.0, 0.0));
    await tester.pumpAndSettle();

    // Tap on BottomNavigationBar 'Profile' icon (index 1) to navigate to DashboardScreen
    await tester.tap(find.byIcon(Icons.person_outline_outlined));
    await tester.pumpAndSettle();

    // Since pushReplacement is used, MyHomePage is replaced by DashboardScreen
    expect(find.byType(DashboardScreen), findsOneWidget);

    group('MyHomePage additional tests', () {
      testWidgets('Initial dark mode flag is false', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: MyHomePage()));

        // Initially the dark mode icon should be moon
        expect(find.byIcon(Icons.brightness_2), findsOneWidget);
      });

      testWidgets('Schedules carousel displays all items', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: MyHomePage()));

        // There should be 3 schedule cards
        expect(find.text('Midterms Schedule'), findsOneWidget);
        expect(find.text('Courses Schedule'), findsOneWidget);
        expect(find.text('Finals Schedule'), findsOneWidget);
      });

      testWidgets('Courses list scrolls with arrow buttons', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: MyHomePage()));

        // Initially find the courses list
        final coursesListFinder = find.byType(ListView);
        expect(coursesListFinder, findsOneWidget);

        // Tap the forward arrow
        await tester.tap(find.widgetWithIcon(IconButton, Icons.arrow_forward_ios));
        await tester.pumpAndSettle();

        // Tap the backward arrow
        await tester.tap(find.widgetWithIcon(IconButton, Icons.arrow_back_ios));
        await tester.pumpAndSettle();

        // If no exceptions occur, test passes for scroll buttons functionality
      });

      testWidgets('Tapping schedule navigates to PdfViewPage', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: MyHomePage()));

        // Tap on the first schedule card
        final scheduleCard = find.text('Midterms Schedule');
        expect(scheduleCard, findsOneWidget);

        await tester.tap(scheduleCard);
        await tester.pumpAndSettle();

        // Verify navigation to PdfViewPage by checking its presence
        expect(find.byType(PdfViewPage), findsOneWidget);
      });
      testWidgets('BottomNavigationBar navigation test', (WidgetTester tester) async {
        // Build MyHomePage widget
        await tester.pumpWidget(MaterialApp(home: MyHomePage()));

        // Verify that Home tab is initially selected
        expect(find.byIcon(Icons.home), findsOneWidget);

        // Tap Profile tab (index 1) and verify navigation to DashboardScreen
        await tester.tap(find.byIcon(Icons.person_outline_outlined));
        await tester.pumpAndSettle();
        expect(find.byType(DashboardScreen), findsOneWidget);

        // Tap Login tab (index 2) and verify navigation to UniversityLoginPage
        await tester.tap(find.byIcon(Icons.login));
        await tester.pumpAndSettle();
        expect(find.byType(UniversityLoginPage), findsOneWidget);

        // Tap Home tab (index 0) and verify navigation back to MyHomePage
        await tester.tap(find.byIcon(Icons.home));
        await tester.pumpAndSettle();
        expect(find.byType(MyHomePage), findsOneWidget);

        // Messages tab (index 3) not implemented, so tapping it does nothing
        await tester.tap(find.byIcon(Icons.message));
        await tester.pumpAndSettle();

        // Should still be on MyHomePage after tapping messages tab
        expect(find.byType(MyHomePage), findsOneWidget);
      });
    });   // You can add more navigation tests for Login and Home similarly if needed
    group('UniversityLoginPage tests', () {
      testWidgets('Initial UI loads correctly', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: UniversityLoginPage()));

        expect(find.text('Email...'), findsOneWidget);
        expect(find.text('Password...'), findsOneWidget);
        expect(find.text('Login'), findsOneWidget);
        expect(find.text('Forgot Password?'), findsOneWidget);
        expect(find.text('Register'), findsOneWidget);
      });

      testWidgets('Email field validation', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: UniversityLoginPage()));
        final Finder emailField = find.byType(TextFormField).at(0);

        // Empty email triggers error
        await tester.enterText(emailField, '');
        await tester.tap(find.text('Login'));
        await tester.pump();
        expect(find.text('Please enter your Email'), findsOneWidget);

        // Invalid email suffix triggers error
        await tester.enterText(emailField, 'user@gmail.com');
        await tester.tap(find.text('Login'));
        await tester.pump();
        expect(find.text('email must end with "eng.asu.edu.eg"'), findsOneWidget);

        // Valid email removes error
        await tester.enterText(emailField, 'user@eng.asu.edu.eg');
        await tester.tap(find.text('Login'));
        await tester.pump();
        expect(find.text('Please enter your Email'), findsNothing);
        expect(find.text('email must end with "eng.asu.edu.eg"'), findsNothing);
      });

      testWidgets('Password field validation', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: UniversityLoginPage()));
        final Finder passwordField = find.byType(TextFormField).at(1);

        // Empty password triggers error
        await tester.enterText(passwordField, '');
        await tester.tap(find.text('Login'));
        await tester.pump();
        expect(find.text('Please enter your password'), findsOneWidget);

        // Password less than 8 chars triggers error
        await tester.enterText(passwordField, 'Abc1!');
        await tester.tap(find.text('Login'));
        await tester.pump();
        expect(find.text('Password must be at least 8 characters'), findsOneWidget);

        // No uppercase triggers error
        await tester.enterText(passwordField, 'password!');
        await tester.tap(find.text('Login'));
        await tester.pump();
        expect(find.text('Password must contain at least one uppercase letter'), findsOneWidget);

        // Not ending with special character triggers error
        await tester.enterText(passwordField, 'Password1');
        await tester.tap(find.text('Login'));
        await tester.pump();
        expect(find.text('Password must end with a special character'), findsOneWidget);

        // Valid password clears errors
        await tester.enterText(passwordField, 'Password!');
        await tester.tap(find.text('Login'));
        await tester.pump();
        expect(find.text('Please enter your password'), findsNothing);
        expect(find.text('Password must be at least 8 characters'), findsNothing);
        expect(find.text('Password must contain at least one uppercase letter'), findsNothing);
        expect(find.text('Password must end with a special character'), findsNothing);
      });

      testWidgets('Password visibility toggle works', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: UniversityLoginPage()));
        final Finder passwordField = find.byType(TextFormField).at(1);
        final Finder toggleButton = find.byIcon(Icons.visibility_off);

        // Initially obscureText = true, visibility_off icon shown
        expect(toggleButton, findsOneWidget);

        // Tap to toggle password visibility
        await tester.tap(toggleButton);
        await tester.pump();

        // Icon should change to visibility
        expect(find.byIcon(Icons.visibility), findsOneWidget);
      });

      testWidgets('Successful login navigates to MyHomePage', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: UniversityLoginPage()));

        await tester.enterText(find.byType(TextFormField).at(0), 'user@eng.asu.edu.eg');
        await tester.enterText(find.byType(TextFormField).at(1), 'Password!');

        await tester.tap(find.text('Login'));
        await tester.pumpAndSettle();

        expect(find.byType(MyHomePage), findsOneWidget);
      });
    });
    testWidgets('PdfViewPage back button pops navigation', (WidgetTester tester) async {
      // Build a test app with MyHomePage as initial route
      await tester.pumpWidget(MaterialApp(
        home: MyHomePage(),
        routes: {
          '/pdfView': (context) => PdfViewPage('assets/sample.pdf'),
        },
      ));

      // Navigate to PdfViewPage
      Navigator.of(tester.element(find.byType(MyHomePage))).pushNamed('/pdfView');
      await tester.pumpAndSettle();

      // Verify PdfViewPage is visible
      expect(find.text('PDF Viewer'), findsOneWidget);

      // Tap the back arrow icon to pop the page
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify we returned to MyHomePage
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.text('PDF Viewer'), findsNothing);
    });
    group("Dashboard Tests", () async {
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Welcome to the Faculty SIS System'),findsOneWidget);
      expect(find.byIcon(Icons.brightness_2), findsOneWidget); // Initially dark mode off, shows moon icon

      // Tap the dark mode toggle icon to switch to dark mode
      await tester.tap(find.byIcon(Icons.brightness_2));
      await tester.pumpAndSettle();

      // Check if icon changed to sun indicating dark mode is on
      expect(find.byIcon(Icons.sunny), findsOneWidget);

      testWidgets('BottomNavigationBar navigation test', (WidgetTester tester) async {
        // Build MyHomePage widget
        await tester.pumpWidget(MaterialApp(home: MyHomePage()));

        // Verify that personal tab is initially selected
        expect(find.byIcon(Icons.person_outline_outlined), findsOneWidget);

        // Tap Profile tab (index 1) and verify navigation to DashboardScreen
        await tester.tap(find.byIcon(Icons.person_outline_outlined));
        await tester.pumpAndSettle();
        expect(find.byType(DashboardScreen), findsOneWidget);

        // Tap Login tab (index 2) and verify navigation to UniversityLoginPage
        await tester.tap(find.byIcon(Icons.login));
        await tester.pumpAndSettle();
        expect(find.byType(UniversityLoginPage), findsOneWidget);

        // Tap Home tab (index 0) and verify navigation back to MyHomePage
        await tester.tap(find.byIcon(Icons.home));
        await tester.pumpAndSettle();
        expect(find.byType(MyHomePage), findsOneWidget);

        // Messages tab (index 3) not implemented, so tapping it does nothing
        await tester.tap(find.byIcon(Icons.message));
        await tester.pumpAndSettle();

        // Should still be on MyHomePage after tapping messages tab
        expect(find.byType(DashboardScreen), findsOneWidget);
      });

    });
    testWidgets("Cards test", (WidgetTester tester) async{
      await tester.pumpWidget(MaterialApp(home: DashboardScreen()));
      expect(find.text('CUMULATIVE GPA'), findsOneWidget);
      expect(find.text('TRAINING WEEKS'), findsOneWidget);
      expect(find.text('CREDIT HOURS'), findsOneWidget);

    });
    testWidgets('Dark mode toggles card and text colors in DashboardScreen', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: DashboardScreen()));

      // Initial colors in light mode
      final cardFinder = find.byWidgetPredicate((widget) =>
      widget is Container && widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).color == Colors.indigo);
      expect(cardFinder, findsWidgets);

      final textFinder = find.text('Dashboard');
      Text dashboardText = tester.widget(textFinder);
      expect(dashboardText.style?.color, Colors.black);

      // Tap dark mode button (brightness_2 icon)
      final darkModeButton = find.byIcon(Icons.brightness_2);
      expect(darkModeButton, findsOneWidget);
      await tester.tap(darkModeButton);
      await tester.pumpAndSettle();

      // Colors after dark mode toggled
      final darkCardFinder = find.byWidgetPredicate((widget) =>
      widget is Container && widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).color == Colors.orange);
      expect(darkCardFinder, findsWidgets);

      final darkTextFinder = find.text('Dashboard');
      dashboardText = tester.widget(darkTextFinder);
      expect(dashboardText.style?.color, Colors.white);
    });
  });
}
