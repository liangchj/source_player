import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:source_player/models/directory_model.dart';
import 'package:source_player/player/models/resource_play_state_model.dart';
import '../../hive/storage.dart';
import '../../models/loading_state_model.dart';
import '../../models/media_file_model.dart';
import '../../models/resource_chapter_model.dart';
import '../../player/controller/player_controller.dart';
import '../../player/utils/player_utils.dart';

class MediaListController extends GetxController {
  DirectoryModel? folder;

  int pageSize = 20;

  bool isRefresh = false;

  var loadingState = LoadingStateModel().obs;

  late PagingController<int, Rx<MediaFileModel>> pagingController;

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
    pagingController = PagingController<int, Rx<MediaFileModel>>(
      getNextPageKey: (PagingState<int, Rx<MediaFileModel>> state) {
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
    isRefresh = true;
    pagingController.value = pagingController.value.copyWith(
      isLoading: true,
      error: null,
    );

    await _fetchVideosInFolder(1);
    isRefresh = false;
    pagingController.value = pagingController.value.copyWith(
      isLoading: false,
      error: null,
    );
  }

  Future<List<Rx<MediaFileModel>>> _fetchVideosInFolder(
    int page, {
    int limit = 20,
  }) async {
    List<Rx<MediaFileModel>> mediaFileList = [];
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
      if (fullFilePath.isEmpty) {
        continue;
      }
      String key = "--$fullFilePath-0";
      // 获取绑定的弹幕文件
      var danmakuPaths = GStorage.danmakuPaths.get(key);
      var danmakuPath = danmakuPaths?.localPath;

      // 获取绑定的字幕文件
      var subtitlePaths = GStorage.subtitlePaths.get(key);
      var subtitlePath = subtitlePaths?.path;
      mediaFileList.add(
        MediaFileModel(
          assetEntity: item,
          danmakuPath: danmakuPath,
          subtitlePath: subtitlePath,
          file: file,
        ).obs,
      );
    }
    return mediaFileList;
  }

  Future<void> playVideo(MediaFileModel activatedItem) async {
    var pages = pagingController.pages ?? [];
    if (pages.isEmpty) {
      return;
    }
    int index = -1;
    List<ResourceChapterModel> chapterList = [];
    int i = 0;
    for (var list in pages) {
      for (var videoItem in list) {
        MediaFileModel item = videoItem.value;
        if (activatedItem == item) {
          index = i;
        }
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
        /*if (item.danmakuPath == null || item.danmakuPath == "") {
          item.danmakuPath = "/storage/emulated/0/1/1.xml";
        }*/
        chapterList.add(
          ResourceChapterModel(
            name: name,
            index: i,
            playUrl: mediaUrl ?? item.file?.path,
            activated: activated,
            mediaFileModel: item,
          ),
        );
        i++;
      }
    }

    PlayerUtils.openLocalVideo(
      chapterList: chapterList,
      playStateModel: ResourcePlayStateModel(
        apiIndex: 0,
        apiGroupIndex: 0,
        chapterGroupIndex: 0,
        chapterIndex: index,
      ),
      playerControllerCallback: (controller) {},
    );
  }
}
