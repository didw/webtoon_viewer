import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:flutter/material.dart';

class WebtoonContentPage extends StatefulWidget {
  final String title;
  final String path;

  const WebtoonContentPage({
    Key? key,
    required this.title,
    required this.path,
  }) : super(key: key);

  @override
  _WebtoonContentPageState createState() => _WebtoonContentPageState();
}

class _WebtoonContentPageState extends State<WebtoonContentPage> {
  List<String> _images = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  void _loadImages() {
    // Get the list of images for the selected webtoon
    String path = widget.path;
    Directory directory = Directory(path);
    List<FileSystemEntity> entities = directory.listSync();

    // Create a list of image paths
    List<String> images = [];
    // loop in sorted way
    entities.sort((a, b) => a.path.compareTo(b.path));
    for (FileSystemEntity entity in entities) {
      if (entity is File) {
        String filename = p.basename(entity.path);
        if (filename.endsWith(".jpg")) {
          images.add(entity.path);
        }
      }
    }

    setState(() {
      _images = images;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(widget.title),
            floating: true,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Image.file(
                  File(_images[index]),
                  fit: BoxFit.cover,
                );
              },
              childCount: _images.length,
            ),
          ),
        ],
      ),
    );
  }
}
