import 'package:classmonitor/screens/LoginScreen.dart';
import 'package:classmonitor/screens/StudentDashboard.dart';
import 'package:classmonitor/screens/adminScreens/SuperAdminDashboard.dart';
import 'package:classmonitor/screens/TeacherDashboard.dart';
import 'package:classmonitor/utils/ApiService.dart';
import 'package:classmonitor/models/user_account.dart'; // Import UserRole enum from here
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.init();

  final isLoggedIn = await ApiService.isUserLoggedIn();
  final role = await ApiService.getRole();

  debugPrint('App start - IsLoggedIn: $isLoggedIn, Initial Role: $role');

  runApp(MyApp(isLoggedIn: isLoggedIn, initialRole: role));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final UserRole? initialRole;

  const MyApp({super.key, required this.isLoggedIn, this.initialRole});

  Widget _getInitialScreen() {
    if (isLoggedIn && initialRole != null) {
      switch (initialRole!) {
        case UserRole.student:
          return const StudentDashboard();
        case UserRole.teacher:
          return const TeacherDashboard();
        case UserRole.superAdmin:
          return const SuperAdminDashboard();
      }
    } else {
      debugPrint(
        'User not logged in or initial role not found. Navigating to LoginScreen.',
      );
      return const LoginScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Class Monitor',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      home: _getInitialScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
