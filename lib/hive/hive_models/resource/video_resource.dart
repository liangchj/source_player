import 'package:hive/hive.dart';

part 'video_resource.g.dart';
@HiveType(typeId: 0)
class VideoResource {
  @HiveField(0)
  String apiKey;

  @HiveField(1)
  String spiGroupEnName;

  @HiveField(2)
  String resourceId;

  @HiveField(3)
  String resourceEnName;

  @HiveField(4)
  String resourceName;

  @HiveField(5)
  String resourceUrl;

  // 预览图（缩略图）
  @HiveField(6)
  String? coverUrl;

  VideoResource({
    required this.apiKey,
    required this.spiGroupEnName,
    required this.resourceId,
    required this.resourceEnName,
    required this.resourceName,
    required this.resourceUrl,
    this.coverUrl,
  });
}
