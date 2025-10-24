import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:source_player/hive/hive_models/resource/video_resource.dart';
import 'package:source_player/hive/storage.dart';

import '../enums/file_source_enums.dart';
import '../hive/hive_models/danmaku/danmaku_paths.dart';
import '../models/barrage_subtitle_model.dart';
import '../models/loading_state_model.dart';
import '../models/media_file_model.dart';

class SearchDanmakuSubtitleController extends GetxController {
  var loadingState = LoadingStateModel().obs;

  late TextEditingController textEditingController;

  var mediaFile = MediaFileModel().obs;

  var danmakuList = <BarrageSubtitleModel>[].obs;
  var danmakuMap = <String, List<BarrageSubtitleModel>>{}.obs;

  var clickVideoNameIndex = 0.obs; // 搜索名称下标

  @override
  void onInit() {
    mediaFile = Get.arguments as Rx<MediaFileModel>;
    super.onInit();
    textEditingController = TextEditingController();
  }

  @override
  void onClose() {
    super.onClose();
    textEditingController.dispose();
  }

  void searchDanmakuList(String keyword) {
    loadingState(
      LoadingStateModel(loading: true, errorMsg: null, loadedSuc: false),
    );
  }

  /// 绑定弹幕
  void bindDanmaku(String path, FileSourceEnums fileSource) {
    // 修改记录弹幕文件路径
    mediaFile(mediaFile.value.copyWith(danmakuPath: path));
    var currentDanmakuPaths = DanmakuPaths(
      VideoResource(
        apiKey: '',
        spiGroupEnName: '',
        resourceId: mediaFile.value.fullFilePath ?? '',
        resourceEnName: mediaFile.value.fileName,
        resourceName: mediaFile.value.fileName,
        resourceUrl: '',
      ),
      0,
      "",
      "",
    );
    // 将弹幕文件路径写入存储
    String key =
        "${currentDanmakuPaths.resource.apiKey}-${currentDanmakuPaths.resource.spiGroupEnName}-${currentDanmakuPaths.resource.resourceId}-${currentDanmakuPaths.episode}";
    var danmakuPaths = GStorage.danmakuPaths.get(key) ?? currentDanmakuPaths;
    if (fileSource == FileSourceEnums.localFile) {
      danmakuPaths.localPath = path;
    } else if (fileSource == FileSourceEnums.networkFile) {
      danmakuPaths.networkPath = path;
    }
    print("弹幕路径写入存储，key:$key，路径: ${danmakuPaths.localPath}");
    GStorage.danmakuPaths.put(key, danmakuPaths);

    // Get.find<VideoFileController>().videoFileList.refresh();
    // MediaData.playFileListMap[fileModel.directory] = Get.find<VideoFileController>().videoFileList;
    // updateVideoFileModel(fileModel);
  }

  /// 移除绑定弹幕
  void unbindDanmaku() {
    // 修改记录弹幕文件路径
    mediaFile(mediaFile.value.copyWith(danmakuPath: ""));
    // 将弹幕文件路径写入存储
    String key = "--${mediaFile.value.fullFilePath ?? ''}-0";
    GStorage.danmakuPaths.delete(key);

    /*Get.find<VideoFileController>().videoFileList.refresh();
    MediaData.playFileListMap[fileModel.directory] = Get.find<VideoFileController>().videoFileList;
    updateVideoFileModel(fileModel);*/
  }
}
