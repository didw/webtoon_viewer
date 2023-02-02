import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:archive/archive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

import 'webtoon/webtoon_list.dart';

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
      home: const WebtoonMainPage(),
    );
  }
}

class WebtoonMainPage extends StatefulWidget {
  const WebtoonMainPage({super.key});

  @override
  WebtoonMainPageState createState() => WebtoonMainPageState();
}

class WebtoonMainPageState extends State<WebtoonMainPage> {
  List<WebtoonList> _webtoonList = [];

  @override
  void initState() {
    super.initState();
    _getPermission();
    _checkForZipFiles();
    _loadWebtoons();
  }

  void _getPermission() async {
    final status = await Permission.storage.status;
    const statusManageStorage = Permission.manageExternalStorage;
    if (status.isDenied ||
        !status.isGranted ||
        !await statusManageStorage.isGranted) {
      await [
        Permission.storage,
        Permission.mediaLibrary,
        Permission.requestInstallPackages,
        Permission.manageExternalStorage,
      ].request();
    }
  }

  void _checkForZipFiles() {
    String path = "/sdcard/Download/Webtoons";
    Directory directory = Directory(path);
    List<FileSystemEntity> entities = directory.listSync(recursive: false);
    for (FileSystemEntity entity in entities) {
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
    List<WebtoonList> webtoons = [];
    for (FileSystemEntity entity in directories) {
      // Check if the entity is a directory
      if (entity is Directory) {
        String title = p.basename(entity.path);
        webtoons.add(WebtoonList(title: title, path: entity.path));
      }
    }

    setState(() {
      _webtoonList = webtoons;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [],
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text("Webtoon List"),
      ),
      body: ListView.builder(
        itemCount: _webtoonList.length,
        itemBuilder: (context, index) {
          WebtoonList webtoonList = _webtoonList[index];
          return ListTile(
            title: Text(
              webtoonList.title,
              style: const TextStyle(
                fontSize: 30.0,
              ),
            ),
            onTap: () {
              // Navigate to the webtoon detail page
              WebtoonList webtoonList = _webtoonList[index];
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WebtoonList(
                    title: webtoonList.title,
                    path: webtoonList.path,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
