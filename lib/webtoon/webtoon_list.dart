import 'dart:io';

import 'package:flutter/material.dart';

import 'webtoon.dart';
import 'webtoon_detail.dart';

class WebtoonList extends StatefulWidget {
  final Webtoon webtoon;

  const WebtoonList({Key? key, required this.webtoon}) : super(key: key);

  @override
  _WebtoonListState createState() => _WebtoonListState();
}

class _WebtoonListState extends State<WebtoonList> {
  final List<Directory> _directories = [];

  @override
  void initState() {
    super.initState();
    _loadWebtoons();
  }

  void _loadWebtoons() {
    String path = widget.webtoon.path;
    Directory directory = Directory(path);
    List<FileSystemEntity> entities = directory.listSync(followLinks: false);

    for (FileSystemEntity entity in entities) {
      if (entity is Directory) {
        _directories.add(entity);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.webtoon.title),
      ),
      body: ListView.builder(
        itemCount: _directories.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WebtoonDetailPage(
                    path: _directories[index].path,
                  ),
                ),
              );
            },
            child: ListTile(
              title: Text(basename(_directories[index].path)),
            ),
          );
        },
      ),
    );
  }
}
