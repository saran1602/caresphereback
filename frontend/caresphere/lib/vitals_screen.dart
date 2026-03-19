import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class VitalsScreen extends StatefulWidget {
  @override
  _VitalsScreenState createState() => _VitalsScreenState();
}

class _VitalsScreenState extends State<VitalsScreen> {
  double heartRate = 135;
  int systolicBP = 160;
  int diastolicBP = 100;
  double pulseRate = 125;

  String riskStatus = "Checking...";
  Color riskColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    evaluateRisk();
  }

  void evaluateRisk() {
    if (heartRate > 120 || systolicBP > 150 || pulseRate > 120) {
      riskStatus = "SEVERE RISK 🚨";
      riskColor = Colors.red;

      Future.delayed(Duration(milliseconds: 800), () {
        showCriticalDialog();
      });
    } else if (heartRate > 100 || systolicBP > 140) {
      riskStatus = "WARNING ⚠️";
      riskColor = Colors.orange;
    } else {
      riskStatus = "NORMAL ✅";
      riskColor = Colors.green;
    }

    setState(() {});
  }

  void showCriticalDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Critical Health Alert 🚑"),
        content: Text(
          "Your vitals indicate severe risk. Immediate consultation or ambulance is recommended.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              showSnackBar("AI booked tentative teleconsultation");
            },
            child: Text("Book Appointment"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await triggerEmergencyAPI();
            },
            child: Text("Call Ambulance"),
          ),
        ],
      ),
    );
  }

  void showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> triggerEmergencyAPI() async {
    showSnackBar("🚑 Triggering Emergency...");

    try {
      var response = await http.post(
        Uri.parse(ApiConfig.emergency),
        body: {
          "patient_name": "Lakshmi",
          "heart_rate": heartRate.toString(),
          "bp": "$systolicBP/$diastolicBP",
          "pulse": pulseRate.toString(),
          "risk": riskStatus,
        },
      );

      if (response.statusCode == 200) {
        showSnackBar("✅ SOS Alert Sent To Hospital 🚨");
      } else {
        showSnackBar("❌ Emergency Failed");
      }
    } catch (e) {
      showSnackBar("❌ Server Not Reachable: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Check Vitals")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 30),

            vitalCard("Heart Rate", "$heartRate bpm"),
            vitalCard("Blood Pressure", "$systolicBP / $diastolicBP mmHg"),
            vitalCard("Pulse Rate", "$pulseRate bpm"),

            SizedBox(height: 40),

            Text(
              riskStatus,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: riskColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget vitalCard(String title, String value) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
