import 'package:classmonitor/screens/StudentDashboard.dart';
import 'package:classmonitor/screens/adminScreens/SuperAdminDashboard.dart';
import 'package:classmonitor/screens/TeacherDashboard.dart';
import 'package:classmonitor/utils/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _error;

  // Animation controllers and variables
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _logoRotation;

  @override
  void initState() {
    super.initState();

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

  Future<void> _performLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final role = await ApiService.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      if (role != null && mounted) {
        Widget destination;
        switch (role) {
          case UserRole.student:
            destination = const StudentDashboard();
            break;
          case UserRole.teacher:
            destination = const TeacherDashboard();
            break;
          case UserRole.superAdmin:
            destination = const SuperAdminDashboard();
            break;
        }
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                destination,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: animation.drive(
                      Tween(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).chain(CurveTween(curve: Curves.easeInOut)),
                    ),
                    child: child,
                  );
                },
          ),
        );
      } else {
        setState(() => _error = 'Invalid credentials. Please try again.');
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;

        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            // decoration: BoxDecoration(
            //   gradient: LinearGradient(
            //     begin: Alignment.topLeft,
            //     end: Alignment.bottomRight,
            //     colors: [
            //       Color(0xFF667eea),
            //       Color.fromARGB(255, 224, 221, 227),
            //       Color(0xFFf093fb),
            //     ],
            //     stops: [0.0, 0.5, 1.0],
            //   ),
            // ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                // Body gradient from CreateUserScreen
                colors: [
                  // Color.fromARGB(255, 255, 255, 255),
                  Color(0xFFFFFFFF),
                  Color(0xFF667eea),

                  // Color(0xFFf093fb),
                ],
                // colors: [Color(0xFF6a11cb), Color(0xFF2575fc)],
                // stops: [0.0, 0.5, 1.0],
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
                                // Logo and Title Section
                                _buildHeader(isSmallScreen),
                                const SizedBox(height: 40),

                                // Form Fields
                                SlideTransition(
                                  position: _slideAnimation,
                                  child: Column(
                                    children: [
                                      _buildUsernameField(isSmallScreen),
                                      const SizedBox(height: 20),
                                      _buildPasswordField(isSmallScreen),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Error Message
                                if (_error != null)
                                  _buildErrorMessage(isSmallScreen),

                                const SizedBox(height: 24),

                                // Login Button
                                _buildLoginButton(isSmallScreen),

                                const SizedBox(height: 20),

                                // Additional Options
                                // _buildAdditionalOptions(isSmallScreen),
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
              gradient: LinearGradient(
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
              Icons.school_rounded,
              size: isSmallScreen ? 40.0 : 50.0,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'ClassMonitor',
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

  Widget _buildUsernameField(bool isSmallScreen) {
    return TextFormField(
      controller: _usernameController,
      style: const TextStyle(color: Colors.black87, fontSize: 16.0),
      decoration: InputDecoration(
        labelText: 'User ID',
        labelStyle: const TextStyle(
          color: Color(0xFF718096),
          fontWeight: FontWeight.w500,
        ),
        hintText: 'User ID',
        hintStyle: const TextStyle(color: Color(0xFFB0B5C0)),
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.person_outline_rounded,
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email or student ID';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(bool isSmallScreen) {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      style: const TextStyle(color: Colors.black87, fontSize: 16.0),
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: const TextStyle(
          color: Color(0xFF718096),
          fontWeight: FontWeight.w500,
        ),
        hintText: 'Enter your password',
        hintStyle: const TextStyle(color: Color(0xFFB0B5C0)),
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.lock_outline_rounded,
            color: Colors.purple.shade600,
            size: isSmallScreen ? 18.0 : 20.0,
          ),
        ),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
          icon: Icon(
            _isPasswordVisible
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
            color: const Color(0xFF718096),
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
          borderSide: BorderSide(color: Colors.purple.shade400, width: 2),
        ),
        contentPadding: EdgeInsets.all(isSmallScreen ? 12.0 : 20.0),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 2) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget _buildErrorMessage(bool isSmallScreen) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(isSmallScreen ? 8.0 : 12.0),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Colors.red.shade600,
            size: isSmallScreen ? 16.0 : 20.0,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _error!,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: isSmallScreen ? 12.0 : 14.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(bool isSmallScreen) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: SizedBox(
        width: double.infinity,
        height: isSmallScreen ? 48.0 : 56.0,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _performLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                // colors: [Colors.blue.shade500, Colors.purple.shade500],
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
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                  : Text(
                      'Sign In',
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

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
