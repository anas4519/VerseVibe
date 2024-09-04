import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_tts/flutter_tts.dart';

class BlogSummary extends StatefulWidget {
  final String blogBody;
  const BlogSummary({super.key, required this.blogBody});

  @override
  State<BlogSummary> createState() => _BlogSummaryState();
}

class _BlogSummaryState extends State<BlogSummary> {
  final gemini = Gemini.instance;
  final FlutterTts flutterTts = FlutterTts();
  String summary = '';
  bool isLoading = true;
  bool isSpeaking = false;

  @override
  void initState() {
    super.initState();
    generateSummary();
    initTts();
  }

  Future<void> initTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  Future<void> generateSummary() async {
    try {
      final result = await gemini.text(
          'Summarize the following blog post in a concise manner:\n\n${widget.blogBody}');

      setState(() {
        if (result != null && result.content != null) {
          summary =
              result.content!.parts?.firstOrNull?.text ?? 'No summary content.';
        } else {
          summary = 'Unable to generate summary.';
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        summary = 'Error generating summary: $e';
        isLoading = false;
      });
    }
  }

  Future<void> speak() async {
    if (isSpeaking) {
      await flutterTts.stop();
      setState(() => isSpeaking = false);
    } else {
      setState(() => isSpeaking = true);
      try {
        var result = await flutterTts.speak(summary);
        if (result == 1) {
        } else {
          print("Speech failed to start");
        }
      } catch (e) {
        print("Error occurred during speech: $e");
      } finally {
        setState(() => isSpeaking = false);
      }
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Blog Summary'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: isLoading ? null : speak,
            icon: Icon(isSpeaking ? Icons.stop : Icons.volume_up_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
          child: Center(
            child: isLoading
                ? const CircularProgressIndicator()
                : Text(
                    summary,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
          ),
        ),
      ),
    );
  }
}
