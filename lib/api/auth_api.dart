import 'dart:convert';

import 'package:http/http.dart' as http;

import '../common/constants/app_constants.dart';
import '../common/utils/logger.dart';
import '../models/user_model.dart';
import 'base_api.dart';

class AuthApi extends BaseApi {
  // 🎯 演示模式：允许的测试账号
  static const Map<String, String> _demoAccounts = {
    'demo@rico.com': 'password123',
    'test@example.com': '123456',
    'admin@rico.com': 'admin123',
    'user@rico.com': 'user123',
  };

  Future<User> login(String email, String password) async {
    try {
      // 🔥 演示模式：检查是否为测试账号
      if (_demoAccounts.containsKey(email)) {
        if (_demoAccounts[email] == password) {
          // 模拟网络延迟
          await Future.delayed(const Duration(milliseconds: 800));

          // 创建演示用户数据
          final user = _createDemoUser(email);

          // 保存演示 token
          await saveToken(
              'demo_token_${DateTime.now().millisecondsSinceEpoch}');

          AppLogger.i('Demo login successful for: $email');
          return user;
        } else {
          throw Exception('密码错误');
        }
      }

      // 🌐 真实 API 模式（当前不可用）
      final response = await http
          .post(
            Uri.parse(
                '${AppConstants.baseUrl}/${AppConstants.apiVersion}/auth/login'),
            headers: getHeaders(),
            body: json.encode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(AppConstants.apiTimeout);

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

      // 如果是网络错误，提供更友好的错误信息
      if (e.toString().contains('Failed host lookup') ||
          e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        throw Exception('网络连接失败，请检查网络或使用演示账号登录');
      }

      rethrow;
    }
  }

  // 一键登录方法 - 直接使用默认演示账号登录
  Future<User> quickLogin() async {
    try {
      // 模拟网络延迟
      await Future.delayed(const Duration(milliseconds: 500));

      // 使用默认的演示账号
      const defaultEmail = 'demo@rico.com';

      // 创建演示用户数据
      final user = _createDemoUser(defaultEmail);

      // 保存演示 token
      await saveToken(
          'quick_login_token_${DateTime.now().millisecondsSinceEpoch}');

      AppLogger.i('Quick login successful for: $defaultEmail');
      return user;
    } catch (e) {
      AppLogger.e('Quick login API error', e);
      rethrow;
    }
  }

  // 🎯 创建演示用户数据
  User _createDemoUser(String email) {
    final now = DateTime.now();

    // 根据邮箱生成不同的用户信息
    Map<String, dynamic> userData = {
      'id': 'demo_${email.split('@')[0]}',
      'email': email,
      'username': email.split('@')[0],
      'createdAt':
          now.subtract(const Duration(days: 30)).millisecondsSinceEpoch,
      'updatedAt': now.millisecondsSinceEpoch,
      'isActive': true,
    };

    switch (email) {
      case 'demo@rico.com':
        userData.addAll({
          'firstName': 'Demo',
          'lastName': 'User',
        });
        break;
      case 'test@example.com':
        userData.addAll({
          'firstName': 'Test',
          'lastName': 'Example',
        });
        break;
      case 'admin@rico.com':
        userData.addAll({
          'firstName': 'Admin',
          'lastName': 'Rico',
        });
        break;
      case 'user@rico.com':
        userData.addAll({
          'firstName': 'Rico',
          'lastName': 'User',
        });
        break;
    }

    return User.fromMap(userData);
  }

  Future<User> register(String email, String password, String username) async {
    try {
      final response = await http
          .post(
            Uri.parse(
                '${AppConstants.baseUrl}/${AppConstants.apiVersion}/auth/register'),
            headers: getHeaders(),
            body: json.encode({
              'email': email,
              'password': password,
              'username': username,
            }),
          )
          .timeout(AppConstants.apiTimeout);

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
        await http
            .post(
              Uri.parse(
                  '${AppConstants.baseUrl}/${AppConstants.apiVersion}/auth/logout'),
              headers: getAuthHeaders(token),
            )
            .timeout(AppConstants.apiTimeout);
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

      final response = await http
          .get(
            Uri.parse(
                '${AppConstants.baseUrl}/${AppConstants.apiVersion}/auth/me'),
            headers: getAuthHeaders(token),
          )
          .timeout(AppConstants.apiTimeout);

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
      final response = await http
          .post(
            Uri.parse(
                '${AppConstants.baseUrl}/${AppConstants.apiVersion}/auth/reset-password'),
            headers: getHeaders(),
            body: json.encode({'email': email}),
          )
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode != 200) {
        throw Exception('Password reset failed: ${response.body}');
      }
    } catch (e) {
      AppLogger.e('Reset password API error', e);
      rethrow;
    }
  }
}
