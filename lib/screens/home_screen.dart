import 'package:blogs_app/services/api_services.dart';
import 'package:blogs_app/widgets/blog.dart';
import 'package:flutter/material.dart';
import 'package:blogs_app/constants/constants.dart';
import 'package:blogs_app/screens/new_blog.dart';
import 'package:blogs_app/services/auth_service.dart';
import 'package:blogs_app/models/blog_model.dart'; // Ensure this import is correct // Ensure this import is correct

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void signOut(BuildContext context) {
      AuthService().signOut(context);
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
            bottom: screenHeight * 0.05, right: screenWidth * 0.03),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (ctx) => NewBlog()));
          },
          backgroundColor: Constants.yellow,
          shape: const CircleBorder(),
          child: const Icon(Icons.add),
        ),
      ),
      appBar: AppBar(
        title: const Text(
          'VibeVerse',
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
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Constants.bg,
        child: Center(
          child: IconButton(
            onPressed: () => signOut(context),
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ),
      ),
      body: SingleChildScrollView(
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
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: Text(
                    'No blogs available.',
                    style: TextStyle(color: Colors.white),
                  ));
                } else {
                  final blogs = snapshot.data!;
                  return SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.06),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: blogs.map((blog) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BlogCard(
                                coverImage: Image.network(
                                    'http://192.168.1.5:8000/images${blog.coverImage}'),
                                author: blog.author,
                                date: blog.date,
                                profileImage: Image.asset('name'),
                                title: blog.title,
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
  }
}
