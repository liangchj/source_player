import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dynamic_api/flutter_dynamic_api.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:source_player/models/video_type_model.dart';
import 'package:source_player/pages/net_resource_list_page.dart';

import '../cache/db/current_configs.dart';
import '../commons/public_commons.dart';
import '../http/dio_utils.dart';
import '../models/video_model.dart';
import '../utils/api_utils.dart';

class NetResourceHomeController extends GetxController {
  Logger logger = Logger();

  /// 加载中
  var loading = true.obs;
  var errorMsg = "".obs;
  var apiConfigLoadSuc = false.obs;

  /// 类型切换controller
  TabController? tabController;

  /// 每个类型的列表
  List<Widget> typeTabBarViews = [];

  /// 类型加载中
  var typeLoading = false.obs;

  /// 类型列表
  var typeList = <VideoTypeModel>[].obs;
  /// 顶级类型列表
  var topTypeList = <VideoTypeModel>[].obs;
  var typeLoadSuc = false.obs;

  @override
  Future<void> onInit() async {
    loading(true);
    bool needWaitLoadOtherApi = false;
    // 获取当前api
    var curApiMsg = await ApiUtils.loadCurrentApi();
    if (curApiMsg.isNotEmpty) {
      if (curApiMsg == "当前未设置api") {
        needWaitLoadOtherApi = true;
      } else {
        errorMsg(curApiMsg);
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
        errorMsg("当前未设置api");
      } else {
        CurrentConfigs.currentApi = CurrentConfigs.enNameToApiMap.values.first;
      }
    } else {
      // 加载其他api
      ApiUtils.getAllApiFromCache();
      ApiUtils.getAllApiFromCustomJsonFile();
    }
    apiConfigLoadSuc(CurrentConfigs.currentApi != null);
    if (errorMsg.value.isEmpty) {
      typeLoading(true);
      // 加载资源列表
      // await loadNetResourceList();
      await loadVideoType();
      // await loadType();
      if (typeList.isNotEmpty) {
        // 设置过滤类型
        // setFilterCriteria();
        createTabBarViews();
      }
    }
    loading(false);
    typeLoading(false);
    super.onInit();
  }

  setFilterCriteria() {
    NetApiModel? typeListApi =
    CurrentConfigs.currentApi!.netApiMap["typeListApi"];
    if (typeListApi == null || typeListApi.filterCriteriaList == null || typeListApi.filterCriteriaList!.isEmpty) {
      return;
    }
    /*var typeFilterCriteria = typeListApi.filterCriteriaList?.firstWhere((e) => e.enName == "type");
    if (typeFilterCriteria != null) {
      typeFilterCriteria.filterCriteriaParamsList = typeListApi.filterCriteriaList!.firstWhere((e) => e.enName == "type").filterCriteriaParamsList;
    }*/
  }

  /// 视频类型
  loadVideoType() async {
    typeList([]);
    typeTabBarViews.clear();
    typeLoadSuc(false);
    CurrentConfigs.currentApiVideoTypeMap = {};
    String desc = "获取视频类型api";
    NetApiModel? typeListApi =
        CurrentConfigs.currentApi!.netApiMap["typeListApi"];
    if (typeListApi == null) {
      errorMsg("当前api未设置$desc");
      return;
    }
    // CurrentConfigs.currentApiRequestParamKeyMap["type"] = typeListApi.re;
    String url =
        CurrentConfigs.currentApi!.apiBaseModel.baseUrl + typeListApi.path;
    Map<String, dynamic> headers = {
      ...typeListApi.requestParams.headerParams ?? {}
    };
    Map<String, dynamic> params = {};
    Map<String, dynamic>? staticParams = typeListApi.requestParams.staticParams;
    if (staticParams != null && staticParams.isNotEmpty) {
      params.addAll({...staticParams});
    }
    Options options = Options(
      // 响应流上前后两次接受到数据的间隔，单位为毫秒。
      receiveTimeout: PublicCommons.netLoadTimeOutDuration,
    );
    try {
      var res = await DioUtils().get(url, params: params,
          options: options,
          extra: {"customError": ""}, shouldRethrow:  true);
      var data = res.data;
      Map<String, dynamic> dataMap = {};
      logger.d(data.runtimeType);
      if (data is Map<String, dynamic>) {
        dataMap = data;
      } else if (data is String) {
        try {
          dataMap = jsonDecode(data);
        } catch (e) {
          logger.e("$desc，结果转换成json报错：$e");
          errorMsg("结果转换成json报错：\n${e.toString()}");
          return;
        }
      }
      PageModel<VideoTypeModel> result;
      if (typeListApi.responseParams.resultConvertJsFn == null ||
          typeListApi.responseParams.resultConvertJsFn!.isEmpty) {
        result = DefaultResponseParser(
          VideoTypeModel.fromJson,
        ).listDataParseFromJson(dataMap, typeListApi);
      } else {
        result = DefaultResponseParser(
          VideoTypeModel.fromJson,
        ).listDataParseFromJsonAndJsFn(dataMap, typeListApi);
      }
      if (result.statusCode == ResponseParseStatusCodeEnum.success.code) {
        typeList(result.modelList ?? []);
        if (typeList.isEmpty) {
          topTypeList([]);
        } else {
          String topTypeId = typeListApi.extendMap?["topTypeId"] ?? "0";
          topTypeList(typeList.where((element) =>
          element.parentId == topTypeId).toList());

          for (var element in typeList) {
            String parentTypeId = element.parentId ?? "";
            List<VideoTypeModel> childTypeList = CurrentConfigs.currentApiVideoTypeMap[parentTypeId] ?? [];
            childTypeList.add(element);
            CurrentConfigs.currentApiVideoTypeMap[parentTypeId] = childTypeList;
          }
        }
        typeLoadSuc(true);
      }
      errorMsg(result.msg);
      // logger.d("$desc，数据转换后：${result.toJson()}");
    } on DioException catch (e) {
      logger.e("$desc，请求报错：\n${e.message}");
      errorMsg("api连接异常，请检查！\n${e.message}");
    } catch (e) {
      logger.e("$desc，请求报错：$e");
      errorMsg("api连接异常，请检查！$e");
    }
  }

  /// 根据视频类型生成视频列表页面
  createTabBarViews() {
    typeTabBarViews.clear();
    for (var item in topTypeList) {
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
      var listParseFromJson;
      if (listApi.responseParams.resultConvertJsFn == null ||
          listApi.responseParams.resultConvertJsFn!.isEmpty) {
        listParseFromJson = DefaultResponseParser(
          VideoModel.fromJson,
        ).listDataParseFromJson(dataMap, listApi);
      } else {
        listParseFromJson = DefaultResponseParser(
          VideoModel.fromJson,
        ).listDataParseFromJsonAndJsFn(dataMap, listApi);
      }
      logger.d("数据转换后：${listParseFromJson.toJson()}");
    });
  }
}
