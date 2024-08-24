import 'package:blogs_app/constants/constants.dart';
import 'package:flutter/material.dart';

class CommentCard extends StatelessWidget {
  const CommentCard({super.key, required this.body, required this.name});
  final String body;
  final String name;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Constants.yellow,
          radius: 30,
          child: const Icon(
            Icons.person,
            size: 35,
          ),
        ),
        SizedBox(width: screenWidth*0.03,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),),
            SizedBox(height: screenHeight*0.005,),
            Text(body, style: const TextStyle(color: Colors.white, fontSize: 18)),
          ],
        )
      ],
    );
  }
}
