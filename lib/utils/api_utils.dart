import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_dynamic_api/flutter_dynamic_api.dart';
import 'package:source_player/hive/storage.dart';

import '../cache/current_configs.dart';
import '../commons/net_api_key_common.dart';
import '../commons/public_commons.dart';

class ApiUtils {
  /// 加载当前设置的网络api
  static Future<String> loadCurrentApi() async {
    String msg = "";
    // 从缓存中获取
    var apiJson = GStorage.setting.get(
      "${SettingBoxKey.cachePrev}-${SettingBoxKey.currentApiKey}",
    );

    if (apiJson != null && apiJson.isNotEmpty) {
      try {
        Map<String, dynamic> map = {};
        if (apiJson is Map) {
          if (apiJson is Map<String, dynamic>) {
            map = apiJson;
          } else {
            map = DataTypeConvertUtils.toMapStrDyMap(apiJson);
          }
        } else {
          map = json.decode(apiJson.toString());
        }
        handleDefaultApiKeyInfo(map);
        var apiConfigModel = ApiConfigModel.fromJson(map);
        CurrentConfigs.updateCurrentApi(apiConfigModel);
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
    var apiJson = GStorage.setting.get(
      "${SettingBoxKey.cachePrev}-${SettingBoxKey.customAddApiKey}",
    );
    if (apiJson != null && apiJson.isNotEmpty) {
      try {
        Map<String, dynamic> map = {};
        if (apiJson is Map) {
          if (apiJson is Map<String, dynamic>) {
            map = apiJson;
          } else {
            map = DataTypeConvertUtils.toMapStrDyMap(apiJson);
          }
        } else {
          map = json.decode(apiJson.toString());
        }
        if (map.isEmpty) {
          return;
        }
        for (var entry in map.entries) {
          var value = entry.value;
          Map<String, dynamic> apiJson = {};
          if (value is! Map<String, dynamic>) {
            try {
              apiJson.addAll(DataTypeConvertUtils.toMapStrDyMap(value));
            } catch (e2) {
              PublicCommons.logger.e(
                "从缓存中获取api解析具体内容不是Map<String, dynamic>类型，无法解析，数据：${entry.value}",
              );
              continue;
            }
          } else {
            apiJson.addAll(value);
          }
          handleDefaultApiKeyInfo(apiJson);
          CurrentConfigs.enNameToApiJsonMap[entry.key] = apiJson;
          try {
            ApiConfigModel apiModel = ApiConfigModel.fromJson(apiJson);
            CurrentConfigs.enNameToApiMap[apiModel.apiBaseModel.enName] =
                apiModel;
          } catch (e1) {
            PublicCommons.logger.e(
              "从缓存中获取api解析具体内容错误，数据（已合并默认内容）：$apiJson，报错：$e1",
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
          var value = entry.value;
          Map<String, dynamic> apiJson = {};
          if (value is! Map<String, dynamic>) {
            try {
              apiJson.addAll(DataTypeConvertUtils.toMapStrDyMap(value));
            } catch (e2) {
              PublicCommons.logger.e(
                "读取路径：$filePath的json文件解析具体内容不是Map<String, dynamic>类型，无法解析，数据：${entry.value}",
              );
              continue;
            }
          } else {
            apiJson.addAll(value);
          }
          handleDefaultApiKeyInfo(apiJson);
          CurrentConfigs.enNameToApiJsonMap[entry.key] = apiJson;
          var validateResult = ApiConfigModel.validateField(apiJson);
          if (!validateResult.flag) {
            PublicCommons.logger.e(
              "读取路径：$filePath的json文件解析具体内容验证不通过，数据（已合并默认内容）：$apiJson，验证信息：${JsonToModelUtils.getValidateResultMsg(validateResult)}",
            );
            continue;
          }
          try {
            ApiConfigModel apiModel = ApiConfigModel.fromJson(apiJson);
            CurrentConfigs.enNameToApiMap[apiModel.apiBaseModel.enName] =
                apiModel;
          } catch (e1) {
            PublicCommons.logger.e(
              "读取路径：$filePath的json文件解析具体内容错误，数据（已合并默认内容）：$apiJson，报错：$e1",
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

  static handleDefaultApiKeyInfo(Map<String, dynamic> map) {
    String apiKeyConfig = map["apiKeyConfig"] ?? "";
    if (apiKeyConfig.isEmpty) {
      return;
    }
    Map<String, dynamic> apiKeyConfigMap =
        NetApiDefaultKeyCommon.apiKeys[apiKeyConfig] ?? {};
    if (apiKeyConfigMap.isEmpty) {
      return;
    }
    Map<String, dynamic> netApiMap = map["netApiMap"] ?? {};
    if (netApiMap.isEmpty) {
      return;
    }
    for (var entry in netApiMap.entries) {
      var defaultApi = apiKeyConfigMap[entry.key];
      Map<String, dynamic>? defaultApiMap;
      if (defaultApi is Map<String, dynamic>) {
        defaultApiMap = defaultApi;
      } else {
        try {
          defaultApiMap = DataTypeConvertUtils.toMapStrDyMap(defaultApi);
        } catch (e) {
          continue;
        }
      }
      if (defaultApiMap.isEmpty) {
        continue;
      }
      Map<String, dynamic>? dataJson;
      if (entry.value is Map<String, dynamic>) {
        dataJson = entry.value;
      } else {
        try {
          dataJson = DataTypeConvertUtils.toMapStrDyMap(entry.value);
        } catch (e) {
          PublicCommons.logger.e(
            "解析api信息中的[${entry.key}]错误，内容不是Map<String, dynamic>类型，无法解析：${entry.value}；报错：$e",
          );
          continue;
        }
      }
      dataJson ??= {};
      netApiMap[entry.key] = dataJson;
      mergeMapInfo(dataJson, defaultApiMap);
    }

    /*Map<String, dynamic>? listApi = netApiMap["listApi"];
    if (listApi != null) {
      mergeMapInfo(listApi, apiKeyConfigMap);
    }*/
  }

  static void mergeMapInfo(
    Map<String, dynamic> targetMap,
    Map<String, dynamic> sourceMap,
  ) {
    for (var entry in sourceMap.entries) {
      if (entry.key == "filterCriteriaList") {
        if (entry.value == null) {
          continue;
        }
        List<Map<String, dynamic>> filterCriteriaList =
            DataTypeConvertUtils.toListMapStrDyMap(entry.value);
        if (filterCriteriaList.isEmpty) {
          continue;
        }
        List<Map<String, dynamic>> targetFilterCriteriaList = [];
        if (targetMap[entry.key] == null) {
          targetMap[entry.key] = filterCriteriaList;
          continue;
        } else {
          try {
            targetFilterCriteriaList = DataTypeConvertUtils.toListMapStrDyMap(
              targetMap[entry.key],
            );
          } catch (e) {
            continue;
          }
        }
        if (targetFilterCriteriaList.isEmpty) {
          targetMap[entry.key] = filterCriteriaList;
          continue;
        }
        List<String> targetFilterCriteriaKeyList = targetFilterCriteriaList
            .map((item) => (item["enName"] ?? item["name"] ?? "").toString())
            .toList();
        for (var filterCriteria in filterCriteriaList) {
          if (!targetFilterCriteriaKeyList.contains(
            (filterCriteria["enName"] ?? filterCriteria["name"] ?? "")
                .toString(),
          )) {
            targetFilterCriteriaList.add(filterCriteria);
          }
        }
        targetMap[entry.key] = filterCriteriaList;
        continue;
      }
      if (entry.value is Map) {
        if (entry.value.isEmpty) {
          continue;
        }
        Map<String, dynamic> config = DataTypeConvertUtils.toMapStrDyMap(
          entry.value,
        );
        Map<String, dynamic> map = {};
        if (targetMap[entry.key] == null) {
          map = {};
        } else {
          map = DataTypeConvertUtils.toMapStrDyMap(targetMap[entry.key]);
        }
        targetMap[entry.key] = map;
        mergeMapInfo(map, config);
        continue;
      }
      var targetValue = targetMap[entry.key];
      if (targetValue == null) {
        targetMap[entry.key] = entry.value;
      }
    }
  }
}
