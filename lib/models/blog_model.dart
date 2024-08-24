
class Blog {
  final String coverImage;
  final String author;
  final DateTime date;
  final String profileImage;
  final String title;
  final String body;
  final String id;

  Blog({
    required this.coverImage,
    required this.author,
    required this.date,
    required this.profileImage,
    required this.title,
    required this.body,
    required this.id
  });

  factory Blog.fromJson(Map<String, dynamic> json) {
    return Blog(
      coverImage: json['coverImageURL'] ?? '',
      author: json['createdBy']['fullName'] ?? '', // Adjust this based on your API response
      date: DateTime.parse(json['createdAt']),
      profileImage: json['profileImage'] ?? '', // Adjust this based on your API response
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      id: json['_id'] ?? ' '
    );
  }
}
