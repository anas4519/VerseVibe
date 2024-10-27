import 'package:blogs_app/constants/constants.dart';
import 'package:blogs_app/screens/blog_page.dart';
import 'package:blogs_app/screens/edit_blog.dart';
import 'package:blogs_app/utils/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BlogCard extends StatefulWidget {
  final String coverImage;
  final String title;
  final String profileImage;
  final String author;
  final DateTime date;
  final String body;
  final String id;
  final bool selfBlog;
  final VoidCallback onDelete;
  final VoidCallback onEdited;

  const BlogCard({
    super.key,
    required this.coverImage,
    required this.author,
    required this.date,
    required this.profileImage,
    required this.title,
    required this.body,
    required this.id,
    required this.selfBlog,
    required this.onDelete,
    required this.onEdited,
  });

  @override
  State<BlogCard> createState() => _BlogCardState();
}

class _BlogCardState extends State<BlogCard> {
  bool isSaved = false;

  @override
  void initState() {
    super.initState();
    _loadBookmarkStatus();
  }

  Future<void> _loadBookmarkStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> bookmarkedBlogs = prefs.getStringList('bookmarkedBlogs') ?? [];
    setState(() {
      isSaved = bookmarkedBlogs.contains(widget.id);
    });
  }

  Future<void> _toggleBookmark() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> bookmarkedBlogs = prefs.getStringList('bookmarkedBlogs') ?? [];

    if (isSaved) {
      // Remove from bookmarks
      bookmarkedBlogs.remove(widget.id);
    } else {
      // Add to bookmarks
      bookmarkedBlogs.add(widget.id);
    }

    await prefs.setStringList('bookmarkedBlogs', bookmarkedBlogs);
    setState(() {
      isSaved = !isSaved;
    });
  }

  String calculateReadTime(String body) {
    final wordCount = body.split(' ').length;
    final readTime =
        (wordCount / 238).ceil(); // Round up to the nearest whole number
    return 'Read Time: $readTime min';
  }

  Future<void> _deleteBlog(String id, BuildContext context) async {
    final response = await http.delete(
      Uri.parse('${Constants.url}blogs/$id'), // Adjust the URL as needed
    );

    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? bookmarkedBlogs =
          prefs.getStringList('bookmarkedBlogs') ?? [];
      if (bookmarkedBlogs.contains(id)) {
        bookmarkedBlogs.remove(id);
        await prefs.setStringList('bookmarkedBlogs', bookmarkedBlogs);
      }
      showSnackBar(context, 'Blog deleted successfully!');

      Navigator.of(context).pop();
      widget.onDelete();
    } else {
      // Show an error message
      showSnackBar(context, 'Failed to delete blog.');
    }
  }

  void _showPopupMenu(BuildContext context, RenderBox button) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    // Show the menu with Edit and Delete options
    showMenu(
      context: context,
      position: position,
      items: [
        const PopupMenuItem(
          value: 'edit',
          child: Text('Edit Blog'),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Text('Delete Blog'),
        ),
      ],
    ).then((value) {
      if (value == 'edit') {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => EditBlog(
                  body: widget.body,
                  title: widget.title,
                  blogId: widget.id,
                  onSaved: () {
                    widget.onEdited();
                  },
                )));
      } else if (value == 'delete') {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  'Confirm Deletion',
                  style: TextStyle(color: Constants.yellow),
                ),
                backgroundColor: Constants.bg,
                content: Text('Are you sure you want to delete this blog?',
                    style: TextStyle(color: Constants.yellow)),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // User pressed No
                    },
                    child: Text(
                      'No',
                      style: TextStyle(color: Constants.yellow),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await _deleteBlog(widget.id, context);
                    },
                    child:
                        Text('Yes', style: TextStyle(color: Constants.yellow)),
                  ),
                ],
              );
            });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => BlogPage(
                  body: widget.body,
                  coverImage: widget.coverImage,
                  author: widget.author,
                  date: widget.date,
                  title: widget.title,
                  blog_id: widget.id,
                  authorImage: widget.profileImage,
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                      screenWidth * 0.04), // Apply rounded corners
                  child: Container(
                    width: double.infinity,
                    height: screenHeight * 0.25, // Adjust the height as needed
                    child: CachedNetworkImage(
                      imageUrl: widget.coverImage,
                      fit: BoxFit.cover, // Ensure the image fits the container
                      errorWidget: (context, url, error) => const Icon(
                        Icons.image,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10, // Adjust positioning as needed
                  left: 10, // Adjust positioning as needed
                  child: IconButton(
                    icon: const Icon(
                      Icons.share,
                      color: Colors.black,
                    ),
                    onPressed: () {},
                  ),
                ),
                Positioned(
                  top: 10, // Adjust positioning as needed
                  right: 10, // Adjust positioning as needed
                  child: IconButton(
                    icon: Icon(
                      widget.selfBlog
                          ? Icons.more_vert
                          : (isSaved ? Icons.bookmark : Icons.bookmark_border),
                      color: Colors.black,
                    ),
                    onPressed: () {
                      if (widget.selfBlog) {
                        final RenderBox button =
                            context.findRenderObject() as RenderBox;
                        _showPopupMenu(context, button);
                      } else {
                        _toggleBookmark();
                        widget.onEdited();
                      }
                    },
                  ),
                ),
              ],
            ),
            const Divider(
              color: Colors.black,
            ),
            Text(
              widget.title,
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
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.white,
                          backgroundImage: widget.profileImage.isNotEmpty
                              ? CachedNetworkImageProvider(widget.profileImage)
                              : null,
                          child: widget.profileImage.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  size: 20,
                                  color: Colors.black,
                                )
                              : null,
                        ),
                        SizedBox(
                          width: screenWidth * 0.01,
                        ),
                        Text(
                          'By: ${widget.author}',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: screenHeight * 0.005,
                    ),
                    Text(
                      calculateReadTime(widget.body),
                      style: const TextStyle(
                          fontSize: 10,
                          color: Colors.green,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                const Spacer(),
                Text(
                  DateFormat("MMM d, yyyy").format(widget.date),
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
