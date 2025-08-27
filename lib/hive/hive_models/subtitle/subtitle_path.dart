
import 'package:hive/hive.dart';

import '../resource/video_resource.dart';

part 'subtitle_path.g.dart';
@HiveType(typeId: 5)
class SubtitlePath {
  @HiveField(0)
  final VideoResource resource;
  @HiveField(1)
  final int episode;
  @HiveField(2)
  String path;

  SubtitlePath(this.resource, this.episode, this.path);
}