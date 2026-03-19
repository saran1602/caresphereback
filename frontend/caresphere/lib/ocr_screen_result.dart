import 'package:flutter/material.dart';
import 'medicine_schedule_screen.dart';

class OCRResultScreen extends StatelessWidget {

  final String extractedText;

  OCRResultScreen({required this.extractedText});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        title: Text("OCR Result"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            SizedBox(height: 20),

            Text(
              "Extracted Prescription Text",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 20),

            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
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
                child: SingleChildScrollView(
                  child: Text(
                    extractedText,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            // ⭐ NEW BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: Icon(Icons.auto_awesome),
                onPressed: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MedicineScheduleScreen(
                        text: extractedText,
                      ),
                    ),
                  );

                },
                label: Text(
                  "Generate Smart Schedule",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),

            SizedBox(height: 12),

            // Existing Done Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Done",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
}