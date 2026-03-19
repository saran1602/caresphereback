import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'patient_signup_screen.dart';
import 'doctor_signup_screen.dart';
import 'caregiver_signup_screen.dart';

class RoleScreen extends StatelessWidget {
  Widget roleCard(
    BuildContext context,
    String role,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 130,
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 8)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            SizedBox(width: 20),
            Text(
              role.toUpperCase(),
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.health_and_safety, size: 90, color: Colors.teal),
              SizedBox(height: 20),
              Text(
                "CareSphere AI",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade800,
                ),
              ),
              SizedBox(height: 10),
              Text("Select Your Role", style: TextStyle(fontSize: 18)),
              SizedBox(height: 40),

              // Caregiver
              roleCard(
                context,
                "caregiver",
                Icons.medical_services,
                Colors.teal,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CaregiverSignupScreen()),
                ),
              ),

              // Patient
              roleCard(
                context,
                "patient",
                Icons.person,
                Colors.blue,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PatientSignupScreen()),
                ),
              ),

              // Doctor
              roleCard(
                context,
                "doctor",
                Icons.local_hospital,
                Colors.red,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DoctorSignupScreen()),
                ),
              ),

              SizedBox(height: 30),

              // Login option
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? "),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                    ),
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
