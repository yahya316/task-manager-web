import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();

  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _error;

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<UserModel> get activeUsers => _users.where((u) => u.isActive).toList();
  List<UserModel> get salesUsers =>
      _users.where((u) => u.role == 'sales').toList();

  Future<void> loadUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _userService.getUsers();

    if (result['success'] == true) {
      _users = result['users'] as List<UserModel>;
    } else {
      _error = result['message'] as String;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createUser(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _userService.createUser(name, email, password);

    _isLoading = false;

    if (result['success'] == true) {
      await loadUsers();
      return true;
    }

    _error = result['message'] as String;
    notifyListeners();
    return false;
  }

  Future<bool> deactivateUser(String id) async {
    final result = await _userService.deactivateUser(id);

    if (result['success'] == true) {
      await loadUsers();
      return true;
    }

    _error = result['message'] as String;
    notifyListeners();
    return false;
  }

  Future<bool> activateUser(String id) async {
    final result = await _userService.activateUser(id);

    if (result['success'] == true) {
      await loadUsers();
      return true;
    }

    _error = result['message'] as String;
    notifyListeners();
    return false;
  }

  Future<bool> deleteUser(String id) async {
    final result = await _userService.deleteUser(id);

    if (result['success'] == true) {
      _users.removeWhere((u) => u.id == id);
      notifyListeners();
      return true;
    }

    _error = result['message'] as String;
    notifyListeners();
    return false;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
