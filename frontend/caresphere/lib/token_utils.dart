import 'package:jwt_decoder/jwt_decoder.dart';

class TokenUtils {
  static Map<String, dynamic>? decodeToken(String token) {
    try {
      return JwtDecoder.decode(token);
    } catch (e) {
      print("Error decoding token: $e");
      return null;
    }
  }

  static String? getUserRole(String token) {
    final decoded = decodeToken(token);
    return decoded?['role'] as String?;
  }

  static String? getUserId(String token) {
    final decoded = decodeToken(token);
    return decoded?['user_id'] as String?;
  }

  static bool isTokenExpired(String token) {
    return JwtDecoder.isExpired(token);
  }

  static DateTime? getExpirationDate(String token) {
    try {
      return JwtDecoder.getExpirationDate(token);
    } catch (e) {
      return null;
    }
  }
}
