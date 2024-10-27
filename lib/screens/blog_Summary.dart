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
  bool isInitialized = false;
  
  // TTS chunking variables
  int currentChunk = 0;
  List<String> textChunks = [];

  @override
  void initState() {
    super.initState();
    generateSummary();
    initTts();
  }

  List<String> _splitTextIntoChunks(String text) {
    List<String> chunks = [];
    final sentences = text.split(RegExp(r'(?<=[.!?])\s+'));
    String currentChunk = '';

    for (String sentence in sentences) {
      if (currentChunk.length + sentence.length < 1000) {
        currentChunk += sentence + ' ';
      } else {
        if (currentChunk.isNotEmpty) {
          chunks.add(currentChunk.trim());
        }
        currentChunk = sentence + ' ';
      }
    }
    
    if (currentChunk.isNotEmpty) {
      chunks.add(currentChunk.trim());
    }
    
    return chunks;
  }

  Future<void> initTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    flutterTts.setCompletionHandler(() {
      if (currentChunk < textChunks.length - 1) {
        // Move to next chunk
        currentChunk++;
        _speakCurrentChunk();
      } else {
        // Reset everything when done
        setState(() {
          isSpeaking = false;
          currentChunk = 0;
        });
      }
    });

    isInitialized = true;
  }

  Future<void> _speakCurrentChunk() async {
    if (currentChunk < textChunks.length) {
      await flutterTts.speak(textChunks[currentChunk]);
    }
  }

  Future<void> generateSummary() async {
    try {
      final result = await gemini.text(
          'Summarize the following blog post in a concise manner:\n\n${widget.blogBody}');

      setState(() {
        if (result != null && result.content != null) {
          summary = result.content!.parts?.firstOrNull?.text ?? 'No summary content.';
          // Split the summary into chunks once we have it
          textChunks = _splitTextIntoChunks(summary);
        } else {
          summary = 'Unable to generate summary.';
          textChunks = [summary]; // Single chunk for error message
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        summary = 'Error generating summary: $e';
        textChunks = [summary]; // Single chunk for error message
        isLoading = false;
      });
    }
  }

  Future<void> speak() async {
    if (!isInitialized) return;

    if (isSpeaking) {
      await flutterTts.stop();
      setState(() {
        isSpeaking = false;
        currentChunk = 0;
      });
    } else {
      setState(() {
        isSpeaking = true;
        currentChunk = 0;
      });
      try {
        await _speakCurrentChunk();
      } catch (e) {
        print("Error occurred during speech: $e");
        setState(() {
          isSpeaking = false;
          currentChunk = 0;
        });
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
            icon: Icon(
              isSpeaking ? Icons.stop_circle : Icons.volume_up,
              color: Colors.white, // Or your theme color
            ),
            tooltip: isSpeaking ? 'Stop Reading' : 'Read Summary',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
          child: Center(
            child: isLoading
                ? const CircularProgressIndicator()
                : SelectableText( // Changed to SelectableText for better user experience
                    summary,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
          ),
        ),
      ),
    );
  }
}