import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> contacts = ["Alice", "Bob", "Charlie", "Emma", "David"];
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _commandProcessed = false;
  Timer? _listeningTimer;
  String _spokenText = ""; // Stores the full spoken command
  FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts.setLanguage("en-US");
    _flutterTts.setSpeechRate(0.5);
  }

  void startListening() async {
    if (_isListening) return;

    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _isListening = true;
        _commandProcessed = false;
        _spokenText = ""; // Reset previous text
      });

      // Wait for the full command (5 seconds)
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
          if (_commandProcessed) return;
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
    _commandProcessed = true;

    if (spokenText.contains("open chat with")) {
      String name = spokenText.replaceAll("open chat with", "").trim();
      _openChat(name);
      return;
    }

    _speak("Command not recognized. Try saying 'Open chat with Alice'.");
  }

  void _openChat(String name) {
    // **Remove extra spaces & punctuation, and make it case-insensitive**
    name = name.replaceAll(RegExp(r'[^\w\s]'), '').trim().toLowerCase();

    String? matchedContact = contacts.firstWhere(
          (contact) => contact.toLowerCase() == name,
      orElse: () => "",
    );

    if (matchedContact.isNotEmpty) {
      _speak("Opening chat with $matchedContact.");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatScreen(username: matchedContact)),
      );
    } else {
      _speak("Contact '$name' not found. Try again.");
    }
  }

  void _speak(String text) async {
    await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(contacts[index]),
            leading: CircleAvatar(
              child: Text(contacts[index][0]),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatScreen(username: contacts[index])),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isListening ? stopListening : startListening,
        child: Icon(_isListening ? Icons.mic_off : Icons.mic),
      ),
    );
  }
}
