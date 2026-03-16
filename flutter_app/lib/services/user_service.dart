import 'package:dio/dio.dart';
import '../models/user_model.dart';
import 'api_client.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getUsers() async {
    try {
      final response = await _apiClient.dio.get('/users');

      if (response.data['success'] == true) {
        final users = (response.data['data'] as List)
            .map((u) => UserModel.fromJson(u))
            .toList();
        return {'success': true, 'users': users};
      }

      return {'success': false, 'message': 'Failed to load users'};
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Connection error';
      return {'success': false, 'message': message};
    }
  }

  Future<Map<String, dynamic>> createUser(
      String name, String email, String password) async {
    try {
      final response = await _apiClient.dio.post('/users', data: {
        'name': name,
        'email': email,
        'password': password,
      });

      if (response.data['success'] == true) {
        final user = UserModel.fromJson(response.data['data']);
        return {'success': true, 'user': user};
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to create user'
      };
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Connection error';
      return {'success': false, 'message': message};
    }
  }

  Future<Map<String, dynamic>> deactivateUser(String id) async {
    try {
      final response =
          await _apiClient.dio.patch('/users/$id/deactivate');

      if (response.data['success'] == true) {
        return {'success': true};
      }

      return {'success': false, 'message': 'Failed to deactivate user'};
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Connection error';
      return {'success': false, 'message': message};
    }
  }

  Future<Map<String, dynamic>> activateUser(String id) async {
    try {
      final response =
          await _apiClient.dio.patch('/users/$id/activate');

      if (response.data['success'] == true) {
        return {'success': true};
      }

      return {'success': false, 'message': 'Failed to activate user'};
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Connection error';
      return {'success': false, 'message': message};
    }
  }

  Future<Map<String, dynamic>> deleteUser(String id) async {
    try {
      final response = await _apiClient.dio.delete('/users/$id');

      if (response.data['success'] == true) {
        return {'success': true};
      }

      return {'success': false, 'message': 'Failed to delete user'};
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Connection error';
      return {'success': false, 'message': message};
    }
  }
}
