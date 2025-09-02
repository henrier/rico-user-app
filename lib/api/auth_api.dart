import 'dart:convert';

import 'package:http/http.dart' as http;

import '../common/constants/app_constants.dart';
import '../common/utils/logger.dart';
import '../models/user_model.dart';
import 'base_api.dart';

class AuthApi extends BaseApi {
  // 🎯 一键登录的默认账号
  static const String _defaultPhone = '12312341234';
  static const String _defaultPassword = 'admin123';

  // 用户登录
  Future<User> login(String phone, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse(
                '${AppConstants.baseUrl}/${AppConstants.apiVersion}/user/login'),
            headers: getHeaders(),
            body: json.encode({
              'phone': phone,
              'password': password,
            }),
          )
          .timeout(AppConstants.apiTimeout);

      AppLogger.i('Login API response: ${response.statusCode}');
      AppLogger.i('Login API body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final userData = responseData['data'];
          final token = userData['token'];

          // 保存token
          await saveToken(token);

          // 创建用户对象（不包含token）
          final userMap = Map<String, dynamic>.from(userData);
          userMap.remove('token'); // 移除token字段，因为User模型中不包含token

          final user = User.fromMap(userMap);

          AppLogger.i('Login successful for phone: $phone');
          return user;
        } else {
          throw Exception('登录失败：${responseData['message'] ?? '未知错误'}');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
            '登录失败：${errorData['message'] ?? 'HTTP ${response.statusCode}'}');
      }
    } catch (e) {
      AppLogger.e('Login API error', e);

      // 如果是网络错误，提供更友好的错误信息
      if (e.toString().contains('Failed host lookup') ||
          e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        throw Exception('网络连接失败，请检查网络连接');
      }

      rethrow;
    }
  }

  // 一键登录方法 - 使用指定的默认账号
  Future<User> quickLogin() async {
    try {
      AppLogger.i('Starting quick login with phone: $_defaultPhone');
      return await login(_defaultPhone, _defaultPassword);
    } catch (e) {
      AppLogger.e('Quick login failed', e);
      rethrow;
    }
  }

  // 用户登出
  Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        final response = await http
            .post(
              Uri.parse(
                  '${AppConstants.baseUrl}/${AppConstants.apiVersion}/user/logout'),
              headers: getAuthHeaders(token),
            )
            .timeout(AppConstants.apiTimeout);

        AppLogger.i('Logout API response: ${response.statusCode}');

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          if (responseData['success'] != true) {
            AppLogger.w(
                'Logout API returned success=false: ${responseData['message']}');
          }
        }
      }

      // 无论API调用是否成功，都清除本地token
      await clearToken();
      AppLogger.i('User logged out and token cleared');
    } catch (e) {
      AppLogger.e('Logout API error', e);
      // 即使API调用失败，也要清除本地token
      await clearToken();
    }
  }

  // 获取当前用户信息
  Future<User?> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) {
        AppLogger.w('No token found, cannot get current user');
        return null;
      }

      final response = await http
          .get(
            Uri.parse(
                '${AppConstants.baseUrl}/${AppConstants.apiVersion}/user/current'),
            headers: getAuthHeaders(token),
          )
          .timeout(AppConstants.apiTimeout);

      AppLogger.i('Get current user API response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final user = User.fromMap(responseData['data']);
          AppLogger.i('Current user retrieved successfully');
          return user;
        } else {
          throw Exception('获取用户信息失败：${responseData['message'] ?? '未知错误'}');
        }
      } else if (response.statusCode == 401) {
        // Token无效，清除它
        AppLogger.w('Token is invalid, clearing it');
        await clearToken();
        return null;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
            '获取用户信息失败：${errorData['message'] ?? 'HTTP ${response.statusCode}'}');
      }
    } catch (e) {
      AppLogger.e('Get current user API error', e);
      return null;
    }
  }

  // 获取用户权限列表
  Future<List<String>> getCurrentUserPermissions() async {
    try {
      final token = await getToken();
      if (token == null) {
        AppLogger.w('No token found, cannot get user permissions');
        return [];
      }

      final response = await http
          .get(
            Uri.parse(
                '${AppConstants.baseUrl}/${AppConstants.apiVersion}/user/current/permissions'),
            headers: getAuthHeaders(token),
          )
          .timeout(AppConstants.apiTimeout);

      AppLogger.i('Get user permissions API response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final permissions = List<String>.from(responseData['data'] ?? []);
          AppLogger.i(
              'User permissions retrieved: ${permissions.length} permissions');
          return permissions;
        } else {
          throw Exception('获取用户权限失败：${responseData['message'] ?? '未知错误'}');
        }
      } else if (response.statusCode == 401) {
        // Token无效，清除它
        AppLogger.w('Token is invalid when getting permissions, clearing it');
        await clearToken();
        return [];
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
            '获取用户权限失败：${errorData['message'] ?? 'HTTP ${response.statusCode}'}');
      }
    } catch (e) {
      AppLogger.e('Get user permissions API error', e);
      return [];
    }
  }
}
