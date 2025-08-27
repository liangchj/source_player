import 'package:hive/hive.dart';

import '../resource/video_resource.dart';
part 'danmaku_paths.g.dart';
@HiveType(typeId: 4)
class DanmakuPaths {
  @HiveField(0)
  final VideoResource resource;
  @HiveField(1)
  final int episode;
  @HiveField(2)
  String networkPath;
  @HiveField(3)
  String localPath;

  String get key => "${resource.apiKey}-${resource.spiGroupEnName}-${resource.resourceId}-$episode}";

  DanmakuPaths(this.resource, this.episode, this.networkPath, this.localPath);
}
