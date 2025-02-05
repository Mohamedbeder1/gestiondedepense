import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

const String GEMINI_API_KEY = "AIzaSyCecBVytIXoAH5mqYjbOksiI7BZW_E12Q4";

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final Gemini gemini = Gemini.instance;
  final List<ChatMessage> _messages = [];
  final ChatUser _user = ChatUser(id: 'user');
  final ChatUser _assistant = ChatUser(id: 'assistant', firstName: 'Assistant');

  Future<void> _sendMessage(String text) async {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        user: _user,
        createdAt: DateTime.now(),
      ));
    });

    try {
      final stream = gemini.streamChat([
        Content(parts: [Part.text(text)])
      ]);
      stream.listen((response) {
        setState(() {
          _messages.add(ChatMessage(
            text: response.output!,
            user: _assistant,
            createdAt: DateTime.now(),
          ));
        });
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Erreur : Impossible d\'obtenir une réponse',
          user: _assistant,
          createdAt: DateTime.now(),
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Assistant'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: DashChat(
        currentUser: _user,
        messages: _messages.reversed.toList(),
        onSend: (ChatMessage message) {
          _sendMessage(message.text);
        },
      ),
    );
  }
}
