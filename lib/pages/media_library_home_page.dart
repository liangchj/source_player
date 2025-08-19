import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:source_player/getx_controller/media_library_controller.dart';

class MediaLibraryHomePage extends StatefulWidget {
  const MediaLibraryHomePage({super.key});

  @override
  State<MediaLibraryHomePage> createState() => _MediaLibraryHomePageState();
}

class _MediaLibraryHomePageState extends State<MediaLibraryHomePage> with AutomaticKeepAliveClientMixin {

  late MediaLibraryController controller;

  @override
  void initState() {
    controller = Get.put(MediaLibraryController());
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("媒体库"),
      ),
      body: ListView(
        children: controller.libraryList.map((e) => e).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
        },
        tooltip: 'getVideo',
        child: const Icon(Icons.add),
      ),
    );
    /*super.build(context);
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
    );*/
  }

  @override
  bool get wantKeepAlive => true;
}
