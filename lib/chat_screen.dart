import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class ChatScreen extends StatefulWidget {
  final String username;
  ChatScreen({required this.username});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> messages = [];
  final TextEditingController messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _waitingForMessage = false;
  bool _isResponding = false;
  bool _commandProcessed = false;
  Timer? _listeningTimer;
  String _spokenText = ""; // Stores the entire spoken command
  FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts.setLanguage("en-US");
    _flutterTts.setSpeechRate(0.5);
  }

  void sendMessage(String text) {
    if (text.isNotEmpty) {
      setState(() {
        messages.add({'type': 'text', 'content': text, 'isUser': true});
      });
      _speak("Message sent.");
    }
    messageController.clear();
    _waitingForMessage = false;
  }

  void readLastMessage() {
    if (messages.isNotEmpty) {
      _speak("Last message was: ${messages.last['content']}");
    } else {
      _speak("No messages to read.");
    }
  }

  void startListening() async {
    if (_isListening || _isResponding) return;

    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _isListening = true;
        _commandProcessed = false;
        _spokenText = ""; // Reset previous text
      });

      // Start a timer to wait for the full command (5 seconds)
      _listeningTimer = Timer(Duration(seconds: 5), () {
        stopListening();
        if (_spokenText.isEmpty) {
          _speak("No command detected. Try again.");
        } else {
          processCommand(_spokenText);
        }
      });

      _speech.listen(
        onResult: (result) async {
          if (_isResponding || _commandProcessed) return;
          _spokenText = result.recognizedWords.toLowerCase().trim();
          print("Detected command: $_spokenText");
        },
      );
    }
  }

  void stopListening() {
    _speech.stop();
    _listeningTimer?.cancel();
    setState(() => _isListening = false);
  }

  void processCommand(String spokenText) {
    _commandProcessed = true; // Ensure only one execution

    if (_waitingForMessage) {
      sendMessage(spokenText);
      return;
    }

    if (spokenText.contains("read last message")) {
      readLastMessage();
      return;
    }

    if (spokenText.contains("send message")) {
      _speak("What would you like to say?");
      _waitingForMessage = true;
      return;
    }

    if (spokenText.contains("go back")) {
      _speak("Going back.");
      Navigator.pop(context);
      return;
    }

    _speak("Command not recognized. Try saying 'Send message' or 'Read last message'.");
  }

  void _speak(String text) async {
    _isResponding = true;
    await _flutterTts.speak(text);
    await Future.delayed(Duration(seconds: 2));
    _isResponding = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat with ${widget.username}")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return ListTile(
                  title: Text(message['content']),
                  tileColor: message['isUser'] ? Colors.blue[100] : Colors.green[100],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => sendMessage(messageController.text),
                ),
              ],
            ),
          ),
          FloatingActionButton(
            onPressed: _isListening ? stopListening : startListening,
            child: Icon(_isListening ? Icons.mic_off : Icons.mic),
          ),
        ],
      ),
    );
  }
}
