import 'dart:convert';
import 'package:classmonitor/screens/LoginScreen.dart';
import 'package:classmonitor/utils/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/user_account.dart';

// Define DepartmentData and ProgramData classes within the same file for clarity
class DepartmentData {
  final String name;
  final List<ProgramData> programs;

  DepartmentData({required this.name, required this.programs});

  factory DepartmentData.fromJson(Map<String, dynamic> json) {
    var programsList = json['programs'] as List;
    List<ProgramData> programs = programsList
        .map((i) => ProgramData.fromJson(i))
        .toList();
    return DepartmentData(name: json['name'], programs: programs);
  }
}

class ProgramData {
  final String name;
  final Map<int, List<String>> semesters;
  final List<String> batches;

  ProgramData({
    required this.name,
    required this.semesters,
    required this.batches,
  });

  factory ProgramData.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> semJson = json['semesters'];
    Map<int, List<String>> semesters = {
      for (var entry in semJson.entries)
        int.parse(entry.key): List<String>.from(entry.value),
    };
    final batches = (json['batches'] as List<dynamic>?)?.cast<String>() ?? [];
    return ProgramData(
      name: json['name'],
      semesters: semesters,
      batches: batches,
    );
  }
}

class ClassMonitorData {
  List<DepartmentData> _allDepartments = [];

  Future<void> loadJson() async {
    final String jsonString = await rootBundle.loadString(
      'assets/dropdown.json',
    );
    final decodedData = json.decode(jsonString);
    final departmentsList = decodedData['departments'] as List;
    _allDepartments = departmentsList
        .map((e) => DepartmentData.fromJson(e))
        .toList();
  }

