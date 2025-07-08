import 'package:flutter_dynamic_api/flutter_dynamic_api.dart';

import 'play_source_model.dart';

class PlaySourceGroupModel {
  final String name;
  final String enName;
  final List<PlaySourceModel> playSourceList;
  // 是否选择了当前资源组
  final bool activated;

  PlaySourceGroupModel({
    required this.name,
    required this.enName,
    required this.playSourceList,
    this.activated = false,
  });

  factory PlaySourceGroupModel.fromJson(Map<String, dynamic> json) {
    List<PlaySourceModel> playSourceList = [];
    var playSourceListVar = json['playSourceList'];
    if (playSourceListVar != null) {
      List<Map<String, dynamic>> playSources = DataTypeConvertUtils.toListMapStrDyMap(playSourceListVar);
      playSourceList = playSources.map((e) => PlaySourceModel.fromJson(e))
          .toList();
    }
    var activated = json['activated'];
    return PlaySourceGroupModel(
      name: json["name"],
      enName: json["enName"] ?? json["name"],
      playSourceList: playSourceList,
      activated: activated == null ? false : bool.tryParse(activated) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "enName": enName,
      "playSourceList": playSourceList.map((e) => e.toJson()).toList(),
    };
  }
}
