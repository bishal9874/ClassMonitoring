import 'package:classmonitor/screens/LoginScreen.dart';
import 'package:classmonitor/screens/SignupScreen.dart';
import 'package:classmonitor/screens/UserManagement.dart';
import 'package:classmonitor/utils/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bool isLoggedIn = await UserAccountService.isUserLoggedIn();
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1E88E5);
    const primaryDarkColor = Color(0xFF0D47A1);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Class Monitor',

      // --- THEME DEFINITION ---
      theme: ThemeData(
        // Use ColorScheme for a modern and consistent color palette
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: primaryDarkColor,
        ),

        // Set the default font for the entire app
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),

        // Define the default style for all AppBars
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white, // Color for title and icons
          elevation: 0,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),

        // Define the default style for all Cards
        // cardTheme: CardTheme(
        //   elevation: 4,
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(12),
        //   ),
        // ),

        // Define the default style for CircularProgressIndicator
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: primaryColor,
        ),
      ),
      initialRoute: isLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/home': (_) => const UserManagementScreen(),
      },
    );
  }
}
