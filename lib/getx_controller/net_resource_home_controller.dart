import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dynamic_api/flutter_dynamic_api.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:source_player/models/loading_state_model.dart';
import 'package:source_player/models/video_type_model.dart';
import 'package:source_player/pages/net_resource_list_page.dart';

import '../cache/db/current_configs.dart';
import '../http/dio_utils.dart';
import '../models/filter_criteria_item_model.dart';
import '../models/video_model.dart';
import '../utils/api_utils.dart';
import '../utils/net_request_utils.dart';

class NetResourceHomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  Logger logger = Logger();

  // 配置加载状态
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
    apiConfigLoadingState(apiConfigLoadingState.value.copyWith(loading: true));
    bool needWaitLoadOtherApi = false;
    // 获取当前api
    var curApiMsg = await ApiUtils.loadCurrentApi();
    if (curApiMsg.isNotEmpty) {
      if (curApiMsg == "当前未设置api") {
        needWaitLoadOtherApi = true;
      } else {
        apiConfigLoadingState(
          apiConfigLoadingState.value.copyWith(errorMsg: curApiMsg),
        );
      }
    }
    if (needWaitLoadOtherApi) {
      // 加载其他api
      await ApiUtils.getAllApiFromCache();
      if (CurrentConfigs.enNameToApiMap.isEmpty) {
        await ApiUtils.getAllApiFromCustomJsonFile();
      } else {
        ApiUtils.getAllApiFromCustomJsonFile();
      }
      if (CurrentConfigs.enNameToApiMap.isEmpty) {
        apiConfigLoadingState(
          apiConfigLoadingState.value.copyWith(errorMsg: "当前未设置api"),
        );
      } else {
        CurrentConfigs.currentApi = CurrentConfigs.enNameToApiMap.values.first;
        CurrentConfigs.updateCurrentApiInfo();
      }
    } else {
      // 加载其他api
      ApiUtils.getAllApiFromCache();
      ApiUtils.getAllApiFromCustomJsonFile();
    }
    apiConfigLoadingState(
      apiConfigLoadingState.value.copyWith(
        loadedSuc: CurrentConfigs.currentApi != null,
      ),
    );
    if (apiConfigLoadingState.value.loadedSuc) {
      // 加载视频类型
      await loadVideoType();
    }
    if (typeLoadingState.value.loadedSuc) {
      // 设置过滤类型
      createTabBarViews();
    }
    apiConfigLoadingState(apiConfigLoadingState.value.copyWith(loading: false));
    typeLoadingState(typeLoadingState.value.copyWith(loading: false));
    super.onInit();
  }

  /// 视频类型
  loadVideoType() async {
    typeLoadingState(
      typeLoadingState.value.copyWith(loading: true, loadedSuc: false),
    );
    videoTypeList([]);
    typeTabBarViews.clear();
    tabController(null);
    CurrentConfigs.currentApiVideoTypeMap = {};
    String desc = "获取视频类型api";
    NetApiModel? typeListApi =
        CurrentConfigs.currentApi!.netApiMap["typeListApi"];
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
            if (item.childType != null && item.childType!.filterCriteriaItemList.isNotEmpty) {
              // item.childType!.filterCriteriaItemList[0].activated = true;
              item.childType!.filterCriteriaItemList.insert(0, FilterCriteriaItemModel(value: item.id, label: '全部', activated: true));
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
      typeLoadingState(typeLoadingState.value.copyWith(
          loading: false,
          errorMsg: e.toString()));
    }
  }

  /// 根据视频类型生成视频列表页面
  createTabBarViews() {
    typeTabBarViews.clear();
    if (videoTypeList.isEmpty) {
      tabController(TabController(length: 1, vsync: this));
      typeTabBarViews.add(NetResourceListPage(videoType: VideoTypeModel(id: "", name: "")));
      return;
    }
    tabController(TabController(length: videoTypeList.length, vsync: this));
    for (var item in videoTypeList) {
      typeTabBarViews.add(NetResourceListPage(videoType: item));
    }
  }

  loadNetResourceList() {
    NetApiModel listApi = CurrentConfigs.currentApi!.netApiMap["listApi"]!;
    String url = CurrentConfigs.currentApi!.apiBaseModel.baseUrl + listApi.path;
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
