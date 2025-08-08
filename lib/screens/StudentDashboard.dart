import 'package:classmonitor/screens/LoginScreen.dart';
import 'package:classmonitor/screens/TimeLineScreen.dart';
import 'package:classmonitor/utils/ApiService.dart';
import 'package:classmonitor/models/user_account.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  UserAccount? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;
  int? _selectedBatch;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
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
        _selectedBatch ??= DateTime.now().year;
      });
    } catch (e) {
      debugPrint('Error fetching user details in StudentDashboard: $e');
      setState(() {
        _errorMessage =
            'Failed to load user details: ${e.toString().replaceFirst('Exception: ', '')}';
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              'Student Dashboard',
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 18 : 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                tooltip: 'Refresh Details',
                onPressed: _isLoading ? null : _fetchUserDetails,
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                tooltip: 'Logout',
                onPressed: _logout,
              ),
            ],
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6a11cb), Color(0xFF2575fc)],
                ),
              ),
            ),
            elevation: 4,
            shadowColor: Colors.black26,
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color.fromARGB(255, 224, 221, 227), Color(0xFF667eea)],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF4a90e2),
                        ),
                      )
                    : _errorMessage != null
                    ? _buildMessageCard(
                        isSmallScreen: isSmallScreen,
                        icon: Icons.error_outline,
                        iconColor: Colors.red.shade600,
                        message: _errorMessage!,
                        messageColor: Colors.red.shade700,
                        buttonText: 'Retry',
                        onButtonPressed: _fetchUserDetails,
                      )
                    : _currentUser == null
                    ? _buildMessageCard(
                        isSmallScreen: isSmallScreen,
                        icon: Icons.person_off,
                        iconColor: Colors.grey.shade600,
                        message: 'No user details available. Please reload.',
                        messageColor: Colors.grey.shade700,
                        buttonText: 'Reload Details',
                        onButtonPressed: _fetchUserDetails,
                      )
                    : SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 16.0 : 32.0,
                          vertical: isSmallScreen ? 16.0 : 24.0,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isSmallScreen ? double.infinity : 400,
                          ),
                          child: _buildUserDetailsCard(isSmallScreen),
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageCard({
    required IconData icon,
    required Color iconColor,
    required String message,
    required Color messageColor,
    required String buttonText,
    required VoidCallback onButtonPressed,
    required bool isSmallScreen,
  }) {
    return Card(
      elevation: 10,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: Colors.white.withOpacity(0.95),
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16.0 : 48.0),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: isSmallScreen ? 50 : 60, color: iconColor),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Text(
              message,
              style: GoogleFonts.poppins(
                color: messageColor,
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isSmallScreen ? 16 : 24),
            ElevatedButton(
              onPressed: onButtonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4a90e2), Color(0xFF9013fe)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 18 : 24,
                    vertical: isSmallScreen ? 10 : 12,
                  ),
                  child: Text(
                    buttonText,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserDetailsCard(bool isSmallScreen) {
    final currentYear = DateTime.now().year;

    return Card(
      elevation: 10,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: Colors.white.withOpacity(0.95),
      margin: const EdgeInsets.symmetric(horizontal: 0),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 24.0 : 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF6a11cb), Color(0xFF2575fc)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4a90e2).withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.person,
                size: isSmallScreen ? 50 : 60,
                color: Colors.white,
              ),
            ),
            SizedBox(height: isSmallScreen ? 20 : 24),
            Text(
              'Welcome, ${_currentUser!.username}!',
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 24 : 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2c3e50),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isSmallScreen ? 10 : 12),
            Text(
              'Role: ${_currentUser!.role.name.toUpperCase()}',
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 16 : 18,
                color: const Color(0xFF7f8c8d),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 20),
            _buildDetailRow(
              'Department:',
              _currentUser!.dept,
              Icons.business,
              isSmallScreen,
            ),
            _buildDetailRow(
              'Program:',
              _currentUser!.prog,
              Icons.school,
              isSmallScreen,
            ),
            _buildDetailRow(
              'Semester:',
              '${_currentUser!.sem}',
              Icons.calendar_today,
              isSmallScreen,
            ),
            _buildDetailRow(
              'Section:',
              _currentUser!.sec,
              Icons.group,
              isSmallScreen,
            ),
            _buildDetailRow(
              'Section:',
              _currentUser!.batch,
              Icons.calendar_month,
              isSmallScreen,
            ),
            // Padding(
            //   padding: EdgeInsets.symmetric(
            //     vertical: isSmallScreen ? 6.0 : 8.0,
            //     horizontal: isSmallScreen ? 4.0 : 8.0,
            //   ),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Row(
            //         children: [
            //           Icon(
            //             Icons.date_range,
            //             size: isSmallScreen ? 18 : 20,
            //             color: const Color(0xFF4a90e2),
            //           ),
            //           SizedBox(width: isSmallScreen ? 6 : 8),
            //           Text(
            //             'Batch:',
            //             style: GoogleFonts.poppins(
            //               fontSize: isSmallScreen ? 14 : 16,
            //               fontWeight: FontWeight.w500,
            //               color: const Color(0xFF2c3e50),
            //             ),
            //           ),
            //         ],
            //       ),
            //       DropdownButton<int>(
            //         value: _selectedBatch,
            //         hint: Text(
            //           'Select Batch',
            //           style: GoogleFonts.poppins(
            //             fontSize: isSmallScreen ? 14 : 16,
            //             color: const Color(0xFF7f8c8d),
            //           ),
            //         ),
            //         items: List.generate(
            //           currentYear - 2019 + 1,
            //           (index) => DropdownMenuItem<int>(
            //             value: 2019 + index,
            //             child: Text(
            //               '${2019 + index}',
            //               style: GoogleFonts.poppins(
            //                 fontSize: isSmallScreen ? 14 : 16,
            //                 fontWeight: FontWeight.w400,
            //                 color: const Color(0xFF7f8c8d),
            //               ),
            //             ),
            //           ),
            //         ),
            //         onChanged: (int? newValue) {
            //           setState(() {
            //             _selectedBatch = newValue;
            //           });
            //         },
            //         underline: Container(
            //           height: 1,
            //           color: const Color(0xFF4a90e2),
            //         ),
            //         icon: const Icon(
            //           Icons.arrow_drop_down,
            //           color: Color(0xFF4a90e2),
            //         ),
            //         style: GoogleFonts.poppins(
            //           fontSize: isSmallScreen ? 14 : 16,
            //           color: const Color(0xFF7f8c8d),
            //         ),
            //         dropdownColor: Colors.white.withOpacity(0.95),
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //     ],
            //   ),
            // ),
            SizedBox(height: isSmallScreen ? 24 : 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TimeLineScreen(
                      user: _currentUser!,
                      // selectedBatch: _selectedBatch,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6a11cb), Color(0xFF2575fc)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4a90e2).withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(
                    vertical: isSmallScreen ? 14 : 16,
                  ),
                  child: Text(
                    'View My Schedule',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    bool isSmallScreen,
  ) {
    if (value.isEmpty || value == '0') return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: isSmallScreen ? 6.0 : 8.0,
        horizontal: isSmallScreen ? 4.0 : 8.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: isSmallScreen ? 18 : 20,
                color: const Color(0xFF4a90e2),
              ),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2c3e50),
                ),
              ),
            ],
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF7f8c8d),
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
