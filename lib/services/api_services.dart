
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/blog_model.dart';

class ApiService {
  final String baseUrl = 'http://192.168.1.5:8000'; // Your API base URL

  Future<List<Blog>> fetchBlogs() async {
    final response = await http.get(Uri.parse('$baseUrl/blogs'));
    print(jsonDecode(response.body));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Blog.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load blogs');
    }
  }
}
