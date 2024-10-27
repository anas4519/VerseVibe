import 'package:blogs_app/providers/user_provider.dart';
import 'package:blogs_app/screens/user_profile.dart';
import 'package:blogs_app/services/api_services.dart';
import 'package:blogs_app/utils/utils.dart';
import 'package:blogs_app/widgets/blog.dart';
import 'package:blogs_app/widgets/drawer_child.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:blogs_app/constants/constants.dart';
import 'package:blogs_app/screens/new_blog.dart';
import 'package:blogs_app/models/blog_model.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    final user = Provider.of<UserProvider>(context, listen: false).user;

    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
            bottom: screenHeight * 0.05, right: screenWidth * 0.03),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (ctx) => const NewBlog()));
          },
          backgroundColor: Constants.yellow,
          shape: const CircleBorder(),
          child: const Icon(Icons.add),
        ),
      ),
      appBar: AppBar(
        title: const Text(
          'VerseVibe',
          style: TextStyle(
              color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Constants.bg,
        leading: IconButton(
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          icon: const Icon(Icons.notes_sharp),
          color: Colors.white,
        ),
        actions: [
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.02),
            child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const UserProfile()));
                },
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
          )
        ],
      ),
      drawer: Drawer(
        backgroundColor: Constants.bg,
        child: const DrawerChild(),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return RefreshIndicator(
          onRefresh: _refresh,
          color: Constants.yellow,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Explore',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      )),
                ),
                FutureBuilder<List<Blog>>(
                  future: ApiService()
                      .fetchBlogs(), // Ensure this returns Future<List<Blog>>
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
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: blogs.map((blog) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  BlogCard(
                                    coverImage: blog.coverImage,
                                    author: blog.author,
                                    date: blog.date,
                                    profileImage: blog.profileImage,
                                    title: blog.title,
                                    body: blog.body,
                                    id: blog.id,
                                    selfBlog: false,
                                    onDelete: () {
                                      setState(() {});
                                    },
                                    onEdited: () {
                                      showSnackBar(
                                          context, 'Blog added to Favourites!');
                                    },
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
          ),
        );
      }),
    );
  }
}
