import 'package:flutter/material.dart';

class WebtoonImageList extends StatelessWidget {
  final Map<String, dynamic> webtoon;

  const WebtoonImageList({Key? key, required this.webtoon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(webtoon['title']),
      ),
      body: ListView.builder(
        itemCount: webtoon['images'].length,
        itemBuilder: (context, index) {
          final image = webtoon['images'][index];
          return SizedBox(
            height: 200,
            child: Image.network(
              image,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}
