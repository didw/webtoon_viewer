import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _needPermission = false;
  String _rootPath = "";

  @override
  void initState() {
    super.initState();
    _getRootPath().then((rootPath) {
      setState(() {
        _rootPath = rootPath;
      });
      _loadWebtoons();
    });
  }

  Future<String> _getRootPath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? rootPath = prefs.getString("rootPath");
    print(rootPath);
    if (rootPath != null) {
      return rootPath;
    }
    return "";
  }

  void _loadWebtoons() {
    print(_rootPath);
    List<FileSystemEntity> directories;
    Directory directory = Directory(_rootPath);
    print(directory);
    try {
      directories = directory.listSync(recursive: false);
      _needPermission = false;
    } catch (e) {
      print(e);
      print("Can not access /sdcard/Download/Webtoons, Allow permission first");
      directories = [];
      _needPermission = true;
    }
    directories.sort((a, b) => a.path.compareTo(b.path));
    List<WebtoonList> webtoons = [];
    for (FileSystemEntity entity in directories) {
      if (entity is Directory) {
        String title = p.basename(entity.path);
        webtoons.add(WebtoonList(title: title, path: entity.path));
      }
    }

    setState(() {
      _webtoonList = webtoons;
    });
  }

  Future<String> _getWebtoonPath() async {
    await Permission.storage.request();
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      return selectedDirectory;
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [],
    );
    return Scaffold(
      appBar: AppBar(
        title: _needPermission
            ? const Text("Add webtoon directory first")
            : const Text("Webtoon List"),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _rootPath = await _getWebtoonPath();
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("rootPath", _rootPath);
          _loadWebtoons();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
