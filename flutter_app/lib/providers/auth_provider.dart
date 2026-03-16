import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  bool _isInitializing = true;
  String? _error;
  bool _isAuthenticated = false;

  AuthProvider() {
    _restoreSession();
  }

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  bool get isManager => _user?.isManager ?? false;
  bool get isSales => _user?.isSales ?? false;

  Future<void> _restoreSession() async {
    try {
      await tryAutoLogin();
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _authService.login(email, password);

    if (result['success'] == true) {
      _user = result['user'] as UserModel;
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _error = result['message'] as String;
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> tryAutoLogin() async {
    final hasToken = await _authService.hasToken();
    if (!hasToken) return false;

    final result = await _authService.getMe();
    if (result['success'] == true) {
      _user = result['user'] as UserModel;
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }

    await _authService.logout();
    return false;
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _isAuthenticated = false;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
