class ChapterItemModel {
  final String id;
  final String name; // 如“第1集”“流浪地球.mp4”
  final String url; // 播放地址
  final bool isCurrent; // 是否为当前播放章节
  final Duration? duration; // 时长

  ChapterItemModel({
    required this.id,
    required this.name,
    required this.url,
    this.isCurrent = false,
    this.duration,
  });
}
