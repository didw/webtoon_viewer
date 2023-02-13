import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:flutter/material.dart';

import 'webtoon.dart';

class WebtoonDetailPage extends StatefulWidget {
  final Webtoon webtoon;

  const WebtoonDetailPage({Key? key, required this.webtoon}) : super(key: key);

  @override
  _WebtoonDetailPageState createState() => _WebtoonDetailPageState();
}

class _WebtoonDetailPageState extends State<WebtoonDetailPage> {
  List<String> _images = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  void _loadImages() {
    // Get the list of images for the selected webtoon
    String path = widget.webtoon.path;
    Directory directory = Directory(path);
    List<FileSystemEntity> entities = directory.listSync();
    setState(() {});
    // Create a list of image paths
    List<String> images = [];
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
      appBar: AppBar(
        title: Text(widget.webtoon.title),
      ),
      body: ListView.builder(
        itemCount: _images.length,
        itemBuilder: (context, index) {
          return Image.file(
            File(_images[index]),
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }
}
