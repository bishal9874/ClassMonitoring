import 'package:classmonitor/utils/ApiService.dart';
import 'package:flutter/material.dart'; // For debugPrint

class UserAccount {
  final String? accountId;
  final String username;
  final String? password;
  final String dept;
  final String prog;
  final String sem;
  final String sec;
  final UserRole role;

  UserAccount({
    this.accountId,
    required this.username,
    this.password,
    required this.dept,
    required this.prog,
    required this.sem,
    required this.sec,
    required this.role,
  });

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    debugPrint('Parsing UserAccount from JSON: $json');

    // Normalize role string and handle invalid roles
    String roleString = (json['role']?.toString().toLowerCase() ?? '');
    UserRole role;
    switch (roleString) {
      case 'student':
        role = UserRole.student;
        break;
      case 'teacher':
        role = UserRole.teacher;
        break;
      case 'superadmin':
      case 'admin':
        role = UserRole.superAdmin;
        break;
      default:
        role = UserRole.student; // Fallback to student
        debugPrint(
          'Warning: Invalid role "$roleString", defaulting to student',
        );
    }

    return UserAccount(
      accountId: json['account_id']?.toString(),
      username: json['username']?.toString() ?? '',
      password: json['password']?.toString(),
      dept: json['dept'] ?? 'N/A',
      prog: json['prog'] ?? 'N/A',
      sem: json['sem']?.toString() ?? 'N/A', // Ensure sem is a string
      sec: json['sec'] ?? 'N/A',
      role: role,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'username': username,
      'dept': dept,
      'prog': prog,
      'sem': sem,
      'sec': sec,
      'role': role.name,
    };
    if (accountId != null && accountId!.isNotEmpty) {
      data['account_id'] = accountId;
    }
    if (password != null && password!.isNotEmpty) {
      data['password'] = password;
    }
    return data;
  }
}
