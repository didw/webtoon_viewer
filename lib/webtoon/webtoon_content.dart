import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:flutter/material.dart';

class WebtoonContentPage extends StatefulWidget {
  final String title;
  final String path;
  final List<Directory> directories;
  final int index;
  final Function updateVisited;

  const WebtoonContentPage({
    Key? key,
    required this.title,
    required this.path,
    required this.directories,
    required this.index,
    required this.updateVisited,
  }) : super(key: key);

  @override
  WebtoonContentPageState createState() => WebtoonContentPageState();
}

class WebtoonContentPageState extends State<WebtoonContentPage> {
  List<String> _images = [];
  int _currentIndex = 0;
  String _title = '';
  String _path = '';

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
    _title = widget.title;
    _path = widget.path;
    _loadImages();
  }

  void _loadImages() {
    // Get the list of images for the selected webtoon
    Directory directory = Directory(_path);
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
            title: Text(_title),
            floating: false,
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
          SliverToBoxAdapter(
            child: Container(
              height: 100.0, // Added space at the bottom
            ),
          ),
          SliverPersistentHeader(
            delegate: _SliverHeaderDelegate(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                height: 200.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      iconSize: 100.0,
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        if (_currentIndex > 0) {
                          _currentIndex--;
                          _path = widget.directories[_currentIndex].path;
                          _title = _path.split('/').last;
                          widget.updateVisited(_currentIndex);
                          _loadImages();
                        }
                      },
                    ),
                    IconButton(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      iconSize: 100.0,
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () {
                        if (_currentIndex < widget.directories.length - 1) {
                          _currentIndex++;
                          _path = widget.directories[_currentIndex].path;
                          _title = _path.split('/').last;
                          widget.updateVisited(_currentIndex);
                          _loadImages();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            pinned: true,
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 200.0, // Added space at the bottom
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverHeaderDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 200.0;

  @override
  double get minExtent => 50.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => false;
}
