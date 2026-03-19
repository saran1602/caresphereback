import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl {
    // Priority: .env > fallback to a default (can be updated during deployment)
    return dotenv.env['API_BASE_URL'] ?? "http://10.161.91.105:5000";
  }

  // Define endpoints here for consistency
  static String get login => "$baseUrl/auth/login";
  static String get signup => "$baseUrl/auth/signup";
  static String get verifyToken => "$baseUrl/auth/verify-token";
  static String get emergency => "$baseUrl/emergency";
  static String get uploadPrescription => "$baseUrl/upload_prescription";
  static String get getReminders => "$baseUrl/get_reminders";
  static String get markMedicineTaken => "$baseUrl/mark_medicine_taken";
  static String get doctorUploadRecord => "$baseUrl/doctor_upload_record";
  static String get chat => "$baseUrl/chat";
}
