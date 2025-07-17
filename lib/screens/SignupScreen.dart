import 'package:classmonitor/screens/LoginScreen.dart';
import 'package:classmonitor/utils/ApiService.dart';
import 'package:flutter/material.dart';
import '../models/user_account.dart';

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

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup successful! Please login.')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        setState(() => _error = 'Signup failed. Try again.');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) =>
                    value!.isEmpty ? 'Username is required' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? 'Password is required' : null,
              ),
              TextFormField(
                controller: _deptController,
                decoration: const InputDecoration(labelText: 'Department'),
                validator: (value) =>
                    value!.isEmpty ? 'Department is required' : null,
              ),
              TextFormField(
                controller: _progController,
                decoration: const InputDecoration(labelText: 'Program'),
                validator: (value) =>
                    value!.isEmpty ? 'Program is required' : null,
              ),
              TextFormField(
                controller: _semController,
                decoration: const InputDecoration(labelText: 'Semester'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty || int.tryParse(value) == null
                    ? 'Valid semester is required'
                    : null,
              ),
              TextFormField(
                controller: _secController,
                decoration: const InputDecoration(labelText: 'Section'),
                validator: (value) =>
                    value!.isEmpty ? 'Section is required' : null,
              ),
              const SizedBox(height: 20),
              if (_error != null)
                Text('❌ $_error', style: const TextStyle(color: Colors.red)),
              if (_loading) const Center(child: CircularProgressIndicator()),
              ElevatedButton(
                onPressed: _loading ? null : _signUp,
                child: const Text('Sign Up'),
              ),
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
