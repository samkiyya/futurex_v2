import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:futurex_app/animation/typing_indicator.dart';
import 'package:futurex_app/videoApp/services/ai_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatBottomSheet extends StatefulWidget {
  const ChatBottomSheet({super.key});

  @override
  State<ChatBottomSheet> createState() => _ChatBottomSheetState();
}

class _ChatBottomSheetState extends State<ChatBottomSheet> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? messagesJson = prefs.getString('chat_messages');
    if (messagesJson != null) {
      List<dynamic> decodedMessages = jsonDecode(messagesJson);
      setState(() {
        _messages.addAll(
          decodedMessages.map((e) => Map<String, String>.from(e)),
        );
      });
    }
  }

  Future<void> _saveMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String messagesJson = jsonEncode(_messages);
    await prefs.setString('chat_messages', messagesJson);
  }

  Future<void> _sendMessage() async {
    String prompt = _messageController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _messages.add({"sender": prompt});
      _messageController.clear();
      isLoading = true;
    });
    await _saveMessages();

    String aiResponse = await OpenAPIService().generateResponse(prompt);
    setState(() {
      _messages.add({"ai": aiResponse});
      isLoading = false;
    });
    await _saveMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Prevents keyboard overlap
      body: Container(
        padding: const EdgeInsets.all(16.0),
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const Text(
              "FutureX AI Support",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Chat area
            Expanded(
              child: SingleChildScrollView(
                reverse: true, // Ensures the input stays visible when typing
                child: Column(
                  children: [
                    _messages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/images/bot.png',
                                  height: 100,
                                  width: 100,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "Got a question?",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 16),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final message = _messages[index];
                              final isSender = message.containsKey("sender");
                              return Align(
                                alignment: isSender
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width * 0.7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSender
                                        ? Colors.blue
                                        : Colors.grey[300],
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(12),
                                      topRight: const Radius.circular(12),
                                      bottomLeft: isSender
                                          ? const Radius.circular(12)
                                          : Radius.zero,
                                      bottomRight: isSender
                                          ? Radius.zero
                                          : const Radius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    message.values.first,
                                    style: TextStyle(
                                      color: isSender
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: TypingIndicator(),
                      ),
                  ],
                ),
              ),
            ),
            // Input field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Ask ...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton.small(
                  onPressed: _sendMessage,
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
