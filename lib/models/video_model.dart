import '../utils/map_data_utils.dart';

class VideoModel {
  // 资源id
  final String id;
  // 名称
  final String name;
  // 名称（英文名称或拼音）
  final String? enName;
  // 类型Id列表
  final List<String> typeIdList;
  // 类型名称列表
  final List<String> typeNameList;
  // 父级类型id
  final String? parentTypeId;
  // 分类列表
  final List<String>? classList;
  // 预览图（缩略图）
  final String? coverUrl;
  // 简介/描述
  final String? blurb;
  // 详细内容介绍
  final String? detailContent;
  // 导演
  final List<String>? directorList;
  // 主演
  final List<String>? actorList;
  // 连载数量（集数）
  final int? serial;
  // 数量（集数）
  final int? total;
  // 时长
  final Duration? duration;
  // 分数
  final double? score;
  // 地区
  final String? area;
  // 语言
  final List<String>? languageList;
  // 年份
  final String? year;
  // 季度
  final String? version;
  // 添加时间
  final DateTime? addTime;
  // 更新时间
  final DateTime? modTime;

  VideoModel({
    required this.id,
    required this.name,
    this.enName,
    required this.typeIdList,
    required this.typeNameList,
    this.parentTypeId,
    this.classList,
    this.coverUrl,
    this.blurb,
    this.detailContent,
    this.directorList,
    this.actorList,
    this.serial,
    this.total,
    this.duration,
    this.score,
    this.area,
    this.languageList,
    this.year,
    this.version,
    this.addTime,
    this.modTime,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: (json["id"] ?? "").toString(),
      name: (json["id"] ?? "").toString(),
      enName: json["enName"],
      typeIdList: MapDataUtils.getListFromMap(json, "typeIdList"),
      typeNameList: MapDataUtils.getListFromMap(json, "typeNameList"),
      parentTypeId: (json["parentTypeId"] ?? "").toString(),
      classList:  MapDataUtils.getListFromMap(json, "classList"),
      coverUrl: json["coverUrl"],
      blurb: json["blurb"],
      detailContent: json["detailContent"],
      directorList:  MapDataUtils.getListFromMap(json, "directorList"),
      actorList:  MapDataUtils.getListFromMap(json, "actorList"),
      // serial:  MapDataUtils.getIntFromMap(json, "serial"),
      total:  MapDataUtils.getIntFromMap(json, "total"),
      duration:  MapDataUtils.getDurationFromMap(json, "duration"),
      score:  MapDataUtils.getDoubleFromMap(json, "score"),
      area:  json["area"],
      languageList:  MapDataUtils.getListFromMap(json, "languageList"),
      year:  json["year"],
      version:  json["version"],
    );
  }



  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
