import 'package:hive/hive.dart';

import '../resource/video_resource.dart';

part 'collect_resource.g.dart';

@HiveType(typeId: 3)
class CollectResource {
  @HiveField(0)
  final VideoResource resource;

  @HiveField(1)
  DateTime time;

  CollectResource(this.resource, this.time);
}
