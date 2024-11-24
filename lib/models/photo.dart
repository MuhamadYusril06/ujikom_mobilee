class Photo {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final List<Comment> comments;

  Photo({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.comments,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    List<Comment> commentList = [];
    if (json['comments'] != null) {
      commentList = (json['comments'] as List).map((comment) => Comment.fromJson(comment)).toList();
    }
    return Photo(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['image_url'],
      comments: commentList,
    );
  }
}

class Comment {
  final int id;
  final String content;

  Comment({
    required this.id,
    required this.content,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      content: json['content'],
    );
  }
} 