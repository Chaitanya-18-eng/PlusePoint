import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserRole { none, observer }

class AuthState with ChangeNotifier {
  UserRole _role = UserRole.none;
  bool _setupComplete = false;
  bool _isLoading = true;

  // Profile data
  String ageGroup = '';
  String locality = '';
  bool _isDarkMode = false;

  AuthState() {
    _loadPersistedState();
  }

  UserRole get role => _role;
  bool get isAuthenticated => _role != UserRole.none;
  bool get isSetupComplete => _setupComplete;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;

  Future<void> _loadPersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    final roleIndex = prefs.getInt('auth_role') ?? 0;
    _role = UserRole.values[roleIndex];
    _setupComplete = prefs.getBool('setup_complete') ?? false;
    ageGroup = prefs.getString('user_age') ?? '';
    locality = prefs.getString('user_locality') ?? '';
    _isDarkMode = prefs.getBool('is_dark_mode') ?? false;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', _isDarkMode);
    notifyListeners();
  }

  Future<void> login() async {
    _role = UserRole.observer;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('auth_role', _role.index);
    notifyListeners();
  }

  Future<void> completeSetup({required String age, required String loc}) async {
    ageGroup = age;
    locality = loc;
    _setupComplete = true;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('setup_complete', true);
    await prefs.setString('user_age', age);
    await prefs.setString('user_locality', loc);
    
    notifyListeners();
  }

  Future<void> logout() async {
    _role = UserRole.none;
    _setupComplete = false;
    ageGroup = '';
    locality = '';
    _isLoading = false;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
