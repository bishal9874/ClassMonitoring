import 'package:classmonitor/screens/adminScreens/EditUserScreen.dart';
import 'package:flutter/material.dart';
import 'package:classmonitor/utils/ApiService.dart';
import 'package:classmonitor/models/user_account.dart';
import 'package:google_fonts/google_fonts.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<UserAccount>> _usersFuture;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  UserRole? _selectedRoleFilter;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );
    _usersFuture = _fetchUsers();
  }

  Future<List<UserAccount>> _fetchUsers() async {
    _animationController.reset();
    final allUsers = await ApiService.getAllUsers();

    List<UserAccount> filteredUsers;

    if (_selectedRoleFilter != null) {
      filteredUsers = allUsers
          .where((user) => user.role == _selectedRoleFilter)
          .toList();
    } else {
      filteredUsers = allUsers;
    }

    if (mounted) {
      _animationController.forward();
    }
    return filteredUsers;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _filterUsersByRole(UserRole? role) {
    if (mounted) {
      setState(() {
        _selectedRoleFilter = role;
        _usersFuture = _fetchUsers();
      });
    }
  }

  Future<void> _navigateToEditScreen(UserAccount user) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => EditUserScreen(user: user)),
    );
    if (result == true) {
      setState(() {
        _usersFuture = _fetchUsers();
      });
    }
  }

  Future<void> _showDeleteConfirmationDialog(UserAccount user) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Confirm Deletion',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2c3e50),
          ),
        ),
        content: Text(
          'Are you sure you want to delete user "${user.username}"? This action cannot be undone.',
          style: GoogleFonts.poppins(fontSize: 16),
        ),
        actions: [
          TextButton(
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: const Color(0xFF7f8c8d)),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFe74c3c),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteUser(user.accountId!);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(String accountId) async {
    try {
      final success = await ApiService.deleteUser(accountId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'User deleted successfully!',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF27ae60),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        setState(() {
          _usersFuture = _fetchUsers();
        });
      } else {
        throw Exception('Failed to delete user.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: ${e.toString().replaceFirst('Exception: ', '')}',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFe74c3c),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Widget _buildRoleFilterDropdown() {
    return Container(
      width: 130, // Adjusted to a more flexible width for a better UI
      height: 40,
      padding: const EdgeInsets.all(4.0),
      margin: const EdgeInsets.only(right: 8.0), // Added some margin
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<UserRole?>(
          value: _selectedRoleFilter,
          icon: const Icon(Icons.filter_list, color: Colors.white),
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
          dropdownColor: const Color(0xFF6a11cb),
          onChanged: _filterUsersByRole,
          items: [
            DropdownMenuItem<UserRole?>(
              value: null,
              child: Text(
                'All Users',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
              ),
            ),
            ...UserRole.values
                .map(
                  (role) => DropdownMenuItem<UserRole>(
                    value: role,
                    child: Text(
                      role.name,
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Users',
          style: GoogleFonts.poppins(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          _buildRoleFilterDropdown(),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                _usersFuture = _fetchUsers();
              });
            },
            tooltip: 'Refresh User List',
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6a11cb), Color(0xFF2575fc)],
            ),
          ),
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
            child: FutureBuilder<List<UserAccount>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF2575fc),
                      strokeWidth: 5,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Color(0xFFe74c3c),
                            size: 70,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Error: ${snapshot.error.toString().replaceFirst('Exception: ', '')}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: const Color(0xFFe74c3c),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _usersFuture = _fetchUsers();
                              });
                            },
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                              size: 22,
                            ),
                            label: Text(
                              'Try Again',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2575fc),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.person_off,
                          color: Color(0xFF7f8c8d),
                          size: 70,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No users found.',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            color: const Color(0xFF7f8c8d),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _usersFuture = _fetchUsers();
                            });
                          },
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 22,
                          ),
                          label: Text(
                            'Refresh',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2575fc),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  final users = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(20.0),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          final delay = (index * 150).clamp(0, 1000);
                          final curve = CurvedAnimation(
                            parent: _animationController,
                            curve: Interval(
                              delay / 1000,
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
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 10.0),
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          color: Colors.white,
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
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor:
                                            user.role == UserRole.student
                                            ? const Color(0xFF3498db)
                                            : const Color(0xFFe67e22),
                                        child: Text(
                                          user.username[0].toUpperCase(),
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user.username,
                                              style: GoogleFonts.poppins(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF2c3e50),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    user.role ==
                                                        UserRole.student
                                                    ? const Color(0xFF3498db)
                                                    : const Color(0xFFe67e22),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Text(
                                                user.role.name.toUpperCase(),
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _buildInfoRow(
                                    icon: Icons.business,
                                    text: 'Department: ${user.dept}',
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInfoRow(
                                    icon: Icons.school,
                                    text: 'Program: ${user.prog}',
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInfoRow(
                                    icon: Icons.class_,
                                    text: 'Sem: ${user.sem}, Sec: ${user.sec}',
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInfoRow(
                                    icon: Icons.date_range,
                                    text: 'Batch: ${user.batch}',
                                  ),
                                  // const Divider(height: 24, thickness: 1),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      _buildActionButton(
                                        buttonName: 'Edit',
                                        icon: Icons.edit,
                                        textColor: Colors.blue,
                                        color: const Color(0xFF2980b9),
                                        tooltip: 'Edit User',
                                        onPressed: () =>
                                            _navigateToEditScreen(user),
                                      ),
                                      const SizedBox(width: 12),
                                      _buildActionButton(
                                        textColor: const Color.fromARGB(
                                          255,
                                          205,
                                          11,
                                          8,
                                        ),
                                        buttonName: 'Delete',
                                        icon: Icons.delete,
                                        color: const Color(0xFFc0392b),
                                        tooltip: 'Delete User',
                                        onPressed: () =>
                                            _showDeleteConfirmationDialog(user),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF7f8c8d)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: const Color(0xFF34495e),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required String buttonName,
    Color? textColor,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              buttonName,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            SizedBox(width: 5),
            Tooltip(
              message: tooltip,
              child: Icon(icon, color: color, size: 14),
            ),
          ],
        ),
      ),
    );
  }
}
