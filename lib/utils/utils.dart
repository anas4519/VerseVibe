import 'dart:convert';

import 'package:blogs_app/constants/constants.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        text,
        style: TextStyle(color: Constants.bg),
      ),
      backgroundColor: Constants.yellow,
    ),
  );
}

void showLoadingDialog(BuildContext context, String content) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          backgroundColor: Constants.bg,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Constants.yellow,
              ),
              const SizedBox(height: 16),
              Text(
                content,
                style: TextStyle(color: Constants.yellow),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> saveMessages(List<ChatMessage> messages) async {
  final prefs = await SharedPreferences.getInstance();
  List<String> encodedMessages =
      messages.map((message) => jsonEncode(message.toJson())).toList();
  await prefs.setStringList('chat_messages', encodedMessages);
}

Future<List<ChatMessage>> loadMessages() async {
  final prefs = await SharedPreferences.getInstance();
  List<String>? encodedMessages = prefs.getStringList('chat_messages');
  if (encodedMessages == null) return [];
  return encodedMessages.map((encodedMessage) {
    final jsonMessage = jsonDecode(encodedMessage) as Map<String, dynamic>;
    return ChatMessage.fromJson(jsonMessage);
  }).toList();
}
