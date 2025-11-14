import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

class AuthProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  // Register a new user
  Future<bool> register(String name, String email, String password, String confirmPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validation
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        _errorMessage = 'Please fill all fields';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (password != confirmPassword) {
        _errorMessage = 'Passwords do not match';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      // Password strength: require minimum 8 characters
      if (password.length < 8) {
        _errorMessage = 'Password must be at least 8 characters';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Require Gmail address (helps avoid phone numbers being entered)
      final gmailRegex = RegExp(r'^[\w.+-]+@gmail\.com$');
      if (!gmailRegex.hasMatch(email)) {
        _errorMessage = 'Please enter a valid Gmail address (example@gmail.com)';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check if email already exists
      final emailExists = await _dbService.emailExists(email);
      if (emailExists) {
        _errorMessage = 'Email already registered';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Create new user
      final newUser = User(
        name: name,
        email: email,
        password: password,
      );

      final success = await _dbService.registerUser(newUser);
      
      if (success) {
        _currentUser = await _dbService.loginUser(email, password);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Registration failed. Please try again';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login user
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (email.isEmpty || password.isEmpty) {
        _errorMessage = 'Please fill all fields';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final user = await _dbService.loginUser(email, password);
      
      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid email or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Update user profile
  Future<bool> updateProfile(String name, String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (name.isEmpty || email.isEmpty) {
        _errorMessage = 'Please fill all fields';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (_currentUser == null) {
        _errorMessage = 'No user logged in';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final updatedUser = _currentUser!.copyWith(
        name: name,
        email: email,
      );

      final success = await _dbService.updateUser(updatedUser);
      
      if (success) {
        _currentUser = updatedUser;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to update profile';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Delete user account and all associated data
  Future<bool> deleteAccount() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_currentUser == null) {
        _errorMessage = 'No user logged in';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final userId = _currentUser!.id!;

      // Delete all user downloads first (database handles cascade delete too)
      await _dbService.deleteUserDownloads(userId);

      // Delete the user account
      final success = await _dbService.deleteUser(userId);

      if (success) {
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to delete account';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}