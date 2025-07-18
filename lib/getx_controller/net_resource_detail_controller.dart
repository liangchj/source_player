import 'package:flutter/material.dart';
import 'package:flutter_dynamic_api/flutter_dynamic_api.dart';
import 'package:flutter_dynamic_api/models/dynamic_params_model.dart';
import 'package:get/get.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
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

  late ScrollController playSourceApiScrollController;
  late ScrollController playSourceGroupScrollController;
  late ScrollController chapterScrollController;
  late ListObserverController chapterObserverController;

  var showBottomSheet = false.obs;

  @override
  void onInit() {
    sourceChapterState = SourceChapterState(this);
    playSourceApiScrollController = ScrollController();
    playSourceGroupScrollController = ScrollController();
    chapterScrollController = ScrollController();
    chapterObserverController = ListObserverController(controller: chapterScrollController);
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
    super.onInit();
  }

  @override
  void onClose() {
    bottomSheetController?.close();
    tabController.dispose();
    playSourceApiScrollController.dispose();
    playSourceGroupScrollController.dispose();
    chapterScrollController.dispose();
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
