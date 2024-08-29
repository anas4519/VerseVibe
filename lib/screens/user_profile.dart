import 'package:blogs_app/constants/constants.dart';
import 'package:blogs_app/models/user.dart';
import 'package:blogs_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: (){}, icon: const Icon(Icons.settings))
        ],
      ),
      body:  SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth*0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(Provider.of<UserProvider>(context, listen: false).user.name, style: const TextStyle(color: Colors.white, fontSize: 18),),
                      Text(Provider.of<UserProvider>(context, listen: false).user.email, style: const TextStyle(color: Colors.white, fontSize: 8),),
                      Text('User id : ${Provider.of<UserProvider>(context, listen: false).user.id}', style: const TextStyle(color: Colors.white, fontSize: 8))
                    ],
                  ),
                  const Spacer(),
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Constants.yellow,
                    child: const Icon(Icons.person),
                  )
                ],
              )
            ],
          ),
        ),
      ),

    );
  }
}