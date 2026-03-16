import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.data['success'] == true) {
        final token = response.data['data']['token'];
        await _apiClient.setToken(token);
        final user = UserModel.fromJson(response.data['data']['user']);
        return {'success': true, 'user': user};
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Login failed'
      };
    } on DioException catch (e) {
      final backendMessage = e.response?.data?['message'];

      if (backendMessage is String && backendMessage.isNotEmpty) {
        return {'success': false, 'message': backendMessage};
      }

      final isAndroid =
          !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
      final networkIssue = e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.unknown;

      if (isAndroid && networkIssue) {
        return {
          'success': false,
          'message':
              'Cannot reach backend at ${AppConstants.baseUrl}. Run with --dart-define=BACKEND_URL=https://wholesome-possibility-production.up.railway.app/api (or your API URL).'
        };
      }

      final message =
          'Connection error. Ensure backend is running and reachable at ${AppConstants.baseUrl}.';
      return {'success': false, 'message': message};
    }
  }

  Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await _apiClient.dio.get('/auth/me');

      if (response.data['success'] == true) {
        final user = UserModel.fromJson(response.data['data']);
        return {'success': true, 'user': user};
      }

      return {'success': false, 'message': 'Failed to get user info'};
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Connection error';
      return {'success': false, 'message': message};
    }
  }

  Future<void> logout() async {
    await _apiClient.clearToken();
  }

  Future<bool> hasToken() async {
    final token = await _apiClient.getToken();
    return token != null;
  }
}
