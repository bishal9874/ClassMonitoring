import 'package:classmonitor/screens/LoginScreen.dart';
import 'package:classmonitor/utils/ApiService.dart';
import 'package:flutter/material.dart';
import '../models/user_account.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final UserAccountService _service = UserAccountService();
  List<UserAccount> _users = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _loading = true);
    try {
      _users = await _service.getAllUsers();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching users: $e')));
    }
    setState(() => _loading = false);
  }

  void _showUserForm({UserAccount? user}) {
    final isEdit = user != null;
    final username = TextEditingController(text: user?.username ?? '');
    final password = TextEditingController(text: user?.password ?? '');
    final dept = TextEditingController(text: user?.dept ?? '');
    final prog = TextEditingController(text: user?.prog ?? '');
    final sem = TextEditingController(text: user?.sem?.toString() ?? '');
    final sec = TextEditingController(text: user?.sec ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? 'Update User' : 'Create User'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: username,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: password,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              TextField(
                controller: dept,
                decoration: const InputDecoration(labelText: 'Department'),
              ),
              TextField(
                controller: prog,
                decoration: const InputDecoration(labelText: 'Program'),
              ),
              TextField(
                controller: sem,
                decoration: const InputDecoration(labelText: 'Semester'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: sec,
                decoration: const InputDecoration(labelText: 'Section'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newUser = UserAccount(
                accountId: user?.accountId,
                username: username.text,
                password: password.text,
                dept: dept.text,
                prog: prog.text,
                sem: int.tryParse(sem.text),
                sec: sec.text,
              );

              try {
                if (isEdit) {
                  await _service.updateUser(newUser);
                } else {
                  await _service.createUser(newUser);
                }
                Navigator.pop(context);
                _fetchUsers();
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: Text(isEdit ? 'Update' : 'Create'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _service.deleteUser(id);
                Navigator.pop(context);
                _fetchUsers();
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await UserAccountService.clearToken();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Account Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (_, index) {
                final user = _users[index];
                return ListTile(
                  title: Text(user.username ?? '-'),
                  subtitle: Text(
                    '${user.dept ?? '-'} | Sem ${user.sem ?? '-'}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showUserForm(user: user),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _confirmDelete(user.accountId!),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
