import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Webtoon Application',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WebtoonList(),
    );
  }
}

class WebtoonList extends StatefulWidget {
  @override
  _WebtoonListState createState() => _WebtoonListState();
}

class _WebtoonListState extends State<WebtoonList> {
  List<Map<String, dynamic>> _webtoons = [];

  @override
  void initState() {
    super.initState();
    _loadWebtoons();
  }

  _loadWebtoons() async {
    final prefs = await SharedPreferences.getInstance();
    final webtoonsJson = prefs.getString('webtoons');
    if (webtoonsJson != null) {
      setState(() {
        _webtoons = List<Map<String, dynamic>>.from(json.decode(webtoonsJson));
      });
    } else {
      // Load webtoons from local file or asset
    }
  }

  _toggleRead(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final webtoonsJson = prefs.getString('webtoons');
    if (webtoonsJson != null) {
      final webtoons =
          List<Map<String, dynamic>>.from(json.decode(webtoonsJson));
      final webtoon = webtoons[index];
      webtoons[index] = {
        'id': webtoon['id'],
        'title': webtoon['title'],
        'read': webtoon['read'] == 0 ? 1 : 0,
      };
      prefs.setString('webtoons', json.encode(webtoons));
      _loadWebtoons();
    } else {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Webtoon List'),
      ),
      body: ListView.builder(
        itemCount: _webtoons.length,
        itemBuilder: (context, index) {
          final webtoon = _webtoons[index];
          return ListTile(
            title: Text(webtoon['title']),
            trailing: Icon(
              webtoon['read'] == 0 ? Icons.bookmark_border : Icons.bookmark,
              color: webtoon['read'] == 0 ? null : Colors.red,
            ),
            onTap: () => _toggleRead(index),
          );
        },
      ),
    );
  }
}
