import 'package:classmonitor/screens/LoginScreen.dart';
import 'package:classmonitor/utils/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:classmonitor/screens/adminScreens/CreateUserScreen.dart';
import 'package:classmonitor/screens/adminScreens/UserListScreen.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  int _studentCount = 0;
  int _teacherCount = 0;
  int _totalClasses = 0;
  int _ongoingClasses = 0;
  int _upcomingClasses = 0;
  int _missedClasses = 0;

  DateTime _selectedDate = DateTime.now(); // New state variable for the date

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _fetchClassStatus();
  }

  Future<void> _fetchUsers() async {
    try {
      final users = await ApiService.getAllUsers();
      if (mounted) {
        setState(() {
          _studentCount = users
              .where((user) => user.role == UserRole.student)
              .length;
          _teacherCount = users
              .where((user) => user.role == UserRole.teacher)
              .length;
        });
      }
    } catch (e) {
      if (mounted) {
        print('Error fetching users: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load user data. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Updated method to accept an optional date
  Future<void> _fetchClassStatus([DateTime? date]) async {
    final dateToFetch = date ?? _selectedDate;
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _totalClasses = 15;
        _ongoingClasses = 3;
        _upcomingClasses = 5;
        _missedClasses = 10;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF2575fc), // Header background color
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2575fc), // Selection color
              onPrimary: Colors.white, // Text color on primary
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _fetchClassStatus(picked); // Fetch data for the new date
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
        automaticallyImplyLeading: false,
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
            colors: [Color.fromARGB(255, 255, 255, 255), Color(0xFF667eea)],
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
                Icon(Icons.school, size: 80, color: const Color(0xFF2c3e50)),
                const SizedBox(height: 20),
                Text(
                  'Hello, Super Admin!',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2c3e50),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Keep your classroom community thriving!',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: const Color.fromARGB(255, 72, 72, 72),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                _buildActionButtons(),

                const SizedBox(height: 30),

                _buildDateSelector(), // New date selector widget

                const SizedBox(height: 30),

                _buildClassStatus(),

                const SizedBox(height: 30),

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
                        color: const Color(0xFF9013fe),
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          textStyle: GoogleFonts.poppins(
                            color: Colors.black87,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

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
                    backgroundColor: const Color(0xFFecf0f1),
                    textColor: const Color(0xFF2c3e50),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserListScreen(),
                        ),
                      ).then((_) => _fetchUsers());
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

  Widget _buildDateSelector() {
    return Card(
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(horizontal: 0),
      color: Colors.white.withOpacity(0.95),
      child: InkWell(
        onTap: () => _selectDate(context),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Viewing Data For:',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF7f8c8d),
                    ),
                  ),
                  Text(
                    '${_selectedDate.day}-${_selectedDate.month}-${_selectedDate.year}',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2c3e50),
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.calendar_today,
                size: 30,
                color: Color(0xFF2575fc),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassStatus() {
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
              'Today\'s Class Status',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2c3e50),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 16.0,
              runSpacing: 16.0,
              alignment: WrapAlignment.center,
              children: [
                _buildMetricCard(
                  icon: Icons.check_circle_outline,
                  label: 'Total Classes',
                  count: _totalClasses,
                  color: const Color(0xFF2ecc71),
                ),
                _buildMetricCard(
                  icon: Icons.access_time_filled,
                  label: 'Ongoing Classes',
                  count: _ongoingClasses,
                  color: const Color(0xFFf1c40f),
                ),
                _buildMetricCard(
                  icon: Icons.schedule,
                  label: 'Upcoming Classes',
                  count: _upcomingClasses,
                  color: const Color(0xFF3498db),
                ),
                _buildMetricCard(
                  icon: Icons.cancel_outlined,
                  label: 'Missed Classes',
                  count: _missedClasses,
                  color: const Color(0xFFe74c3c),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return SizedBox(
      width: 110,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Icon(icon, size: 30, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2c3e50),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$count',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
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
