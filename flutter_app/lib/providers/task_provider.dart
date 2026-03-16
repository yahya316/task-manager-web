import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../models/activity_log_model.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<TaskModel> _tasks = [];
  TaskModel? _selectedTask;
  List<ActivityLogModel> _activityFeed = [];
  bool _isLoading = false;
  String? _error;

  List<TaskModel> get tasks => _tasks;
  TaskModel? get selectedTask => _selectedTask;
  List<ActivityLogModel> get activityFeed => _activityFeed;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalTasks => _tasks.length;
  int get pendingTasks => _tasks.where((t) => t.status == 'Pending').length;
  int get inProgressTasks =>
      _tasks.where((t) => t.status == 'In Progress').length;
  int get completedTasks => _tasks.where((t) => t.status == 'Completed').length;

  Future<void> loadTasks({String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _taskService.getTasks(status: status);

    if (result['success'] == true) {
      _tasks = result['tasks'] as List<TaskModel>;
    } else {
      _error = result['message'] as String;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadTask(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _taskService.getTask(id);

    if (result['success'] == true) {
      _selectedTask = result['task'] as TaskModel;
    } else {
      _error = result['message'] as String;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createTask(Map<String, dynamic> taskData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _taskService.createTask(taskData);

    _isLoading = false;

    if (result['success'] == true) {
      await loadTasks();
      return true;
    }

    _error = result['message'] as String;
    notifyListeners();
    return false;
  }

  Future<bool> updateTask(String id, Map<String, dynamic> taskData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _taskService.updateTask(id, taskData);

    _isLoading = false;

    if (result['success'] == true) {
      await loadTasks();
      return true;
    }

    _error = result['message'] as String;
    notifyListeners();
    return false;
  }

  Future<bool> deleteTask(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _taskService.deleteTask(id);

    _isLoading = false;

    if (result['success'] == true) {
      _tasks.removeWhere((t) => t.id == id);
      notifyListeners();
      return true;
    }

    _error = result['message'] as String;
    notifyListeners();
    return false;
  }

  Future<bool> changeStatus(String id, String newStatus,
      {String? note, bool? paymentReceived}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _taskService.changeStatus(
      id,
      newStatus,
      note: note,
      paymentReceived: paymentReceived,
    );

    _isLoading = false;

    if (result['success'] == true) {
      _selectedTask = result['task'] as TaskModel;
      // Also update in the list
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index >= 0) {
        _tasks[index] = _selectedTask!;
      }
      notifyListeners();
      return true;
    }

    _error = result['message'] as String;
    notifyListeners();
    return false;
  }

  Future<bool> updatePaymentStatus(String id, bool paymentReceived,
      {String? note}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _taskService.updatePaymentStatus(
      id,
      paymentReceived,
      note: note,
    );

    _isLoading = false;

    if (result['success'] == true) {
      _selectedTask = result['task'] as TaskModel;
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index >= 0) {
        _tasks[index] = _selectedTask!;
      }
      notifyListeners();
      return true;
    }

    _error = result['message'] as String;
    notifyListeners();
    return false;
  }

  Future<void> loadActivity() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _taskService.getActivity();

    if (result['success'] == true) {
      _activityFeed = result['activities'] as List<ActivityLogModel>;
    } else {
      _error = result['message'] as String;
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSelectedTask() {
    _selectedTask = null;
  }
}
