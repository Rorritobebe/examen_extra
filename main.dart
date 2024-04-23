import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Universidades',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: UniversidadListScreen(),
    );
  }
}

class Universidad {
  final String name;
  final String country;
  final String domain;
  final List<String> webPages;

  Universidad({
    required this.name,
    required this.country,
    required this.domain,
    required this.webPages,
  });

  factory Universidad.fromJson(Map<String, dynamic> json) {
    return Universidad(
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      domain: json['domain'] ?? '',
      webPages:
          json['web_pages'] != null ? List<String>.from(json['web_pages']) : [],
    );
  }
}

class ApiService {
  static const String apiUrl =
      'http://universities.hipolabs.com/search?country=mexico';

  static Future<List<Universidad>> fetchUniversidades() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Universidad.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load universities: ${response.statusCode}');
    }
  }
}

class UniversidadListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Universidades')),
      body: FutureBuilder<List<Universidad>>(
        future: ApiService.fetchUniversidades(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data![index].name),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UniversidadDetailScreen(
                          universidad: snapshot.data![index]),
                    ),
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

class UniversidadDetailScreen extends StatelessWidget {
  final Universidad universidad;

  UniversidadDetailScreen({required this.universidad});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(universidad.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('País: ${universidad.country}'),
            Text('Dominio: ${universidad.domain}'),
            Text('Páginas web:'),
            Column(
              children: universidad.webPages.map((url) => Text(url)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
