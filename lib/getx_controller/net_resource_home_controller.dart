import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dynamic_api/flutter_dynamic_api.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../cache/db/current_configs.dart';
import '../http/dio_utils.dart';
import '../models/video_model.dart';
import '../utils/api_utils.dart';

class NetResourceHomeController extends GetxController {
  /// 加载中
  var loading = true.obs;
  var errorMsg = "".obs;

  Logger logger = Logger();

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
    // await loadCurrentApi();
    if (errorMsg.value.isEmpty) {
      // 加载资源列表
      await loadNetResourceList();
      // await loadType();
    }
    loading(false);

    super.onInit();
  }

  loadType() {
    /*ApiSettingModel typeSetting = CurrentConfigs.currentApi!.filterCriteriaApiList![0].filterCriteriaApiSetting!;
    String url = CurrentConfigs.currentApi!.baseUrl + typeSetting.path;

    Map<String, dynamic> params = {};
    Map<String, dynamic>? staticParams = typeSetting.requestParams.staticParams;
    if (staticParams != null && staticParams.isNotEmpty) {
      params.addAll({
        ...staticParams
      });
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
      if (typeSetting.responseParams.resultConvertJsFn == null || typeSetting.responseParams.resultConvertJsFn!.isEmpty) {
        listParseFromJson = MaccmsResponseParser().listFilterCriteriaByJson(dataMap, typeSetting);
      } else {
        JsFnConvertResponseParser().listFilterCriteriaByExecuteJsFn(dataMap, typeSetting);
      }
      logger.d("数据转换后：${listParseFromJson.toJson()}");

    });*/

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
      params.addAll({
        ...staticParams
      });
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
      if (listApi.responseParams.resultConvertJsFn == null || listApi.responseParams.resultConvertJsFn!.isEmpty) {
        listParseFromJson = DefaultResponseParser(VideoModel.fromJson).listDataParseFromJson(
            dataMap, listApi);
      } else {
        listParseFromJson = DefaultResponseParser(VideoModel.fromJson).listDataParseFromJsonAndJsFn(dataMap, listApi);
      }
      logger.d("数据转换后：${listParseFromJson.toJson()}");
    });
  }
}
