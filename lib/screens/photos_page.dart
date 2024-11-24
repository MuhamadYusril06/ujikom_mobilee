import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/photo.dart' as photo;
import '../models/comment.dart';
import '../models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/login_page.dart';

class PhotosPage extends StatefulWidget {
  final int galleryId;
  final User? currentUser;

  const PhotosPage({
    Key? key, 
    required this.galleryId,
    this.currentUser,
  }) : super(key: key);

  @override
  _PhotosPageState createState() => _PhotosPageState();
}

class _PhotosPageState extends State<PhotosPage> {
  final TextEditingController _commentController = TextEditingController();

  Future<List<photo.Photo>> fetchPhotos() async {
    final response = await http.get(
      Uri.parse('https://ujikom2024pplg.smkn4bogor.sch.id/0074198522/ujikom_api/public/api/galleries/${widget.galleryId}')
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        List<dynamic> photos = jsonResponse['data']['photos'];
        return photos.map((p) => photo.Photo.fromJson(p)).toList();
      } else {
        throw Exception('Failed to load photos');
      }
    } else {
      throw Exception('Failed to load photos');
    }
  }

  Future<List<Comment>> fetchComments(int photoId) async {
    final response = await http.get(
      Uri.parse('https://ujikom2024pplg.smkn4bogor.sch.id/0074198522/ujikom_api/public/api/comments')
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      List<dynamic> allComments = jsonResponse['data'];
      
      // Filter komentar berdasarkan photo_id
      List<Comment> photoComments = allComments
          .where((comment) => comment['attributes']['photo']['id'] == photoId)
          .map((comment) => Comment.fromJson(comment))
          .toList();
      
      return photoComments;
    } else {
      throw Exception('Failed to load comments');
    }
  }

  Future<void> _addComment(String content, int photoId) async {
    if (content.isEmpty || widget.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Silakan login terlebih dahulu untuk mengirim komentar')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://ujikom2024pplg.smkn4bogor.sch.id/0074198522/ujikom_api/public/api/comments'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'content': content,
          'photo_id': photoId,
          'user_id': widget.currentUser!.id,
        }),
      );

      if (response.statusCode == 201) {
        // Bersihkan input dan refresh komentar
        setState(() {
          _commentController.clear();
        });
        
        // Tampilkan pesan sukses
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Komentar berhasil ditambahkan')),
        );

        // Refresh daftar komentar
        setState(() {
          fetchComments(photoId);
        });
      } else {
        // Parse error message dari response
        Map<String, dynamic> errorResponse = json.decode(response.body);
        String errorMessage = errorResponse['message'] ?? 'Gagal menambahkan komentar';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  // Tambahkan fungsi untuk menghapus komentar
  Future<void> _deleteComment(int commentId) async {
    try {
      print('Mencoba menghapus komentar dengan ID: $commentId');
      print('User yang login: ${widget.currentUser?.id}');

      // Ambil token dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token'); // Pastikan token disimpan saat login

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Silakan login ulang')),
        );
        return;
      }

      final response = await http.delete(
        Uri.parse('https://ujikom2024pplg.smkn4bogor.sch.id/0074198522/ujikom_api/public/api/comments/$commentId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token', // Tambahkan token ke header
        },
      );

      print('Status response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Komentar berhasil dihapus')),
        );
        // Refresh komentar setelah berhasil dihapus
        setState(() {});
      } else {
        Map<String, dynamic> errorResponse = json.decode(response.body);
        String errorMessage = errorResponse['message'] ?? 'Gagal menghapus komentar';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      print('Error saat menghapus komentar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  // Fungsi untuk menampilkan dialog konfirmasi hapus
  void _showDeleteConfirmation(int commentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hapus Komentar'),
          content: Text('Apakah Anda yakin ingin menghapus komentar ini?'),
          actions: <Widget>[
            TextButton(
              child: Text('Batal', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteComment(commentId);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gallery Photos'),
      ),
      body: FutureBuilder<List<photo.Photo>>(
        future: fetchPhotos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data?.isEmpty ?? true) {
            return Center(child: Text('No photos in this gallery'));
          } else {
            final photos = snapshot.data ?? [];
            return ListView.builder(
              itemCount: photos.length,
              itemBuilder: (context, index) {
                final photo = photos[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        photo.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: Center(child: Icon(Icons.error)),
                          );
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              photo.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(photo.description),
                            SizedBox(height: 16),
                            Text(
                              'Komentar:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            FutureBuilder<List<Comment>>(
                              future: fetchComments(photo.id),
                              builder: (context, commentSnapshot) {
                                if (commentSnapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                } else if (commentSnapshot.hasError) {
                                  return Text('Error: ${commentSnapshot.error}');
                                } else {
                                  final comments = commentSnapshot.data ?? [];
                                  return Column(
                                    children: [
                                      ...comments.map((comment) => ListTile(
                                        title: Text(comment.content),
                                        subtitle: Text('${comment.userName} - ${comment.createdAt}'),
                                        trailing: widget.currentUser != null && widget.currentUser!.id == comment.userId
                                            ? IconButton(
                                                icon: Icon(Icons.delete, color: Colors.red),
                                                onPressed: () {
                                                  print('User ID dari komentar: ${comment.userId}'); // Debug print
                                                  print('User ID yang login: ${widget.currentUser?.id}'); // Debug print
                                                  _showDeleteConfirmation(comment.id);
                                                },
                                              )
                                            : null,
                                      )).toList(),
                                      if (widget.currentUser != null)
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              TextField(
                                                controller: _commentController,
                                                decoration: InputDecoration(
                                                  hintText: 'Tulis komentar Anda...',
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8.0),
                                                  ),
                                                  suffixIcon: IconButton(
                                                    icon: Icon(Icons.send),
                                                    onPressed: () {
                                                      if (_commentController.text.isNotEmpty) {
                                                        _addComment(_commentController.text, photo.id);
                                                      }
                                                    },
                                                  ),
                                                ),
                                                maxLines: 3,
                                                minLines: 1,
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'Tekan ikon kirim untuk mengirim komentar',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      else
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: TextButton(
                                            onPressed: () {
                                              // Navigasi ke halaman login
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => LoginPage(
                                                    onLoginSuccess: (user) {
                                                      Navigator.pop(context);
                                                      setState(() {});
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              'Login untuk mengirim komentar',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}