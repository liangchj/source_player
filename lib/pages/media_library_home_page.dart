import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:source_player/player/controller/player_controller.dart';

import '../models/play_source_group_model.dart';
import '../models/play_source_model.dart';
import '../models/resource_chapter_model.dart';
import '../models/video_model.dart';

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
          TextButton(
            onPressed: () {
              PlayerController controller = Get.put(PlayerController());
              VideoModel videoModel = VideoModel(
                id: '1',
                name: '测试',
                typeId: '',
                typeName: '',
                playSourceList: [
                  PlaySourceModel(
                    playSourceGroupList: [
                      PlaySourceGroupModel(
                        chapterList: [
                          ResourceChapterModel(
                            name: '1',
                            index: 0,
                            playUrl: "asset://assets/video/test.mp4",
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );
              controller.openLocalVideo(videoModel);
            },
            child: Text("测试播放视频"),
          ),
        ],
      ),
    );
  }
}
