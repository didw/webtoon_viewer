import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:archive/archive.dart';

import 'webtoon/webtoon.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Webtoon Application',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WebtoonListPage(),
    );
  }
}

class WebtoonListPage extends StatefulWidget {
  const WebtoonListPage({super.key});

  @override
  _WebtoonListPageState createState() => _WebtoonListPageState();
}

class _WebtoonListPageState extends State<WebtoonListPage> {
  List<Webtoon> _webtoonList = [];

  @override
  void initState() {
    super.initState();
    _checkForZipFiles();
    _loadWebtoons();
  }

  void _checkForZipFiles() {
    String path = "/sdcard/Download/Webtoons";
    Directory directory = Directory(path);
    List<FileSystemEntity> entities = directory.listSync(recursive: false);
    print(entities);
    for (FileSystemEntity entity in entities) {
      print(entity);
      if (entity is File) {
        String filename = p.basename(entity.path);
        if (filename.endsWith(".zip")) {
          String subDirectoryName = filename.substring(0, filename.length - 4);
          if (!Directory("$path/$subDirectoryName").existsSync()) {
            // Extract the zip file
            List<int> bytes = entity.readAsBytesSync();
            Archive archive = ZipDecoder().decodeBytes(bytes);
            for (ArchiveFile file in archive) {
              String fileName = p.basename(file.name);
              File("$path/$subDirectoryName/$fileName")
                  .writeAsBytesSync(file.content);
            }
          }
        }
      }
    }
  }

  void _loadWebtoons() {
    // Define the predefined path to the directory
    String path = "/sdcard/Download/Webtoons";

    // Get the list of directories in the predefined path
    Directory directory = Directory(path);
    List<FileSystemEntity> directories = directory.listSync(recursive: false);

    // Create a list of webtoons
    List<Webtoon> webtoons = [];
    for (FileSystemEntity entity in directories) {
      // Check if the entity is a directory
      if (entity is Directory) {
        String title = p.basename(entity.path);
        webtoons.add(Webtoon(title: title, path: entity.path));
      }
    }

    setState(() {
      _webtoonList = webtoons;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Webtoon List"),
      ),
      body: ListView.builder(
        itemCount: _webtoonList.length,
        itemBuilder: (context, index) {
          Webtoon webtoon = _webtoonList[index];
          return ListTile(
            title: Text(webtoon.title),
            onTap: () {
              // Navigate to the webtoon detail page
              Webtoon webtoon = _webtoonList[index];
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WebtoonList(webtoon: webtoon),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
