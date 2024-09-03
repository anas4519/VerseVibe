import 'dart:convert';

class User {
  final String id;
  final String name;
  final String email;
  final String token;
  String? imageUrl;  // Use a String to store the image URL

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'token': token,
      'image': imageUrl,  // Store the image as a URL string
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      token: map['token'] ?? '',
      imageUrl: map['image'],  // Retrieve the image URL string
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}
