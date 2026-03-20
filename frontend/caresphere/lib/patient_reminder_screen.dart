import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'notification_service.dart';
import 'auth_service.dart';
import 'api_config.dart';

class PatientReminderScreen extends StatefulWidget {
  final String? userId;
  PatientReminderScreen({this.userId});

  @override
  State<PatientReminderScreen> createState() => _PatientReminderScreenState();
}

class _PatientReminderScreenState extends State<PatientReminderScreen> {
  List<Map<String, dynamic>> medicines = [];
  bool loading = true;
  String patientName = "Loading..."; 
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

  @override
  void initState() {
    super.initState();
    NotificationService().initNotifications();
    _loadPatientData();
  }

  Future<void> _loadPatientData() async {
    if (widget.userId != null) {
      final profile = await authService.getUserProfile(widget.userId!);
      if (profile['success']) {
        final user = profile['user'];
        String nameToFetch = user['full_name'];
        String role = user['role'];

        if (role == 'caregiver' && user['assigned_patient_id'] != null) {
            // Fetch assigned patient name
            final patientProfile = await authService.getUserProfile(user['assigned_patient_id']);
            if (patientProfile['success']) {
              nameToFetch = patientProfile['user']['full_name'];
            }
        }

        setState(() {
          patientName = nameToFetch;
        });
        fetchReminders();
      } else {
        setState(() {
          patientName = "Patient";
          loading = false;
        });
      }
    } else {
      setState(() {
          patientName = "Guest";
          loading = false;
      });
    }
  }

  Future<void> fetchReminders() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.getReminders}/$patientName"),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          medicines = data.map((item) {
            final timeStr = item['time'] ?? "Unknown";
            return {
              "id": item['id'],
              "time": timeStr,
              "name": item['medicine'] ?? "Medicine",
              "taken": item['taken'] ?? false,
              "icon": _getIconForTime(timeStr),
              "color": _getColorForTime(timeStr),
            };
          }).toList();
          loading = false;
        });

        // Schedule notifications for reminders
        _scheduleNotifications();
      } else {
        setState(() => loading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ Failed to fetch reminders")));
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
    }
  }

  void _scheduleNotifications() {
    for (int i = 0; i < medicines.length; i++) {
      final med = medicines[i];
      final DateTime scheduledTime = _parseTime(med['time']);

      NotificationService().scheduleNotification(
        i,
        "💊 Medicine Reminder",
        "Time to take ${med['name']}",
        scheduledTime,
      );
    }
  }

  DateTime _parseTime(String timeStr) {
    final now = DateTime.now();

    if (timeStr.toLowerCase().contains("morning")) {
      return DateTime(now.year, now.month, now.day, 8, 0);
    } else if (timeStr.toLowerCase().contains("afternoon")) {
      return DateTime(now.year, now.month, now.day, 13, 0);
    } else if (timeStr.toLowerCase().contains("night")) {
      return DateTime(now.year, now.month, now.day, 21, 0);
    } else {
      // Try to parse custom time format (HH:MM)
      try {
        final parts = timeStr.split(':');
        if (parts.length == 2) {
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          return DateTime(now.year, now.month, now.day, hour, minute);
        }
      } catch (e) {
        print("Error parsing time: $e");
      }
      return now.add(Duration(hours: 1));
    }
  }

  IconData _getIconForTime(String time) {
    if (time.toLowerCase().contains("morning")) {
      return Icons.wb_sunny;
    } else if (time.toLowerCase().contains("afternoon")) {
      return Icons.wb_cloudy;
    } else if (time.toLowerCase().contains("night")) {
      return Icons.nightlight_round;
    }
    return Icons.schedule;
  }

  Color _getColorForTime(String time) {
    if (time.toLowerCase().contains("morning")) {
      return Colors.orange;
    } else if (time.toLowerCase().contains("afternoon")) {
      return Colors.blue;
    } else if (time.toLowerCase().contains("night")) {
      return Colors.indigo;
    }
    return Colors.teal;
  }

  void markTaken(int index) {
    final newStatus = !medicines[index]["taken"];
    final medId = medicines[index]["id"];

    setState(() {
      medicines[index]["taken"] = newStatus;
    });

    // Update on backend
    _updateMedicineStatus(medId, newStatus);

    if (newStatus) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ ${medicines[index]['name']} marked as taken"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("↩️ ${medicines[index]['name']} marked as not taken"),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _updateMedicineStatus(int medId, bool taken) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.markMedicineTaken),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": medId, "taken": taken}),
      );

      if (response.statusCode != 200) {
        print("⚠️ Failed to update medicine status on backend");
      }
    } catch (e) {
      print("❌ Error updating medicine status: $e");
    }
  }

  void testNotification() {
    NotificationService().showInstantNotification(
      "💊 Test Reminder",
      "This is a test notification for medicine reminder",
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: Text("Today's Medicines")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    int takenCount = medicines.where((m) => m["taken"] == true).length;
    double progress = medicines.isEmpty ? 0 : takenCount / medicines.length;

    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        title: Text("Today's Medicines"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() => loading = true);
              fetchReminders();
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: "Logout",
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 20),

          // Progress Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Text(
                  "Medicine Progress",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade800,
                  ),
                ),
                SizedBox(height: 10),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(20),
                ),
                SizedBox(height: 8),
                Text(
                  "$takenCount / ${medicines.length} Taken",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Medicine Cards
          medicines.isEmpty
              ? Expanded(
                  child: Center(
                    child: Text(
                      "No reminders assigned yet",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    itemCount: medicines.length,
                    itemBuilder: (context, index) {
                      var med = medicines[index];

                      return Container(
                        margin: EdgeInsets.only(bottom: 18),
                        padding: EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10,
                              color: Colors.grey.shade300,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Icon Box
                            Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                color: med["color"].withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                med["icon"],
                                color: med["color"],
                                size: 30,
                              ),
                            ),

                            SizedBox(width: 16),

                            // Medicine Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    med["time"],
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: med["color"],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    med["name"],
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Mark Taken Button
                            IconButton(
                              icon: Icon(
                                med["taken"]
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: med["taken"]
                                    ? Colors.green
                                    : Colors.grey,
                                size: 30,
                              ),
                              onPressed: () => markTaken(index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

          // Test & Voice Reminder Buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.notifications),
                    label: Text("Test Notification"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                    ),
                    onPressed: testNotification,
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.volume_up, size: 28),
                    label: Text("Play Voice Reminder"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 6,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("🔊 Voice Reminder Played")),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
