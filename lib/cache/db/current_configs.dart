
import 'package:flutter_dynamic_api/flutter_dynamic_api.dart';

/// 当前运行的配置信息
class CurrentConfigs {
  /// 当前api
  static ApiConfigModel? currentApi;
  static Map<String, Map<String, dynamic>> enNameToApiJsonMap = {};
  // static List<ApiModel> allApiList = [];
  static Map<String, ApiConfigModel> enNameToApiMap = {};
}
