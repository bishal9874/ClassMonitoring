import 'package:classmonitor/models/programDropdowndata.dart';
import 'package:classmonitor/utils/ApiService.dart';
import 'package:classmonitor/models/user_account.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  UserRole _selectedRole = UserRole.student;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  final ClassMonitorData _classMonitorData = ClassMonitorData();

  String? _selectedDepartment;
  String? _selectedProgram;
  String? _selectedSemester;
  String? _selectedSection;
  String? _selectedBatch;

  List<ProgramData> _availablePrograms = [];
  List<int> _availableSemesters = [];
  List<String> _availableSections = [];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _logoRotation;

  @override
  void initState() {
    super.initState();
    _loadData();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _logoRotation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await _classMonitorData.loadJson();
      debugPrint(
        'Loaded departments: ${_classMonitorData.allDepartments.map((d) => d.name).toList()}',
      );
      for (var dept in _classMonitorData.allDepartments) {
        debugPrint(
          'Department: ${dept.name}, Programs: ${dept.programs.map((p) => p.name).toList()}',
        );
        for (var prog in dept.programs) {
          debugPrint(
            'Program: ${prog.name}, Semesters: ${prog.semesters.keys.toList()}',
          );
        }
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading ClassMonitorData: $e');
      setState(() {
        _errorMessage = 'Failed to load department data. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _onDepartmentChanged(String? newValue) {
    setState(() {
      _selectedDepartment = newValue;
      _selectedProgram = null;
      _selectedSemester = null;
      _selectedSection = null;
      _selectedBatch = null;
      _availablePrograms = [];
      _availableSemesters = [];
      _availableSections = [];

      if (newValue != null) {
        final department = _classMonitorData.allDepartments.firstWhereOrNull(
          (dept) => dept.name == newValue,
        );
        if (department != null) {
          _availablePrograms = department.programs;
          debugPrint(
            'Selected Department: $newValue, Available Programs: ${_availablePrograms.map((p) => p.name).toList()}',
          );
        } else {
          debugPrint('Department not found: $newValue');
        }
      }
    });
  }

  void _onProgramChanged(String? newValue) {
    setState(() {
      _selectedProgram = newValue;
      _selectedSemester = null;
      _selectedSection = null;
      _selectedBatch = null;
      _availableSemesters = [];
      _availableSections = [];

      if (newValue != null && _selectedDepartment != null) {
        final department = _classMonitorData.allDepartments.firstWhereOrNull(
          (dept) => dept.name == _selectedDepartment,
        );
        if (department != null) {
          final program = department.programs.firstWhereOrNull(
            (prog) => prog.name == newValue,
          );
          if (program != null) {
            _availableSemesters = program.semesters.keys.toList();
            _availableSemesters.sort();

            debugPrint(
              'Selected Program: $newValue, Available Semesters (Ints): $_availableSemesters',
            );
          } else {
            debugPrint(
              'Program "$newValue" not found in department "$_selectedDepartment"',
            );
          }
        } else {
          debugPrint('Department "$_selectedDepartment" not found');
        }
      }
    });
  }

  void _onSemesterChanged(String? newValue) {
    setState(() {
      _selectedSemester = newValue;
      _selectedSection = null;
      _availableSections = [];

      if (newValue != null &&
          _selectedProgram != null &&
          _selectedDepartment != null) {
        final department = _classMonitorData.allDepartments.firstWhereOrNull(
          (dept) => dept.name == _selectedDepartment,
        );
        if (department != null) {
          final program = department.programs.firstWhereOrNull(
            (p) => p.name == _selectedProgram,
          );
          if (program != null) {
            final int? semesterKey = int.tryParse(newValue);
            if (semesterKey != null &&
                program.semesters.containsKey(semesterKey)) {
              _availableSections = program.semesters[semesterKey] ?? [];
              debugPrint(
                'Selected Semester: $newValue, Available Sections: $_availableSections',
              );
            } else {
              debugPrint(
                'Semester key "$newValue" (parsed as $semesterKey) not found for Program: $_selectedProgram.',
              );
            }
          } else {
            debugPrint(
              'Program "$_selectedProgram" not found for department "$_selectedDepartment".',
            );
          }
        } else {
          debugPrint('Department "$_selectedDepartment" not found.');
        }
      } else {
        debugPrint(
          'Semester changed but no program/department selected or invalid semester: $newValue',
        );
      }
    });
  }

  void _onSectionChanged(String? newValue) {
    setState(() {
      _selectedSection = newValue;
      debugPrint('Selected Section: $newValue');
    });
  }

  void _onBatchChanged(String? newValue) {
    setState(() {
      _selectedBatch = newValue;
      debugPrint('Selected Batch: $newValue');
    });
  }

  void _onRoleChanged(UserRole? newValue) {
    setState(() {
      _selectedRole = newValue!;
      if (_selectedRole == UserRole.teacher) {
        _selectedDepartment = "N/A";
        _selectedProgram = "N/A";
        _selectedSemester = "N/A";
        _selectedSection = "N/A";
        _selectedBatch = "N/A";
        _availablePrograms = [];
        _availableSemesters = [];
        _availableSections = [];
      } else {
        _selectedDepartment = null;
        _selectedProgram = null;
        _selectedSemester = null;
        _selectedSection = null;
        _selectedBatch = null;
        _availablePrograms = [];
        _availableSemesters = [];
        _availableSections = [];
        _loadData();
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) {
      debugPrint('Form validation failed.');
      return;
    }

    if (_selectedRole == UserRole.student &&
        (_selectedDepartment == null ||
            _selectedProgram == null ||
            _selectedSemester == null ||
            _selectedSection == null ||
            _selectedBatch == null)) {
      setState(() {
        _errorMessage =
            'Please select all fields: Department, Program, Semester, Section, and Batch.';
        _successMessage = null;
      });
      debugPrint('Student role: Missing required fields.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final newUser = UserAccount(
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        dept: _selectedRole == UserRole.teacher ? "N/A" : _selectedDepartment!,
        prog: _selectedRole == UserRole.teacher ? "N/A" : _selectedProgram!,
        sem: _selectedRole == UserRole.teacher ? "N/A" : _selectedSemester!,
        sec: _selectedRole == UserRole.teacher ? "N/A" : _selectedSection!,
        batch: _selectedRole == UserRole.teacher ? "N/A" : _selectedBatch!,
        role: _selectedRole,
      );

      debugPrint('Attempting to create user with data: ${newUser.toJson()}');

      final success = await ApiService.createUser(newUser);

      if (success && mounted) {
        setState(() {
          _successMessage = 'User "${newUser.username}" created successfully!';
          _usernameController.clear();
          _passwordController.clear();
          if (_selectedRole == UserRole.student) {
            _selectedDepartment = null;
            _selectedProgram = null;
            _selectedSemester = null;
            _selectedSection = null;
            _selectedBatch = null;
            _availablePrograms = [];
            _availableSemesters = [];
            _availableSections = [];
            _loadData();
          }
        });
        debugPrint('User creation successful.');
      } else if (mounted) {
        setState(() {
          _errorMessage = 'Failed to create user. Please try again.';
          _successMessage = null;
        });
        debugPrint('User creation failed (ApiService returned false).');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _successMessage = null;
        });
        debugPrint('Error during user creation: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final departments = _classMonitorData.allDepartments;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Create User',
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 20.0 : 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
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
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color.fromARGB(255, 255, 255, 255), Color(0xFF667eea)],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16.0 : 32.0,
                    vertical: isSmallScreen ? 16.0 : 24.0,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isSmallScreen ? double.infinity : 400,
                    ),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Card(
                        elevation: 20,
                        shadowColor: Colors.black.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        color: Colors.white.withOpacity(0.95),
                        child: Container(
                          padding: EdgeInsets.all(isSmallScreen ? 16.0 : 32.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildHeader(isSmallScreen),
                                const SizedBox(height: 40),
                                SlideTransition(
                                  position: _slideAnimation,
                                  child: Column(
                                    children: [
                                      _buildInputField(
                                        controller: _usernameController,
                                        labelText: 'Username',
                                        icon: Icons.person_outline_rounded,
                                        validatorText: 'Username is required',
                                        isSmallScreen: isSmallScreen,
                                      ),
                                      const SizedBox(height: 20),
                                      _buildInputField(
                                        controller: _passwordController,
                                        labelText: 'Password',
                                        icon: Icons.lock_outline_rounded,
                                        obscureText: true,
                                        validatorText: 'Password is required',
                                        isSmallScreen: isSmallScreen,
                                      ),
                                      const SizedBox(height: 16),
                                      _buildDropdownField<UserRole>(
                                        value: _selectedRole,
                                        labelText: 'Role',
                                        icon: Icons.assignment_ind,
                                        items: const [
                                          DropdownMenuItem(
                                            value: UserRole.student,
                                            child: Text('Student'),
                                          ),
                                          DropdownMenuItem(
                                            value: UserRole.teacher,
                                            child: Text('Teacher'),
                                          ),
                                        ],
                                        onChanged: _onRoleChanged,
                                        validatorText: 'Role is required',
                                        isSmallScreen: isSmallScreen,
                                      ),
                                      const SizedBox(height: 16),
                                      _selectedRole == UserRole.teacher
                                          ? _buildNAField(
                                              labelText: 'Department',
                                              icon: Icons.business,
                                              isSmallScreen: isSmallScreen,
                                            )
                                          : _buildDropdownField<String>(
                                              value: _selectedDepartment,
                                              labelText: 'Department',
                                              icon: Icons.business,
                                              items: departments
                                                  .map(
                                                    (dept) =>
                                                        DropdownMenuItem<
                                                          String
                                                        >(
                                                          value: dept.name,
                                                          child: Text(
                                                            dept.name,
                                                          ),
                                                        ),
                                                  )
                                                  .toList(),
                                              onChanged: _onDepartmentChanged,
                                              validatorText:
                                                  'Department is required',
                                              hintText: departments.isEmpty
                                                  ? 'No departments available'
                                                  : 'Select a Department',
                                              isSmallScreen: isSmallScreen,
                                            ),
                                      const SizedBox(height: 16),
                                      _selectedRole == UserRole.teacher
                                          ? _buildNAField(
                                              labelText: 'Program',
                                              icon: Icons.school,
                                              isSmallScreen: isSmallScreen,
                                            )
                                          : _buildDropdownField<String>(
                                              value: _selectedProgram,
                                              labelText: 'Program',
                                              icon: Icons.school,
                                              items: _availablePrograms
                                                  .map(
                                                    (prog) =>
                                                        DropdownMenuItem<
                                                          String
                                                        >(
                                                          value: prog.name,
                                                          child: Text(
                                                            prog.name,
                                                          ),
                                                        ),
                                                  )
                                                  .toList(),
                                              onChanged: _onProgramChanged,
                                              validatorText:
                                                  'Program is required',
                                              hintText:
                                                  _availablePrograms.isEmpty
                                                  ? 'Select a Department first'
                                                  : 'Select a Program',
                                              isSmallScreen: isSmallScreen,
                                            ),
                                      const SizedBox(height: 16),
                                      _selectedRole == UserRole.teacher
                                          ? _buildNAField(
                                              labelText: 'Semester',
                                              icon: Icons.calendar_today,
                                              isSmallScreen: isSmallScreen,
                                            )
                                          : _buildDropdownField<String>(
                                              value: _selectedSemester,
                                              labelText: 'Semester',
                                              icon: Icons.calendar_today,
                                              items: _availableSemesters
                                                  .map(
                                                    (sem) =>
                                                        DropdownMenuItem<
                                                          String
                                                        >(
                                                          value: sem.toString(),
                                                          child: Text('$sem'),
                                                        ),
                                                  )
                                                  .toList(),
                                              onChanged: _onSemesterChanged,
                                              validatorText:
                                                  'Semester is required',
                                              hintText:
                                                  _availableSemesters.isEmpty
                                                  ? 'Select a Program first'
                                                  : 'Select a Semester',
                                              isSmallScreen: isSmallScreen,
                                            ),
                                      const SizedBox(height: 16),
                                      _selectedRole == UserRole.teacher
                                          ? _buildNAField(
                                              labelText: 'Section',
                                              icon: Icons.group,
                                              isSmallScreen: isSmallScreen,
                                            )
                                          : _buildDropdownField<String>(
                                              value: _selectedSection,
                                              labelText: 'Section',
                                              icon: Icons.group,
                                              items: _availableSections
                                                  .map(
                                                    (sec) =>
                                                        DropdownMenuItem<
                                                          String
                                                        >(
                                                          value: sec,
                                                          child: Text(sec),
                                                        ),
                                                  )
                                                  .toList(),
                                              onChanged: _onSectionChanged,
                                              validatorText:
                                                  'Section is required',
                                              hintText:
                                                  _availableSections.isEmpty
                                                  ? 'Select a Semester first'
                                                  : 'Select a Section',
                                              isSmallScreen: isSmallScreen,
                                            ),
                                      const SizedBox(height: 16),
                                      _selectedRole == UserRole.teacher
                                          ? _buildNAField(
                                              labelText: 'Batch',
                                              icon: Icons.date_range,
                                              isSmallScreen: isSmallScreen,
                                            )
                                          : _buildDropdownField<String>(
                                              value: _selectedBatch,
                                              labelText: 'Batch',
                                              icon: Icons.date_range,
                                              items:
                                                  _classMonitorData
                                                      .allDepartments
                                                      .firstWhereOrNull(
                                                        (dept) =>
                                                            dept.name ==
                                                            _selectedDepartment,
                                                      )
                                                      ?.programs
                                                      .firstWhereOrNull(
                                                        (prog) =>
                                                            prog.name ==
                                                            _selectedProgram,
                                                      )
                                                      ?.batches // This is the list you want to map
                                                      .map(
                                                        (batch) =>
                                                            DropdownMenuItem<
                                                              String
                                                            >(
                                                              value: batch,
                                                              child: Text(
                                                                batch,
                                                              ),
                                                            ),
                                                      )
                                                      .toList() ??
                                                  [],
                                              onChanged: _onBatchChanged,
                                              validatorText:
                                                  'Batch is required',
                                              hintText: _selectedProgram == null
                                                  ? 'Select a Program first'
                                                  : 'Select a Batch',
                                              isSmallScreen: isSmallScreen,
                                            ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                if (_errorMessage != null ||
                                    _successMessage != null)
                                  _buildMessage(isSmallScreen),
                                const SizedBox(height: 24),
                                _buildCreateButton(isSmallScreen),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return Column(
      children: [
        RotationTransition(
          turns: _logoRotation,
          child: Container(
            padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF6a11cb), Color(0xFF2575fc)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              Icons.person_add,
              size: isSmallScreen ? 40.0 : 50.0,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Create New User',
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 24.0 : 28.0,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3748),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Smart classroom management system',
          style: GoogleFonts.inter(
            fontSize: isSmallScreen ? 12.0 : 14.0,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
    required String validatorText,
    required bool isSmallScreen,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black87, fontSize: 16.0),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(
          color: Color(0xFF718096),
          fontWeight: FontWeight.w500,
        ),
        hintText: labelText,
        hintStyle: const TextStyle(color: Color(0xFFB0B5C0)),
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                (icon == Icons.lock_outline_rounded
                        ? Colors.purple
                        : Colors.blue)
                    .withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: (icon == Icons.lock_outline_rounded
                ? Colors.purple.shade600
                : Colors.blue.shade600),
            size: isSmallScreen ? 18.0 : 20.0,
          ),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: (icon == Icons.lock_outline_rounded
                ? Colors.purple.shade400
                : Colors.blue.shade400),
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.all(isSmallScreen ? 12.0 : 20.0),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? validatorText : null,
    );
  }

  Widget _buildDropdownField<T>({
    required T? value,
    required String labelText,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required String validatorText,
    String? hintText,
    required bool isSmallScreen,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: DropdownButtonFormField<T>(
            value: value,
            decoration: InputDecoration(
              labelText: labelText,
              labelStyle: const TextStyle(
                color: Color(0xFF718096),
                fontWeight: FontWeight.w500,
              ),
              hintText: hintText,
              hintStyle: const TextStyle(color: Color(0xFFB0B5C0)),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.blue.shade600,
                  size: isSmallScreen ? 18.0 : 20.0,
                ),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
              ),
              contentPadding: EdgeInsets.all(isSmallScreen ? 12.0 : 20.0),
            ),
            items: items.isNotEmpty ? items : null,
            onChanged: items.isNotEmpty ? onChanged : null,
            validator: (v) =>
                v == null && validatorText.isNotEmpty ? validatorText : null,
            dropdownColor: Colors.white,
            iconEnabledColor: Colors.blue.shade600,
            isExpanded: true,
          ),
        ),
      ],
    );
  }

  Widget _buildNAField({
    required String labelText,
    required IconData icon,
    required bool isSmallScreen,
  }) {
    return AbsorbPointer(
      child: TextFormField(
        readOnly: true,
        initialValue: 'N/A',
        style: const TextStyle(color: Colors.black54, fontSize: 16.0),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(
            color: Color(0xFF718096),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.grey.shade600,
              size: isSmallScreen ? 18.0 : 20.0,
            ),
          ),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade400, width: 2),
          ),
          contentPadding: EdgeInsets.all(isSmallScreen ? 12.0 : 20.0),
        ),
      ),
    );
  }

  Widget _buildMessage(bool isSmallScreen) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(isSmallScreen ? 8.0 : 12.0),
      decoration: BoxDecoration(
        color: (_errorMessage != null ? Colors.red : Colors.green).shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (_errorMessage != null ? Colors.red : Colors.green).shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _errorMessage != null
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline,
            color: _errorMessage != null
                ? Colors.red.shade600
                : Colors.green.shade600,
            size: isSmallScreen ? 16.0 : 20.0,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage ?? _successMessage!,
              style: TextStyle(
                color: _errorMessage != null
                    ? Colors.red.shade700
                    : Colors.green.shade700,
                fontSize: isSmallScreen ? 12.0 : 14.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton(bool isSmallScreen) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: SizedBox(
        width: double.infinity,
        height: isSmallScreen ? 48.0 : 56.0,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _createUser,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6a11cb), Color(0xFF2575fc)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              alignment: Alignment.center,
              child: _isLoading
                  ? SizedBox(
                      height: isSmallScreen ? 20.0 : 24.0,
                      width: isSmallScreen ? 20.0 : 24.0,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Create User',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 14.0 : 16.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
