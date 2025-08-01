import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:classmonitor/models/user_account.dart';
import 'package:classmonitor/utils/ApiService.dart';

class EditUserScreen extends StatefulWidget {
  final UserAccount user;

  const EditUserScreen({super.key, required this.user});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _deptController;
  late TextEditingController _progController;
  late TextEditingController _semController;
  late TextEditingController _secController;
  late UserRole _selectedRole;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _usernameController = TextEditingController(text: user.username);
    _passwordController = TextEditingController(text: user.password ?? 'N/A');
    _deptController = TextEditingController(text: user.dept);
    _progController = TextEditingController(text: user.prog);
    _semController = TextEditingController(text: user.sem);
    _secController = TextEditingController(text: user.sec);
    _selectedRole = user.role;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _deptController.dispose();
    _progController.dispose();
    _semController.dispose();
    _secController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedUser = UserAccount(
        accountId: widget.user.accountId,
        username: _usernameController.text,
        dept: _deptController.text,
        prog: _progController.text,
        sem: _semController.text,
        sec: _secController.text,
        role: _selectedRole,
      );

      final success = await ApiService.updateUser(updatedUser);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'User updated successfully!',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: const Color(0xFF27ae60),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        throw Exception('Failed to update user.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: ${e.toString().replaceFirst('Exception: ', '')}',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: const Color(0xFFe74c3c),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit User',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: isLargeScreen ? 28 : 26,
            fontWeight: FontWeight.w700,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6a11cb), Color(0xFF2575fc)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 8,
        shadowColor: Colors.black38,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFf0f4ff), Color(0xFFe6e9ff)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isLargeScreen
                        ? constraints.maxWidth * 0.15
                        : 16.0,
                    vertical: 24.0,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFffffff), Color(0xFFf8f9ff)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(isLargeScreen ? 24.0 : 20.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildTextField(
                                  controller: _usernameController,
                                  label: 'Username',
                                  icon: Icons.person,
                                  enabled: false,
                                  index: 0,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _passwordController,
                                  label: 'Password',
                                  icon: Icons.lock,
                                  enabled: false,
                                  obscureText: !_isPasswordVisible,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                  index: 1,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _deptController,
                                  label: 'Department',
                                  icon: Icons.business,
                                  index: 2,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _progController,
                                  label: 'Program',
                                  icon: Icons.school,
                                  index: 3,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _semController,
                                  label: 'Semester',
                                  icon: Icons.class_,
                                  index: 4,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _secController,
                                  label: 'Section',
                                  icon: Icons.group,
                                  index: 5,
                                ),
                                const SizedBox(height: 24),
                                AnimatedBuilder(
                                  animation: _animationController,
                                  builder: (context, child) {
                                    final curve = CurvedAnimation(
                                      parent: _animationController,
                                      curve: const Interval(
                                        0.6,
                                        1.0,
                                        curve: Curves.easeOutCubic,
                                      ),
                                    );
                                    return Opacity(
                                      opacity: curve.value,
                                      child: Transform.translate(
                                        offset: Offset(
                                          0,
                                          (1.0 - curve.value) * 20,
                                        ),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: DropdownButtonFormField<UserRole>(
                                    value: _selectedRole,
                                    decoration: InputDecoration(
                                      labelText: 'Role',
                                      labelStyle: GoogleFonts.poppins(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.verified_user,
                                        color: Colors.grey,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.withOpacity(0.2),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      disabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                    ),
                                    items: UserRole.values.map((role) {
                                      return DropdownMenuItem(
                                        value: role,
                                        child: Text(
                                          role.name.toUpperCase(),
                                          style: GoogleFonts.poppins(
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: null, // Disables the dropdown
                                    disabledHint: Text(
                                      _selectedRole.name.toUpperCase(),
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                AnimatedBuilder(
                                  animation: _animationController,
                                  builder: (context, child) {
                                    final curve = CurvedAnimation(
                                      parent: _animationController,
                                      curve: const Interval(
                                        0.7,
                                        1.0,
                                        curve: Curves.easeOutCubic,
                                      ),
                                    );
                                    return Opacity(
                                      opacity: curve.value,
                                      child: Transform.scale(
                                        scale: 0.95 + curve.value * 0.05,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: _isLoading
                                      ? const Center(
                                          child: CircularProgressIndicator(
                                            color: Color(0xFF2575fc),
                                            strokeWidth: 5,
                                          ),
                                        )
                                      : ElevatedButton.icon(
                                          onPressed: _saveUser,
                                          icon: const Icon(
                                            Icons.save,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                          label: Text(
                                            'Save Changes',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: isLargeScreen ? 18 : 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF2575fc,
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              vertical: isLargeScreen ? 18 : 16,
                                              horizontal: isLargeScreen
                                                  ? 32
                                                  : 24,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            elevation: 6,
                                            shadowColor: Colors.black
                                                .withOpacity(0.2),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    bool obscureText = false,
    Widget? suffixIcon,
    required int index,
  }) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final curve = CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.1,
            0.5 + index * 0.1,
            curve: Curves.easeOutCubic,
          ),
        );
        return Opacity(
          opacity: curve.value,
          child: Transform.translate(
            offset: Offset(0, (1.0 - curve.value) * 20),
            child: child,
          ),
        );
      },
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            color: enabled ? const Color(0xFF2c3e50) : Colors.grey[600],
            fontWeight: FontWeight.w500,
            fontSize: isLargeScreen ? 16 : 14,
          ),
          prefixIcon: Icon(
            icon,
            color: enabled ? const Color(0xFF2575fc) : Colors.grey,
            size: isLargeScreen ? 24 : 20,
          ),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: enabled
              ? Colors.white.withOpacity(0.9)
              : Colors.grey.withOpacity(0.2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2575fc), width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: isLargeScreen ? 16 : 14,
            horizontal: 16,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a $label';
          }
          return null;
        },
      ),
    );
  }
}
