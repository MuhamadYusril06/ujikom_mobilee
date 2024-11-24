import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';

class InfoPage extends StatelessWidget {
  final User? user;

  const InfoPage({Key? key, this.user}) : super(key: key);

  Future<List<Map<String, dynamic>>> fetchInfos() async {
    try {
      final response = await http.get(Uri.parse('https://ujikom2024pplg.smkn4bogor.sch.id/0074198522/ujikom_api/public/api/infos'));

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse.containsKey('data')) {
          List<dynamic> data = jsonResponse['data'];
          return data.map((info) => {
            'id': info['id'],
            'title': info['title'],
            'content': info['content'],
          }).toList();
        } else {
          throw Exception('Data tidak ditemukan');
        }
      } else {
        throw Exception('Gagal memuat informasi');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Informasi'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchInfos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final infos = snapshot.data ?? [];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                children: [
                  const Text(
                    'Daftar Informasi',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: infos.length,
                      itemBuilder: (context, index) {
                        final info = infos[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  info['title'] ?? 'Tidak ada judul',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  info['content'] != null ? (info['content'].length > 100 ? info['content'].substring(0, 100) + '...' : info['content']) : 'Tidak ada konten',
                                  style: TextStyle(color: Colors.grey),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Spacer(),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Aksi untuk melihat detail
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.info, color: Colors.white),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}