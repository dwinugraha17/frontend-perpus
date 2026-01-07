import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unilam_library/models/user_model.dart';
import 'package:unilam_library/services/api_service.dart';
import 'package:image_picker/image_picker.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage; // Field baru untuk pesan error
  final ApiService _apiService = ApiService();

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage; // Getter

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null; // Reset error
    notifyListeners();
    try {
      final response = await _apiService.post('/login', {'email': email, 'password': password});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        _user = UserModel.fromJson(data['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final body = jsonDecode(response.body);
        _errorMessage = body['message'] ?? 'Login gagal. Cek email/password.';
      }
    } catch (e) {
      debugPrint(e.toString());
      _errorMessage = 'Gagal terhubung ke server. Cek koneksi internet.';
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String name, String email, String password, String phoneNumber) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.post('/register', {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password, // Auto-confirm for simplicity in this demo
        'phone_number': phoneNumber,
      });

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        _user = UserModel.fromJson(data['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _user = null;
    notifyListeners();
  }

  Future<void> fetchUser() async {
    try {
      final response = await _apiService.get('/user');
      if (response.statusCode == 200) {
        _user = UserModel.fromJson(jsonDecode(response.body));
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<bool> updateProfile({required String name, required String phoneNumber, XFile? photo}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.postMultipart(
        '/profile/update',
        {
          'name': name,
          'phone_number': phoneNumber,
        },
        photo,
      );

      debugPrint('Update Profile Response: ${response.body}'); // DEBUG LOG

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _user = UserModel.fromJson(data['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Update profile error: $e');
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }
}
