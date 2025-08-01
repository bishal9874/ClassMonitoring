import 'package:classmonitor/screens/LoginScreen.dart';
import 'package:classmonitor/utils/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:classmonitor/screens/adminScreens/CreateUserScreen.dart';
import 'package:classmonitor/screens/adminScreens/UserListScreen.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:classmonitor/models/user_account.dart'; // Import UserRole

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  int _studentCount = 0;
  int _teacherCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final users = await ApiService.getAllUsers();
      setState(() {
        _studentCount = users
            .where((user) => user.role == UserRole.student)
            .length;
        _teacherCount = users
            .where((user) => user.role == UserRole.teacher)
            .length;
      });
    } catch (e) {
      print('Error fetching users: $e');
      // Optionally show a SnackBar or a dialog to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load user data. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
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
        automaticallyImplyLeading: false,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Colors.white),
        //   onPressed: () => Navigator.of(context).pop(),
        // ),
        title: Text(
          'Super Admin Hub',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Sign Out',
            onPressed: _logout,
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              // AppBar gradient from CreateUserScreen
              colors: [Color(0xFF6a11cb), Color(0xFF2575fc)],
            ),
          ),
        ),
        elevation: 4,
        shadowColor: Colors.black26, // Consistent shadow
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // Body gradient from CreateUserScreen
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color(0xFF667eea),
              // Color(0xFFf093fb),
            ],
            // stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),
                // Welcome Section
                Icon(
                  Icons.school,
                  size: 80,
                  color: const Color(0xFF2c3e50),
                ), // Darker icon color
                const SizedBox(height: 20),
                Text(
                  'Hello, Super Admin!',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(
                      0xFF2c3e50,
                    ), // Consistent dark text color
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Keep your classroom community thriving!',
                  style: GoogleFonts.poppins(
                    // Changed to Poppins for consistency
                    fontSize: 16,
                    color: const Color.fromARGB(
                      255,
                      72,
                      72,
                      72,
                    ), // Consistent muted text color
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Action Buttons
                _buildActionButtons(),

                const SizedBox(height: 30),

                // Enrollment Overview Chart
                _buildChartCard(
                  title: 'Current Enrollment Overview',
                  chart: SfCartesianChart(
                    primaryXAxis: CategoryAxis(
                      title: AxisTitle(
                        text: 'Role',
                        textStyle: GoogleFonts.poppins(
                          color: const Color(0xFF2c3e50),
                        ),
                      ),
                      labelStyle: GoogleFonts.poppins(
                        color: const Color(0xFF7f8c8d),
                      ),
                    ),
                    primaryYAxis: NumericAxis(
                      title: AxisTitle(
                        text: 'Count',
                        textStyle: GoogleFonts.poppins(
                          color: const Color(0xFF2c3e50),
                        ),
                      ),
                      labelStyle: GoogleFonts.poppins(
                        color: const Color(0xFF7f8c8d),
                      ),
                      minimum: 0,
                      maximum:
                          (_studentCount > _teacherCount
                              ? _studentCount
                              : _teacherCount) +
                          5,
                      interval: 5,
                    ),
                    legend: Legend(
                      isVisible: true,
                      textStyle: GoogleFonts.poppins(
                        color: const Color(0xFF2c3e50),
                      ),
                    ),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <CartesianSeries<EnrollmentData, String>>[
                      ColumnSeries<EnrollmentData, String>(
                        dataSource: [
                          EnrollmentData('Students', _studentCount),
                          EnrollmentData('Teachers', _teacherCount),
                        ],
                        xValueMapper: (EnrollmentData data, _) => data.category,
                        yValueMapper: (EnrollmentData data, _) => data.count,
                        name: 'Enrollments',
                        color: const Color(0xFF4a90e2),
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          textStyle: GoogleFonts.poppins(
                            color: Colors.black87,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Class Status by Program Chart
                _buildChartCard(
                  title: 'Class Status by Program',
                  chart: SfCartesianChart(
                    primaryXAxis: CategoryAxis(
                      title: AxisTitle(
                        text: 'Program',
                        textStyle: GoogleFonts.poppins(
                          color: const Color(0xFF2c3e50),
                        ),
                      ),
                      labelStyle: GoogleFonts.poppins(
                        color: const Color(0xFF7f8c8d),
                      ),
                      labelRotation: -45,
                    ),
                    primaryYAxis: NumericAxis(
                      title: AxisTitle(
                        text: 'Students',
                        textStyle: GoogleFonts.poppins(
                          color: const Color(0xFF2c3e50),
                        ),
                      ),
                      labelStyle: GoogleFonts.poppins(
                        color: const Color(0xFF7f8c8d),
                      ),
                      minimum: 0,
                      maximum: 50,
                      interval: 10,
                    ),
                    legend: Legend(
                      isVisible: true,
                      textStyle: GoogleFonts.poppins(
                        color: const Color(0xFF2c3e50),
                      ),
                    ),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <CartesianSeries<ProgramData, String>>[
                      ColumnSeries<ProgramData, String>(
                        dataSource: [
                          ProgramData('CSE (General)', 45),
                          ProgramData('CSE (AI & ML)', 30),
                          ProgramData('CSE (Cyber Sec)', 20),
                          ProgramData('CSE (Data Sci)', 25),
                          ProgramData('CSE (Cloud)', 15),
                          ProgramData('Robotics & AI', 10),
                          ProgramData('ECE (General)', 35),
                          ProgramData('EE (General)', 20),
                        ],
                        xValueMapper: (ProgramData data, _) => data.program,
                        yValueMapper: (ProgramData data, _) =>
                            data.studentCount,
                        name: 'Students',
                        color: const Color(0xFF9013fe), // Consistent purple
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          textStyle: GoogleFonts.poppins(
                            // Poppins for data labels
                            color: Colors.black87,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Enrollment Trend Over Time Chart
                _buildChartCard(
                  title: 'Enrollment Trend (Last 6 Months)',
                  chart: SfCartesianChart(
                    primaryXAxis: CategoryAxis(
                      title: AxisTitle(
                        text: 'Month',
                        textStyle: GoogleFonts.poppins(
                          color: const Color(0xFF2c3e50),
                        ),
                      ),
                      labelStyle: GoogleFonts.poppins(
                        color: const Color(0xFF7f8c8d),
                      ),
                    ),
                    primaryYAxis: NumericAxis(
                      title: AxisTitle(
                        text: 'Students',
                        textStyle: GoogleFonts.poppins(
                          color: const Color(0xFF2c3e50),
                        ),
                      ),
                      labelStyle: GoogleFonts.poppins(
                        color: const Color(0xFF7f8c8d),
                      ),
                      minimum: 0,
                      maximum: 100,
                      interval: 20,
                    ),
                    legend: Legend(
                      isVisible: true,
                      textStyle: GoogleFonts.poppins(
                        color: const Color(0xFF2c3e50),
                      ),
                    ),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <CartesianSeries<TrendData, String>>[
                      LineSeries<TrendData, String>(
                        dataSource: [
                          TrendData('Jan', 60),
                          TrendData('Feb', 70),
                          TrendData('Mar', 80),
                          TrendData('Apr', 85),
                          TrendData('May', 90),
                          TrendData('Jun', 95),
                        ],
                        xValueMapper: (TrendData data, _) => data.month,
                        yValueMapper: (TrendData data, _) => data.count,
                        name: 'Students',
                        color: const Color(0xFFff6b6b),
                        width: 2,
                        markerSettings: const MarkerSettings(isVisible: true),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Department-wise Student Distribution Chart
                _buildChartCard(
                  title: 'Student Distribution by Department',
                  chart: SfCircularChart(
                    legend: Legend(
                      isVisible: true,
                      textStyle: GoogleFonts.poppins(
                        color: const Color(0xFF2c3e50),
                      ),
                    ),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <CircularSeries<DepartmentData, String>>[
                      PieSeries<DepartmentData, String>(
                        dataSource: [
                          DepartmentData('CSE', 150),
                          DepartmentData('ECE', 80),
                          DepartmentData('EE', 50),
                          DepartmentData('CE', 40),
                          DepartmentData('Bio-Med', 30),
                        ],
                        xValueMapper: (DepartmentData data, _) =>
                            data.department,
                        yValueMapper: (DepartmentData data, _) => data.count,
                        name: 'Students',
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          textStyle: GoogleFonts.poppins(
                            color: Colors.black87,
                            fontSize: 12,
                          ),
                        ),
                        pointColorMapper: (DepartmentData data, _) =>
                            _getDepartmentColor(data.department),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                _buildChartCard(
                  title: 'Teacher Distribution by Department',
                  chart: SfCartesianChart(
                    primaryXAxis: CategoryAxis(
                      title: AxisTitle(
                        text: 'Department',
                        textStyle: GoogleFonts.poppins(
                          color: const Color(0xFF2c3e50),
                        ),
                      ),
                      labelStyle: GoogleFonts.poppins(
                        color: const Color(0xFF7f8c8d),
                      ),
                    ),
                    primaryYAxis: NumericAxis(
                      title: AxisTitle(
                        text: 'Teachers',
                        textStyle: GoogleFonts.poppins(
                          color: const Color(0xFF2c3e50),
                        ),
                      ),
                      labelStyle: GoogleFonts.poppins(
                        color: const Color(0xFF7f8c8d),
                      ),
                      minimum: 0,
                      maximum: 30,
                      interval: 5,
                    ),
                    legend: Legend(
                      isVisible: true,
                      textStyle: GoogleFonts.poppins(
                        color: const Color(0xFF2c3e50),
                      ),
                    ),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <CartesianSeries<TeacherData, String>>[
                      BarSeries<TeacherData, String>(
                        dataSource: [
                          TeacherData('CSE', 20),
                          TeacherData('ECE', 15),
                          TeacherData('EE', 10),
                          TeacherData('CE', 8),
                          TeacherData('Bio-Med', 5),
                        ],
                        xValueMapper: (TeacherData data, _) => data.department,
                        yValueMapper: (TeacherData data, _) => data.count,
                        name: 'Teachers',
                        color: const Color(0xFF4caf50),
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          textStyle: GoogleFonts.poppins(
                            color: Colors.black87,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Card(
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(horizontal: 0),
      color: Colors.white.withOpacity(0.95),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Admin Actions',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2c3e50),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.person_add,
                    label: 'Add New Member',
                    // Use gradient button for primary actions
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4a90e2), Color(0xFF9013fe)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateUserScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.group,
                    label: 'See All Members',
                    // Use a subtle background for secondary action
                    backgroundColor: const Color(0xFFecf0f1), // Light grey
                    textColor: const Color(0xFF2c3e50), // Dark text
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserListScreen(),
                        ),
                      ).then(
                        (_) => _fetchUsers(),
                      ); // Refresh user counts when returning
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color? backgroundColor,
    Color? textColor,
    Gradient? gradient,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: gradient != null
          ? BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: (gradient.colors.first).withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            )
          : BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: (backgroundColor ?? Colors.grey).withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 28, color: textColor ?? Colors.white),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor ?? Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartCard({required String title, required Widget chart}) {
    return Card(
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(horizontal: 0),
      color: Colors.white.withOpacity(0.95),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2c3e50),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            SizedBox(height: 250, child: chart),
          ],
        ),
      ),
    );
  }

  Color _getDepartmentColor(String department) {
    switch (department) {
      case 'CSE':
        return const Color(0xFF4a90e2);
      case 'ECE':
        return const Color(0xFF9013fe);
      case 'EE':
        return const Color(0xFFff6b6b);
      case 'CE':
        return const Color(0xFF4caf50);
      case 'Bio-Med':
        return const Color(0xFFffca28);
      default:
        return Colors.grey;
    }
  }
}

class EnrollmentData {
  final String category;
  final int count;

  EnrollmentData(this.category, this.count);
}

class ProgramData {
  final String program;
  final int studentCount;

  ProgramData(this.program, this.studentCount);
}

class TrendData {
  final String month;
  final int count;

  TrendData(this.month, this.count);
}

class DepartmentData {
  final String department;
  final int count;

  DepartmentData(this.department, this.count);
}

class TeacherData {
  final String department;
  final int count;

  TeacherData(this.department, this.count);
}
