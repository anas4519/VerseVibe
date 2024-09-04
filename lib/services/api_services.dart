
import 'dart:convert';
import 'package:blogs_app/constants/constants.dart';
import 'package:http/http.dart' as http;
import '../models/blog_model.dart';

class ApiService {
  final String baseUrl = 'https://versevibe.onrender.com'; // Your API base URL

  Future<List<Blog>> fetchBlogs() async {
    final response = await http.get(Uri.parse('$baseUrl/blogs'));
    
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      
      return data.map((json) => Blog.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load blogs');
    }
  }
  
  Future<List<Blog>> fetchUserBlogs(String userID) async {
    final response = await http.get(Uri.parse('$baseUrl/blogs/user/$userID'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Blog.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load blogs');
    }
  }

  Future<List<dynamic>> fetchComments(String blogId) async {
    final String url = '${Constants.url}blogs/comment/$blogId';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          // Include Authorization header if required
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> comments = jsonDecode(response.body);
        return comments;
      } else {
        print('Failed to fetch comments. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching comments: $e');
      return [];
    }
  }


  
}
