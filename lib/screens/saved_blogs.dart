import 'package:blogs_app/constants/constants.dart';
import 'package:blogs_app/widgets/blog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SavedBlogs extends StatefulWidget {
  const SavedBlogs({super.key});

  @override
  State<SavedBlogs> createState() => _SavedBlogsState();
}

class _SavedBlogsState extends State<SavedBlogs> {
  List<Map<String, dynamic>> savedBlogs = [];
  bool _isLoading = true; // Track the loading state

  @override
  void initState() {
    super.initState();
    _loadSavedBlogs();
  }

  Future<void> _loadSavedBlogs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedBlogIds = prefs.getStringList('bookmarkedBlogs');
    if (savedBlogIds != null && savedBlogIds.isNotEmpty) {
      await _fetchBlogsByIds(savedBlogIds);
    }
    setState(() {
      _isLoading = false; // Loading complete
    });
  }

  Future<void> _fetchBlogsByIds(List<String> blogIds) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.url}blogs/getBlogsByIds'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"ids": blogIds}),
      );
      if (response.statusCode == 200) {
        final List<dynamic> blogDataList = json.decode(response.body);
        print(blogDataList);
        setState(() {
          savedBlogs = blogDataList.cast<Map<String, dynamic>>();
        });
      } else {
        print('Failed to load blogs.');
      }
    } catch (e) {
      print('Error fetching blogs: $e');
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _isLoading = true; // Set loading to true when refreshing
      savedBlogs.clear();
    });
    await _loadSavedBlogs();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Blogs'),
        centerTitle: true,
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        // Show circular progress indicator while loading
        if (_isLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: Constants.yellow,
            ),
          );
        }

        if (savedBlogs.isEmpty) {
          return Center(
            child: Text(
              'You have not saved any blogs yet.',
              style: TextStyle(color: Constants.yellow),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          color: Constants.yellow,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              children: savedBlogs.map((blog) {
                return Column(
                  children: [
                    BlogCard(
                      coverImage:
                          '${Constants.imageurl}/images${blog['coverImageURL']}',
                      author: blog['createdBy'],
                      date: DateTime.parse(blog['createdAt']),
                      profileImage:
                          Image.asset('name'), // Adjust this based on your backend
                      title: blog['title'],
                      body: blog['body'],
                      id: blog['_id'],
                      selfBlog: false,
                      onDelete: () {},
                      onEdited: () {
                        setState(() {});
                        
                      },
                    ),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      }),
    );
  }
}
