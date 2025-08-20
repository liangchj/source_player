
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../cache/db/cache_const.dart';
import '../cache/shared_preferences_cache.dart';
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
    mediaFile(Get.arguments as MediaFileModel?);
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
      LoadingStateModel(
        loading: true,
        errorMsg: null,
        loadedSuc: false,
      ),
    );
  }


  /// 绑定弹幕
  void bindDanmaku(String path) {
    // 修改记录弹幕文件路径
    mediaFile(mediaFile.value.copyWith(
      danmakuPath: path,
    ));
    // 将弹幕文件路径写入存储
    SharedPreferencesCache.asyncPrefs.setString(CacheConst.cachePrev + (mediaFile.value.fullFilePath ?? "") + CacheConst.mediaFileDanmakuFilePath, path);


    
    // Get.find<VideoFileController>().videoFileList.refresh();
    // MediaData.playFileListMap[fileModel.directory] = Get.find<VideoFileController>().videoFileList;
    // updateVideoFileModel(fileModel);
  }

  /// 移除绑定弹幕
  void unbindDanmaku() {
    // 修改记录弹幕文件路径
    mediaFile(mediaFile.value.copyWith(
      danmakuPath: "",
    ));
    // 将弹幕文件路径写入存储
    SharedPreferencesCache.asyncPrefs.clear(allowList: {CacheConst.cachePrev + (mediaFile.value.fullFilePath ?? "") + CacheConst.mediaFileDanmakuFilePath});
    /*Get.find<VideoFileController>().videoFileList.refresh();
    MediaData.playFileListMap[fileModel.directory] = Get.find<VideoFileController>().videoFileList;
    updateVideoFileModel(fileModel);*/
  }


}