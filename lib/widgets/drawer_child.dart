import 'package:blogs_app/constants/constants.dart';
import 'package:blogs_app/providers/user_provider.dart';
import 'package:blogs_app/screens/gemini_screen.dart';
import 'package:blogs_app/screens/new_blog.dart';
import 'package:blogs_app/screens/saved_blogs.dart';
import 'package:blogs_app/screens/user_profile.dart';
import 'package:blogs_app/services/auth_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DrawerChild extends StatelessWidget {
  const DrawerChild({super.key});

  @override
  Widget build(BuildContext context) {
    void signOut(BuildContext context) {
      AuthService().signOut(context);
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.height;
    final user = Provider.of<UserProvider>(context, listen: false).user;
    void _viewFullScreenImage(BuildContext context, String imageUrl) {
      print('${Constants.imageurl}$imageUrl');
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Scaffold(
          body: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Center(
              child: Hero(
                tag: 'profileImage',
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
                // child: Image.network(
                //   '${Constants.imageurl}$imageUrl',
                //   fit: BoxFit.contain,
                // ),
              ),
            ),
          ),
        ),
      ));
    }

    return Padding(
      padding: EdgeInsets.only(
          top: screenHeight * 0.1,
          left: screenWidth * 0.02,
          right: screenWidth * 0.02,
          bottom: screenWidth * 0.02),
      child: Column(
        children: [
          GestureDetector(
              onTap: user.profileImageURL != null
                  ? () => _viewFullScreenImage(context, user.profileImageURL!)
                  : null,
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Constants.yellow,
                backgroundImage: user.profileImageURL != null
                    ? CachedNetworkImageProvider(user.profileImageURL!)
                    : null,
                child: user.profileImageURL == null
                    ? const Icon(Icons.person)
                    : null,
              )),
          SizedBox(
            height: screenHeight * 0.01,
          ),
          Text(
            user.name,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          Text(
            user.email,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          SizedBox(
            height: screenHeight * 0.01,
          ),
          const Divider(
            color: Colors.grey,
          ),
          SizedBox(
            height: screenHeight * 0.01,
          ),
          ListTile(
            leading: Icon(
              Icons.home_filled,
              color: Constants.yellow,
            ),
            title: const Text(
              'Home',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            onTap: Navigator.of(context).pop,
          ),
          ListTile(
            leading: Icon(
              Icons.bookmark,
              color: Constants.yellow,
            ),
            title: const Text(
              'Saved Blogs',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => const SavedBlogs()));
            },
          ),
          ListTile(
            leading: Icon(
              Icons.edit,
              color: Constants.yellow,
            ),
            title: const Text(
              'New Blog',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: ((ctx) => const NewBlog())));
            },
          ),
          ListTile(
            leading: Icon(
              Icons.smart_toy_outlined,
              color: Constants.yellow,
            ),
            // leading: Text('AI', style: TextStyle(color: Constants.yellow, fontSize: 18)),
            title: const Text(
              'Write With AI',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: ((ctx) => const GeminiScreen())));
            },
          ),
          ListTile(
            leading: Icon(
              Icons.person,
              color: Constants.yellow,
            ),
            title: const Text(
              'My Account',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: ((ctx) => const UserProfile())));
            },
          ),
          ListTile(
            leading: Icon(
              Icons.logout_rounded,
              color: Constants.yellow,
            ),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            onTap: () => signOut(context),
          ),
        ],
      ),
    );
  }
}
