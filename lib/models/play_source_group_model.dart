import 'package:flutter_dynamic_api/flutter_dynamic_api.dart';
import 'package:source_player/models/resource_chapter_model.dart';


class PlaySourceGroupModel {
  final String? name;
  final String? enName;
  final List<ResourceChapterModel> chapterList;

  PlaySourceGroupModel({
    this.name,
    this.enName,
    required this.chapterList,
  });

  factory PlaySourceGroupModel.fromJson(Map<String, dynamic> json) {
    List<ResourceChapterModel> chapterList = [];
    var chapterListVar = json['chapterList'];
    if (chapterListVar != null) {
      try {
        List<Map<String, dynamic>> chapters = DataTypeConvertUtils
            .toListMapStrDyMap(chapterListVar);
        chapterList = chapters.map((e) => ResourceChapterModel.fromJson(e))
            .toList();
      } catch (e) {
        throw Exception("结果转换成json报错：\n${e.toString()}");
      }
    }
    return PlaySourceGroupModel(
      name: json["name"],
      enName: json["enName"] ?? json["name"],
      chapterList: chapterList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "enName": enName,
      "chapterList": chapterList.map((e) => e.toJson()).toList(),
    };
  }
}
