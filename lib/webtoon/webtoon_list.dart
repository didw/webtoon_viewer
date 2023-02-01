import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'webtoon_content.dart';

class WebtoonList extends StatefulWidget {
  final String title;
  final String path;

  const WebtoonList({
    Key? key,
    required this.title,
    required this.path,
  }) : super(key: key);

  @override
  _WebtoonListState createState() => _WebtoonListState();
}

class _WebtoonListState extends State<WebtoonList> {
  final List<Directory> _directories = [];
  Set<String> _visitedIndices = {};

  @override
  void initState() {
    super.initState();
    _loadWebtoons();
  }

  void _loadWebtoons() {
    String path = widget.path;
    Directory directory = Directory(path);
    List<FileSystemEntity> entities = directory.listSync(followLinks: false);

    for (FileSystemEntity entity in entities) {
      if (entity is Directory) {
        _directories.add(entity);
      }
    }
  }

  void _updateVisitedIndices(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("$index", true);
    setState(() {
      _visitedIndices.add("$index");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: _directories.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              _updateVisitedIndices(index);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WebtoonContentPage(
                    title: p.basename(_directories[index].path),
                    path: _directories[index].path,
                    directories: _directories,
                    index: index,
                    updateVisited: _updateVisitedIndices,
                  ),
                ),
              );
            },
            child: ListTile(
              title: Text(
                p.basename(_directories[index].path),
                style: TextStyle(
                  color: _visitedIndices.contains("$index")
                      ? Colors.black38
                      : Colors.black87,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
