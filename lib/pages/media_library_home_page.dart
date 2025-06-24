import 'package:flutter/material.dart';

class MediaLibraryHomePage extends StatefulWidget {
  const MediaLibraryHomePage({super.key});

  @override
  State<MediaLibraryHomePage> createState() => _MediaLibraryHomePageState();
}

class _MediaLibraryHomePageState extends State<MediaLibraryHomePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("媒体库", style: TextStyle(color: Colors.black)),
    );
  }
}
