import 'package:classmonitor/utils/ApiService.dart'; // For UserRole enum
import 'package:flutter/material.dart';

class UserAccount {
  final String? accountId;
  final String username;
  final String? password;
  final String dept;
  final String prog;
  final String sem;
  final String sec;
  final String batch;
  final UserRole role;

  UserAccount({
    this.accountId,
    required this.username,
    this.password,
    required this.dept,
    required this.prog,
    required this.sem,
    required this.sec,
    required this.batch,
    required this.role,
  });

  // --- CORRECTED `copyWith` METHOD ---
  UserAccount copyWith({
    String? accountId,
    String? username,
    String? password,
    String? dept,
    String? prog,
    String? sem,
    String? sec,
    String? batch,
    UserRole? role, // Corrected type from String? to UserRole?
  }) {
    return UserAccount(
      // Now includes all fields from the class
      accountId: accountId ?? this.accountId,
      username: username ?? this.username, // Added missing required field
      password: password ?? this.password,
      dept: dept ?? this.dept,
      prog: prog ?? this.prog,
      sem: sem ?? this.sem,
      sec: sec ?? this.sec,
      batch: batch ?? this.batch,
      role: role ?? this.role, // Now types match correctly
    );
  }
  // --- END OF CORRECTION ---

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    debugPrint('Parsing UserAccount from JSON: $json');

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
        role = UserRole.student;
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
      sem: json['sem']?.toString() ?? 'N/A',
      sec: json['sec'] ?? 'N/A',
      batch: json['batch']?.toString() ?? 'N/A',
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
      'batch': batch,
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
