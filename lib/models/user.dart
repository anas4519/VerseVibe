import 'dart:convert';

class User {
  final String id;
  final String name;
  final String email;
  final String token;
  User(
      {required this.id,
      required this.name,
      required this.email,
      required this.token});

  Map<String, dynamic> toMap() {
    return {'name': name, 'email': email, 'token': token};
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      token: map['token'] ?? '',
    );
  }
  String toJson() => json.encode(toMap());
  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}