  List<DepartmentData> get allDepartments => _allDepartments;
}

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
  final ClassMonitorData _classMonitorData = ClassMonitorData();
  Future<void>? _dataLoadFuture;

  // Filter states
  String? _selectedDepartment;
  String? _selectedProgram;
  String? _selectedSemester;
  String? _selectedSection;
  String? _selectedBatch;
  DateTime? _selectedDate;

  // Lists for dropdown options
  List<String> _departments = [];
  List<String> _programs = [];
  List<String> _semesters = [];
  List<String> _sections = [];
  List<String> _batches = [];

  Future<List<UserAccount>>? _filteredUsersFuture;

  @override
  void initState() {
    super.initState();

    _selectedDate = DateTime.now();
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

    // Initialize JSON data loading
    _dataLoadFuture = _loadData();
  }

  Future<void> _loadData() async {
    await _classMonitorData.loadJson();
    if (mounted) {
      setState(() {
        _departments = _classMonitorData.allDepartments
            .map((dept) => dept.name)
            .toList();
      });
    }
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

  void _onDepartmentChanged(String? department) {
    setState(() {
      _selectedDepartment = department;
      _selectedProgram = null;
      _selectedSemester = null;
      _selectedSection = null;
      _selectedBatch = null;
      // _selectedDate = null;
      _filteredUsersFuture = null;

      if (department != null) {
        final dept = _classMonitorData.allDepartments.firstWhere(
          (d) => d.name == department,
          orElse: () => DepartmentData(name: '', programs: []),
        );
        _programs = dept.programs.map((prog) => prog.name).toList();
        _semesters = [];
        _sections = [];
        _batches = [];
      } else {
        _programs = [];
        _semesters = [];
        _sections = [];
        _batches = [];
      }
    });
  }

  void _onProgramChanged(String? program) {
    setState(() {
      _selectedProgram = program;
      _selectedSemester = null;
      _selectedSection = null;
      _selectedBatch = null;
      // _selectedDate = null;
      _filteredUsersFuture = null;

      if (program != null && _selectedDepartment != null) {
        final dept = _classMonitorData.allDepartments.firstWhere(
          (d) => d.name == _selectedDepartment,
          orElse: () => DepartmentData(name: '', programs: []),
        );
        final prog = dept.programs.firstWhere(
          (p) => p.name == program,
          orElse: () => ProgramData(name: '', semesters: {}, batches: []),
        );
        _semesters = prog.semesters.keys.map((sem) => sem.toString()).toList();
        _batches = prog.batches;
        _sections = [];
      } else {
        _semesters = [];
        _sections = [];
        _batches = [];
      }
    });
  }

  void _onSemesterChanged(String? semester) {
    setState(() {
      _selectedSemester = semester;
      _selectedSection = null;
      _selectedBatch = null;
      // _selectedDate = null;
      _filteredUsersFuture = null;

      if (semester != null &&
          _selectedProgram != null &&
          _selectedDepartment != null) {
        final dept = _classMonitorData.allDepartments.firstWhere(
          (d) => d.name == _selectedDepartment,
          orElse: () => DepartmentData(name: '', programs: []),
        );
        final prog = dept.programs.firstWhere(
          (p) => p.name == _selectedProgram,
          orElse: () => ProgramData(name: '', semesters: {}, batches: []),
        );
        final sem = int.tryParse(semester);
        _sections = sem != null ? prog.semesters[sem] ?? [] : [];
      } else {
        _sections = [];
      }
    });
  }

  void _onSectionChanged(String? section) {
    setState(() {
      _selectedSection = section;
      _selectedDate = null;
      _filteredUsersFuture = null;
    });
  }

  void _onBatchChanged(String? batch) {
    setState(() {
      _selectedBatch = batch;
      _selectedDate = null;
      _filteredUsersFuture = null;
    });
  }

  void _onDateChanged(DateTime? date) {
    setState(() {
      _selectedDate = date;
      _filteredUsersFuture = null;
    });
  }

  void _filterUsers() {
    if (_selectedDepartment != null &&
        _selectedProgram != null &&
        _selectedSemester != null &&
        _selectedSection != null &&
        _selectedBatch != null &&
        _selectedDate != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      setState(() {
        // _filteredUsersFuture = ApiService.getUsersByFilters(
        // formattedDate
        //   _selectedDepartment!,
        //   _selectedProgram!,
        //   _selectedSemester!,
        //   _selectedSection!,
        // _selectedBatch!,
        // );
        debugPrint('''
formattedDate: $formattedDate
Selected Department: $_selectedDepartment
Selected Program: $_selectedProgram
Selected Semester: $_selectedSemester
Selected Section: $_selectedSection
Selected Batch: $_selectedBatch
''');
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select all filters and a date to search',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF6a11cb),
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
      _selectedBatch = null;
      _selectedDate = DateTime.now();
      _filteredUsersFuture = null;
      _programs = [];
      _semesters = [];
      _sections = [];
      _batches = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildModernAppBar(),
      body: FutureBuilder<void>(
        future: _dataLoadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2575fc)),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading data: ${snapshot.error}',
                    style: GoogleFonts.poppins(
                      color: Colors.red.shade600,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _dataLoadFuture = _loadData();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6a11cb),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Retry',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6a11cb).withOpacity(0.2),
                        blurRadius: 12,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: AnimatedBuilder(
                    animation: _tabController.animation!,
                    builder: (context, child) {
                      return TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6a11cb), Color(0xFF2575fc)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6a11cb).withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
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
                                  const Icon(Icons.person, size: 20),
                                  const SizedBox(width: 8),
                                  const Text('My Profile'),
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
                                  const Icon(Icons.search, size: 20),
                                  const SizedBox(width: 8),
                                  const Text('Find Class'),
                                ],
                              ),
                            ),
                          ),
                        ],
                        overlayColor: MaterialStateProperty.all(
                          Colors.transparent,
                        ),
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
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6a11cb), Color(0xFF2575fc)],
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6a11cb).withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.school, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Teacher Dashboard',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'ClassMonitor System',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
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
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6a11cb).withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
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
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6a11cb).withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.logout, color: Colors.white, size: 20),
          ),
          onPressed: () async {
            final shouldLogout = await _showLogoutDialog();
            if (shouldLogout && mounted) {
              await ApiService.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
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
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A40),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your personal information and details',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 20),
          FutureBuilder<UserAccount>(
            future: _teacherDetailsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingCard();
              } else if (snapshot.hasError) {
                return _buildErrorCard(snapshot.error.toString());
              } else if (!snapshot.hasData) {
                return _buildEmptyCard('No profile data available');
              } else {
                return _buildProfileCard(snapshot.data!);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab() {
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
                      'Find Class Period To Check as done or not !',
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A40),
                      ),
                    ),
                    Text(
                      'Filter users by department, program, semester, section & batch',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              if (_hasAnyFilter())
                TextButton.icon(
                  onPressed: _resetFilters,
                  icon: const Icon(Icons.clear, color: Colors.red),
                  label: Text(
                    'Reset',
                    style: GoogleFonts.poppins(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
            ],
          ),
          const SizedBox(height: 20),
          _buildFilterCard(),
          const SizedBox(height: 20),
          _buildSearchButton(),
          const SizedBox(height: 20),
          if (_filteredUsersFuture != null) _buildFilterResults(),
        ],
      ),
    );
  }

  Widget _buildFilterCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6a11cb).withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildDepartmentDropdown()),
              const SizedBox(width: 12),
              Expanded(child: _buildProgramDropdown()),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildSemesterDropdown()),
              const SizedBox(width: 12),
              Expanded(child: _buildSectionDropdown()),
            ],
          ),
          const SizedBox(height: 16),
          _buildBatchDropdown(),
          const SizedBox(height: 16),
          _buildDatePicker(),
        ],
      ),
    );
  }

  Widget _buildDepartmentDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Department',
        labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
        prefixIcon: const Icon(Icons.business, color: Color(0xFF6a11cb)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2575fc), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      value: _selectedDepartment,
      items: _departments
          .map(
            (dept) => DropdownMenuItem(
              value: dept,
              child: Text(dept, style: GoogleFonts.poppins()),
            ),
          )
          .toList(),
      onChanged: _onDepartmentChanged,
      hint: Text('Select Department', style: GoogleFonts.poppins()),
      isExpanded: true,
    );
  }

  Widget _buildProgramDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Program',
        labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
        prefixIcon: const Icon(Icons.school, color: Color(0xFF6a11cb)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2575fc), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      value: _selectedProgram,
      items: _programs
          .map(
            (prog) => DropdownMenuItem(
              value: prog,
              child: Text(prog, style: GoogleFonts.poppins()),
            ),
          )
          .toList(),
      onChanged: _selectedDepartment != null ? _onProgramChanged : null,
      hint: Text(
        _selectedDepartment == null ? 'Select Dept first' : 'Select Program',
        style: GoogleFonts.poppins(),
      ),
      isExpanded: true,
      menuMaxHeight: 300,
    );
  }

  Widget _buildSemesterDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Semester',
        labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
        prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF6a11cb)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2575fc), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      value: _selectedSemester,
      items: _semesters
          .map(
            (sem) => DropdownMenuItem(
              value: sem,
              child: Text('Semester $sem', style: GoogleFonts.poppins()),
            ),
          )
          .toList(),
      onChanged: _selectedProgram != null ? _onSemesterChanged : null,
      hint: Text(
        _selectedProgram == null ? 'Select Program first' : 'Select Semester',
        style: GoogleFonts.poppins(),
      ),
      isExpanded: true,
      menuMaxHeight: 300,
    );
  }

  Widget _buildSectionDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Section',
        labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
        prefixIcon: const Icon(Icons.group, color: Color(0xFF6a11cb)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2575fc), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      value: _selectedSection,
      items: _sections
          .map(
            (sec) => DropdownMenuItem(
              value: sec,
              child: Text('Section $sec', style: GoogleFonts.poppins()),
            ),
          )
          .toList(),
      onChanged: _selectedSemester != null ? _onSectionChanged : null,
      hint: Text(
        _selectedSemester == null ? 'Select Semester first' : 'Select Section',
        style: GoogleFonts.poppins(),
      ),
      isExpanded: true,
      menuMaxHeight: 300,
    );
  }

  Widget _buildBatchDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Batch',
        labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
        prefixIcon: const Icon(Icons.date_range, color: Color(0xFF6a11cb)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2575fc), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      value: _selectedBatch,
      items: _batches
          .map(
            (batch) => DropdownMenuItem(
              value: batch,
              child: Text(batch, style: GoogleFonts.poppins()),
            ),
          )
          .toList(),
      onChanged: _selectedProgram != null ? _onBatchChanged : null,
      hint: Text(
        _selectedProgram == null ? 'Select Program first' : 'Select Batch',
        style: GoogleFonts.poppins(),
      ),
      isExpanded: true,
      menuMaxHeight: 300,
    );
  }

  Widget _buildDatePicker() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _selectedDate != null
              ? const Color(0xFF2575fc)
              : Colors.grey[300]!,
          width: _selectedDate != null ? 2 : 1,
        ),
        color: Colors.grey[50],
      ),
      child: GestureDetector(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: _selectedDate ?? DateTime.now(),
            firstDate: DateTime(2025, 1, 1),
            lastDate: DateTime(2026, 12, 31),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFF6a11cb),
                    onPrimary: Colors.white,
                    surface: Colors.white,
                  ),
                  dialogBackgroundColor: Colors.white,
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF2575fc),
                    ),
                  ),
                ),
                child: child!,
              );
            },
          );
          if (date != null) {
            _onDateChanged(date);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, color: Color(0xFF6a11cb)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _selectedDate == null
                      ? 'Select Date'
                      : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: _selectedDate == null
                        ? Colors.grey[600]
                        : const Color(0xFF1A1A40),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: Color(0xFF6a11cb)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    final canSearch =
        _selectedDepartment != null &&
        _selectedProgram != null &&
        _selectedSemester != null &&
        _selectedSection != null &&
        _selectedBatch != null &&
        _selectedDate != null;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: canSearch ? _filterUsers : null,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: const Color(0xFF6a11cb).withOpacity(0.3),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: canSearch
                ? const LinearGradient(
                    colors: [Color(0xFF6a11cb), Color(0xFF2575fc)],
                  )
                : const LinearGradient(colors: [Colors.grey, Colors.grey]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search, color: Colors.white, size: 20),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search Results',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A40),
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<UserAccount>>(
          future: _filteredUsersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingCard();
            } else if (snapshot.hasError) {
              return _buildErrorCard(snapshot.error.toString());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyResultsCard();
            } else {
              return Column(
                children: snapshot.data!
                    .map(
                      (user) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildUserCard(user),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6a11cb), Color(0xFF2575fc)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 32),
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
                        color: const Color(0xFF1A1A40),
                      ),
                    ),
                    Text(
                      teacher.role.name.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF6a11cb),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailRow(Icons.business, 'Department', teacher.dept),
          _buildDetailRow(Icons.school, 'Program', teacher.prog),
          _buildDetailRow(
            Icons.calendar_today,
            'Semester',
            teacher.sem.toString(),
          ),
          _buildDetailRow(Icons.group, 'Section', teacher.sec),
          _buildDetailRow(Icons.date_range, 'Batch', teacher.batch ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserAccount user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6a11cb).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6a11cb).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF6a11cb).withOpacity(0.1),
                child: const Icon(Icons.person, color: Color(0xFF6a11cb)),
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
                        color: const Color(0xFF1A1A40),
                      ),
                    ),
                    Text(
                      user.role.name.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF6a11cb),
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
          const SizedBox(height: 8),
          _buildCompactDetail('Batch', user.batch ?? 'N/A', Icons.date_range),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6a11cb).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF2575fc), size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF1A1A40),
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
        Icon(icon, size: 16, color: const Color(0xFF6a11cb)),
        const SizedBox(width: 4),
        Text(
          '$label: $value',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6a11cb).withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2575fc)),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Error: ${error.replaceFirst('Exception: ', '')}',
              style: GoogleFonts.poppins(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6a11cb).withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          message,
          style: GoogleFonts.poppins(
            color: Colors.grey[600],
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyResultsCard() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6a11cb).withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No users found',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
              fontWeight: FontWeight.w400,
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
        _selectedSection != null ||
        _selectedBatch != null ||
        _selectedDate != null;
  }

  Future<bool> _showLogoutDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            title: Row(
              children: [
                const Icon(Icons.logout, color: Color(0xFF6a11cb)),
                const SizedBox(width: 8),
                Text(
                  'Confirm Logout',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A40),
                  ),
                ),
              ],
            ),
            content: Text(
              'Are you sure you want to logout?',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6a11cb), Color(0xFF2575fc)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    'Logout',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}
