import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:flutter/material.dart';

class WebtoonContentPage extends StatefulWidget {
  final String title;
  final String path;
  final List<Directory> directories;
  final int index;

  const WebtoonContentPage({
    Key? key,
    required this.title,
    required this.path,
    required this.directories,
    required this.index,
  }) : super(key: key);

  @override
  _WebtoonContentPageState createState() => _WebtoonContentPageState();
}

class _WebtoonContentPageState extends State<WebtoonContentPage> {
  List<String> _images = [];
  late ScrollController _scrollController;

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
          SliverPersistentHeader(
            delegate: _SliverHeaderDelegate(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                height: 50.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        if (widget.index > 0) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WebtoonContentPage(
                                title: widget.directories[widget.index - 1].path
                                    .split('/')
                                    .last,
                                path: widget.directories[widget.index - 1].path,
                                directories: widget.directories,
                                index: widget.index - 1,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_forward),
                      onPressed: () {
                        if (widget.index < widget.directories.length - 1) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WebtoonContentPage(
                                title: widget.directories[widget.index + 1].path
                                    .split('/')
                                    .last,
                                path: widget.directories[widget.index + 1].path,
                                directories: widget.directories,
                                index: widget.index + 1,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            pinned: true,
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
  double get maxExtent => 50.0;

  @override
  double get minExtent => 50.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => false;
}
