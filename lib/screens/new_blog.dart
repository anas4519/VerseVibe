import 'dart:io';
import 'package:blogs_app/providers/user_provider.dart';
import 'package:blogs_app/screens/home_screen.dart';
import 'package:blogs_app/utils/utils.dart';
import 'package:blogs_app/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class NewBlog extends StatefulWidget {
  const NewBlog({super.key});

  @override
  State<NewBlog> createState() => _NewBlogState();
}

class _NewBlogState extends State<NewBlog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  Future<void> postData(
      String title, String body, XFile image, BuildContext context) async {
    showLoadingDialog(context, 'Posting Blog...');
    final url =
        Uri.parse('${Constants.url}blogs/'); // Replace with your actual URL

    try {
      var request = http.MultipartRequest('POST', url);
      var user = Provider.of<UserProvider>(context, listen: false).user;
      // Add text fields to the request
      request.fields['title'] = title;
      request.fields['body'] = body;
      request.fields['user_id'] = user.id;

      // Add the image file to the request
      var stream = http.ByteStream(image.openRead());
      stream.cast();
      var multipartFile =
          await http.MultipartFile.fromPath("coverImage", image.path);
      request.files.add(multipartFile);

      // Send the request
      var response = await request.send();

      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        showSnackBar(context, 'Blog posted successfully!');
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (ctx) => const HomeScreen()),
            (route) => false);
      } else {
        showSnackBar(context,
            'Failed to post blog. Status code: ${response.statusCode}');
      }
    } catch (e) {
      showSnackBar(context, 'Error: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  void _deleteImage() {
    setState(() {
      _imageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Blog'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Container(
                  height: screenHeight * 0.4,
                  decoration: BoxDecoration(
                    border: Border.all(color: Constants.yellow),
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                  child: TextFormField(
                    controller: _bodyController,
                    cursorColor: Constants.yellow,
                    maxLines: null,
                    style: const TextStyle(color: Colors.white),
                    expands: true,
                    decoration: const InputDecoration(
                      fillColor: Colors.white,
                      border: InputBorder.none,
                      hintText: 'Start Typing...',
                      hintStyle: TextStyle(color: Colors.white),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the body content';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Container(
                  height: screenHeight * 0.2,
                  decoration: BoxDecoration(
                    border: Border.all(color: Constants.yellow),
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                    // color: Colors.grey[200],
                  ),
                  child: Center(
                    child: _imageFile == null
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.image,
                                    size: 50, color: Constants.yellow),
                                onPressed: _pickImage,
                              ),
                              Text('Upload Cover Image',
                                  style: TextStyle(color: Constants.yellow)),
                            ],
                          )
                        : Stack(
                            children: [
                              Positioned.fill(
                                child: Image.file(
                                  File(_imageFile!.path),
                                  fit: BoxFit.contain,
                                ),
                              ),
                              Positioned(
                                right: 10,
                                top: 10,
                                child: IconButton(
                                  icon: const Icon(Icons.delete_sharp,
                                      color: Colors.red),
                                  onPressed: _deleteImage,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Center(
                  child: TextButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        if (_imageFile != null) {
                          postData(_titleController.text, _bodyController.text,
                              _imageFile!, context);
                        }
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all<Color>(Constants.yellow),
                      foregroundColor:
                          WidgetStateProperty.all<Color>(Constants.bg),
                    ),
                    child: const Text('Post'),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
