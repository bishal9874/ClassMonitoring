import 'package:classmonitor/screens/LoginScreen.dart';
import 'package:classmonitor/utils/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:classmonitor/models/user_account.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _deptController = TextEditingController();
  final _progController = TextEditingController();
  final _semController = TextEditingController();
  final _secController = TextEditingController();
  bool _loading = false;
  String? _error;

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

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = UserAccount(
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        dept: _deptController.text.trim(),
        prog: _progController.text.trim(),
        sem: int.tryParse(_semController.text.trim()),
        sec: _secController.text.trim(),
      );
      final success = await UserAccountService().signUp(user);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signup successful! Please login.')),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        } else {
          setState(() => _error = 'Signup failed. Please try again.');
        }
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
              validator: (v) => v!.isEmpty ? 'Username is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (v) => v!.isEmpty ? 'Password is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _deptController,
              decoration: const InputDecoration(labelText: 'Department'),
              validator: (v) => v!.isEmpty ? 'Department is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _progController,
              decoration: const InputDecoration(labelText: 'Program'),
              validator: (v) => v!.isEmpty ? 'Program is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _semController,
              decoration: const InputDecoration(labelText: 'Semester'),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty || int.tryParse(v) == null
                  ? 'Valid semester is required'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _secController,
              decoration: const InputDecoration(labelText: 'Section'),
              validator: (v) => v!.isEmpty ? 'Section is required' : null,
            ),
            const SizedBox(height: 20),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  '❌ $_error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _signUp,
                child: const Text('Sign Up'),
              ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
