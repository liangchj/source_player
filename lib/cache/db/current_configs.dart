
import 'package:flutter_dynamic_api/flutter_dynamic_api.dart';
import 'package:source_player/models/video_type_model.dart';

/// 当前运行的配置信息
class CurrentConfigs {
  /// 当前api
  static ApiConfigModel? currentApi;
  static NetApiModel? listApi;
  static Map<String, Map<String, dynamic>> enNameToApiJsonMap = {};
  // static List<ApiModel> allApiList = [];
  static Map<String, ApiConfigModel> enNameToApiMap = {};
  /// 当前api的资源类型
  static Map<String, List<VideoTypeModel>> currentApiVideoTypeMap = {};

  /// 当前请求参数key
  /*static Map<String, String> currentApiRequestParamKeyMap = {

  };*/


  static updateCurrentApiInfo() {
    if (CurrentConfigs.currentApi == null) {
      listApi = null;
    } else {
      listApi = CurrentConfigs.currentApi!.netApiMap["listApi"];
    }
  }
}
