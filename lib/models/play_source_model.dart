
import 'package:flutter_dynamic_api/flutter_dynamic_api.dart';

import 'play_source_group_model.dart';

class PlaySourceModel {
  // 来源api
  ApiConfigModel? api;
  // 当前api下有哪些资源列表
  final List<PlaySourceGroupModel> playSourceGroupList;

  PlaySourceModel({
    this.api,
    required this.playSourceGroupList,
  });

  factory PlaySourceModel.fromJson(Map<String, dynamic> json) {
    List<PlaySourceGroupModel> playSourceGroupList = [];
    var playSourceGroupListVar = json['playSourceGroupList'];
    if (playSourceGroupListVar != null) {
      List<Map<String, dynamic>> playSourceGroups = DataTypeConvertUtils.toListMapStrDyMap(playSourceGroupListVar);
      playSourceGroupList = playSourceGroups.map((e) => PlaySourceGroupModel.fromJson(e))
        .toList();
    }
    ApiConfigModel? api;
    var apiVar = json['api'];
    if (apiVar != null) {
      api = ApiConfigModel.fromJson(apiVar);
    }
    return PlaySourceModel(
      api: api,
      playSourceGroupList: playSourceGroupList,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "api": api?.toJson(),
      "playSourceGroupList": playSourceGroupList.map((e) => e.toJson()).toList(),
    };
  }
}