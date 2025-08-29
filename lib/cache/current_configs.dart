
import 'package:flutter_dynamic_api/flutter_dynamic_api.dart';
import 'package:source_player/hive/storage.dart';

import '../models/filter_criteria_list_model.dart';

/// 当前运行的配置信息
class CurrentConfigs {
  /// 当前api
  static ApiConfigModel? currentApi;
  static NetApiModel? listApi;
  static Map<String, Map<String, dynamic>> enNameToApiJsonMap = {};
  // static List<ApiModel> allApiList = [];
  static Map<String, ApiConfigModel> enNameToApiMap = {};
  /// 当前api的资源类型
  static Map<String, FilterCriteriaListModel?> currentApiVideoTypeMap = {};

  /// 当前请求参数key

  // 通用的过滤条件
  static Map<String, FilterCriteriaListModel> commonFilterMap = {};

  static updateCurrentApi(ApiConfigModel? api) {
    CurrentConfigs.currentApi = api;
    // GStorage.setting.put("${SettingBoxKey.cachePrev}-${SettingBoxKey.currentApiKey}", {CurrentConfigs.currentApi?.apiBaseModel.enName: CurrentConfigs.currentApi?.toJson()});
    GStorage.setting.put("${SettingBoxKey.cachePrev}-${SettingBoxKey.currentApiKey}", CurrentConfigs.currentApi?.toJson());
    CurrentConfigs.updateCurrentApiInfo();
  }


  static updateCurrentApiInfo() {
    if (CurrentConfigs.currentApi == null) {
      listApi = null;
    } else {
      listApi = CurrentConfigs.currentApi!.netApiMap["listApi"];
    }
  }

  static mergeCommonFilterMap(Map<String, dynamic> map) {
    for (var entry in map.entries) {
      try {
        commonFilterMap[entry.key] =
            FilterCriteriaListModel.fromJson(entry.value);
      } catch (e) {
        continue;
      }
    }
  }
}
