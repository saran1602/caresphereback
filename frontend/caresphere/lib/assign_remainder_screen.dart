import 'package:flutter/material.dart';

class AssignReminderScreen extends StatefulWidget {
  @override
  State<AssignReminderScreen> createState() => _AssignReminderScreenState();
}

class _AssignReminderScreenState extends State<AssignReminderScreen> {

  String selectedMedicine = "Metformin";
  String selectedTime = "Morning";
  String selectedLanguage = "Tamil";

  List<String> medicines = [
    "Metformin",
    "BP Tablet",
    "Insulin"
  ];

  List<String> timings = [
    "Morning",
    "Afternoon",
    "Night"
  ];

  List<String> languages = [
    "Tamil",
    "English",
    "Hindi"
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.teal.shade50,

      appBar: AppBar(
        title: Text("Assign Voice Reminder"),
        centerTitle: true,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(height: 20),

            Text(
              "Setup Medicine Reminder",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade800,
              ),
            ),

            SizedBox(height: 6),

            Text(
              "Patient will receive voice notification",
              style: TextStyle(color: Colors.grey.shade600),
            ),

            SizedBox(height: 30),

            buildDropdown("Select Medicine", medicines,
                selectedMedicine, (val){
                  setState(() => selectedMedicine = val!);
                }),

            SizedBox(height: 20),

            buildDropdown("Select Time", timings,
                selectedTime, (val){
                  setState(() => selectedTime = val!);
                }),

            SizedBox(height: 20),

            buildDropdown("Voice Language", languages,
                selectedLanguage, (val){
                  setState(() => selectedLanguage = val!);
                }),

            Spacer(),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                icon: Icon(Icons.notifications_active, size: 28),
                label: Text(
                  "Assign Reminder",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 8,
                ),
                onPressed: () {

                  showDialog(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)
                          ),
                          title: Text("Reminder Assigned"),
                          content: Text(
                              "$selectedMedicine reminder set at $selectedTime in $selectedLanguage"),
                          actions: [
                            TextButton(
                              onPressed: (){
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: Text("OK"),
                            )
                          ],
                        );
                      }
                  );

                },
              ),
            ),

            SizedBox(height: 20),

          ],
        ),
      ),
    );
  }

  Widget buildDropdown(
      String title,
      List<String> items,
      String value,
      Function(String?) onChanged
      ){

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),

        SizedBox(height: 8),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                blurRadius: 6,
                color: Colors.grey.shade300,
              )
            ],
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            value: value,
            underline: SizedBox(),
            items: items.map((e){
              return DropdownMenuItem(
                child: Text(e),
                value: e,
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}