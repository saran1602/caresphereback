import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_config.dart';

class TamilChatbot extends StatefulWidget {
  final Widget child;
  const TamilChatbot({Key? key, required this.child}) : super(key: key);

  @override
  State<TamilChatbot> createState() => _TamilChatbotState();
}

class _TamilChatbotState extends State<TamilChatbot> {
  late stt.SpeechToText _speech;
  late FlutterTts _tts;
  bool _isListening = false;
  bool _isProcessing = false;
  String _recognizedText = "";
  String _response = "";
  final TextEditingController _textController = TextEditingController();

  // 22 Scheduled Languages of India
  final List<Map<String, String>> languages = [
    {"name": "Tamil", "stt": "ta-IN", "tts": "ta-IN"},
    {"name": "Hindi", "stt": "hi-IN", "tts": "hi-IN"},
    {"name": "English", "stt": "en-IN", "tts": "en-IN"},
    {"name": "Bengali", "stt": "bn-IN", "tts": "bn-IN"},
    {"name": "Telugu", "stt": "te-IN", "tts": "te-IN"},
    {"name": "Marathi", "stt": "mr-IN", "tts": "mr-IN"},
    {"name": "Gujarati", "stt": "gu-IN", "tts": "gu-IN"},
    {"name": "Kannada", "stt": "kn-IN", "tts": "kn-IN"},
    {"name": "Malayalam", "stt": "ml-IN", "tts": "ml-IN"},
    {"name": "Punjabi", "stt": "pa-IN", "tts": "pa-IN"},
    {"name": "Odia", "stt": "or-IN", "tts": "or-IN"},
    {"name": "Urdu", "stt": "ur-IN", "tts": "ur-IN"},
    {"name": "Assamese", "stt": "as-IN", "tts": "as-IN"},
    {"name": "Sanskrit", "stt": "sa-IN", "tts": "sa-IN"},
  ];

  Map<String, String> _selectedLang = {"name": "Tamil", "stt": "ta-IN", "tts": "ta-IN"};

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    _speech = stt.SpeechToText();
    _tts = FlutterTts();

    try {
      await _tts.setLanguage(_selectedLang['tts']!);
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.8);
    } catch (e) {
      print("❌ Init error: $e");
    }
  }

  Future<void> _startListening() async {
    if (!mounted) return;

    try {
      bool available = await _speech.initialize(
        onError: (error) => setState(() => _isListening = false),
      );

      if (available) {
        setState(() {
          _isListening = true;
          _recognizedText = "";
        });

        _speech.listen(
          localeId: _selectedLang['stt'],
          onResult: (result) {
            setState(() {
              _recognizedText = result.recognizedWords;
            });

            if (result.finalResult && _recognizedText.isNotEmpty) {
              _getResponse(_recognizedText);
              _stopListening();
            }
          },
        );
      }
    } catch (e) {
      setState(() => _isListening = false);
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  void _getResponse(String userInput) async {
    if (!mounted) return;
    setState(() {
      _isProcessing = true;
      _response = "";
    });

    try {
      var res = await http.post(
        Uri.parse(ApiConfig.chat),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": userInput, "language": _selectedLang['name']}),
      );

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        String aiText = data['response'];

        setState(() {
          _response = aiText;
          _isProcessing = false;
        });

        await _tts.speak(aiText);
      } else {
        setState(() {
          _response = "Error: Could not reach AI service.";
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        _response = "Connection error.";
        _isProcessing = false;
      });
    }
  }

  void _showChatDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "AI Health Assistant",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                        ),
                        DropdownButton<Map<String, String>>(
                          value: _selectedLang,
                          onChanged: (val) {
                            setDialogState(() => _selectedLang = val!);
                            setState(() => _selectedLang = val!);
                            _tts.setLanguage(val!['tts']!);
                          },
                          items: languages.map((lang) {
                            return DropdownMenuItem(
                              value: lang,
                              child: Text(lang['name']!, style: TextStyle(fontSize: 12)),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    Divider(),
                    
                    if (_recognizedText.isNotEmpty)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(10)),
                          child: Text(_recognizedText),
                        ),
                      ),
                    
                    if (_response.isNotEmpty)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                          child: Text(_response),
                        ),
                      ),
                      
                    if (_isProcessing)
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(),
                      ),

                    SizedBox(height: 20),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            decoration: InputDecoration(
                              hintText: "Type or ask...",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                              contentPadding: EdgeInsets.symmetric(horizontal: 20),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send, color: Colors.teal),
                          onPressed: () {
                            if (_textController.text.isNotEmpty) {
                              String txt = _textController.text;
                              setDialogState(() => _recognizedText = txt);
                              _getResponse(txt);
                              _textController.clear();
                            }
                          },
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 20),
                    
                    GestureDetector(
                      onTap: () {
                        if (_isListening) {
                          _stopListening();
                        } else {
                          _startListening();
                        }
                        setDialogState(() {});
                      },
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: _isListening ? Colors.red : Colors.teal,
                        child: Icon(_isListening ? Icons.stop : Icons.mic, color: Colors.white, size: 30),
                      ),
                    ),
                    
                    SizedBox(height: 10),
                    Text(
                      _isListening ? "Listening..." : "Tap to Speak",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: _showChatDialog,
            backgroundColor: Colors.teal,
            child: Icon(Icons.support_agent, color: Colors.white),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    _textController.dispose();
    super.dispose();
  }
}
