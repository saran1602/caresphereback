import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'auth_service.dart';
import 'api_config.dart';

class DoctorDashboard extends StatefulWidget {
  final String? userId;

  DoctorDashboard({this.userId});

  @override
  _DoctorDashboardState createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  String aiSummary = "";
  String prescriptionSuggestion = "";

  FlutterTts tts = FlutterTts();

  final patientController = TextEditingController();
  final medicineController = TextEditingController();
  final timeController = TextEditingController();

  bool loading = false;
  bool suggestingMed = false;
  bool assigningReminder = false;
  
  Map<String, dynamic>? structuredData;
  List<dynamic> patientProgress = [];

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

  // ================= OCR Upload =================

  Future uploadRecord() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return;

      setState(() => loading = true);

      var request = http.MultipartRequest(
        "POST",
        Uri.parse("${ApiConfig.baseUrl}/doctor_upload_record"),
      );

      request.files.add(await http.MultipartFile.fromPath("file", image.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var data = jsonDecode(responseBody);
        
        setState(() {
          try {
            var rawStructured = data['structured_data'];
            Map<String, dynamic> processedData = {};
            
            if (rawStructured is String) {
              var decoded = jsonDecode(rawStructured);
              if (decoded is Map<String, dynamic>) {
                processedData = decoded;
              } else {
                print("⚠️ OCR JSON is not a Map: $decoded");
              }
            } else if (rawStructured is Map<String, dynamic>) {
              processedData = rawStructured;
            } else if (rawStructured != null) {
              print("⚠️ Unexpected structured_data type: ${rawStructured.runtimeType}");
            }
            
            structuredData = processedData;
            aiSummary = processedData['clinical_summary'] ?? processedData['summary'] ?? "No summary available";
          } catch (e) {
            print("❌ OCR Parsing Error: $e");
            aiSummary = "Error parsing medical data. Please try again with a clearer image.";
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Record Processed Successfully")),
        );
      } else {
        var errorBody = await response.stream.bytesToString();
        var errorMsg = "Upload Failed";
        try {
          var errorData = jsonDecode(errorBody);
          errorMsg = errorData['error'] ?? errorMsg;
        } catch (_) {}
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ $errorMsg")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  Future fetchPatientProgress() async {
    try {
      final docId = widget.userId ?? "doctor_123";
      final res = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/doctor/patient_progress/$docId"),
      );

      if (res.statusCode == 200) {
        setState(() {
          patientProgress = jsonDecode(res.body);
        });
      }
    } catch (e) {
      print("Error fetching progress: $e");
    }
  }

  // ================= AI SUMMARY =================

  Future generateSummary() async {
    try {
      setState(() => loading = true);

      var res = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/doctor_ai_summary"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": structuredData?['patient_name'] ?? "Unknown",
          "age": "N/A", // Not usually in OCR structured data yet
          "conditions": [structuredData?['diagnosis'] ?? "N/A"],
          "allergies": [],
          "symptoms": [],
          "vitals": structuredData?['vitals'] ?? {},
          "lab_results": structuredData?['lab_results'] ?? [],
          "medicines": structuredData?['medicines'] ?? [],
        }),
      );

      if (res.statusCode == 200) {
        var summaryData = jsonDecode(res.body);
        
        if (summaryData is Map) {
          String summary = summaryData["summary"] ?? summaryData["clinical_summary"] ?? "No summary available";
          setState(() {
            aiSummary = summary;
            loading = false;
          });
        } else if (summaryData is String) {
          setState(() {
            aiSummary = summaryData;
            loading = false;
          });
        } else {
          setState(() {
            aiSummary = "Error: Unexpected summary data format.";
            loading = false;
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ AI Summary Generated")),
        );
      } else {
        setState(() => loading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ Failed: ${res.statusCode}")));
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
    }
  }

  // ================= SPEAK =================

  Future speakSummary() async {
    try {
      if (aiSummary.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("⚠ No summary to speak")));
        return;
      }
      await tts.setSpeechRate(0.4);
      await tts.speak(aiSummary);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ TTS Error: $e")));
    }
  }

  // ================= AI PRESCRIPTION =================

  Future getPrescriptionSuggestion() async {
    try {
      if (aiSummary.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("⚠ Generate summary first")));
        return;
      }

      setState(() => suggestingMed = true);

      var res = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/ai_prescription_suggest"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"summary": aiSummary}),
      );

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        setState(() {
          prescriptionSuggestion = data["suggestion"] ?? data.toString();
          suggestingMed = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("✅ Medication Suggested")));
      } else {
        setState(() => suggestingMed = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ Failed: ${res.statusCode}")));
      }
    } catch (e) {
      setState(() => suggestingMed = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
    }
  }

  // ================= ASSIGN REMINDER =================

  Future assignReminder() async {
    try {
      if (patientController.text.isEmpty ||
          medicineController.text.isEmpty ||
          timeController.text.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("⚠ Fill all fields")));
        return;
      }

      setState(() => assigningReminder = true);

      var res = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/assign_reminder"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "patient": patientController.text,
          "medicine": medicineController.text,
          "time": timeController.text,
        }),
      );

      if (res.statusCode == 200) {
        patientController.clear();
        medicineController.clear();
        timeController.clear();

        setState(() => assigningReminder = false);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("✅ Reminder Assigned")));
      } else {
        setState(() => assigningReminder = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ Failed: ${res.statusCode}")));
      }
    } catch (e) {
      setState(() => assigningReminder = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Doctor Clinical Dashboard"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: "Logout",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== UPLOAD SECTION =====
            Text(
              "📋 Medical Records",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: loading ? null : uploadRecord,
                icon: Icon(Icons.upload_file),
                label: Text("Upload Medical Record"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  disabledBackgroundColor: Colors.grey,
                ),
              ),
            ),

            SizedBox(height: 25),

            // ===== AI SUMMARY SECTION =====
            Text(
              "🤖 AI Analysis",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: loading ? null : generateSummary,
                icon: loading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Icon(Icons.psychology),
                label: Text(loading ? "Generating..." : "Generate AI Summary"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  disabledBackgroundColor: Colors.grey,
                ),
              ),
            ),

            if (aiSummary.isNotEmpty) ...[
              SizedBox(height: 15),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.summarize, color: Colors.teal),
                          SizedBox(width: 8),
                          Text(
                            "Clinical Summary",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                      Divider(height: 25),
                      Text(
                        aiSummary,
                        style: TextStyle(fontSize: 15, height: 1.4),
                      ),
                      SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton.icon(
                          onPressed: speakSummary,
                          icon: Icon(Icons.volume_up),
                          label: Text("🔊 Listen to Summary"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade700,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // ===== LAB RESULTS SECTION =====
            if (structuredData != null && 
                structuredData!['lab_results'] is List && 
                (structuredData!['lab_results'] as List).isNotEmpty) ...[
              SizedBox(height: 25),
              Text(
                "🧪 Lab Test Results",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              SizedBox(height: 10),
              Card(
                elevation: 3,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('Parameter')),
                      DataColumn(label: Text('Value')),
                      DataColumn(label: Text('Normal Range')),
                    ],
                    rows: (structuredData!['lab_results'] as List).map((item) {
                      return DataRow(cells: [
                        DataCell(Text(item['parameter']?.toString() ?? '')),
                        DataCell(Text("${item['value']?.toString() ?? ''} ${item['unit']?.toString() ?? ''}")),
                        DataCell(Text(item['normal_range']?.toString() ?? 'N/A')),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ],

            SizedBox(height: 25),

            // ===== MEDICATION SUGGESTION SECTION =====
            Text(
              "💊 Treatment Plan",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: (aiSummary.isEmpty || suggestingMed)
                    ? null
                    : getPrescriptionSuggestion,
                icon: suggestingMed
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Icon(Icons.medical_services),
                label: Text(
                  suggestingMed ? "Suggesting..." : "Suggest Medication",
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  disabledBackgroundColor: Colors.grey,
                ),
              ),
            ),

            if (prescriptionSuggestion.isNotEmpty) ...[
              SizedBox(height: 15),
              Card(
                color: Colors.orange.shade50,
                elevation: 3,
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Suggested Medication Plan:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(prescriptionSuggestion),
                    ],
                  ),
                ),
              ),
            ],

            SizedBox(height: 25),

            // ===== ASSIGN REMINDER SECTION =====
            Text(
              "⏰ Patient Reminders",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: patientController,
              decoration: InputDecoration(
                labelText: "Patient Name",
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            SizedBox(height: 12),

            TextField(
              controller: medicineController,
              decoration: InputDecoration(
                labelText: "Medicine Name",
                prefixIcon: Icon(Icons.medical_services),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            SizedBox(height: 12),

            TextField(
              controller: timeController,
              decoration: InputDecoration(
                labelText: "Time (e.g., 08:00 AM)",
                prefixIcon: Icon(Icons.access_time),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: assigningReminder ? null : assignReminder,
                icon: assigningReminder
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Icon(Icons.add_alarm),
                label: Text(
                  assigningReminder ? "Assigning..." : "Assign Reminder",
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  disabledBackgroundColor: Colors.grey,
                ),
              ),
            ),

            SizedBox(height: 30),

            // ===== PATIENT PROGRESS SECTION =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "📈 Patient Adherence",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                TextButton.icon(
                  onPressed: fetchPatientProgress,
                  icon: Icon(Icons.refresh, size: 18),
                  label: Text("Refresh"),
                ),
              ],
            ),
            SizedBox(height: 10),
            if (patientProgress.isEmpty)
              Center(child: Text("Register patients to track progress"))
            else
              ...patientProgress.map((p) {
                return Card(
                  margin: EdgeInsets.only(bottom: 15),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal.shade100,
                      child: Text(p['patient_name'] != null && p['patient_name'].isNotEmpty ? p['patient_name'][0] : "?"),
                    ),
                    title: Text(p['patient_name'] ?? "Unknown Patient"),
                    subtitle: Text("ID: ${p['patient_id'] ?? 'N/A'}"),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${(p['adherence_rate'] ?? 0.0).toStringAsFixed(0)}%",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: (p['adherence_rate'] ?? 0) > 70 ? Colors.green : Colors.red,
                          ),
                        ),
                        Text("${p['taken_meds'] ?? 0}/${p['total_meds'] ?? 0} Taken"),
                      ],
                    ),
                  ),
                );
              }).toList(),

            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
