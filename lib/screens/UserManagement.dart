import 'package:classmonitor/screens/LoginScreen.dart';
import 'package:classmonitor/screens/TimeLineScreen.dart';
import 'package:classmonitor/utils/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:classmonitor/models/user_account.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  late Future<UserAccount> _currentUserFuture;
  late Future<List<UserAccount>> _allUsersFuture;

  @override
  void initState() {
    super.initState();
    _currentUserFuture = UserAccountService().getCurrentUser();
    _allUsersFuture = UserAccountService().getAllUsers();
  }

  Future<void> _logout() async {
    await UserAccountService().logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(child: _buildSectionTitle('Your Profile')),
              const SizedBox(height: 12),
              FadeInUp(child: _buildCurrentUserSection()),
              const SizedBox(height: 24),
              FadeInDown(child: _buildScheduleCard()),
              const SizedBox(height: 24),
              FadeInDown(child: _buildSectionTitle('All Registered Users')),
              const SizedBox(height: 12),
              FadeInUp(child: _buildAllUsersSection()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF0D47A1),
      ),
    );
  }

  Widget _buildCurrentUserSection() {
    return FutureBuilder<UserAccount>(
      future: _currentUserFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E88E5)),
            ),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return _buildErrorCard('Could not load your profile.');
        }
        final user = snapshot.data!;
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Color(0xFFFFFFFF), Color(0xFFF1F8FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF1E88E5),
                child: Text(
                  user.username?[0].toUpperCase() ?? 'N/A',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                user.username ?? 'N/A',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0D47A1),
                ),
              ),
              subtitle: Text(
                'Dept: ${user.dept ?? 'N/A'}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildScheduleCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TimeLineScreen()),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const Icon(Icons.calendar_today, color: Colors.white),
            title: Text(
              'View Class Schedule',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildAllUsersSection() {
    return FutureBuilder<List<UserAccount>>(
      future: _allUsersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E88E5)),
            ),
          );
        }
        if (snapshot.hasError) {
          return _buildErrorCard('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildErrorCard('No users found.');
        }
        final users = snapshot.data!;
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Column(
              children: users
                  .asMap()
                  .entries
                  .map(
                    (entry) => FadeInUp(
                      delay: Duration(milliseconds: 100 * entry.key),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Text(
                          entry.value.username ?? 'No Username',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF0D47A1),
                          ),
                        ),
                        subtitle: Text(
                          entry.value.dept ?? 'No Department',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: const Icon(
                          Icons.person_outline,
                          color: Color(0xFF1E88E5),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorCard(String message) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          message,
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.red[700]),
        ),
      ),
    );
  }
}
