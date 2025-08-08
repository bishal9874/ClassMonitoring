import 'package:classmonitor/models/classesDataModel.dart';
import 'package:classmonitor/utils/baseUrl.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../models/user_account.dart';
import '../models/class_stat.dart';
import 'package:flutter/material.dart';

class _Endpoints {
  static const getPeriods = '/student/submit_class_stat.php';
  static const submitClassStat = '/student/submit_class_stat.php';
  static const adminSubmitClassStat = '/admin/submit_class_stat.php';
}

enum UserRole { student, teacher, superAdmin }

class ApiService {
  ApiService._();

  static final Dio _dio = Dio();
  static final Dio _timeApiDio = Dio();
  static const String _tokenKey = 'jwt_token';
  static const String _roleKey = 'user_role';
  static const String _usernameKey = 'user_username';
  static const String _isLoggedInKey = 'isUserLoggedIn';

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);

    _dio.options = BaseOptions(
      baseUrl: myApiConfig.baseUrl,
      headers: {
        'Content-Type': myApiConfig.contentType,
        if (token != null) 'Authorization': 'Bearer $token',
      },
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    );

    _timeApiDio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('🚀 ${options.method} ${options.uri}');
          debugPrint('📤 Request Data: ${options.data}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('✅ ${response.statusCode} ${response.requestOptions.uri}');
          handler.next(response);
        },
        onError: (error, handler) {
          debugPrint(
            '❌ ${error.response?.statusCode} ${error.requestOptions.uri}',
          );
          debugPrint('❌ Error: ${error.message}');
          handler.next(error);
        },
      ),
    );
    debugPrint("ApiService initialized. Base URL: ${myApiConfig.baseUrl}");
  }

  /// Centralized error handling for Dio exceptions.
  static String _handleDioError(DioException e) {
    if (e.response != null) {
      final dynamic errorData = e.response?.data;
      if (errorData is Map && errorData.containsKey('error')) {
        return errorData['error'] as String;
      }
      switch (e.response?.statusCode) {
        case 401:
          return 'Invalid username or password.';
        case 400:
          return 'Missing or invalid login details.';
        case 404:
          return 'Requested endpoint not found on server.';
        case 500:
          return 'Server internal error. Please try again later.';
        default:
          return 'Server Error (${e.response?.statusCode}): An unknown server error occurred.';
      }
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Connection timed out. Please check your internet connection.';
      case DioExceptionType.connectionError:
        return 'Network connection error. Please check your internet connection.';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.unknown:
        if (e.error is SocketException) {
          return 'No internet connection. Please check your network.';
        }
        return 'Network Error: ${e.message ?? 'An unexpected network error occurred.'}';
      default:
        return 'Network Error: ${e.message ?? 'An unexpected error occurred.'}';
    }
  }

  /// Retries an API call up to [maxAttempts] times with a [delay] between attempts.
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

  /// Validates login time using an external time API (bypassed for development).
  static Future<void> _validateLoginTime() async {
    debugPrint('Skipping time validation for testing.');
    return; // Bypass for development

    DateTime networkTime;
    try {
      final response = await _timeApiDio.get(
        'http://worldtimeapi.org/api/timezone/Asia/Kolkata',
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

    if ((networkTime.difference(DateTime.now()).abs()) >
        const Duration(minutes: 2)) {
      throw Exception(
        'System time is incorrect. Please update your device clock.',
      );
    }

    if (networkTime.weekday > DateTime.friday) {
      throw Exception('Login is only allowed from Monday to Friday.');
    }
  }

  /// Authenticates a user and returns their role.
  static Future<UserRole?> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      debugPrint('Login attempt with empty username or password.');
      throw Exception('Username and password cannot be empty.');
    }

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
        await _saveSession(token, username, UserRole.superAdmin);
        UserAccount userDetails;
        try {
          userDetails = await getCurrentUserDetails();
          debugPrint(
            'Successfully fetched Admin user details: ${userDetails.toJson()}',
          );
          await _saveSession(token, username, userDetails.role);
        } catch (e) {
          debugPrint(
            'WARNING: Failed to get full admin user details after token. Assuming superAdmin. Error: $e',
          );
          userDetails = UserAccount(
            username: username,
            dept: '',
            prog: '',
            sem: '',
            sec: '',
            batch: '',
            role: UserRole.superAdmin,
          );
        }
        return userDetails.role;
      }
    } on DioException catch (e) {
      if (e.response != null &&
          e.response!.statusCode! >= 400 &&
          e.response!.statusCode! < 500) {
        debugPrint(
          'Admin login failed with client error (${e.response?.statusCode}). Trying student/teacher login...',
        );
      } else {
        throw Exception(_handleDioError(e));
      }
    } catch (e, stackTrace) {
      debugPrint(
        'Unexpected error during initial admin login attempt: $e\nStackTrace: $stackTrace',
      );
    }

    try {
      await _validateLoginTime();
      debugPrint(
        'Attempting Student/Teacher login for: $username via /student/login.php',
      );
      final commonLoginResponse = await _withRetry(
        () => _dio.post(
          '/student/login.php',
          data: {'username': username, 'password': password},
        ),
        3,
      );

      debugPrint('Student/Teacher login response: ${commonLoginResponse.data}');

      if (commonLoginResponse.statusCode == 200 &&
          commonLoginResponse.data is Map &&
          commonLoginResponse.data['token'] != null) {
        final token = commonLoginResponse.data['token'];
        await _saveSession(token, username, UserRole.student);
        UserAccount userDetails;
        try {
          userDetails = await getCurrentUserDetails();
          debugPrint(
            'Successfully fetched Student/Teacher user details: ${userDetails.toJson()}',
          );
        } catch (e) {
          debugPrint(
            'ERROR: Failed to get user details after token acquisition. Clearing session: $e',
          );
          await logout();
          throw Exception(
            'Login successful, but failed to retrieve user role. Please try again.',
          );
        }
        await _saveSession(token, username, userDetails.role);
        return userDetails.role;
      }
      debugPrint(
        'Invalid login response from /student/login.php (no token or bad status): ${commonLoginResponse.data}',
      );
      return null;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e, stackTrace) {
      debugPrint(
        'Unexpected student/teacher login error: $e\nStackTrace: $stackTrace',
      );
      throw Exception('Login failed: $e');
    }
  }

  /// Saves user session data to SharedPreferences.
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
    _dio.options.headers['Authorization'] = 'Bearer $token';
    debugPrint(
      'Session saved: Username=$username, Role=${role.name}, IsLoggedIn=true',
    );
  }

  /// Logs out the user and clears session data.
  static Future<void> logout() async {
    debugPrint('*** LOGOUT CALLED FROM: ${StackTrace.current} ***');
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _dio.options.headers.remove('Authorization');
    debugPrint('User logged out. Session cleared.');
  }

  /// Checks if a user is logged in.
  static Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// Retrieves the user's role from SharedPreferences.
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
        return null;
      }
    }
    return null;
  }

  /// Fetches the current user's details.
  static Future<UserAccount> getCurrentUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(_usernameKey);
    if (username == null || username.isEmpty) {
      throw Exception(
        'Username not found in session. User might not be logged in.',
      );
    }
    try {
      final response = await _withRetry(
        () => _dio.post(
          '/student/get_user_details.php',
          data: {'username': username},
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

  /// Fetches all user accounts (admin only).
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

  /// Creates a new user account (admin only).
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

  /// Updates an existing user account (admin only).
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

  /// Deletes a user account by ID (admin only).
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

  /// Fetches class statistics for a given date, user role, and user context.
  static Future<List<ClassStat>> fetchClassStatsByDate(
    DateTime date, {
    required UserRole userRole,
    required UserAccount user,
    CancelToken? cancelToken,
  }) async {
    try {
      if (user.prog == null || user.prog!.isEmpty)
        throw Exception('Invalid user program information');
      if (user.dept == null || user.dept!.isEmpty)
        throw Exception('Invalid user department information');
      if (user.sem == null || user.sem!.isEmpty)
        throw Exception('Invalid user semester information');
      if (user.sec == null || user.sec!.isEmpty)
        throw Exception('Invalid user section information');
      if (user.batch == null || user.batch!.isEmpty)
        throw Exception('Invalid user batch information');

      final endpoint = userRole == UserRole.superAdmin
          ? _Endpoints.adminSubmitClassStat
          : _Endpoints.submitClassStat;
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);

      final response = await _withRetry(
        () => _dio.post(
          endpoint,
          data: {
            'date': formattedDate,
            'prog': user.prog!.trim(),
            'dept': user.dept!.trim(),
            'sem': user.sem!.trim(),
            'section': user.sec!.trim(),
            'batch': user.batch!.trim(),
          },
          cancelToken: cancelToken,
        ),
        3,
      );

      debugPrint('Raw class stats response from $endpoint: ${response.data}');

      if (response.statusCode == 200) {
        List<dynamic>? statsData;
        if (response.data is Map<String, dynamic> &&
            response.data['class_stats'] is List) {
          statsData = response.data['class_stats'];
        } else if (response.data is List) {
          statsData = response.data;
        }

        if (statsData != null && statsData.isNotEmpty) {
          return statsData
              .map((json) {
                try {
                  return ClassStat.fromJson(json as Map<String, dynamic>);
                } catch (e) {
                  debugPrint('⚠️ Error parsing class stat: $e');
                  return null;
                }
              })
              .whereType<ClassStat>()
              .toList();
        }
      }
      debugPrint('No class stats found or invalid response format.');
      return [];
    } on DioException catch (e) {
      debugPrint('❌ DioException in fetchClassStatsByDate: ${e.message}');
      throw Exception(_handleDioError(e));
    } catch (e, stackTrace) {
      debugPrint(
        '❌ General error in fetchClassStatsByDate: $e\nStackTrace: $stackTrace',
      );
      throw Exception('Failed to fetch class stats: $e');
    }
  }

  /// Fetches class periods for a given date and user context.
  static Future<List<ClassPeriod>> fetchPeriodsForDate(
    DateTime date, {
    required UserAccount user,
    CancelToken? cancelToken,
  }) async {
    try {
      if (user.prog == null || user.prog!.isEmpty)
        throw Exception('Invalid user program information');
      if (user.dept == null || user.dept!.isEmpty)
        throw Exception('Invalid user department information');
      if (user.sem == null || user.sem!.isEmpty)
        throw Exception('Invalid user semester information');
      if (user.sec == null || user.sec!.isEmpty)
        throw Exception('Invalid user section information');
      if (user.batch == null || user.batch!.isEmpty)
        throw Exception('Invalid user batch information');

      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final response = await _withRetry(
        () => _dio.post(
          _Endpoints.getPeriods,
          data: {
            'date': formattedDate,
            'prog': user.prog!.trim(),
            'dept': user.dept!.trim(),
            'sem': user.sem!.trim(),
            'section': user.sec!.trim(),
            'batch': user.batch!.trim(),
          },
          cancelToken: cancelToken,
        ),
        3,
      );

      debugPrint(
        'Raw periods response from ${_Endpoints.getPeriods}: ${response.data}',
      );

      if (response.statusCode == 200) {
        List<dynamic>? periodsData;
        if (response.data is Map<String, dynamic> &&
            response.data['periods'] is List) {
          periodsData = response.data['periods'];
        } else if (response.data is List) {
          periodsData = response.data;
        }

        if (periodsData != null && periodsData.isNotEmpty) {
          return periodsData
              .map((json) {
                try {
                  return ClassPeriod.fromJson(json as Map<String, dynamic>);
                } catch (e) {
                  debugPrint('⚠️ Error parsing period: $e');
                  return null;
                }
              })
              .whereType<ClassPeriod>()
              .toList();
        }
      }

      // Fallback to default periods if API returns no valid data
      debugPrint('No valid periods found, returning default periods');
      return List.generate(8, (index) {
        final startTime = DateTime(
          date.year,
          date.month,
          date.day,
          9 + index,
          0,
        );
        final endTime = startTime.add(const Duration(hours: 1));
        return ClassPeriod(
          subject: 'P${index + 1}',
          startTime: startTime,
          endTime: endTime,
          status: _getPeriodStatus(startTime, endTime, date),
          remark: '',
          attendanceStatus: false,
        );
      });
    } on DioException catch (e) {
      debugPrint('❌ DioException in fetchPeriodsForDate: ${e.message}');
      throw Exception(_handleDioError(e));
    } catch (e, stackTrace) {
      debugPrint(
        '❌ General error in fetchPeriodsForDate: $e\nStackTrace: $stackTrace',
      );
      throw Exception('Failed to fetch periods: $e');
    }
  }

  /// Determines the status of a class period based on its start and end times.
  static PeriodStatus _getPeriodStatus(
    DateTime start,
    DateTime end,
    DateTime selectedDate,
  ) {
    final now = DateTime.now();
    final isToday =
        selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    if (!isToday) {
      return selectedDate.isBefore(now)
          ? PeriodStatus.completed
          : PeriodStatus.upcoming;
    }

    if (now.isBefore(start)) return PeriodStatus.upcoming;
    if (now.isAfter(end)) return PeriodStatus.completed;
    return PeriodStatus.ongoing;
  }

  /// Creates or updates a class attendance statistic for the day.
  static Future<bool> upsertClassStat(
    ClassStat stat, {
    required UserRole userRole,
    CancelToken? cancelToken,
  }) async {
    try {
      if (stat.date.isEmpty) throw Exception('Date is required');
      if (stat.prog.isEmpty) throw Exception('Program is required');
      if (stat.dept.isEmpty) throw Exception('Department is required');
      if (stat.sem.isEmpty) throw Exception('Semester is required');
      if (stat.section.isEmpty) throw Exception('Section is required');

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      if (token == null || token.isEmpty) {
        debugPrint('❌ No valid token found in session.');
        throw Exception('User is not authenticated. Please log in again.');
      }

      final endpoint = userRole == UserRole.superAdmin
          ? _Endpoints.adminSubmitClassStat
          : _Endpoints.submitClassStat;
      final submissionData = stat.toJson();

      // Generate marking string for attended periods (e.g., 'p1.p3.p5')
      final List<String> attendedPeriods = [];
      for (int i = 1; i <= 8; i++) {
        if (submissionData['p$i'] == 1) {
          attendedPeriods.add('p$i');
        }
      }
      final String markingString = attendedPeriods.join('.');

      submissionData['last_entry'] = DateFormat(
        'yyyy-MM-dd HH:mm:ss',
      ).format(DateTime.now());

      if (userRole == UserRole.student) {
        submissionData['cr_marking'] = markingString;
        submissionData['prof_marking'] = stat.profMarking ?? '';
      } else if (userRole == UserRole.teacher ||
          userRole == UserRole.superAdmin) {
        submissionData['prof_marking'] = markingString;
        submissionData['cr_marking'] = stat.crMarking ?? '';
      }

      debugPrint(
        '📤 Submitting class stat to $endpoint with data: $submissionData',
      );

      final response = await _withRetry(
        () =>
            _dio.put(endpoint, data: submissionData, cancelToken: cancelToken),
        3,
      );

      debugPrint('✅ Raw upsert response from $endpoint: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          final responseData = response.data as Map<String, dynamic>;
          final success = responseData['success'];
          final status = responseData['status']?.toString().toLowerCase();
          if (success == true ||
              success == 'true' ||
              status == 'success' ||
              status == 'ok' ||
              status == 'updated' ||
              status == 'inserted') {
            debugPrint('✅ Class stat upserted successfully');
            return true;
          } else {
            final message =
                responseData['message'] ??
                responseData['error'] ??
                'Unknown error from server';
            debugPrint('❌ Server reported failure: $message');
            return false;
          }
        } else {
          debugPrint(
            '❌ Invalid response format: Expected Map, got ${response.data.runtimeType}',
          );
          return false;
        }
      }
      debugPrint('❌ Invalid response status: ${response.statusCode}');
      return false;
    } on DioException catch (e) {
      debugPrint('❌ DioException in upsertClassStat: ${e.message}');
      throw Exception(_handleDioError(e));
    } catch (e, stackTrace) {
      debugPrint(
        '❌ General error in upsertClassStat: $e\nStackTrace: $stackTrace',
      );
      throw Exception('Failed to save data: $e');
    }
  }
}

extension ClassStatExtension on ClassStat {
  String getRemark(int periodNumber) {
    switch (periodNumber) {
      case 1:
        return p1Remarks;
      case 2:
        return p2Remarks;
      case 3:
        return p3Remarks;
      case 4:
        return p4Remarks;
      case 5:
        return p5Remarks;
      case 6:
        return p6Remarks;
      case 7:
        return p7Remarks;
      case 8:
        return p8Remarks;
      default:
        return '';
    }
  }

  int getPeriodStatus(int periodNumber) {
    switch (periodNumber) {
      case 1:
        return p1;
      case 2:
        return p2;
      case 3:
        return p3;
      case 4:
        return p4;
      case 5:
        return p5;
      case 6:
        return p6;
      case 7:
        return p7;
      case 8:
        return p8;
      default:
        return 0;
    }
  }
}
