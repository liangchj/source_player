import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_dynamic_api/flutter_dynamic_api.dart';
import 'package:flutter_dynamic_api/utils/json_to_model_utils.dart';

import '../cache/db/current_configs.dart';
import '../cache/shared_preferences_cache.dart';
import '../commons/cache_key_commons.dart';
import '../commons/public_commons.dart';

class ApiUtils {
  /// 加载当前设置的网络api
  static Future<String> loadCurrentApi() async {
    String msg = "";
    // 从缓存中获取
    String? apiJsonStr = await SharedPreferencesCache()
        .getAsyncPrefs()
        .getString(CacheKeyCommons.currentApiKey);
    if (apiJsonStr != null && apiJsonStr.isNotEmpty) {
      try {
        CurrentConfigs.currentApi = ApiConfigModel.fromJson(json.decode(apiJsonStr));
      } catch (e) {
        msg = "解析当前api出错：$e";
      }
    } else {
      msg = "当前未设置api";
    }
    return msg;
  }

  /// 从缓存中获取所有的api
  /// 将api转成json字符串，然后以英文名作为key生成map，再转成字符串存入
  static getAllApiFromCache() async {
    // 从缓存中获取
    String? apiJsonStr = await SharedPreferencesCache()
        .getAsyncPrefs()
        .getString(CacheKeyCommons.apiKey);
    if (apiJsonStr != null && apiJsonStr.isNotEmpty) {
      try {
        Map<String, dynamic> map = json.decode(apiJsonStr);
        if (map.isEmpty) {
          return;
        }
        for (var entry in map.entries) {
          if (entry.value is! Map<String, dynamic>) {
            PublicCommons.logger.e(
              "从缓存中获取api解析具体内容不是Map<String, dynamic>类型，无法解析，数据：${entry.value}",
            );
            continue;
          }
          CurrentConfigs.enNameToApiJsonMap[entry.key] = entry.value;
          try {
            ApiConfigModel apiModel = ApiConfigModel.fromJson(entry.value);
            CurrentConfigs.enNameToApiMap[apiModel.apiBaseModel.enName] = apiModel;
          } catch (e1) {
            PublicCommons.logger.e(
              "从缓存中获取api解析具体内容错误，数据：${entry.value}，报错：$e1",
            );
          }
        }
      } catch (e) {
        PublicCommons.logger.e("从缓存中获取api解析错误：$e");
      }
    }
    PublicCommons.logger.d(
      "从缓存中获取api信息：enNameToApiJsonMap：${CurrentConfigs.enNameToApiJsonMap}, enNameToApiMap: ${CurrentConfigs.enNameToApiMap}",
    );
  }

  /// 从自定义json文件中获取
  static getAllApiFromCustomJsonFile() async {
    String filePath = PublicCommons.apiJsonFilePath;
    if (filePath.isEmpty) {
      return;
    }
    try {
      Map<String, dynamic> resultMap = {};
      String jsonStr = await rootBundle.loadString(filePath);
      if (jsonStr.isEmpty) {
        return;
      }
      try {
        resultMap = jsonDecode(jsonStr);
        if (resultMap.isEmpty) {
          return;
        }
        for (var entry in resultMap.entries) {
          if (entry.value is! Map<String, dynamic>) {
            PublicCommons.logger.e(
              "读取路径：$filePath的json文件解析具体内容不是Map<String, dynamic>类型，无法解析，数据：${entry.value}",
            );
            continue;
          }
          CurrentConfigs.enNameToApiJsonMap[entry.key] = entry.value;
          var validateResult = ApiConfigModel.validateField(
            entry.value,
          );
          if (!validateResult.flag) {

            PublicCommons.logger.e(
              "读取路径：$filePath的json文件解析具体内容验证不通过，数据：${entry.value}，验证信息：${JsonToModelUtils.getValidateResultMsg(validateResult)}",
            );
            continue;
          }
          try {
            ApiConfigModel apiModel = ApiConfigModel.fromJson(entry.value);
            CurrentConfigs.enNameToApiMap[apiModel.apiBaseModel.enName] = apiModel;
          } catch (e1) {
            PublicCommons.logger.e(
              "读取路径：$filePath的json文件解析具体内容错误，数据：${entry.value}，报错：$e1",
            );
          }
        }
      } catch (e) {
        PublicCommons.logger.e("解析json报错：$e");
      }
    } catch (ee) {
      PublicCommons.logger.e("读取路径：$filePath的json文件报错：$ee");
    }
    PublicCommons.logger.d(
      "读取路径：$filePath的json文件后api信息：enNameToApiJsonMap：${CurrentConfigs.enNameToApiJsonMap}, enNameToApiMap: ${CurrentConfigs.enNameToApiMap}",
    );
  }
}
