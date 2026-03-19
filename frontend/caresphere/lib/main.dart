import 'package:flutter/material.dart';
import 'role_screen.dart';
import 'notification_service.dart';
import 'auth_service.dart';
import 'dashboard_screen.dart';
import 'token_utils.dart';
import 'tamil_chatbot.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await NotificationService().initNotifications();
  runApp(CareSphereApp());
}

class CareSphereApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "CareSphere AI",
      theme: ThemeData(primarySwatch: Colors.teal),
      builder: (context, child) {
        return TamilChatbot(child: child!);
      },
      home: AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatefulWidget {
  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  final AuthService authService = AuthService();
  bool isChecking = true;
  bool isLoggedIn = false;
  String? userRole;
  String? userId;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final loggedIn = await authService.isLoggedIn();

    if (loggedIn) {
      final verified = await authService.verifyToken();
      if (verified) {
        final token = await authService.getToken();
        if (token != null) {
          // Decode token to get role and userId
          final role = TokenUtils.getUserRole(token);
          final id = TokenUtils.getUserId(token);

          setState(() {
            isLoggedIn = true;
            userRole = role;
            userId = id;
            isChecking = false;
          });
        } else {
          setState(() {
            isLoggedIn = false;
            isChecking = false;
          });
        }
      } else {
        await authService.deleteToken();
        setState(() {
          isLoggedIn = false;
          isChecking = false;
        });
      }
    } else {
      setState(() {
        isLoggedIn = false;
        isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isChecking) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return isLoggedIn
        ? DashboardScreen(role: userRole ?? 'patient', userId: userId)
        : LandingScreen();
  }
}

class LandingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.health_and_safety, size: 100, color: Colors.teal),

              SizedBox(height: 25),

              Text(
                "CareSphere AI",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade800,
                ),
              ),

              SizedBox(height: 15),

              Text(
                "AI Driven Preventive Healthcare Monitoring System",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17),
              ),

              SizedBox(height: 50),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  child: Text("Continue", style: TextStyle(fontSize: 20)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RoleScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
