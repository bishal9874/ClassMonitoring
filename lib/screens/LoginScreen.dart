import 'package:classmonitor/screens/SignupScreen.dart';
import 'package:classmonitor/screens/UserManagement.dart';
import 'package:classmonitor/utils/ApiService.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final success = await UserAccountService().login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );
      if (mounted && success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const UserManagementScreen()),
        );
      } else {
        setState(() => _error = 'Invalid username or password.');
      }
    } catch (e) {
      setState(
        () => _error = e.toString().replaceFirst(
          'Exception: ',
          'Your date and time incorrect. ',
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (value) =>
                      value!.isEmpty ? 'Username is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) =>
                      value!.isEmpty ? 'Password is required' : null,
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
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: _login,
                    child: const Text('Login'),
                  ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const SignupScreen()),
                  ),
                  child: const Text('Need an account? Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
