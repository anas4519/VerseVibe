import 'dart:io';
import 'dart:typed_data';

import 'package:blogs_app/constants/constants.dart';
import 'package:blogs_app/providers/user_provider.dart';
import 'package:blogs_app/utils/utils.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class GeminiScreen extends StatefulWidget {
  const GeminiScreen({super.key});

  @override
  State<GeminiScreen> createState() => _GeminiScreenState();
}

class _GeminiScreenState extends State<GeminiScreen> {
  List<ChatMessage> messages = [];
  List<Content> chatHistory = [];
  late ChatUser currentUser;
  final Gemini gemini = Gemini.instance;
  final ChatUser geminiUser = ChatUser(id: '1', firstName: 'VV Assistant');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      setState(() {
        currentUser = ChatUser(
            id: user.id,
            firstName: user.name,
            profileImage: user.profileImageURL);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('VV Assistant')),
      body: Padding(
        padding: EdgeInsets.only(bottom: screenHeight * 0.01),
        child: currentUser == null
            ? const Center(child: CircularProgressIndicator())
            : DashChat(
                currentUser: currentUser,
                onSend: _sendMessage,
                messages: messages,
                messageOptions: MessageOptions(
                  messageTextBuilder: (ChatMessage message,
                      ChatMessage? previousMessage, ChatMessage? nextMessage) {
                    return Text(
                      message.text,
                      style: const TextStyle(
                          fontSize: 16), // Adjust the font size here
                    );
                  },
                  showCurrentUserAvatar: true,
                  currentUserContainerColor: Constants.yellow,
                  timeTextColor: Constants.yellow,
                  currentUserTextColor: Constants.bg,
                  containerColor: const Color(0xFFE1BEE7),
                  onLongPressMessage: (ChatMessage message) {
                    // Handle long press to copy the message content
                    Clipboard.setData(ClipboardData(text: message.text));
                    showSnackBar(context, 'Message copied to clipboard!');
                  },
                ),
                inputOptions: InputOptions(
                  trailing: [
                    IconButton(
                      onPressed: _sendMediaMessage,
                      icon: Icon(
                        Icons.image,
                        color: Constants.yellow,
                      ),
                    ),
                  ],
                  inputDecoration: InputDecoration(
                    hintStyle: const TextStyle(color: Colors.white),
                    hintText: 'Write a Message...',
                    labelStyle: const TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.08),
                      borderSide: BorderSide(
                        color: Constants.yellow,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.08),
                      borderSide: BorderSide(
                        color: Constants.yellow,
                      ),
                    ),
                  ),
                  cursorStyle: CursorStyle(color: Constants.yellow),
                  inputTextStyle: const TextStyle(color: Colors.white),
                  sendButtonBuilder: (onSend) => IconButton(
                    icon: Icon(Icons.send, color: Constants.yellow),
                    onPressed: onSend,
                  ),
                ),
              ),
      ),
    );
  }

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages];
    });

    try {
      String question = chatMessage.text;
      List<Uint8List>? images;

      // Add user message to chat history
      chatHistory.add(Content(parts: [Parts(text: question)], role: 'user'));

      if (chatMessage.medias?.isNotEmpty ?? false) {
        images = [File(chatMessage.medias!.first.url).readAsBytesSync()];
      }

      gemini.chat(chatHistory).then((response) {
        String res = response?.output ?? '';

        // Add model's response to chat history
        chatHistory.add(Content(parts: [Parts(text: res)], role: 'model'));

        ChatMessage message =
            ChatMessage(user: geminiUser, createdAt: DateTime.now(), text: res);

        setState(() {
          messages = [message, ...messages];
        });
      }).catchError((e) {
        print('Error generating response: $e');
        // Optionally, show an error message to the user
        showSnackBar(context, 'Failed to get response');
      });
    } catch (e) {
      print(e);
    }
  }

  void _sendMediaMessage() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      ChatMessage chatMessage = ChatMessage(
        user: currentUser,
        createdAt: DateTime.now(),
        text: 'Describe this picture',
        medias: [
          ChatMedia(url: file.path, fileName: "", type: MediaType.image)
        ],
      );
      _sendMessage(chatMessage);
    }
  }
}
