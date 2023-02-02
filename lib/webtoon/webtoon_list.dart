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
  final Set<String> _visitedIndices = {};

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
    _loadVisitedIndices();
  }

  void _loadVisitedIndices() {
    SharedPreferences.getInstance().then((prefs) {
      for (int i = 0; i < _directories.length; i++) {
        final String name = "${widget.title}_$i";
        if (prefs.getBool(name) ?? false) {
          setState(() {
            _visitedIndices.add(name);
          });
        }
      }
    });
  }

  void _updateVisitedIndices(String title, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String name = "${title}_$index";
    prefs.setBool(name, true);
    setState(() {
      _visitedIndices.add(name);
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
              _updateVisitedIndices(widget.title, index);
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
                  color: _visitedIndices.contains("${widget.title}_$index")
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
