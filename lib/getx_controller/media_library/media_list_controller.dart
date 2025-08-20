import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:source_player/models/directory_model.dart';
import 'package:source_player/utils/logger_utils.dart';

import '../../cache/db/cache_const.dart';
import '../../cache/shared_preferences_cache.dart';
import '../../models/loading_state_model.dart';
import '../../models/media_file_model.dart';
import '../../models/play_source_group_model.dart';
import '../../models/play_source_model.dart';
import '../../models/resource_chapter_model.dart';
import '../../models/video_model.dart';
import '../../player/controller/player_controller.dart';

class MediaListController extends GetxController {
  DirectoryModel? folder;

  int pageSize = 20;

  var loadingState = LoadingStateModel().obs;

  // var mediaFileList = <MediaFileModel>[].obs;

  // 暂时使用（播放器中的章节设计不合理，先暂时使用）
  var videoModel = VideoModel(id: "", name: "", typeId: "", typeName: "");

  late PagingController<int, MediaFileModel> pagingController;

  @override
  void onInit() {
    folder = Get.arguments as DirectoryModel?;
    if (folder == null) {
      loadingState(
        loadingState.value.copyWith(
          loading: false,
          loadedSuc: false,
          errorMsg: "传入的路径为空",
        ),
      );
    } else {
      loadingState(
        loadingState.value.copyWith(
          loading: false,
          loadedSuc: true,
          errorMsg: null,
        ),
      );
    }
    pagingController = PagingController<int, MediaFileModel>(
      getNextPageKey: (PagingState<int, MediaFileModel> state) {
        if (!state.hasNextPage || state.lastPageIsEmpty) return null;
        return state.nextIntPageKey;
      },
      fetchPage: (int pageKey) async {
        return await _fetchVideosInFolder(pageKey);
      },
    );

    // 注册资源变化监听
    PhotoManager.addChangeCallback(_onAssetsChanged);

    /// 启用事件通知订阅。
    PhotoManager.startChangeNotify();
    super.onInit();
  }

  @override
  void onClose() {
    /// 取消事件通知订阅。
    PhotoManager.stopChangeNotify();
    // 移除监听，避免内存泄漏
    PhotoManager.removeChangeCallback(_onAssetsChanged);
    super.onClose();
  }

  void _onAssetsChanged(MethodCall call) {
    var index = ((pagingController.pages?.length ?? 0) / 20).ceil();
    pagingController.value.reset();
    pagingController.refresh();
    if (index > 1) {
      for (int i = 2; i <= index; i++) {
        pagingController.fetchNextPage();
      }
    }
  }

  Future<void> onRefresh() async {
    pagingController.value = pagingController.value.copyWith(
      isLoading: false,
      error: null,
    );
    await _fetchVideosInFolder(1);
  }

  Future<List<MediaFileModel>> _fetchVideosInFolder(
    int page, {
    int limit = 20,
  }) async {
    List<MediaFileModel> mediaFileList = [];
    if (folder == null || folder!.assetPathEntity == null) {
      return mediaFileList;
    }
    List<AssetEntity> assetEntityList = await folder!.assetPathEntity!
        .getAssetListPaged(
          page: page == 0 ? 0 : page - 1, // 分页获取，0为第一页
          size: limit, // 每页数量
        );
    for (var item in assetEntityList) {
      var file = await item.file;
      String fullFilePath = file?.path ?? "";
      // 获取绑定的弹幕文件
      var danmakuPath = await SharedPreferencesCache.asyncPrefs.getString(
        CacheConst.cachePrev +
            fullFilePath +
            CacheConst.mediaFileDanmakuFilePath,
      );
      // 获取绑定的字幕文件
      var subtitlePath = await SharedPreferencesCache.asyncPrefs.getString(
        CacheConst.cachePrev +
            fullFilePath +
            CacheConst.mediaFileSubtitleFilePath,
      );
      mediaFileList.add(MediaFileModel(assetEntity: item, danmakuPath: danmakuPath, subtitlePath: subtitlePath, file: file));
    }
    return mediaFileList;
  }

  Future<void> playVideo(MediaFileModel item) async {
    var pages = pagingController.pages ?? [];
    if (pages.isEmpty) {
      return;
    }
    List<ResourceChapterModel> chapterList = [];
    int index = 0;
    for (var list in pages) {
      for (var item in list) {
        String name = "";
        if (item.file != null) {
          name = item.file!.path.substring(
            item.file!.path.lastIndexOf("/") + 1,
          );
          name = name.substring(0, name.lastIndexOf("."));
        } else {
          name = item.assetEntity?.title ?? "";
        }
        var mediaUrl = await item.assetEntity?.getMediaUrl();
        bool activated = item.assetEntity?.id == item.assetEntity?.id;
        chapterList.add(
          ResourceChapterModel(
            name: name,
            index: index,
            playUrl: mediaUrl ?? item.file?.path,
            activated: activated,
          ),
        );
        index++;
      }

      final videoModel = VideoModel(
        id: "",
        name: "",
        typeId: "",
        typeName: "",
        playSourceList: [
          PlaySourceModel(
            playSourceGroupList: [
              PlaySourceGroupModel(chapterList: chapterList),
            ],
          ),
        ],
      );
      Get.delete<PlayerController>();
      // 获取播放器控制器并播放视频
      PlayerController controller = Get.put(PlayerController());
      controller.openLocalVideo(videoModel);
    }
  }
}
