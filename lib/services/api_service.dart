import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unilam_library/core/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

class ApiService {
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true', // Header untuk melewati peringatan Ngrok
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    final url = '${AppConstants.baseUrl}$endpoint';
    debugPrint('[API] POST: $url');
    return await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 30));
  }

  Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    return await http.get(
      Uri.parse('${AppConstants.baseUrl}$endpoint'),
      headers: headers,
    ).timeout(const Duration(seconds: 30));
  }

  Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    return await http.delete(
      Uri.parse('${AppConstants.baseUrl}$endpoint'),
      headers: headers,
    ).timeout(const Duration(seconds: 30));
  }

  Future<http.Response> postMultipart(String endpoint, Map<String, String> fields, XFile? file) async {
    final token = await getToken();
    var request = http.MultipartRequest('POST', Uri.parse('${AppConstants.baseUrl}$endpoint'));
    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });
    request.fields.addAll(fields);
    if (file != null) {
      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes(
          'profile_photo',
          await file.readAsBytes(),
          filename: file.name,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath('profile_photo', file.path));
      }
    }
    var streamedResponse = await request.send().timeout(const Duration(seconds: 30));
    return await http.Response.fromStream(streamedResponse);
  }
}
