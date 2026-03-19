import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class SOSScreen extends StatefulWidget {
  @override
  _SOSScreenState createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> {
  bool sending = false;

  Future<void> sendSOSAlert() async {
    setState(() => sending = true);

    try {
      var response = await http.post(
        Uri.parse(ApiConfig.emergency),
        body: {"patient_name": "Patient", "sugar": "NA", "bp": "NA"},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✅ SOS Alert Sent! Ambulance Dispatched"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Failed to send SOS"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Server Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Emergency SOS"), backgroundColor: Colors.red),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emergency, size: 80, color: Colors.red),
            SizedBox(height: 20),
            Text(
              "Emergency SOS System",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Click button to send emergency alert to ambulance",
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            SizedBox(
              width: 200,
              height: 200,
              child: ElevatedButton(
                onPressed: sending ? null : sendSOSAlert,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  disabledBackgroundColor: Colors.grey,
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    sending
                        ? CircularProgressIndicator(color: Colors.white)
                        : Icon(Icons.call, size: 60, color: Colors.white),
                    SizedBox(height: 10),
                    Text(
                      sending ? "Sending..." : "SOS ALERT",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            Text(
              "Ambulance will be dispatched immediately",
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
