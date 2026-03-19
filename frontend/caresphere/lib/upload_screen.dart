import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'ocr_screen_result.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_config.dart';

class UploadScreen extends StatefulWidget {
  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {

  File? imageFile;
  bool loading = false;

  Future uploadImage(File file) async {

    setState(() {
      loading = true;
    });

    try {

      print("📡 Sending OCR request...");

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.uploadPrescription),
      );

      request.files.add(
        await http.MultipartFile.fromPath('file', file.path),
      );

      var response = await request.send();

      print("✅ Response status: ${response.statusCode}");

      var res = await response.stream.bytesToString();

      print("📄 Raw response: $res");

      var data = jsonDecode(res);

      setState(() {
        loading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OCRResultScreen(
            extractedText: data["extracted_text"],
          ),
        ),
      );

    } catch (e) {

      setState(() {
        loading = false;
      });

      print("❌ ERROR OCCURRED: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Server not reachable")),
      );
    }
  }

  Future pickFromCamera() async {

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);

    if (picked == null) return;

    File file = File(picked.path);

    setState(() {
      imageFile = file;
    });

    await uploadImage(file);
  }

  Future pickFromGallery() async {

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    File file = File(picked.path);

    setState(() {
      imageFile = file;
    });

    await uploadImage(file);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(title: Text("Upload Prescription"), centerTitle: true),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              if (loading)
                Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text("AI Reading Prescription...")
                  ],
                ),

              if (!loading) ...[
                Icon(Icons.document_scanner, size: 80, color: Colors.teal),

                SizedBox(height: 15),

                Text(
                  "Add Patient Prescription",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade800,
                  ),
                ),

                SizedBox(height: 30),

                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.teal, width: 2),
                  ),
                  child: imageFile != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(imageFile!, fit: BoxFit.cover),
                  )
                      : Center(child: Text("No Image Selected")),
                ),

                SizedBox(height: 25),

                ElevatedButton.icon(
                  onPressed: pickFromCamera,
                  icon: Icon(Icons.camera_alt),
                  label: Text("Capture Photo"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 55),
                    backgroundColor: Colors.teal,
                  ),
                ),

                SizedBox(height: 15),

                ElevatedButton.icon(
                  onPressed: pickFromGallery,
                  icon: Icon(Icons.photo),
                  label: Text("Select from Gallery"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 55),
                    backgroundColor: Colors.teal.shade400,
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}