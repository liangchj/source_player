import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:source_player/models/directory_model.dart';

import '../../models/loading_state_model.dart';
import '../../models/media_file_model.dart';

class MediaListController extends GetxController {
  DirectoryModel? folder;

  var loadingState = LoadingStateModel().obs;

  var mediaFileList = <MediaFileModel>[].obs;

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
    super.onInit();
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
      mediaFileList.add(MediaFileModel(assetEntity: item));
    }
    return mediaFileList;
  }
}
