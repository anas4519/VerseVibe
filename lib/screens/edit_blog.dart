import 'package:blogs_app/constants/constants.dart';
import 'package:blogs_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditBlog extends StatefulWidget {
  final String title;
  final String body;
  final String blogId;
  final VoidCallback onSaved;

  const EditBlog(
      {super.key,
      required this.title,
      required this.body,
      required this.blogId,
      required this.onSaved});

  @override
  _EditBlogState createState() => _EditBlogState();
}

class _EditBlogState extends State<EditBlog> {
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _bodyController = TextEditingController(text: widget.body);
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _updateBlog() async {
    final response = await http.patch(
      Uri.parse('${Constants.url}blogs/${widget.blogId}'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'title': _titleController.text,
        'body': _bodyController.text,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      widget.onSaved();
      showSnackBar(context, 'Blog updated successfully!');
    } else {
      showSnackBar(context, 'Failed to update Blog.');
    }
  }

  void _scrollToEnd() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Blog'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                _scrollToEnd();
              },
              icon: const Icon(Icons.arrow_circle_down_sharp))
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          TextFormField(
            controller: _titleController,
            cursorColor: Constants.yellow,
            maxLines: null,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelStyle: const TextStyle(color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
                borderSide: BorderSide(
                  color: Constants.yellow,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
                borderSide: BorderSide(
                  color: Constants.yellow,
                ),
              ),
              labelText: 'Title',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
          ),
          SizedBox(height: screenHeight * 0.02),
          TextFormField(
            controller: _bodyController,
            cursorColor: Constants.yellow,
            maxLines: null,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelStyle: const TextStyle(color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
                borderSide: BorderSide(
                  color: Constants.yellow,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
                borderSide: BorderSide(
                  color: Constants.yellow,
                ),
              ),
              labelText: 'Body',
            ),
          ),
          SizedBox(
            height: screenHeight * 0.02,
          ),
          Center(
            child: TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        'Save Changes',
                        style: TextStyle(color: Constants.yellow),
                      ),
                      backgroundColor: Constants.bg,
                      content: Text(
                        'Make sure you have verified everything before saving.',
                        style: TextStyle(color: Constants.yellow),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // User pressed No
                          },
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Constants.yellow),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _updateBlog(); // Call the update function
                          },
                          child: Text('Save',
                              style: TextStyle(color: Constants.yellow)),
                        ),
                      ],
                    );
                  },
                );
              },
              style: TextButton.styleFrom(backgroundColor: Constants.yellow),
              child: Text(
                'Save Changes',
                style: TextStyle(color: Constants.bg),
              ),
            ),
          )
        ]),
      ),
    );
  }
}
