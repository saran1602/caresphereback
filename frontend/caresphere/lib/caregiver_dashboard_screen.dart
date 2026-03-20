import 'package:flutter/material.dart';
import 'upload_screen.dart';
import 'vitals_screen.dart';
import 'sos_screen.dart';
import 'patient_reminder_screen.dart';
import 'auth_service.dart';

class CaregiverDashboard extends StatefulWidget {
  final String? userId;

  CaregiverDashboard({this.userId});

  @override
  State<CaregiverDashboard> createState() => _CaregiverDashboardState();
}

class _CaregiverDashboardState extends State<CaregiverDashboard> {
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
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        title: Text("Caregiver Dashboard"),
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
              "Upload Prescription",
              Icons.camera_alt,
              context,
              UploadScreen(),
            ),
            featureButton(
              "Enter Patient Vitals",
              Icons.favorite,
              context,
              VitalsScreen(),
            ),
            featureButton(
              "SOS Emergency",
              Icons.warning_amber_rounded,
              context,
              SOSScreen(),
            ),
            featureButton(
              "View Patient Reminders",
              Icons.medication,
              context,
              PatientReminderScreen(userId: widget.userId), // This uses caregiver ID, but PatientReminderScreen fetches profile. 
                                                           // Better to pass patient_id if we have it.
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade300, blurRadius: 8),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Caregiver Info",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "User ID: ${widget.userId ?? 'N/A'}",
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "You can monitor the assigned patient's vitals, medications, and health status.",
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
