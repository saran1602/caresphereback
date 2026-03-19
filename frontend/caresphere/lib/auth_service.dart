import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'api_config.dart';

class AuthService {
  late final String baseUrl;
  static const storage = FlutterSecureStorage();

  AuthService() {
    baseUrl = ApiConfig.baseUrl;
  }

  // Save token to secure storage
  Future<void> saveToken(String token) async {
    await storage.write(key: 'auth_token', value: token);
  }

  // Get token from secure storage
  Future<String?> getToken() async {
    return await storage.read(key: 'auth_token');
  }

  // Delete token from secure storage
  Future<void> deleteToken() async {
    await storage.delete(key: 'auth_token');
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null) return false;
    return await verifyToken();
  }

  // Signup
  Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String phone,
    required String fullName,
    required String role,
    String? dateOfBirth,
    String? relationship,
    String? licenseNumber,
    String? specialization,
  }) async {
    try {
      final body = {
        'email': email,
        'password': password,
        'phone': phone,
        'full_name': fullName,
        'role': role,
      };

      // Add role-specific fields
      if (dateOfBirth != null) {
        body['date_of_birth'] = dateOfBirth;
      }
      if (relationship != null) {
        body['relationship'] = relationship;
      }
      if (licenseNumber != null) {
        body['license_number'] = licenseNumber;
      }
      if (specialization != null) {
        body['specialization'] = specialization;
      }

      final response = await http.post(
        Uri.parse(ApiConfig.signup),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await saveToken(data['token']);
        return {'success': true, 'user': data['user']};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['error']};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveToken(data['token']);
        return {'success': true, 'user': data['user']};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['error']};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Verify token
  Future<bool> verifyToken() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await http.get(
        Uri.parse(ApiConfig.verifyToken),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get user profile
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'error': 'No token'};

      final response = await http.get(
        Uri.parse("$baseUrl/auth/user/$userId"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'user': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['error']};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Logout
  Future<void> logout() async {
    await deleteToken();
  }

  // Upload certificate (for doctors)
  Future<Map<String, dynamic>> uploadCertificate({
    required String filePath,
    required String certificateType,
  }) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'error': 'No token'};

      final request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/auth/doctor/upload-certificate"),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      request.fields['certificate_type'] = certificateType;

      final response = await request.send();

      if (response.statusCode == 201) {
        final body = await response.stream.bytesToString();
        final data = jsonDecode(body);
        return {'success': true, 'data': data};
      } else {
        final body = await response.stream.bytesToString();
        final error = jsonDecode(body);
        return {'success': false, 'error': error['error']};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Assign patient to caregiver
  Future<Map<String, dynamic>> assignPatient({
    required String patientId,
  }) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'error': 'No token'};

      final response = await http.post(
        Uri.parse("$baseUrl/auth/caregiver/assign-patient"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({'patient_id': patientId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['error']};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
