import 'package:flutter/material.dart';
import 'vitals_screen.dart';
import 'sos_screen.dart';
import 'patient_reminder_screen.dart';
import 'doctor_dashboard_screen.dart';
import 'caregiver_dashboard_screen.dart';
import 'auth_service.dart';

class DashboardScreen extends StatefulWidget {
  final String role;
  final String? userId;

  DashboardScreen({required this.role, this.userId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService authService = AuthService();

  void _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await authService.logout();
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            child: Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget featureButton(
    String title,
    IconData icon,
    BuildContext context,
    Widget screen,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SizedBox(
        width: double.infinity,
        height: 65,
        child: ElevatedButton.icon(
          icon: Icon(icon, size: 30),
          label: Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 5,
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Route to role-specific dashboard
    if (widget.role == 'doctor') {
      return DoctorDashboard(userId: widget.userId);
    } else if (widget.role == 'caregiver') {
      return CaregiverDashboard(userId: widget.userId);
    }

    // Patient Dashboard
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        title: Text("Patient Dashboard"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: "Logout",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            featureButton(
              "Today's Medicines",
              Icons.notifications_active,
              context,
              PatientReminderScreen(),
            ),
            featureButton(
              "Check Risk",
              Icons.analytics,
              context,
              VitalsScreen(),
            ),
            featureButton("SOS Emergency", Icons.warning, context, SOSScreen()),
          ],
        ),
      ),
    );
  }
}
