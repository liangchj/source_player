
import 'package:flutter_dynamic_api/flutter_dynamic_api.dart';
import 'package:source_player/models/resource_chapter_model.dart';

class PlaySourceModel {
// 来源api
  final ApiConfigModel api;
  // 当前api下有哪些资源列表
  final List<ResourceChapterModel> chapterList;
  // 是否选择了当前资源
  final bool activated;

  PlaySourceModel({
    required this.api,
    required this.chapterList,
    required this.activated,
  });

  factory PlaySourceModel.fromJson(Map<String, dynamic> json) {
    List<ResourceChapterModel> chapterList = [];
    var chapterListVar = json['chapterList'];
    if (chapterListVar != null) {
      List<Map<String, dynamic>> chapters = DataTypeConvertUtils.toListMapStrDyMap(chapterListVar);
      chapterList = chapters.map((e) => ResourceChapterModel.fromJson(e))
        .toList();
    }
    var activated = json['activated'];
    return PlaySourceModel(
      api: ApiConfigModel.fromJson(json['api']),
      chapterList: chapterList,
      activated: activated == null ? false : bool.tryParse(activated) ?? false,
    );
  }
}