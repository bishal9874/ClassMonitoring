import 'package:classmonitor/utils/baseUrl.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_account.dart';

class UserAccountService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: myApiConfig.baseUrl,
      headers: {
        'Content-Type': myApiConfig.contentType,
        'Authorization': myApiConfig.authToken,
      },
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  static const String _isLoggedInKey = 'isUserLoggedIn';
  static const String _usernameKey = 'loggedInUsername';

  // Check if the user is currently logged in
  static Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  static final Dio _timeApiDio = Dio();
  Future<void> _validateLoginTime() async {
    DateTime networkTime;
    try {
      final response = await _timeApiDio.get(
        'https://timeapi.io/api/time/current/zone?timeZone=Asia/Kolkata',
      );
      if (response.statusCode == 200 && response.data['dateTime'] != null) {
        networkTime = DateTime.parse(response.data['dateTime']);
      } else {
        throw Exception('Could not verify network time.');
      }
    } catch (e) {
      throw Exception('Could not connect to time server to verify login.');
    }

    final systemTime = DateTime.now();
    final timeDifference = networkTime.difference(systemTime).abs();

    const acceptableDifference = Duration(minutes: 2);

    if (timeDifference > acceptableDifference) {
      throw Exception(
        'System time is incorrect. Please update your device clock.',
      );
    }
    if (networkTime.weekday > DateTime.friday) {
      throw Exception('Login is only allowed from Monday to Friday.');
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      await _validateLoginTime();
      final response = await _dio.get(
        'user_account.php',
        queryParameters: {'username': username, 'password': password},
      );

      if (response.statusCode == 200 && response.data?['accounts'] != null) {
        final List<dynamic> accounts = response.data['accounts'];
        final userExists = accounts.any(
          (account) => account['username'] == username,
        );

        if (userExists) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(_isLoggedInKey, true);
          await prefs.setString(_usernameKey, username);
          return true;
        }
      }
      return false;
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? e.message;
      throw Exception('Login failed: $message');
    } catch (e) {
      throw Exception('An unexpected error occurred during login.');
    }
  }

  // Handle user logout: clear the session state
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_usernameKey);
  }

  // Handle user signup
  Future<bool> signUp(UserAccount user) async {
    try {
      final response = await _dio.post('user_account.php', data: user.toJson());
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      throw Exception(
        'Signup failed: ${e.response?.data['message'] ?? e.message}',
      );
    }
  }

  // Get all users
  Future<List<UserAccount>> getAllUsers() async {
    try {
      final response = await _dio.get('user_account.php');
      final List<dynamic> data = response.data['accounts'];
      return data.map((json) => UserAccount.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(
        'Failed to fetch users: ${e.response?.data['message'] ?? e.message}',
      );
    }
  }

  // Create a new user
  Future<UserAccount> createUser(UserAccount user) async {
    try {
      final response = await _dio.post('user_account.php', data: user.toJson());
      return UserAccount.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        'Failed to create user: ${e.response?.data['message'] ?? e.message}',
      );
    }
  }

  // Update an existing user
  Future<UserAccount> updateUser(UserAccount user) async {
    try {
      final response = await _dio.put('user_account.php', data: user.toJson());
      return UserAccount.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        'Failed to update user: ${e.response?.data['message'] ?? e.message}',
      );
    }
  }

  // Delete a user
  Future<void> deleteUser(int accountId) async {
    try {
      await _dio.delete('user_account.php', data: {'account_id': accountId});
    } on DioException catch (e) {
      throw Exception(
        'Failed to delete user: ${e.response?.data['message'] ?? e.message}',
      );
    }
  }
  //Fetch details for only the currrent  user logged in

  Future<UserAccount> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(_usernameKey);

    if (username == null) {
      throw Exception('No user is logged in.');
    }

    try {
      final response = await _dio.get(
        'user_account.php',
        queryParameters: {'username': username},
      );
      if (response.statusCode == 200 && response.data?['accounts'] != null) {
        final List<dynamic> accounts = response.data['accounts'];
        final userAccountData = accounts.firstWhere(
          (account) => account['username'] == username,
          orElse: () => null,
        );

        if (userAccountData != null) {
          return UserAccount.fromJson(userAccountData);
        }
      }
      throw Exception('Failed to find user data.');
    } catch (e) {
      throw Exception('Failed to fetch user details.');
    }
  }
}
