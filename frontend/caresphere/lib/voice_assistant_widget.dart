import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:animate_do/animate_do.dart';

class VoiceAssistantWidget extends StatefulWidget {
  final Widget child;
  const VoiceAssistantWidget({Key? key, required this.child}) : super(key: key);

  @override
  _VoiceAssistantWidgetState createState() => _VoiceAssistantWidgetState();
}

class _VoiceAssistantWidgetState extends State<VoiceAssistantWidget> {
  late stt.SpeechToText _speech;
  late FlutterTts _tts;
  bool _isListening = false;
  String _text = "எப்படி உதவ முடியும்?"; // "How can I help?" in Tamil
  bool _isExpanded = false;
  Offset _offset = Offset(300, 600);
  bool _isProcessing = false;
  bool _isInitialized = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _tts = FlutterTts();
    _initializeTTS();
  }

  Future<void> _initializeTTS() async {
    try {
      await _tts.setLanguage("ta-IN");
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.8);
      setState(() => _isInitialized = true);
    } catch (e) {
      print("TTS Initialization error: $e");
      setState(() {
        _isInitialized = true;
        _initError = "TTS Error: $e";
      });
    }
  }

  void _listen() async {
    try {
      if (!_isListening) {
        bool available = await _speech.initialize(
          onStatus: (val) => print('onStatus: $val'),
          onError: (val) => print('onError: $val'),
        );
        if (available) {
          setState(() => _isListening = true);
          _speech.listen(
            localeId: "ta-IN",
            onResult: (val) {
              if (mounted) {
                setState(() {
                  _text = val.recognizedWords;
                });
              }
            },
          );
        }
      } else {
        setState(() => _isListening = false);
        _speech.stop();
        if (_text.isNotEmpty && _text != "எப்படி உதவ முடியும்?") {
          _sendToBackend(_text);
        }
      }
    } catch (e) {
      print("Listen error: $e");
      if (mounted) {
        setState(() {
          _isListening = false;
          _text = "மன்னிக்கவும், voice error.";
        });
      }
    }
  }

  Future<void> _sendToBackend(String query) async {
    if (!mounted) return;
    setState(() => _isProcessing = true);

    // Dummy responses - no backend call needed
    final dummyResponses = {
      "hello": "வணக்கம்! எப்படி உதவ முடியும்?",
      "hi": "வணக்கம்! நீங்கள் எப்படி உள்ளீர்கள்?",
      "help":
          "நான் உங்களுக்கு உதவ முடியும். நோய், மருந்து அல்லது உணவு பற்றி கேட்கவும்.",
      "health":
          "ஆரோக்கியம் என்பது முக்கியமானது. தினமும் சிறிது நடைப்பயிற்சி செய்யுங்கள்.",
      "medicine": "மருந்தை எடுக்கும் முன் மருத்துவரை கலந்தாலோசிக்கவும்.",
      "food":
          "ஆரோக்கியமான உணவை சாப்பிடுங்கள். பச்சை காய்கறிகள் மற்றும் பழங்கள் முக்கியம்.",
      "water": "தினமும் போதுமான தண்ணீர் குடிக்கவும்.",
      "pain": "வலி இருந்தால் மருத்துவரை பார்க்கவும்.",
      "fever":
          "காய்ச்சல் இருந்தால் மெல்ல தண்ணீர் குடிக்கவும் மற்றும் சரியாக தூங்கவும்.",
      "sugar": "சர்க்கரை நோய் உள்ளவர்கள் இனிப்பு சாப்பாடு தவிர்க்க வேண்டும்.",
    };

    try {
      // Simulate network delay
      await Future.delayed(Duration(milliseconds: 800));

      String queryLower = query.toLowerCase();
      String response =
          dummyResponses[queryLower] ??
          "நன்றி. உங்கள் கேள்வியை மீண்டும் கேட்கவும் அல்லது 'help' கேட்கவும்.";

      if (mounted) {
        setState(() {
          _text = response;
          _isProcessing = false;
        });

        // Speak the response
        try {
          await _tts.speak(response);
        } catch (ttsError) {
          print("TTS speak error: $ttsError");
        }
      }
    } catch (e) {
      print("Chat error: $e");
      if (mounted) {
        setState(() {
          _text = "பிழை ஏற்பட்டது. மீண்டும் முயற்சி செய்யவும்.";
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (!_isInitialized)
          Positioned.fill(
            child: Container(
              color: Colors.black87,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                ),
              ),
            ),
          ),
        if (_isInitialized)
          Positioned(
            left: _offset.dx,
            top: _offset.dy,
            child: Draggable(
              feedback: _buildFloatingButton(isFloating: true),
              childWhenDragging: Container(),
              onDragEnd: (details) {
                setState(() {
                  _offset = details.offset;
                });
              },
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: _buildFloatingButton(),
              ),
            ),
          ),
        if (_isExpanded && _isInitialized) _buildExpandedUI(),
      ],
    );
  }

  Widget _buildFloatingButton({bool isFloating = false}) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Colors.orange, Colors.redAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.9),
          radius: 30,
          child: Icon(
            _isExpanded ? Icons.close : Icons.face,
            size: 35,
            color: Colors.deepOrange,
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedUI() {
    return Positioned(
      bottom: 100,
      left: 20,
      right: 20,
      child: FadeInUp(
        duration: Duration(milliseconds: 300),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "CareSphere AI - தமிழ்",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  Divider(),
                  SizedBox(height: 10),
                  if (_initError != null)
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _initError!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade900,
                        ),
                      ),
                    )
                  else
                    Text(
                      _text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blueGrey.shade800,
                      ),
                    ),
                  SizedBox(height: 20),
                  if (_isProcessing)
                    CircularProgressIndicator(color: Colors.deepOrange)
                  else
                    GestureDetector(
                      onTap: _listen,
                      child: Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: _isListening ? Colors.red : Colors.deepOrange,
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
                        ? "கேட்கிறது..."
                        : "பேச அழுத்தவும்", // "Listening..." : "Press to talk"
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
