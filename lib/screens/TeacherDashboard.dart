import 'package:classmonitor/screens/LoginScreen.dart';
import 'package:classmonitor/utils/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_account.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard>
    with TickerProviderStateMixin {
  late Future<UserAccount> _teacherDetailsFuture;
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Filter states
  String? _selectedDepartment;
  String? _selectedProgram;
  String? _selectedSemester;
  String? _selectedSection;

  // Futures for dropdown options (now fetching from API)
  Future<List<String>>? _departmentsFuture;
  Future<List<String>>? _programsFuture;
  Future<List<String>>? _semestersFuture;
  Future<List<String>>? _sectionsFuture;

  Future<List<UserAccount>>? _filteredUsersFuture;

  @override
  void initState() {
    super.initState();
    _teacherDetailsFuture = ApiService.getCurrentUserDetails();
    _tabController = TabController(length: 2, vsync: this);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();

    // Initialize the departments future on initState
    _departmentsFuture = ApiService.getDepartments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refreshTeacherDetails() async {
    setState(() {
      _teacherDetailsFuture = ApiService.getCurrentUserDetails();
    });
  }

  // --- API Call Functions for Dropdowns ---
  void _onDepartmentChanged(String? department) {
    setState(() {
      _selectedDepartment = department;
      _selectedProgram = null; // Reset dependent dropdowns
      _selectedSemester = null;
      _selectedSection = null;
      _filteredUsersFuture = null; // Clear previous search results

      _programsFuture = department != null
          ? ApiService.getPrograms(department)
          : null;
      _semestersFuture = null;
      _sectionsFuture = null;
    });
  }

  void _onProgramChanged(String? program) {
    setState(() {
      _selectedProgram = program;
      _selectedSemester = null; // Reset dependent dropdowns
      _selectedSection = null;
      _filteredUsersFuture = null;

      _semestersFuture = (_selectedDepartment != null && program != null)
          ? ApiService.getSemesters(_selectedDepartment!, program)
          : null;
      _sectionsFuture = null;
    });
  }

  void _onSemesterChanged(String? semester) {
    setState(() {
      _selectedSemester = semester;
      _selectedSection = null; // Reset dependent dropdowns
      _filteredUsersFuture = null;

      _sectionsFuture =
          (_selectedDepartment != null &&
              _selectedProgram != null &&
              semester != null)
          ? ApiService.getSections(
              _selectedDepartment!,
              _selectedProgram!,
              semester,
            )
          : null;
    });
  }

  void _onSectionChanged(String? section) {
    setState(() {
      _selectedSection = section;
      _filteredUsersFuture = null; // Reset when section changes
    });
  }
  // --- End API Call Functions for Dropdowns ---

  void _filterUsers() {
    if (_selectedDepartment != null &&
        _selectedProgram != null &&
        _selectedSemester != null &&
        _selectedSection != null) {
      setState(() {
        _filteredUsersFuture = ApiService.getUsersByFilters(
          _selectedDepartment!,
          _selectedProgram!,
          _selectedSemester!,
          _selectedSection!,
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select all filters to search'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedDepartment = null;
      _selectedProgram = null;
      _selectedSemester = null;
      _selectedSection = null;
      _filteredUsersFuture = null;
      _programsFuture = null; // Clear futures for dependent dropdowns
      _semestersFuture = null;
      _sectionsFuture = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Removed isDarkMode variable. Assuming light mode styling.

    return Scaffold(
      backgroundColor: Colors.grey[50], // Fixed light mode background
      appBar: _buildModernAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white.withOpacity(0.95), Colors.grey.shade50],
                ),
              ),
              child: AnimatedBuilder(
                animation: _tabController.animation!,
                builder: (context, child) {
                  return TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade500, Colors.purple.shade500],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize
                        .tab, // This makes the indicator match tab width
                    indicatorWeight: 0, // This removes any additional underline
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey[600],
                    labelStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    unselectedLabelStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                    tabs: [
                      Tab(
                        child: SizedBox(
                          width: 150,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person, size: 20),
                              SizedBox(width: 8),
                              Text('My Profile'),
                            ],
                          ),
                        ),
                      ),
                      Tab(
                        child: SizedBox(
                          width: 150,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search, size: 20),
                              SizedBox(width: 8),
                              Text('Find Users'),
                            ],
                          ),
                        ),
                      ),
                    ],
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                    splashFactory: NoSplash.splashFactory,
                  );
                },
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildProfileTab(), _buildFilterTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade600, Colors.purple.shade600],
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.school, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Teacher Dashboard',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'ClassMonitor System',
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.refresh, color: Colors.white, size: 20),
          ),
          onPressed: _refreshTeacherDetails,
          tooltip: 'Refresh Profile',
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.logout, color: Colors.white, size: 20),
          ),
          onPressed: () async {
            final shouldLogout = await _showLogoutDialog();
            if (shouldLogout) {
              await ApiService.logout();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              }
            }
          },
          tooltip: 'Logout',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Profile',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748), // Fixed color
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your personal information and details',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600], // Fixed color
            ),
          ),
          const SizedBox(height: 20),
          FutureBuilder<UserAccount>(
            future: _teacherDetailsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingCard(); // Removed isDarkMode param
              } else if (snapshot.hasError) {
                return _buildErrorCard(
                  snapshot.error.toString(),
                ); // Removed isDarkMode param
              } else if (!snapshot.hasData) {
                return _buildEmptyCard(
                  'No profile data available',
                ); // Removed isDarkMode param
              } else {
                return _buildProfileCard(
                  snapshot.data!,
                ); // Removed isDarkMode param
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab() {
    // Removed isDarkMode parameter
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Find Users',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3748), // Fixed color
                      ),
                    ),
                    Text(
                      'Filter users by department, program, semester & section',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[600], // Fixed color
                      ),
                    ),
                  ],
                ),
              ),
              if (_hasAnyFilter())
                TextButton.icon(
                  onPressed: _resetFilters,
                  icon: const Icon(Icons.clear),
                  label: const Text('Reset'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Filter Cards
          _buildFilterCard(), // Removed isDarkMode parameter
          const SizedBox(height: 20),

          // Search Button
          _buildSearchButton(), // Removed isDarkMode parameter
          const SizedBox(height: 20),

          // Results
          if (_filteredUsersFuture != null)
            _buildFilterResults(), // Removed isDarkMode parameter
        ],
      ),
    );
  }

  Widget _buildFilterCard() {
    // Removed isDarkMode parameter
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, // Fixed color
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDepartmentDropdown(),
              ), // Removed isDarkMode param
              const SizedBox(width: 12),
              Expanded(
                child: _buildProgramDropdown(),
              ), // Removed isDarkMode param
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSemesterDropdown(),
              ), // Removed isDarkMode param
              const SizedBox(width: 12),
              Expanded(
                child: _buildSectionDropdown(),
              ), // Removed isDarkMode param
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentDropdown() {
    // Removed isDarkMode parameter
    return FutureBuilder<List<String>>(
      future: _departmentsFuture,
      builder: (context, snapshot) {
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Department',
            prefixIcon: const Icon(Icons.business, color: Colors.blue),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50], // Fixed color
          ),
          value: _selectedDepartment,
          items: snapshot.hasData
              ? snapshot.data!
                    .map(
                      (dept) =>
                          DropdownMenuItem(value: dept, child: Text(dept)),
                    )
                    .toList()
              : [],
          onChanged: snapshot.hasData ? _onDepartmentChanged : null,
          hint: snapshot.connectionState == ConnectionState.waiting
              ? const Text('Loading...')
              : snapshot.hasError
              ? const Text('Error loading departments')
              : const Text('Select Department'),
          isExpanded: true,
        );
      },
    );
  }

  Widget _buildProgramDropdown() {
    // Removed isDarkMode parameter
    return FutureBuilder<List<String>>(
      future: _programsFuture,
      builder: (context, snapshot) {
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Program',
            prefixIcon: const Icon(Icons.school, color: Colors.green),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50], // Fixed color
          ),
          value: _selectedProgram,
          items: snapshot.hasData
              ? snapshot.data!
                    .map(
                      (prog) =>
                          DropdownMenuItem(value: prog, child: Text(prog)),
                    )
                    .toList()
              : [],
          onChanged: snapshot.hasData && _selectedDepartment != null
              ? _onProgramChanged
              : null,
          hint: _selectedDepartment == null
              ? const Text('Select Dept first')
              : snapshot.connectionState == ConnectionState.waiting
              ? const Text('Loading...')
              : snapshot.hasError
              ? const Text('Error loading programs')
              : const Text('Select Program'),
          isExpanded: true,
          menuMaxHeight: 300,
        );
      },
    );
  }

  Widget _buildSemesterDropdown() {
    // Removed isDarkMode parameter
    return FutureBuilder<List<String>>(
      future: _semestersFuture,
      builder: (context, snapshot) {
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Semester',
            prefixIcon: const Icon(Icons.calendar_today, color: Colors.orange),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50], // Fixed color
          ),
          value: _selectedSemester,
          items: snapshot.hasData
              ? snapshot.data!
                    .map(
                      (sem) => DropdownMenuItem(
                        value: sem,
                        child: Text('Semester $sem'),
                      ),
                    )
                    .toList()
              : [],
          onChanged: snapshot.hasData && _selectedProgram != null
              ? _onSemesterChanged
              : null,
          hint: _selectedProgram == null
              ? const Text('Select Program first')
              : snapshot.connectionState == ConnectionState.waiting
              ? const Text('Loading...')
              : snapshot.hasError
              ? const Text('Error loading semesters')
              : const Text('Select Semester'),
          isExpanded: true,
          menuMaxHeight: 300,
        );
      },
    );
  }

  Widget _buildSectionDropdown() {
    // Removed isDarkMode parameter
    return FutureBuilder<List<String>>(
      future: _sectionsFuture,
      builder: (context, snapshot) {
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Section',
            prefixIcon: const Icon(Icons.group, color: Colors.purple),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50], // Fixed color
          ),
          value: _selectedSection,
          items: snapshot.hasData
              ? snapshot.data!
                    .map(
                      (sec) => DropdownMenuItem(
                        value: sec,
                        child: Text('Section $sec'),
                      ),
                    )
                    .toList()
              : [],
          onChanged: snapshot.hasData && _selectedSemester != null
              ? _onSectionChanged
              : null,
          hint: _selectedSemester == null
              ? const Text('Select Semester first')
              : snapshot.connectionState == ConnectionState.waiting
              ? const Text('Loading...')
              : snapshot.hasError
              ? const Text('Error loading sections')
              : const Text('Select Section'),
          isExpanded: true,
          menuMaxHeight: 300,
        );
      },
    );
  }

  Widget _buildSearchButton() {
    final canSearch =
        _selectedDepartment != null &&
        _selectedProgram != null &&
        _selectedSemester != null &&
        _selectedSection != null;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        // <--- CHANGED FROM ElevatedButton.icon to ElevatedButton
        onPressed: canSearch ? _filterUsers : null,
        style: ElevatedButton.styleFrom(
          // Set background to transparent so the Ink's gradient can show through
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent, // Remove default shadow
          padding:
              EdgeInsets.zero, // Remove default padding to let Ink control it
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Ink(
          // <--- This Ink widget is now the 'child' of ElevatedButton
          decoration: BoxDecoration(
            gradient: canSearch
                ? LinearGradient(
                    colors: [Colors.blue.shade500, Colors.purple.shade500],
                  )
                : null,
            color: canSearch
                ? null
                : Colors.grey[300], // Background color when disabled
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            alignment: Alignment.center,
            // The Row with icon and text now lives inside the Ink's child
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Search Users',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterResults() {
    // Removed isDarkMode parameter
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search Results',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3748), // Fixed color
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<UserAccount>>(
          future: _filteredUsersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingCard(); // Removed isDarkMode param
            } else if (snapshot.hasError) {
              return _buildErrorCard(
                snapshot.error.toString(),
              ); // Removed isDarkMode param
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyResultsCard(); // Removed isDarkMode param
            } else {
              return Column(
                children: snapshot.data!
                    .map(
                      (user) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildUserCard(user), // Removed isDarkMode param
                      ),
                    )
                    .toList(),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildProfileCard(UserAccount teacher) {
    // Removed isDarkMode parameter
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, // Fixed color
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.purple.shade400],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacher.username,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3748), // Fixed color
                      ),
                    ),
                    Text(
                      teacher.role.name.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Profile Details
          _buildDetailRow(
            Icons.business,
            'Department',
            teacher.dept,
          ), // Removed isDarkMode param
          _buildDetailRow(
            Icons.school,
            'Program',
            teacher.prog,
          ), // Removed isDarkMode param
          _buildDetailRow(
            Icons.calendar_today,
            'Semester',
            teacher.sem.toString(),
          ), // Removed isDarkMode param
          _buildDetailRow(
            Icons.group,
            'Section',
            teacher.sec,
          ), // Removed isDarkMode param
        ],
      ),
    );
  }

  Widget _buildUserCard(UserAccount user) {
    // Removed isDarkMode parameter
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, // Fixed color
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!, // Fixed color
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Icon(Icons.person, color: Colors.blue.shade600),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87, // Fixed color
                      ),
                    ),
                    Text(
                      user.role.name.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCompactDetail('Dept', user.dept, Icons.business),
              ),
              Expanded(
                child: _buildCompactDetail('Prog', user.prog, Icons.school),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildCompactDetail(
                  'Sem',
                  user.sem.toString(),
                  Icons.calendar_today,
                ),
              ),
              Expanded(
                child: _buildCompactDetail('Sec', user.sec, Icons.group),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    // Removed isDarkMode parameter
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue.shade600, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600], // Fixed color
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.black87, // Fixed color
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactDetail(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          '$label: $value',
          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildLoadingCard() {
    // Removed isDarkMode parameter
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white, // Fixed color
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorCard(String error) {
    // Removed isDarkMode parameter
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Error: ${error.replaceFirst('Exception: ', '')}',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    // Removed isDarkMode parameter
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white, // Fixed color
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          message,
          style: GoogleFonts.inter(
            color: Colors.grey[600], // Fixed color
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyResultsCard() {
    // Removed isDarkMode parameter
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white, // Fixed color
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: Colors.grey[400], // Fixed color
          ),
          const SizedBox(height: 16),
          Text(
            'No users found',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600], // Fixed color
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[500], // Fixed color
            ),
          ),
        ],
      ),
    );
  }

  bool _hasAnyFilter() {
    return _selectedDepartment != null ||
        _selectedProgram != null ||
        _selectedSemester != null ||
        _selectedSection != null;
  }

  Future<bool> _showLogoutDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Confirm Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
