import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../common/constants/app_constants.dart';
import '../common/utils/logger.dart';
import 'base_api.dart';

class AuthApi extends BaseApi {
  Future<User> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/${AppConstants.apiVersion}/auth/login'),
        headers: getHeaders(),
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = User.fromMap(data['user']);
        
        // Save token for future requests
        await saveToken(data['token']);
        
        return user;
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      AppLogger.e('Login API error', e);
      rethrow;
    }
  }

  Future<User> register(String email, String password, String username) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/${AppConstants.apiVersion}/auth/register'),
        headers: getHeaders(),
        body: json.encode({
          'email': email,
          'password': password,
          'username': username,
        }),
      ).timeout(AppConstants.apiTimeout);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final user = User.fromMap(data['user']);
        
        // Save token for future requests
        await saveToken(data['token']);
        
        return user;
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      AppLogger.e('Registration API error', e);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        await http.post(
          Uri.parse('${AppConstants.baseUrl}/${AppConstants.apiVersion}/auth/logout'),
          headers: getAuthHeaders(token),
        ).timeout(AppConstants.apiTimeout);
      }
      
      // Clear stored token
      await clearToken();
    } catch (e) {
      AppLogger.e('Logout API error', e);
      // Still clear token even if API call fails
      await clearToken();
      rethrow;
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/${AppConstants.apiVersion}/auth/me'),
        headers: getAuthHeaders(token),
      ).timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromMap(data['user']);
      } else if (response.statusCode == 401) {
        // Token is invalid, clear it
        await clearToken();
        return null;
      } else {
        throw Exception('Failed to get current user: ${response.body}');
      }
    } catch (e) {
      AppLogger.e('Get current user API error', e);
      return null;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/${AppConstants.apiVersion}/auth/reset-password'),
        headers: getHeaders(),
        body: json.encode({'email': email}),
      ).timeout(AppConstants.apiTimeout);

      if (response.statusCode != 200) {
        throw Exception('Password reset failed: ${response.body}');
      }
    } catch (e) {
      AppLogger.e('Reset password API error', e);
      rethrow;
    }
  }
}
