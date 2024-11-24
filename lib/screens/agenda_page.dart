import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';

class AgendaPage extends StatelessWidget {
  final User? user;

  const AgendaPage({Key? key, required this.user}) : super(key: key);

  Future<List<Map<String, dynamic>>> fetchAgendas() async {
    final response = await http.get(Uri.parse('https://ujikom2024pplg.smkn4bogor.sch.id/0074198522/ujikom_api/public/api/agendas'));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse.containsKey('data')) {
        List<dynamic> data = jsonResponse['data'];
        return data.map((agenda) => {
          'id': agenda['id'],
          'title': agenda['title'],
          'description': agenda['description'],
          'event_date': agenda['event_date'],
        }).toList();
      } else {
        throw Exception('Failed to load agendas');
      }
    } else {
      throw Exception('Failed to load agendas');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agenda'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchAgendas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final agendas = snapshot.data ?? [];
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: agendas.length,
              itemBuilder: (context, index) {
                final agenda = agendas[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 5,
                  child: ListTile(
                    leading: Icon(Icons.event, color: Colors.blue),
                    title: Text(agenda['title']),
                    subtitle: Text(agenda['description']),
                    trailing: Text(_formatDate(agenda['event_date'])),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  String _formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return "${parsedDate.day}-${parsedDate.month}-${parsedDate.year}";
  }
} 