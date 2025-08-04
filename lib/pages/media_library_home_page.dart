import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:source_player/player/controller/player_controller.dart';

class MediaLibraryHomePage extends StatefulWidget {
  const MediaLibraryHomePage({super.key});

  @override
  State<MediaLibraryHomePage> createState() => _MediaLibraryHomePageState();
}

class _MediaLibraryHomePageState extends State<MediaLibraryHomePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      // child: Text("媒体库", style: TextStyle(color: Colors.black)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("媒体库", style: TextStyle(color: Colors.black)),
          TextButton(onPressed: () {
            PlayerController controller = Get.put(PlayerController());
            controller.openLocalVideo();
          }, child: Text("测试播放视频")),
        ]
      ),
    );
  }
}
