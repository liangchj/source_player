import 'package:flutter_dynamic_api/flutter_dynamic_api.dart';

import '../cache/db/current_configs.dart';
import 'media_file_model.dart';

class ResourceChapterModel {
  final String name;

  /// 是否选中
  bool activated;

  /// 是否播放中
  bool playing;

  /// 下标，用于升序和降序
  int index;

  /// 播放链接
  final String? playUrl;

  Map<String, dynamic>? extras;
  Map<String, String>? httpHeaders;
  Duration? start;
  Duration? end;

  MediaFileModel? mediaFileModel;

  Duration? historyDuration;

  ResourceChapterModel({
    required this.name,
    this.activated = false,
    this.playing = false,
    required this.index,
    this.playUrl,
    this.extras,
    this.httpHeaders,
    this.start,
    this.end,
    this.mediaFileModel,
    this.historyDuration,
  });
  factory ResourceChapterModel.fromJson(Map<String, dynamic> json) {
    var activated = json['activated'];
    var playing = json['playing'];
    var index = json['index'];
    var extrasVar = json['extras'];
    Map<String, dynamic>? extras;
    if (extrasVar != null) {
      try {
        extras = DataTypeConvertUtils.toMapStrDyMap(extrasVar);
      } catch (e) {}
    }
    var httpHeadersVar = json['httpHeaders'];
    Map<String, String>? httpHeaders;
    if (httpHeadersVar != null) {
      try {
        httpHeaders = Map<String, String>.from(httpHeadersVar);
      } catch (e) {}
    }
    var startVar = json['start'];
    Duration? start;
    if (startVar != null) {
      try {
        start = Duration(seconds: startVar);
      } catch (e) {}
    }
    var endVar = json['end'];
    Duration? end;
    if (endVar != null) {
      try {
        end = Duration(seconds: endVar);
      } catch (e) {}
    }

    return ResourceChapterModel(
      name: json['name'] ?? "",
      activated: activated == null ? false : bool.tryParse(activated) ?? false,
      playing: playing == null ? false : bool.tryParse(playing) ?? false,
      index: index == null
          ? -1
          : index.runtimeType == int
          ? index
          : int.parse(index.toString()),
      playUrl: json['playUrl'],
      extras: extras,
      httpHeaders: httpHeaders,
      start: start,
      end: end,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "activated": activated,
      "playing": playing,
      "index": index,
      "playUrl": playUrl,
      "extras": extras,
      "httpHeaders": httpHeaders,
      "start": start?.inSeconds,
      "end": end?.inSeconds,
    };
  }
}
