class Comment {
  final int id;
  final String content;
  final String createdAt;
  final String updatedAt;
  final Map<String, dynamic> user;
  final Map<String, dynamic> photo;

  Comment({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.photo,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      content: json['attributes']['content'],
      createdAt: json['attributes']['created_at'],
      updatedAt: json['attributes']['updated_at'],
      user: json['attributes']['user'],
      photo: json['attributes']['photo'],
    );
  }

  String get userName => user['name'] ?? 'Unknown';
  int get userId => int.parse(user['id'].toString());
}