import 'dart:convert';

class User {
  final String id;
  final String name;
  final String email;
  final String token;
  String? profileImageURL;  // Use a String to store the image URL

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    this.profileImageURL,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'token': token,
      'profileImageURL': profileImageURL,  // Store the image as a URL string
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      token: map['token'] ?? '',
      profileImageURL: map['profileImageURL'],  // Retrieve the image URL string
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}
