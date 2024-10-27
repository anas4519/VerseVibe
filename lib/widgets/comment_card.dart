import 'package:blogs_app/constants/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CommentCard extends StatelessWidget {
  const CommentCard(
      {super.key, required this.body, required this.name, required this.image});
  final String body;
  final String name;
  final String image;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Aligns content at the top
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Constants.yellow,
          backgroundImage:
              image.isNotEmpty ? CachedNetworkImageProvider(image) : null,
          child: image.isEmpty
              ? const Icon(
                  Icons.person,
                  size: 30,
                  color: Colors.black,
                )
              : null,
        ),
        SizedBox(width: screenWidth * 0.03),
        Expanded(
          // Allows the Column to take up the remaining space
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: screenHeight * 0.005),
              Text(
                body,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                maxLines: null, // Allows the text to wrap to multiple lines
                overflow:
                    TextOverflow.visible, // Ensures it doesn’t get cut off
              ),
            ],
          ),
        ),
      ],
    );
  }
}
