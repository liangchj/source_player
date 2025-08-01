import 'package:flutter/material.dart';
import 'package:flutter_dynamic_api/flutter_dynamic_api.dart';
import 'package:flutter_dynamic_api/models/dynamic_params_model.dart';
import 'package:get/get.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:source_player/commons/widget_style_commons.dart';
import 'package:source_player/models/video_model.dart';

import '../cache/db/current_configs.dart';
import '../models/loading_state_model.dart';
import '../utils/net_request_utils.dart';
import 'state/source_chapter_state.dart';

class NetResourceDetailController extends GetxController with GetSingleTickerProviderStateMixin {
  final String resourceId;
  NetResourceDetailController(this.resourceId);

  var loadingState = LoadingStateModel().obs;
  var videoModel = Rx<VideoModel?>(null);
  NetApiModel? detailApi;

  // 底部弹出BottomSheet控制器
  PersistentBottomSheetController? bottomSheetController;

  // 详情页面的子页面的key
  late GlobalKey<ScaffoldState> childKey;
  // 详情页的tab控制器
  late TabController tabController;
  final List<Widget> tabs = [
    Tab(text: "详情"),
    Tab(text: "评论"),
  ];

  late SourceChapterState sourceChapterState;

  ScrollController? nestedScrollController;
  // api来源滚动控制器
  ScrollController? playSourceApiScrollController;
  ListObserverController? playSourceApiObserverController;

  // 来源组滚动控制器
  ScrollController? playSourceGroupScrollController;
  ListObserverController? playSourceGroupObserverController;

  // 章节分组滚动控制器
  ScrollController? chapterGroupScrollController;
  ListObserverController? chapterGroupObserverController;

  // 章节滚动控制器
  ScrollController? chapterScrollController;
  ListObserverController? chapterObserverController;


  var showBottomSheet = false.obs;

  @override
  void onInit() {
    sourceChapterState = SourceChapterState(this);
    loadingState(
      loadingState.value.copyWith(
        loading: true,
        loadedSuc: false,
        errorMsg: null,
      ),
    );
    detailApi = CurrentConfigs.currentApi!.netApiMap["detailApi"];
    if (detailApi == null) {
      loadingState(loadingState.value.copyWith(
        loading: false,
        loadedSuc: false,
        errorMsg: "未配置详情接口",
      ));
    }
    else if (resourceId.isEmpty) {
      loadingState(loadingState.value.copyWith(
        loading: false,
        loadedSuc: false,
        errorMsg: "传入的资源id为空!",
      ));
    }
    else {
      childKey = GlobalKey<ScaffoldState>();
      tabController = TabController(length: tabs.length, vsync: this);
      loadResourceDetail();
    }
    _initEver();
    super.onInit();
  }

  void _initEver() {
    ever(videoModel, (val) {
      var length = sourceChapterState.currentPlayedChapterList.length;
      int group = (length / WidgetStyleCommons.chapterGroupCount).ceil();
      if (group < 1) {
        group = 1;
      }
      sourceChapterState.chapterGroup(group);
      sourceChapterState.chapterGroupIndex(0);
    });

    ever(sourceChapterState.selectedSourceGroupIndex, (value) {
      int jumpToIndex = -1;
      if (sourceChapterState.playedSourceApiIndex.value != sourceChapterState.selectedSourceApiIndex.value
      || sourceChapterState.playedSourceGroupIndex.value != sourceChapterState.selectedSourceGroupIndex.value) {
        sourceChapterState.chapterGroupIndex(0);
      } else {
        jumpToIndex = sourceChapterState.chapterGroupActivatedIndex;
      }
      if (jumpToIndex >= 0) {
        sourceChapterState.chapterGroupIndex(jumpToIndex);
      }
    });

    // 选择章节
    ever(sourceChapterState.chapterIndex, (value) {
      // 只有选中了章节才能标记当前组为播放
      // sourceChapterState.playedSourceApiIndex.value = sourceChapterState.selectedSourceApiIndex.value;
      sourceChapterState.playedSourceApiIndex(sourceChapterState.selectedSourceApiIndex.value);
      sourceChapterState.playedSourceGroupIndex(sourceChapterState.selectedSourceGroupIndex.value);
      // sourceChapterState.playedSourceGroupIndex.value = sourceChapterState.selectedSourceGroupIndex.value;
    });


  }

  // 初始化控制器
  void _initController() {
    nestedScrollController = ScrollController();

    playSourceApiScrollController = ScrollController();
    playSourceGroupObserverController = ListObserverController(controller: playSourceApiScrollController);

    if (sourceChapterState.currentPlayedSourceGroupList.length > 1) {
      playSourceGroupScrollController = ScrollController();
      playSourceApiObserverController = ListObserverController(controller: playSourceGroupScrollController);
    }

    if (sourceChapterState.chapterGroup.value > 1) {
      chapterGroupScrollController = ScrollController();
      chapterGroupObserverController =
          ListObserverController(controller: chapterGroupScrollController);
    }

    chapterScrollController = ScrollController();
    chapterObserverController = ListObserverController(controller: chapterScrollController);
  }

  // 销毁控制器
  void _disposeController() {
    bottomSheetController?.close();
    nestedScrollController?.dispose();
    tabController.dispose();
    playSourceApiScrollController?.dispose();
    playSourceGroupScrollController?.dispose();
    chapterGroupScrollController?.dispose();
    chapterScrollController?.dispose();
  }

  @override
  void onClose() {
    _disposeController();
    super.onClose();
  }

  // 加载资源详情
  Future<void> loadResourceDetail() async {
    loadingState(
      loadingState.value.copyWith(
        loading: true,
        loadedSuc: false,
        errorMsg: null,
      ),
    );
    videoModel(null);
    Map<String, dynamic> params = {};
    var dynamicParams = detailApi!.requestParams.dynamicParams;
    if (dynamicParams == null || !dynamicParams.keys.contains("id")) {
      params["id"] = resourceId;
    } else {
      DynamicParamsModel idParams = dynamicParams["id"]!;
      params[idParams.requestKey] = resourceId;
    }
    try {
      DefaultResponseModel<VideoModel> res = await NetRequestUtils.loadResource<VideoModel>(
        detailApi!,
        VideoModel.fromJson,
        params: params,
      );
      if (res.statusCode == ResponseParseStatusCodeEnum.success.code) {
        if (res.model != null && res.model!.id == resourceId) {
          videoModel(res.model);
          for (var playSource in res.model!.playSourceList!) {
            playSource.api ??= CurrentConfigs.currentApi;
          }
        }

        _initController();
      } else {
        loadingState(loadingState.value.copyWith(loading: false, loadedSuc: false, errorMsg: "加载资源失败：${res.msg}" ,));
        return;
      }

      print("资源信息: ${videoModel.value?.toJson()}");
    } catch (e) {
      loadingState(loadingState.value.copyWith(loading: false, loadedSuc: false, errorMsg: "加载资源报错：${e.toString()}" ,));
    }
    loadingState(loadingState.value.copyWith(loading: false, loadedSuc: true, errorMsg: null,));
  }

  bool canPopScope() {
    if (bottomSheetController != null) {
      bottomSheetController!.close();
      bottomSheetController = null;
      showBottomSheet( false);
      return false;
    }
    return true;
  }

  void closeBottomSheet() {
    if (bottomSheetController != null) {
      bottomSheetController!.close();
      bottomSheetController = null;
      showBottomSheet( false);
    }
  }
}
