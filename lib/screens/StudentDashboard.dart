import 'package:classmonitor/screens/LoginScreen.dart';
import 'package:classmonitor/screens/TimeLineScreen.dart';
import 'package:classmonitor/utils/ApiService.dart';
import 'package:classmonitor/models/user_account.dart'; // Import the UserAccount model
import 'package:flutter/material.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  UserAccount? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails(); // Fetch user details when the dashboard initializes
  }

  Future<void> _fetchUserDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final user = await ApiService.getCurrentUserDetails();
      setState(() {
        _currentUser = user;
      });
    } catch (e) {
      debugPrint('Error fetching user details in StudentDashboard: $e');
      setState(() {
        _errorMessage =
            'Failed to load user details: ${e.toString().replaceFirst('Exception: ', '')}';
        // If getting details fails, it might be due to a token issue, so log out.
        // However, be cautious with auto-logout here; user might just have a bad connection.
        // For production, you might want to differentiate network errors vs token expiry.
        _logout(); // Log out if user details cannot be fetched
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await ApiService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh), // Add a refresh button for details
            tooltip: 'Refresh Details',
            onPressed: _isLoading
                ? null
                : _fetchUserDetails, // Disable while loading
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator() // Show loading spinner
            : _errorMessage != null
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _fetchUserDetails,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : _currentUser == null
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person_off, size: 60, color: Colors.grey),
                    const SizedBox(height: 10),
                    const Text(
                      'No user details available.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _fetchUserDetails,
                      child: const Text('Reload Details'),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.school, size: 80, color: Colors.indigo),
                  const SizedBox(height: 20),
                  Text(
                    'Welcome, ${_currentUser!.username}!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Role: ${_currentUser!.role.name}', // Display role
                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                  if (_currentUser!.dept.isNotEmpty)
                    Text(
                      'Department: ${_currentUser!.dept}',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  if (_currentUser!.prog.isNotEmpty)
                    Text(
                      'Program: ${_currentUser!.prog}',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  if (_currentUser!.sem > 0)
                    Text(
                      'Semester: ${_currentUser!.sem}',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  if (_currentUser!.sec.isNotEmpty)
                    Text(
                      'Section: ${_currentUser!.sec}',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      // Placeholder for a student-specific action

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TimeLineScreen(),
                        ),
                      );

                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   const SnackBar(
                      //     content: Text(
                      //       'Viewing your schedule... (Not implemented)',
                      //     ),
                      //   ),
                      // );
                    },
                    child: const Text('View My Schedule'),
                  ),
                ],
              ),
      ),
    );
  }
}
