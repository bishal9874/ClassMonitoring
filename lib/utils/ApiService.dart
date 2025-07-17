import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_account.dart';

class UserAccountService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://classmonitor.aucseapp.in/',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer secure',
      },
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('Token') ?? 'secure';
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('Token');
    _dio.options.headers.remove('Authorization');
  }

  Future<bool> signUp(UserAccount user) async {
    try {
      final response = await _dio.post('user_account.php', data: user.toJson());
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      throw Exception('Signup failed: ${e.message}');
    } catch (e) {
      throw Exception('Signup failed: $e');
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await _dio.get(
        'user_account.php',
        queryParameters: {'username': username, 'password': password},
      );
      if (response.data != null &&
          (response.data['success'] == true ||
              response.data['username'] != null)) {
        loadToken();
        return true;
      }
      return false;
    } on DioException catch (e) {
      throw Exception('Login failed: ${e.message}');
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<List<UserAccount>> getAllUsers() async {
    try {
      final response = await _dio.get('user_account.php');
      final data = response.data as List;
      return data.map((json) => UserAccount.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  Future<UserAccount> createUser(UserAccount user) async {
    try {
      final response = await _dio.post('user_account.php', data: user.toJson());
      return UserAccount.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<UserAccount> updateUser(UserAccount user) async {
    try {
      final response = await _dio.put('user_account.php', data: user.toJson());
      return UserAccount.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> deleteUser(int accountId) async {
    try {
      await _dio.delete('user_account.php', data: {'account_id': accountId});
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }
}
