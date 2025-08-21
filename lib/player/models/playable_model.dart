
class PlayableModel {
  final String id;
  final String name;
  final String url;
  final Map<String, dynamic>? extra; // 扩展信息（差异化字段）

  PlayableModel({
    required this.id,
    required this.name,
    required this.url,
    this.extra,
  });
}
