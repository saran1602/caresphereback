import 'assign_remainder_screen.dart';
import 'package:flutter/material.dart';

class MedicineScheduleScreen extends StatelessWidget {
  final String text;

  MedicineScheduleScreen({required this.text});

  @override
  Widget build(BuildContext context) {
    // ⭐ For hackathon demo we simulate parsed medicines
    List<Map<String, dynamic>> meds = [
      {
        "time": "Morning",
        "name": "Metformin 500mg",
        "icon": Icons.wb_sunny,
        "color": Colors.orange,
      },
      {
        "time": "Afternoon",
        "name": "BP Tablet",
        "icon": Icons.wb_cloudy,
        "color": Colors.blue,
      },
      {
        "time": "Night",
        "name": "Insulin",
        "icon": Icons.nightlight_round,
        "color": Colors.indigo,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.teal.shade50,

      appBar: AppBar(
        title: Text("Smart Medicine Schedule"),
        centerTitle: true,
        elevation: 0,
      ),

      body: Column(
        children: [
          SizedBox(height: 20),

          Text(
            "Today's Medicines",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade800,
            ),
          ),

          SizedBox(height: 6),

          Text(
            "AI generated from prescription",
            style: TextStyle(color: Colors.grey.shade600),
          ),

          SizedBox(height: 20),

          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 18),
              itemCount: meds.length,
              itemBuilder: (context, index) {
                var med = meds[index];

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
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: med["color"].withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(med["icon"], color: med["color"], size: 30),
                      ),

                      SizedBox(width: 16),

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

                      Icon(
                        Icons.check_circle_outline,
                        color: Colors.green,
                        size: 28,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // ⭐ Floating Assign Reminder Button (Centered Feel)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            icon: Icon(Icons.notifications_active, size: 28),
            label: Text(
              "Assign Voice Reminder",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 6,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AssignReminderScreen()),
              );
            },
          ),
        ),
      ),
    );
  }
}
