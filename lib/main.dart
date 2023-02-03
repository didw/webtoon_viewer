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
  bool _needPermission = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _loadWebtoons();
  }

  void _handlePermissionDenied(
      Map<Permission, PermissionStatus> permissionResult) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Permissions Required'),
          content: const Text(
              'Please grant the storage and manage external storage permissions to continue.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _requestPermissions() async {
    var permissionResult = await [
      Permission.storage,
      Permission.manageExternalStorage,
    ].request();

    if (permissionResult[Permission.storage]!.isGranted &&
        permissionResult[Permission.manageExternalStorage]!.isGranted) {
      // Permissions are granted
    } else {
      _handlePermissionDenied(permissionResult);
    }
  }

  void _loadWebtoons() {
    const String path = "/sdcard/Download/Webtoons";
    List<FileSystemEntity> directories;
    Directory directory = Directory(path);
    try {
      directories = directory.listSync(recursive: false);
    } catch (e) {
      print(e);
      const Tooltip(
        message:
            "Can not eccess /sdcard/Download/Webtoons, Allow permission first",
        child: Text(
            "Can not eccess /sdcard/Download/Webtoons, Allow permission first"),
      );
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

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [],
    );
    return Scaffold(
      appBar: AppBar(
        title: _needPermission
            ? const Text("Need Permission")
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
    );
  }
}
