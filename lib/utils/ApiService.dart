import 'package:classmonitor/utils/baseUrl.dart'; // Imports ApiConfig and myApiConfig
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:io'; // Import for SocketException (used in DioExceptionType.unknown check)

import '../models/user_account.dart'; // UserAccount model definition
import '../models/class_stat.dart'; // ClassStat model definition
import 'package:flutter/material.dart'; // For debugPrint

enum UserRole { student, teacher, superAdmin }

class ApiService {
  ApiService._();

  static final Dio _dio = Dio();
  static final Dio _timeApiDio = Dio(); // For external time validation
  static const String _tokenKey = 'jwt_token';
  static const String _roleKey = 'user_role';
  static const String _usernameKey = 'user_username';
  static const String _isLoggedInKey = 'isUserLoggedIn';

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);

    _dio.options = BaseOptions(
      baseUrl: myApiConfig.baseUrl, // e.g., 'https://classmonitor.aucseapp.in/'
      headers: {
        'Content-Type': myApiConfig.contentType, // e.g., 'application/json'
        if (token != null)
          'Authorization': 'Bearer $token', // Set token if already present
      },
      connectTimeout: const Duration(
        seconds: 15,
      ), // 15 seconds connection timeout
      receiveTimeout: const Duration(seconds: 15), // 15 seconds receive timeout
    );

    _timeApiDio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    );
    debugPrint("ApiService initialized. Base URL: ${myApiConfig.baseUrl}");
  }

  // --- Centralized Error Handling for DioExceptions ---
  static String _handleDioError(DioException e) {
    if (e.response != null) {
      final dynamic errorData = e.response?.data;
      if (errorData is Map && errorData.containsKey('error')) {
        return errorData['error']
            as String; // Specific error message from server
      }
      if (e.response?.statusCode == 401) {
        return 'Invalid username or password.';
      } else if (e.response?.statusCode == 400) {
        return 'Missing or invalid login details.';
      } else if (e.response?.statusCode == 404) {
        return 'Requested endpoint not found on server.';
      } else if (e.response?.statusCode == 500) {
        return 'Server internal error. Please try again later.';
      }
      return 'Server Error (${e.response?.statusCode}): An unknown server error occurred.';
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Connection timed out. Please check your internet connection.';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'Network connection error. Please check your internet connection.';
    } else if (e.type == DioExceptionType.cancel) {
      return 'Request cancelled.';
    } else if (e.type == DioExceptionType.unknown &&
        e.error is SocketException) {
      return 'No internet connection. Please check your network.';
    }
    return 'Network Error: ${e.message ?? 'An unexpected network error occurred.'}';
  }

  // --- Retry Mechanism for API Calls ---
  static Future<dynamic> _withRetry(
    Future<dynamic> Function() apiCall,
    int maxAttempts, {
    Duration delay = const Duration(seconds: 2),
  }) async {
    int attempts = 0;
    while (attempts < maxAttempts) {
      try {
        return await apiCall();
      } on DioException catch (e) {
        attempts++;
        // Re-throw immediately for client errors (4xx) on the last attempt,
        // or for any error if max attempts are reached.
        if (attempts == maxAttempts ||
            (e.response != null &&
                e.response!.statusCode! >= 400 &&
                e.response!.statusCode! < 500)) {
          throw Exception(_handleDioError(e));
        }
        debugPrint(
          'Retrying API call ($attempts/$maxAttempts) after error: ${e.message}',
        );
        await Future.delayed(delay);
      }
    }
    throw Exception('Max retry attempts reached for API call.');
  }

  // --- Time Validation (Currently Bypassed for Development) ---
  static Future<void> _validateLoginTime() async {
    debugPrint('Skipping time validation for testing.');
    return; // Temporarily bypass for easier development

    DateTime networkTime;
    try {
      final response = await _timeApiDio.get(
        'http://worldtimeapi.org/api/timezone/Asia/Kolkata', // Use a reliable time API
      );
      if (response.statusCode == 200 && response.data['datetime'] != null) {
        networkTime = DateTime.parse(response.data['datetime']);
        debugPrint('Network Time: $networkTime');
        debugPrint('Device Time: ${DateTime.now()}');
      } else {
        throw Exception('Failed to get valid network time from API.');
      }
    } on DioException catch (e) {
      throw Exception(
        'Failed to connect to time server: ${_handleDioError(e)}',
      );
    }

    // Check if network time is significantly different from device time
    if ((networkTime.difference(DateTime.now()).abs()) >
        const Duration(minutes: 2)) {
      throw Exception(
        'System time is incorrect. Please update your device clock.',
      );
    }

    // Check if it's a weekday (Monday=1, Friday=5). Allows logins Mon-Fri.
    if (networkTime.weekday > DateTime.friday) {
      throw Exception('Login is only allowed from Monday to Friday.');
    }
  }

  // --- Main Login Method ---
  static Future<UserRole?> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      debugPrint('Login attempt with empty username or password.');
      throw Exception('Username and password cannot be empty.');
    }

    // 1. Attempt Admin login first
    try {
      debugPrint('Attempting Admin login for: $username');
      final adminLoginResponse = await _withRetry(
        () => _dio.post(
          '/admin/login.php',
          data: {'username': username, 'password': password},
        ),
        3,
      );

      debugPrint(
        'Admin login response - Status: ${adminLoginResponse.statusCode}, Data: ${adminLoginResponse.data}',
      );

      if (adminLoginResponse.statusCode == 200 &&
          adminLoginResponse.data is Map &&
          adminLoginResponse.data['token'] != null) {
        final token = adminLoginResponse.data['token'];

        // --- CORRECTED FLOW FOR ADMIN: Save username/token FIRST ---
        // Temporarily save session so getCurrentUserDetails can retrieve username
        await _saveSession(
          token,
          username,
          UserRole.superAdmin,
        ); // Assume superAdmin initially

        UserAccount userDetails;
        try {
          userDetails =
              await getCurrentUserDetails(); // Fetch full admin details using saved username
          debugPrint(
            'Successfully fetched Admin user details: ${userDetails.toJson()}',
          );
          // Important: Re-save session with the actual role if getCurrentUserDetails returned a more specific one
          await _saveSession(token, username, userDetails.role);
        } catch (e) {
          debugPrint(
            'WARNING: Failed to get full admin user details after token. Assuming superAdmin. Error: $e',
          );
          // If fetching admin details fails, assume superAdmin based on initial successful token
          // The session is already saved, no need to resave unless role changed.
          userDetails = UserAccount(
            username: username,
            dept: '',
            prog: '',
            sem: '',
            sec: '', // Default values for missing details
            role: UserRole
                .superAdmin, // Confirm superAdmin as the default fallback
          );
        }
        return userDetails.role;
      }
    } on DioException catch (e) {
      // If it's a client error (e.g., 401 for wrong admin creds), don't re-throw,
      // just log and proceed to try student/teacher login.
      if (e.response != null &&
          e.response!.statusCode! >= 400 &&
          e.response!.statusCode! < 500) {
        debugPrint(
          'Admin login failed with client error (${e.response?.statusCode}). Trying student/teacher login...',
        );
      } else {
        // Re-throw server errors (5xx) or network errors directly
        throw Exception(_handleDioError(e));
      }
    } catch (e, stackTrace) {
      debugPrint(
        'Unexpected error during initial admin login attempt: $e\nStackTrace: $stackTrace',
      );
    }

    // 2. Attempt Student/Teacher login via the /student/login.php endpoint
    try {
      await _validateLoginTime(); // Validate time before student/teacher login

      debugPrint(
        'Attempting Student/Teacher login for: $username via /student/login.php',
      );
      final commonLoginResponse = await _withRetry(
        () => _dio.post(
          '/student/login.php', // This endpoint is used for BOTH student and teacher
          data: {'username': username, 'password': password},
        ),
        3,
      );

      debugPrint('Student/Teacher login response: ${commonLoginResponse.data}');

      if (commonLoginResponse.statusCode == 200 &&
          commonLoginResponse.data is Map &&
          commonLoginResponse.data['token'] != null) {
        final token = commonLoginResponse.data['token'];

        // --- CORRECTED FLOW FOR STUDENT/TEACHER: Save username/token FIRST ---
        // Temporarily save session assuming 'student' role. This ensures username is available.
        await _saveSession(
          token,
          username,
          UserRole.student,
        ); // Will be updated by actual role

        UserAccount userDetails;
        try {
          userDetails =
              await getCurrentUserDetails(); // Now username is available in prefs
          debugPrint(
            'Successfully fetched Student/Teacher user details: ${userDetails.toJson()}',
          );
        } catch (e) {
          debugPrint(
            'ERROR: Failed to get user details after token acquisition. Clearing session.: $e',
          );
          await logout(); // Log out because we can't get crucial user details (like actual role)
          throw Exception(
            'Login successful, but failed to retrieve user role. Please try again.',
          );
        }

        // Now save the session again with the *actual* role fetched from userDetails
        await _saveSession(token, username, userDetails.role);
        return userDetails.role;
      }
      debugPrint(
        'Invalid login response from /student/login.php (no token or bad status): ${commonLoginResponse.data}',
      );
      return null; // Login failed for student/teacher
    } on DioException catch (e) {
      throw Exception(
        _handleDioError(e),
      ); // Handle Dio errors for student/teacher login
    } catch (e, stackTrace) {
      debugPrint(
        'Unexpected student/teacher login error: $e\nStackTrace: $stackTrace',
      );
      throw Exception('Login failed: $e');
    }
  }

  // --- Session Management ---
  static Future<void> _saveSession(
    String token,
    String username,
    UserRole role,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_usernameKey, username);
    await prefs.setString(_roleKey, role.name);
    await prefs.setBool(_isLoggedInKey, true);
    _dio.options.headers['Authorization'] =
        'Bearer $token'; // Always update Dio's header for subsequent calls
    debugPrint(
      'Session saved: Token (masked)=..., Username=$username, Role=${role.name}, IsLoggedIn=true',
    );
  }

  static Future<void> logout() async {
    // THIS IS YOUR KEY DEBUG PRINT! Check your console for this exact line and its stack trace.
    debugPrint('*** LOGOUT CALLED FROM: ${StackTrace.current} ***');
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clears all stored session data
    _dio.options.headers.remove('Authorization'); // Remove auth header
    debugPrint('User logged out. Session cleared.');
  }

  static Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  static Future<UserRole?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    final roleString = prefs.getString(_roleKey);
    debugPrint('Stored role retrieved from preferences: $roleString');
    if (roleString != null) {
      try {
        return UserRole.values.firstWhere((e) => e.name == roleString);
      } catch (e) {
        debugPrint(
          'Error parsing stored role "$roleString", defaulting to null. Error: $e',
        );
        return null; // Return null if stored role string is not a valid enum value
      }
    }
    return null;
  }

  // --- User Account Management (Generic and Admin Specific) ---
  static Future<UserAccount> getCurrentUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(
      _usernameKey,
    ); // Retrieve username from saved session
    if (username == null || username.isEmpty) {
      throw Exception(
        'Username not found in session for getCurrentUserDetails. User might not be logged in or session is corrupt.',
      );
    }
    try {
      // This endpoint is assumed to provide details for student, teacher, or admin based on the token
      // and/or the username provided.
      final response = await _withRetry(
        () => _dio.post(
          '/student/get_user_details.php', // Use this endpoint for all user detail fetching
          data: {'username': username}, // Send username in the body
          // --- IMPORTANT: READ BELOW ---
          // If your backend relies solely on the JWT token in the header and
          // ignores/is confused by the username in the body for this endpoint,
          // then COMMENT OUT the 'data: {'username': username}' line above.
          // Test with Postman first to confirm if the username in the body is needed or not.
        ),
        3,
      );
      debugPrint(
        'Raw User details response from /student/get_user_details.php: ${response.data}',
      );
      if (response.statusCode == 200 &&
          response.data is Map &&
          response.data['user'] != null) {
        return UserAccount.fromJson(response.data['user']);
      }
      throw Exception(
        'Invalid response format or no "user" data in details endpoint. Response: ${response.data}',
      );
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  static Future<List<UserAccount>> getAllUsers() async {
    try {
      final response = await _withRetry(
        () => _dio.get('/admin/user_account.php'),
        3,
      );
      if (response.statusCode == 200 &&
          response.data is Map &&
          response.data['accounts'] != null) {
        final List accounts = response.data['accounts'];
        return accounts.map((json) => UserAccount.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  static Future<bool> createUser(UserAccount user) async {
    try {
      final response = await _withRetry(
        () => _dio.post('/admin/user_account.php', data: user.toJson()),
        3,
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  // -- UPDATE USER ---
  static Future<bool> updateUser(UserAccount user) async {
    try {
      final response = await _withRetry(
        () => _dio.put('/admin/user_account.php', data: user.toJson()),
        3,
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  // --- DELETE USER ---
  static Future<bool> deleteUser(String account_id) async {
    try {
      final response = await _withRetry(
        () => _dio.delete(
          '/admin/user_account.php',
          data: {'account_id': account_id},
        ),
        3,
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  // --- Class Statistics Management ---
  static Future<List<ClassStat>> fetchClassStatsByDate(
    DateTime date, {
    required bool forAdmin,
  }) async {
    final endpoint = forAdmin
        ? '/admin/submit_class_stat.php'
        : '/student/submit_class_stat.php';
    try {
      final response = await _withRetry(
        () => _dio.get(
          endpoint,
          queryParameters: {'date': DateFormat('yyyy-MM-dd').format(date)},
        ),
        3,
      );
      if (response.statusCode == 200 &&
          response.data is Map &&
          response.data['class_stats'] != null) {
        final List data = response.data['class_stats'];
        return data.map((json) => ClassStat.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  static Future<bool> upsertClassStat(
    ClassStat stat, {
    required bool forAdmin,
  }) async {
    final endpoint = forAdmin
        ? '/admin/submit_class_stat.php'
        : '/student/submit_class_stat.php';
    try {
      final Map<String, dynamic> data = stat.toJson();
      if (forAdmin) {
        data['mode'] =
            'upsert'; // Assuming the backend expects 'mode' for admin upsert
      }
      final response = await _withRetry(
        () => _dio.post(endpoint, data: data),
        3,
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  static Future<List<String>> getDepartments() async {
    try {
      final response = await _withRetry(
        () => _dio.get('/common/get_departments.php'),
        3,
      );
      if (response.statusCode == 200 &&
          response.data is Map &&
          response.data['departments'] != null) {
        final List<dynamic> data = response.data['departments'];
        return data.map((e) => e.toString()).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  static Future<List<String>> getPrograms(String department) async {
    try {
      final response = await _withRetry(
        () => _dio.get(
          '/common/get_programs.php',
          queryParameters: {'dept': department},
        ),
        3,
      );
      if (response.statusCode == 200 &&
          response.data is Map &&
          response.data['programs'] != null) {
        final List<dynamic> data = response.data['programs'];
        return data.map((e) => e.toString()).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  static Future<List<String>> getSemesters(
    String department,
    String program,
  ) async {
    try {
      final response = await _withRetry(
        () => _dio.get(
          '/common/get_semesters.php',
          queryParameters: {'dept': department, 'prog': program},
        ),
        3,
      );
      if (response.statusCode == 200 &&
          response.data is Map &&
          response.data['semesters'] != null) {
        final List<dynamic> data = response.data['semesters'];
        return data.map((e) => e.toString()).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  static Future<List<String>> getSections(
    String department,
    String program,
    String semester,
  ) async {
    try {
      final response = await _withRetry(
        () => _dio.get(
          '/common/get_sections.php',
          queryParameters: {
            'dept': department,
            'prog': program,
            'sem': semester,
          },
        ),
        3,
      );
      if (response.statusCode == 200 &&
          response.data is Map &&
          response.data['sections'] != null) {
        final List<dynamic> data = response.data['sections'];
        return data.map((e) => e.toString()).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  static Future<List<UserAccount>> getUsersByFilters(
    String department,
    String program,
    String semester,
    String section,
  ) async {
    try {
      final response = await _withRetry(
        () => _dio.get(
          '/admin/filtered_users.php',
          queryParameters: {
            'dept': department,
            'prog': program,
            'sem': semester,
            'sec': section,
          },
        ),
        3,
      );
      if (response.statusCode == 200 &&
          response.data is Map &&
          response.data['users'] != null) {
        final List<dynamic> data = response.data['users'];
        return data.map((json) => UserAccount.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
}
