import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../core/services/api_service.dart';
import '../models/user_model.dart';

/// Provider untuk autentikasi dan state user yang sedang login
class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isCheckingAuth = true;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  bool get isCheckingAuth => _isCheckingAuth;
  String? get errorMessage => _errorMessage;
  UserRole? get currentRole => _currentUser?.role;

  /// Memeriksa status login saat aplikasi pertama kali dibuka
  Future<void> checkLoginStatus() async {
    _isCheckingAuth = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        final response = await ApiService.get('/auth/profile');
        if (response['success'] == true) {
          _currentUser = UserModel.fromJson(response['data']);
        } else {
          await prefs.remove('token');
        }
      }
    } catch (e) {
      // Token tidak valid atau server mati
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
    }

    _isCheckingAuth = false;
    notifyListeners();
  }

  /// Login menggunakan API
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.post('/auth/login', {
        'username': username,
        'password': password,
      });

      if (response['success'] == true) {
        final token = response['data']['token'];
        final userData = response['data']['user'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        _currentUser = UserModel.fromJson(userData);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    _currentUser = null;
    _errorMessage = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }

  /// Hapus error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
