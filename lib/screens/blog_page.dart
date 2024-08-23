import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BlogPage extends StatefulWidget {
  const BlogPage(
      {super.key,
      required this.body,
      required this.coverImage,
      required this.author,
      required this.date,
      required this.title});
  final String body;
  final Image coverImage;
  final String author;
  final DateTime date;
  final String title;

  @override
  State<BlogPage> createState() => _BlogPageState();
}

var isLiked = false;
var isSaved = false;

class _BlogPageState extends State<BlogPage> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: () {
            setState(() {
                  isLiked = !isLiked;
                });
          }, icon: isLiked
                  ? const Icon(Icons.favorite, color: Colors.red,)
                  : const Icon(Icons.favorite_border)),
          IconButton(
              onPressed: () {
                setState(() {
                  isSaved = !isSaved;
                });
              },
              icon: isSaved
                  ? const Icon(Icons.bookmark)
                  : const Icon(Icons.bookmark_border))
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
                    image: DecorationImage(
                        image: widget.coverImage.image, fit: BoxFit.cover),
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
                  Image.asset(
                    'assets/image.png',
                    height: 20,
                    width: 20,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(
                    width: screenWidth * 0.02,
                  ),
                  Text(
                    'By : ${widget.author}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  const Spacer(),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.ios_share_rounded)),
                ],
              ),
              SizedBox(
                height: screenHeight * 0.02,
              ),
              Text(
                widget.body,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 16),
              )
            ],
          ),
        ),
      ),
    );
  }
}
