import 'package:dio/dio.dart';
import '../models/task_model.dart';
import '../models/activity_log_model.dart';
import 'api_client.dart';

class TaskService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getTasks({String? status}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null && status != 'All') {
        queryParams['status'] = status;
      }

      final response = await _apiClient.dio.get(
        '/tasks',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final tasks = (response.data['data'] as List)
            .map((t) => TaskModel.fromJson(t))
            .toList();
        return {'success': true, 'tasks': tasks};
      }

      return {'success': false, 'message': 'Failed to load tasks'};
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Connection error';
      return {'success': false, 'message': message};
    }
  }

  Future<Map<String, dynamic>> getTask(String id) async {
    try {
      final response = await _apiClient.dio.get('/tasks/$id');

      if (response.data['success'] == true) {
        final task = TaskModel.fromJson(response.data['data']);
        return {'success': true, 'task': task};
      }

      return {'success': false, 'message': 'Failed to load task'};
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Connection error';
      return {'success': false, 'message': message};
    }
  }

  Future<Map<String, dynamic>> createTask(Map<String, dynamic> taskData) async {
    try {
      final response = await _apiClient.dio.post('/tasks', data: taskData);

      if (response.data['success'] == true) {
        final task = TaskModel.fromJson(response.data['data']);
        return {'success': true, 'task': task};
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to create task'
      };
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Connection error';
      return {'success': false, 'message': message};
    }
  }

  Future<Map<String, dynamic>> updateTask(
      String id, Map<String, dynamic> taskData) async {
    try {
      final response = await _apiClient.dio.put('/tasks/$id', data: taskData);

      if (response.data['success'] == true) {
        final task = TaskModel.fromJson(response.data['data']);
        return {'success': true, 'task': task};
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to update task'
      };
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Connection error';
      return {'success': false, 'message': message};
    }
  }

  Future<Map<String, dynamic>> deleteTask(String id) async {
    try {
      final response = await _apiClient.dio.delete('/tasks/$id');

      if (response.data['success'] == true) {
        return {'success': true};
      }

      return {'success': false, 'message': 'Failed to delete task'};
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Connection error';
      return {'success': false, 'message': message};
    }
  }

  Future<Map<String, dynamic>> changeStatus(String id, String newStatus,
      {String? note, bool? paymentReceived}) async {
    try {
      final data = <String, dynamic>{'newStatus': newStatus};
      if (note != null && note.isNotEmpty) {
        data['note'] = note;
      }
      if (paymentReceived != null) {
        data['paymentReceived'] = paymentReceived;
      }

      final response =
          await _apiClient.dio.patch('/tasks/$id/status', data: data);

      if (response.data['success'] == true) {
        final task = TaskModel.fromJson(response.data['data']);
        return {'success': true, 'task': task};
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to change status'
      };
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Connection error';
      return {'success': false, 'message': message};
    }
  }

  Future<Map<String, dynamic>> updatePaymentStatus(
    String id,
    bool paymentReceived, {
    String? note,
  }) async {
    try {
      final data = <String, dynamic>{'paymentReceived': paymentReceived};
      if (note != null && note.isNotEmpty) {
        data['note'] = note;
      }

      final response =
          await _apiClient.dio.patch('/tasks/$id/payment', data: data);

      if (response.data['success'] == true) {
        final task = TaskModel.fromJson(response.data['data']);
        return {'success': true, 'task': task};
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to update payment status'
      };
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Connection error';
      return {'success': false, 'message': message};
    }
  }

  Future<Map<String, dynamic>> getActivity() async {
    try {
      final response = await _apiClient.dio.get('/activity');

      if (response.data['success'] == true) {
        final activities = (response.data['data'] as List)
            .map((a) => ActivityLogModel.fromJson(a))
            .toList();
        return {'success': true, 'activities': activities};
      }

      return {'success': false, 'message': 'Failed to load activity'};
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Connection error';
      return {'success': false, 'message': message};
    }
  }
}
