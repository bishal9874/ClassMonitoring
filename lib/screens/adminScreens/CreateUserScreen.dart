import 'package:flutter/material.dart';
import 'package:classmonitor/utils/ApiService.dart';
import 'package:classmonitor/models/user_account.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _deptController = TextEditingController();
  final _progController = TextEditingController();
  final _semController = TextEditingController();
  final _secController = TextEditingController();

  UserRole _selectedRole = UserRole.student; // Default role
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _deptController.dispose();
    _progController.dispose();
    _semController.dispose();
    _secController.dispose();
    super.dispose();
  }

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) {
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
        dept: _deptController.text.trim(),
        prog: _progController.text.trim(),
        sem: int.parse(_semController.text.trim()),
        sec: _secController.text.trim(),
        role: _selectedRole,
      );

      final success = await ApiService.createUser(newUser);

      if (success && mounted) {
        setState(() {
          _successMessage = 'User "${newUser.username}" created successfully!';
          _usernameController.clear();
          _passwordController.clear();
          _deptController.clear();
          _progController.clear();
          _semController.clear();
          _secController.clear();
          _selectedRole = UserRole.student;
        });
      } else if (mounted) {
        setState(() {
          _errorMessage = 'Failed to create user. Please try again.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New User'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter User Details',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v!.isEmpty ? 'Username is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (v) => v!.isEmpty ? 'Password is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deptController,
                decoration: const InputDecoration(
                  labelText: 'Department',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (v) => v!.isEmpty ? 'Department is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _progController,
                decoration: const InputDecoration(
                  labelText: 'Program (e.g., B.Tech, M.Tech)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.school),
                ),
                validator: (v) => v!.isEmpty ? 'Program is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _semController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Semester',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                validator: (v) {
                  if (v!.isEmpty) return 'Semester is required';
                  if (int.tryParse(v) == null)
                    return 'Invalid semester (must be a number)';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _secController,
                decoration: const InputDecoration(
                  labelText: 'Section (e.g., A, B, 1)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.group),
                ),
                validator: (v) => v!.isEmpty ? 'Section is required' : null,
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<UserRole>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Select Role',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.assignment_ind),
                ),
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
                onChanged: (UserRole? newValue) {
                  setState(() {
                    _selectedRole = newValue!;
                  });
                },
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_successMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _successMessage!,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _createUser,
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Create User'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
