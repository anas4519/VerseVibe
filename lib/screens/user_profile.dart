import 'dart:convert';
import 'dart:io';
import 'package:blogs_app/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:blogs_app/constants/constants.dart';
import 'package:blogs_app/models/blog_model.dart';
import 'package:blogs_app/providers/user_provider.dart';
import 'package:blogs_app/services/api_services.dart';
import 'package:blogs_app/widgets/blog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAndUploadImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final File imageFile = File(pickedFile.path);

    try {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
            '${Constants.uri}upload-profile-image/${user.id}'), // Update URL as needed
      );

      request.files.add(
          await http.MultipartFile.fromPath('profileImage', imageFile.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await http.Response.fromStream(response);
        final responseJson = jsonDecode(responseData.body);
        // Update user provider with new profile image URL
        Provider.of<UserProvider>(context, listen: false).user.imageUrl =
            (responseJson['imageUrl']);
        showSnackBar(context, 'Profile image updated successfully');
      } else {
        showSnackBar(context, 'Failed to upload image');
      }
    } catch (e) {
      showSnackBar(context, 'Error: $e');
    }
  }

  void _viewFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Scaffold(
        body: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Center(
            child: Hero(
              tag: 'profileImage',
              child: Image.network(
                '${Constants.url}$imageUrl',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final user = Provider.of<UserProvider>(context, listen: false).user;
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.settings))
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18),
                            ),
                            Text(
                              user.email,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 8),
                            ),
                            Text('User id : ${user.id}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 8))
                          ],
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: user.imageUrl != null
                              ? () =>
                                  _viewFullScreenImage(context, user.imageUrl!)
                              : null,
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: Constants.yellow,
                            backgroundImage: user.imageUrl != null
                                ? NetworkImage(
                                    '${Constants.url}${user.imageUrl!}')
                                : null,
                            child: user.imageUrl == null
                                ? IconButton(
                                    icon: const Icon(Icons.camera_alt_outlined),
                                    onPressed: _pickAndUploadImage,
                                  )
                                : null,
                          ),
                        )
                      ],
                    ),
                    // SizedBox(height: screenHeight*0.04,),
                    // const Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //   children: [
                    //     const Text('35.2 Blogs', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),),
                    //     const Text('158 Likes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),),
                    //     const Text('12.5 Comments', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),),

                    //   ],
                    // ),
                    SizedBox(
                      height: screenHeight * 0.01,
                    ),
                    const Divider(
                      color: Colors.grey,
                    ),
                    const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Your Blogs',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        )),
                  ],
                ),
              ),
              FutureBuilder<List<Blog>>(
                future: ApiService().fetchUserBlogs(
                  Provider.of<UserProvider>(context, listen: false).user.id,
                ), // Ensure this returns Future<List<Blog>>
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator(
                      color: Constants.yellow,
                    ));
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text(
                      'No blogs available.',
                      style: TextStyle(color: Colors.white),
                    ));
                  } else {
                    final blogs = snapshot.data!;
                    return SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: screenWidth * 0.04,
                            right: screenWidth * 0.04),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: blogs.map((blog) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                BlogCard(
                                  coverImage: Image.network(
                                      '${Constants.url}images${blog.coverImage}'),
                                  author: blog.author,
                                  date: blog.date,
                                  profileImage: Image.asset('name'),
                                  title: blog.title,
                                  body: blog.body,
                                  id: blog.id,
                                ),
                                SizedBox(height: screenHeight * 0.02),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ));
  }
}
