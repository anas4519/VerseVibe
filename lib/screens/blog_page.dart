import 'dart:convert';

import 'package:blogs_app/constants/constants.dart';
import 'package:blogs_app/providers/user_provider.dart';
import 'package:blogs_app/screens/blog_Summary.dart';
import 'package:blogs_app/services/api_services.dart';
import 'package:blogs_app/utils/utils.dart';
import 'package:blogs_app/widgets/comment_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BlogPage extends StatefulWidget {
  const BlogPage(
      {super.key,
      required this.body,
      required this.coverImage,
      required this.author,
      required this.date,
      required this.title,
      required this.blog_id,
      required this.authorImage});
  final String body;
  final String coverImage;
  final String author;
  final DateTime date;
  final String title;
  final String blog_id;
  final String authorImage;

  @override
  State<BlogPage> createState() => _BlogPageState();
}

var isLiked = false;
var isSaved = false;

class _BlogPageState extends State<BlogPage> {
  final TextEditingController _commentController = TextEditingController();
  List<dynamic> _comments = [];
  final FlutterTts flutterTts = FlutterTts();
  bool isSpeaking = false;
  bool isInitialized = false;

  int currentChunk = 0;
  List<String> textChunks = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarkStatus();
    _fetchAndSetComments();
    ApiService();
    initTts();
    textChunks = _splitTextIntoChunks(widget.body);
  }

  List<String> _splitTextIntoChunks(String text) {
    List<String> chunks = [];
    // Split by sentences (roughly) and combine into ~1000 character chunks
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
        currentChunk++;
        _speakCurrentChunk();
      } else {
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

  Future<void> _fetchAndSetComments() async {
    final comments = await ApiService().fetchComments(widget.blog_id);
    setState(() {
      _comments = comments;
    });
  }

  Future<void> postComment(String content) async {
    final String url = '${Constants.url}blogs/comment/${widget.blog_id}';
    final String userId =
        Provider.of<UserProvider>(context, listen: false).user.id;
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'content': content,
          'createdBy': userId,
        }),
      );

      if (response.statusCode == 200) {
        showSnackBar(context, 'Comment posted Successfuly!');
      } else {
        showSnackBar(context,
            'Failed to post comment. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error posting comment: $e');
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _loadBookmarkStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> bookmarkedBlogs = prefs.getStringList('bookmarkedBlogs') ?? [];
    setState(() {
      isSaved = bookmarkedBlogs.contains(widget.blog_id);
    });
  }

  Future<void> _toggleBookmark() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> bookmarkedBlogs = prefs.getStringList('bookmarkedBlogs') ?? [];

    if (isSaved) {
      // Remove from bookmarks
      bookmarkedBlogs.remove(widget.blog_id);
    } else {
      // Add to bookmarks
      bookmarkedBlogs.add(widget.blog_id);
    }

    await prefs.setStringList('bookmarkedBlogs', bookmarkedBlogs);
    setState(() {
      isSaved = !isSaved;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final user = Provider.of<UserProvider>(context, listen: false).user;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: Constants.yellow,
            ),
            onPressed: () {
              // Handle bookmark button press
              _toggleBookmark();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: screenHeight * 0.3,
                  width: screenWidth * 0.9,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                        screenWidth * 0.04), // Apply the same borderRadius
                    child: CachedNetworkImage(
                      imageUrl: widget.coverImage,
                      fit: BoxFit
                          .cover, // Ensures the image covers the container properly
                      errorWidget: (context, url, error) => Icon(
                        Icons.image,
                        color: Constants.yellow,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: screenHeight * 0.01,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Posted on : ${DateFormat("MMM d, yyyy").format(widget.date)}',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.02,
              ),
              Text(
                widget.title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24),
              ),
              // SizedBox(
              //   height: screenHeight * 0.02,
              // ),
              Row(
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: Constants.bg,
                    backgroundImage: widget.authorImage.isNotEmpty
                        ? CachedNetworkImageProvider(widget.authorImage)
                        : null,
                    child: widget.authorImage.isEmpty
                        ? const Icon(
                            Icons.person,
                            size: 20,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  SizedBox(
                    width: screenWidth * 0.02,
                  ),
                  Text(
                    'By : ${widget.author}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      IconButton(
                        onPressed: speak,
                        icon: Icon(
                          isSpeaking ? Icons.stop_circle : Icons.volume_up,
                        ),
                        tooltip: isSpeaking ? 'Stop Reading' : 'Read Blog',
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (ctx) => BlogSummary(
                                    blogBody: widget.body,
                                  )));
                        },
                        icon: const Icon(Icons.smart_toy_outlined),
                        tooltip: 'Summarize',
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: screenHeight * 0.02,
              ),
              SelectableText(
                widget.body,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 16),
              ),
              SizedBox(
                height: screenHeight * 0.04,
              ),
              Text(
                'Comments (${_comments.length})',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: screenHeight * 0.02,
              ),

              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Constants.yellow,
                    backgroundImage: user.profileImageURL != null
                        ? CachedNetworkImageProvider(user.profileImageURL!)
                        : null,
                    child: user.profileImageURL == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  SizedBox(
                    width: screenWidth * 0.02,
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _commentController,
                      cursorColor: Constants.yellow,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Add a comment ...',
                        hintStyle: const TextStyle(color: Colors.white),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.015,
                          horizontal: screenWidth * 0.04,
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.zero, // Rectangular shape
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Constants.yellow, width: 2.0),
                          borderRadius: BorderRadius.circular(
                              screenWidth * 0.04), // Rectangular shape
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Constants.yellow, width: 2.0),
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.04),
                          // Rectangular shape
                        ),
                      ),
                      minLines: 1,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      // validator: (value) {
                      //   if (value == null || value.isEmpty) {
                      //     return 'Please enter your email';
                      //   }
                      //   return null;
                      // },
                    ),
                  ),
                  SizedBox(
                    width: screenWidth * 0.02,
                  ),
                  Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Constants.yellow),
                    child: IconButton(
                        onPressed: () async {
                          if (_commentController.text.isNotEmpty) {
                            await postComment(_commentController.text);
                            setState(() {
                              _fetchAndSetComments();
                            });
                          }
                          FocusScope.of(context).unfocus();
                          _commentController.clear();
                        },
                        icon: Icon(
                          Icons.arrow_upward_rounded,
                          color: Constants.bg,
                          size: 15,
                        )),
                  )
                ],
              ),
              SizedBox(
                height: screenHeight * 0.02,
              ),
              ListView.builder(
                shrinkWrap:
                    true, // Important to ensure ListView doesn't scroll independently
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  final comment = _comments[index];
                  final createdBy = comment['createdBy'] ?? {}; // Handle null
                  final name = createdBy['fullName'] ??
                      'Unknown'; // Provide a default name
                  final image = createdBy['profileImageURL'] ?? '';
                  return Column(
                    children: [
                      CommentCard(
                          body:
                              comment['content'] ?? 'No content', // Handle null
                          name: name,
                          image: image),
                      SizedBox(
                        height: screenHeight * 0.02,
                      )
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
