
import 'package:flutter_dynamic_api/flutter_dynamic_api.dart';

import 'play_source_group_model.dart';

class PlaySourceModel {
  // 来源api
  final ApiConfigModel api;
  // 当前api下有哪些资源列表
  final List<PlaySourceGroupModel> playSourceGroupList;
  // 是否选择了当前资源
  final bool activated;

  PlaySourceModel({
    required this.api,
    required this.playSourceGroupList,
    required this.activated,
  });

  factory PlaySourceModel.fromJson(Map<String, dynamic> json) {
    List<PlaySourceGroupModel> playSourceGroupList = [];
    var playSourceGroupListVar = json['playSourceGroupList'];
    if (playSourceGroupListVar != null) {
      List<Map<String, dynamic>> playSourceGroups = DataTypeConvertUtils.toListMapStrDyMap(playSourceGroupListVar);
      playSourceGroupList = playSourceGroups.map((e) => PlaySourceGroupModel.fromJson(e))
        .toList();
    }
    var activated = json['activated'];
    return PlaySourceModel(
      api: ApiConfigModel.fromJson(json['api']),
      playSourceGroupList: playSourceGroupList,
      activated: activated == null ? false : bool.tryParse(activated) ?? false,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "api": api.toJson(),
      "playSourceGroupList": playSourceGroupList.map((e) => e.toJson()).toList(),
      "activated": activated,
    };
  }
}