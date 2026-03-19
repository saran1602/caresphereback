import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

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

  // Tamil responses dictionary
  final Map<String, String> responses = {
    "hello": "வணக்கம்! நான் உங்களுக்கு எப்படி உதவ முடியும்?",
    "hi": "வணக்கம்! எப்படி உள்ளீர்கள்?",
    "help":
        "நான் உங்களுக்கு உதவ முடியும். நோய், மருந்து அல்லது உணவு பற்றி கேட்கவும்.",
    "health":
        "ஆரோக்கியம் மிகவும் முக்கியமாகும். தினமும் நடைப்பயிற்சி செய்யுங்கள்.",
    "medicine": "மருந்தை எடுக்கும் முன் மருத்துவரை கலந்தாலோசிக்கவும்.",
    "food": "ஆரோக்கியமான உணவை சாப்பிடுங்கள். பச்சை காய்கறிகள் முக்கியம்.",
    "water": "தினமும் பொதுவாக நீர் குடிக்க வேண்டும்.",
    "pain": "வலி இருந்தால் மருத்துவரை பார்க்கவும்.",
    "fever": "காய்ச்சல் இருந்தால் ஓய்வு எடுத்து நீர் குடிக்கவும்.",
    "sugar": "சர்க்கரை நோய் உள்ளவர்கள் இனிப்பு தவிர்க்க வேண்டும்.",
    "diabetes": "糖尿病உள்ளவர்கள் மருத்துவரை அடிக்கடி சந்திக்க வேண்டும்.",
    "pressure": "இரத்த அழுத்தம் சரிபார்க்கவும். சவ்வு தவிர்க்கவும்.",
    "exercise": "நாள் ஒன்றுக்கு முப்பது நிமிடம் நடையை உத்தமம்.",
    "sleep": "எட்டு மணிநேரம் தூங்க வேண்டும்.",
  };

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    _speech = stt.SpeechToText();
    _tts = FlutterTts();

    try {
      await _tts.setLanguage("ta-IN");
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.8);
      print("✅ Chatbot initialized");
    } catch (e) {
      print("❌ Init error: $e");
    }
  }

  Future<void> _startListening() async {
    if (!mounted) return;

    try {
      bool available = await _speech.initialize(
        onError: (error) {
          print('❌ Speech Error: $error');
          if (mounted) {
            setState(() {
              _isListening = false;
              _response = "பேச்சு பிழை: $error";
            });
          }
        },
        onStatus: (status) {
          print('📢 Status: $status');
        },
      );

      if (available) {
        if (mounted) {
          setState(() {
            _isListening = true;
            _recognizedText = "";
          });
        }

        _speech.listen(
          localeId: "ta-IN",
          onResult: (result) {
            print("🎤 Recognized: ${result.recognizedWords}");
            if (mounted) {
              setState(() {
                _recognizedText = result.recognizedWords;
              });

              // Auto-process when user stops speaking
              if (result.finalResult && _recognizedText.isNotEmpty) {
                print("✅ Final result: $_recognizedText");
                _getResponse(_recognizedText);
                _stopListening();
              }
            }
          },
        );
      } else {
        print("❌ Speech recognition not available");
        if (mounted) {
          setState(() {
            _response = "பேச்சு அங்கீகாரம் கிடைக்கவில்லை";
            _isListening = false;
          });
        }
      }
    } catch (e) {
      print("❌ Listen error: $e");
      if (mounted) {
        setState(() {
          _isListening = false;
          _response = "பிழை: $e";
        });
      }
    }
  }

  void _stopListening() {
    _speech.stop();
    if (mounted) {
      setState(() => _isListening = false);
    }
  }

  void _getResponse(String userInput) async {
    if (!mounted) return;
    setState(() => _isProcessing = true);

    try {
      // Find matching response
      String query = userInput.toLowerCase().trim();
      print("🔍 Looking for response for: $query");

      String response =
          "இப்போது சொல்லலாம். வேறு கேள்வி கேட்கவும். (hello, help, health, medicine, food, water பற்றி கேட்கவும்)";

      // Exact match first
      if (responses.containsKey(query)) {
        response = responses[query]!;
        print("✅ Exact match found!");
      } else {
        // Partial match
        for (var key in responses.keys) {
          if (query.contains(key)) {
            response = responses[key]!;
            print("✅ Partial match found: $key");
            break;
          }
        }
      }

      if (mounted) {
        setState(() {
          _response = response;
          _isProcessing = false;
        });

        // Speak the response
        try {
          print("🔊 Speaking response...");
          await _tts.speak(response);
          print("✅ Speech completed");
        } catch (e) {
          print("❌ TTS error: $e");
        }
      }
    } catch (e) {
      print("❌ Response error: $e");
      if (mounted) {
        setState(() {
          _response = "பிழை ஏற்பட்டது. மீண்டும் முயற்சி செய்யவும்.";
          _isProcessing = false;
        });
      }
    }
  }

  void _showChatDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return Dialog(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Text(
                      "தமிழ் உதவியாளர்",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                    Divider(height: 20),
                    SizedBox(height: 10),

                    // User speech display
                    if (_recognizedText.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "நீங்கள்:",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _recognizedText,
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    if (_recognizedText.isEmpty)
                      Text(
                        "உங்கள் பேச்சு இங்கே தோன்றும்",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    SizedBox(height: 15),

                    // Response display
                    if (_response.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "உதவியாளர்:",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(_response, style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    if (_response.isEmpty && _recognizedText.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "பதிலளிக்கிறது...",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                    SizedBox(height: 20),

                    // Text input for manual entry
                    TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: "சொல்லவோ அல்லது எழுதவோ...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.send, color: Colors.deepOrange),
                          onPressed: () {
                            if (_textController.text.isNotEmpty) {
                              setDialogState(() {
                                _recognizedText = _textController.text;
                              });
                              _getResponse(_textController.text);
                              _textController.clear();
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    if (_isProcessing)
                      Column(
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.deepOrange,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text("பதிலளிக்கிறது..."),
                        ],
                      )
                    else
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (_isListening) {
                                _stopListening();
                              } else {
                                _startListening();
                              }
                              setDialogState(() {});
                            },
                            child: Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: _isListening
                                    ? Colors.red
                                    : Colors.deepOrange,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isListening ? Icons.stop : Icons.mic,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            _isListening
                                ? "🔴 கேட்டுக்கொண்டிருக்கிறது..."
                                : "🎤 பேச்சு தொடங்க அழுத்தவும்",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 20),

                    // Close button
                    ElevatedButton(
                      onPressed: () {
                        _stopListening();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                      ),
                      child: Text(
                        "மூடவும்",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      // Cleanup when dialog closes
      _stopListening();
      _speech.stop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Floating mic button (bottom right)
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: _showChatDialog,
            backgroundColor: Colors.deepOrange,
            child: Icon(Icons.mic, color: Colors.white, size: 28),
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
