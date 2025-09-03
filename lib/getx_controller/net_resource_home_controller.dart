import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dynamic_api/flutter_dynamic_api.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:source_player/models/loading_state_model.dart';
import 'package:source_player/models/video_type_model.dart';
import 'package:source_player/pages/net_resource_list_page.dart';

import '../cache/current_configs.dart';
import '../http/dio_utils.dart';
import '../models/filter_criteria_item_model.dart';
import '../models/video_model.dart';
import '../utils/api_utils.dart';
import '../utils/net_request_utils.dart';
import 'net_resource_list_controller.dart';

class NetResourceHomeController extends GetxController
    with GetTickerProviderStateMixin {
  Logger logger = Logger();

  var activatedApi = Rx<ApiConfigModel?>(null);

  // 配置加载状态
  var activatedApiConfigLoadingState = LoadingStateModel().obs;
  var apiConfigLoadingState = LoadingStateModel().obs;

  /// 类型切换controller
  var tabController = Rx<TabController?>(null);

  /// 每个类型的列表
  List<Widget> typeTabBarViews = [];

  /// 类型加载中
  var typeLoadingState = LoadingStateModel().obs;

  /// 类型列表
  var videoTypeList = <VideoTypeModel>[].obs;

  @override
  Future<void> onInit() async {
    logger.d("NetResourceHomeController init");
    _initEver();
    loadApiSetting();
    super.onInit();
  }

  void _initEver() {
    ever(activatedApi, (val) async {
      Get.delete<NetResourceListController>();
      loadInfo();
    });
  }

  Future<void> loadApiSetting() async {
    activatedApiConfigLoadingState(
      activatedApiConfigLoadingState.value.copyWith(loading: true),
    );
    apiConfigLoadingState(apiConfigLoadingState.value.copyWith(loading: true));

    // 获取当前api
    var curApiMsg = await ApiUtils.loadCurrentApi();
    bool needWaitLoadOtherApi = curApiMsg == "当前未设置api";

    activatedApiConfigLoadingState(
      activatedApiConfigLoadingState.value.copyWith(
        loading: false,
      ),
    );
    List<String> cacheErrorMsgList = [];
    List<String> fileErrorMsgList = [];
    if (needWaitLoadOtherApi) {
      // 加载其他api
      cacheErrorMsgList.addAll(await ApiUtils.getAllApiFromCache());
      if (CurrentConfigs.enNameToApiMap.isEmpty) {
        fileErrorMsgList.addAll(await ApiUtils.getAllApiFromCustomJsonFile());
      } else {
        fileErrorMsgList.addAll(await ApiUtils.getAllApiFromCustomJsonFile());
      }
      if (CurrentConfigs.enNameToApiMap.isEmpty) {
        apiConfigLoadingState(
          apiConfigLoadingState.value.copyWith(errorMsg: "当前未设置api"),
        );
      } else {
        CurrentConfigs.updateCurrentApi(
          CurrentConfigs.enNameToApiMap.values.first,
        );
      }
    } else {
      // 加载其他api
      cacheErrorMsgList.addAll(await ApiUtils.getAllApiFromCache());
      fileErrorMsgList.addAll(await ApiUtils.getAllApiFromCustomJsonFile());
    }
    apiConfigLoadingState(
      apiConfigLoadingState.value.copyWith(
        loading: false,
        loadedSuc: cacheErrorMsgList.isEmpty && fileErrorMsgList.isEmpty,
        errorMsg: cacheErrorMsgList.isEmpty && fileErrorMsgList.isEmpty
                ? null
            : cacheErrorMsgList.join("；") + fileErrorMsgList.join("；"),
      ),
    );
    activatedApi(CurrentConfigs.currentApi);

    if (activatedApi.value != null) {
      activatedApiConfigLoadingState(
        activatedApiConfigLoadingState.value.copyWith(
          loadedSuc: true,
          errorMsg: null,
        ),
      );
    } else {
      if (cacheErrorMsgList.isEmpty && fileErrorMsgList.isEmpty) {
        activatedApiConfigLoadingState(
          activatedApiConfigLoadingState.value.copyWith(
            loadedSuc: curApiMsg == "当前未设置api",
            errorMsg: curApiMsg,
          ),
        );
      } else {
        activatedApiConfigLoadingState(
          activatedApiConfigLoadingState.value.copyWith(
            loadedSuc: false,
            errorMsg: "解析api配置出错",
          ),
        );
      }
    }

    typeLoadingState(typeLoadingState.value.copyWith(loading: false));
  }

  Future<void> loadInfo() async {
    if (apiConfigLoadingState.value.loadedSuc) {
      // 加载视频类型
      await loadVideoType();
    }
    if (typeLoadingState.value.loadedSuc) {
      // 设置过滤类型
      createTabBarViews();
    }
  }

  void _clearTabController() {
    if (tabController.value != null) {
      tabController.value!.dispose();
    }
  }

  /// 视频类型
  loadVideoType() async {
    typeLoadingState(
      typeLoadingState.value.copyWith(loading: true, loadedSuc: false),
    );
    videoTypeList([]);
    typeTabBarViews.clear();
    _clearTabController();
    tabController(null);
    CurrentConfigs.currentApiVideoTypeMap = {};
    String desc = "获取视频类型api";
    NetApiModel? typeListApi = activatedApi.value?.netApiMap["typeListApi"];
    if (typeListApi == null) {
      typeLoadingState(
        typeLoadingState.value.copyWith(loading: false, loadedSuc: true),
      );
      return;
    }
    try {
      PageModel<VideoTypeModel> result =
          await NetRequestUtils.loadPageResource<VideoTypeModel>(
            typeListApi,
            VideoTypeModel.fromJson,
          );
      bool suc = result.statusCode == ResponseParseStatusCodeEnum.success.code;
      String errorMsg = "";
      if (suc) {
        videoTypeList(result.modelList ?? []);
        if (videoTypeList.isNotEmpty) {
          for (var item in videoTypeList) {
            if (item.childType != null &&
                item.childType!.filterCriteriaItemList.isNotEmpty) {
              // item.childType!.filterCriteriaItemList[0].activated = true;
              item.childType!.filterCriteriaItemList.insert(
                0,
                FilterCriteriaItemModel(
                  value: item.id,
                  label: '全部',
                  activated: true,
                ),
              );
            }
            CurrentConfigs.currentApiVideoTypeMap[item.id] = item.childType;
          }
        }
      } else {
        errorMsg = result.msg ?? "获取数据失败";
      }
      typeLoadingState(
        typeLoadingState.value.copyWith(
          loading: false,
          loadedSuc: suc,
          errorMsg: errorMsg,
        ),
      );
    } catch (e) {
      logger.e("$desc，$e");
      typeLoadingState(
        typeLoadingState.value.copyWith(loading: false, errorMsg: e.toString()),
      );
    }
  }

  /// 根据视频类型生成视频列表页面
  createTabBarViews() {
    typeTabBarViews.clear();
    if (videoTypeList.isEmpty) {
      tabController(TabController(length: 1, vsync: this));
      typeTabBarViews.add(
        NetResourceListPage(
          videoType: VideoTypeModel(id: "", name: ""),
        ),
      );
      return;
    }
    tabController(TabController(length: videoTypeList.length, vsync: this));
    for (var item in videoTypeList) {
      typeTabBarViews.add(NetResourceListPage(videoType: item));
    }
  }

  loadNetResourceList() {
    NetApiModel listApi = activatedApi.value!.netApiMap["listApi"]!;
    String url = activatedApi.value!.apiBaseModel.baseUrl + listApi.path;
    Map<String, dynamic> params = {"pg": 1};
    Map<String, dynamic>? staticParams = listApi.requestParams.staticParams;
    if (staticParams != null && staticParams.isNotEmpty) {
      // for (var entry in staticParams.entries) {
      //   params[entry.key] =
      // }
      params.addAll({...staticParams});
    }
    Options options = Options(
      //响应流上前后两次接受到数据的间隔，单位为毫秒。
      receiveTimeout: const Duration(milliseconds: 60000),
    );
    DioUtils().get(url, params: params, options: options).then((res) {
      logger.d("请求返回数据：$res");
      Map<String, dynamic> dataMap = {};
      var data = res.data;
      logger.d(data.runtimeType);
      if (data is Map<String, dynamic>) {
        dataMap = data;
      } else if (data is String) {
        try {
          dataMap = jsonDecode(data);
        } catch (e) {
          logger.e("结果转换成json报错：$e");
        }
      }
      var listParseFromJson = DefaultResponseParser(
        VideoModel.fromJson,
      ).listDataParse(dataMap, listApi);

      logger.d("数据转换后：${listParseFromJson.toJson()}");
    });
  }
}
