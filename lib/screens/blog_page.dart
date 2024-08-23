import 'package:blogs_app/constants/constants.dart';
import 'package:blogs_app/utils/utils.dart';
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
          IconButton(
              onPressed: () {
                setState(() {
                  isLiked = !isLiked;
                });
              },
              icon: isLiked
                  ? const Icon(
                      Icons.favorite,
                      color: Colors.red,
                    )
                  : const Icon(Icons.favorite_border)),
          IconButton(
              onPressed: () {
                setState(() {
                  if(!isSaved){
                    showSnackBar(context, 'Blog Added to Favourites!');
                    isSaved = true;
                  } else{
                    showSnackBar(context, 'Blog Removed from Favourites.');
                    isSaved = false;
                  }
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
              ),
              SizedBox(
                height: screenHeight * 0.04,
              ),
              const Text(
                'Comments (0)',
                style: TextStyle(
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
                    backgroundColor: Constants.yellow,
                    radius: 30,
                    child: const Icon(
                      Icons.person,
                      size: 35,
                    ), // Adjust the radius to control the size of the circle
                  ),
                  SizedBox(
                    width: screenWidth * 0.02,
                  ),
                  Expanded(
                    child: TextFormField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Add a comment ...',
                        hintStyle: const TextStyle(color: Colors.white),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.025,
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
                  IconButton(onPressed: (){}, icon: Icon(Icons.file_upload_outlined, color: Constants.yellow, size: 30,))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
