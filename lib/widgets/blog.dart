import 'package:blogs_app/screens/blog_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BlogCard extends StatelessWidget {
  final Image coverImage;
  final String title;
  final Image profileImage;
  final String author;
  final DateTime date;
  final String body;
  final String id;
  // final String body;
  const BlogCard(
      {super.key,
      required this.coverImage,
      required this.author,
      required this.date,
      required this.profileImage,
      required this.title,
      required this.body, required this.id});
  String calculateReadTime(String body) {
    final wordCount = body.split(' ').length;
    final readTime =
        (wordCount / 238).ceil(); // Round up to the nearest whole number
    return 'Read Time: $readTime min';
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => BlogPage(
                  body: body,
                  coverImage: coverImage,
                  author: author,
                  date: date,
                  title: title,
                  blog_id: id,
                )));
      },
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.02),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: screenHeight * 0.25, // Adjust the height as needed
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                    image: DecorationImage(
                      image: coverImage.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 10, // Adjust positioning as needed
                  left: 10, // Adjust positioning as needed
                  child: IconButton(
                    icon: const Icon(
                      Icons.bookmark_border,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      // Handle favorite button press
                    },
                  ),
                ),
                Positioned(
                  top: 10, // Adjust positioning as needed
                  right: 10, // Adjust positioning as needed
                  child: IconButton(
                    icon: const Icon(Icons.share, color: Colors.black),
                    onPressed: () {
                      // Handle share button press
                    },
                  ),
                ),
              ],
            ),
            // SizedBox(
            //   height: screenHeight * 0.02,
            // ),
            const Divider(
              color: Colors.black,
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: screenHeight * 0.01,
            ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/image.png',
                          height: 20,
                          width: 20,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(
                          width: screenWidth * 0.01,
                        ),
                        Text(
                          'By: $author',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: screenHeight * 0.005,
                    ),
                    Text(
                      calculateReadTime(body),
                      style: const TextStyle(
                          fontSize: 10,
                          color: Colors.green,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                const Spacer(),
                Text(
                  DateFormat("MMM d, yyyy").format(date),
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
