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

  ResourceChapterModel({
     required this.name,
    this.activated = false,
    this.playing = false,
    required this.index,
    this.playUrl,
  });
  factory ResourceChapterModel.fromJson(Map<String, dynamic> json) {
    var activated = json['activated'];
    var playing = json['playing'];
    var index = json['index'];
    return ResourceChapterModel(
      name: json['name'] ?? "",
      activated: activated == null ? false : bool.tryParse(activated) ?? false,
      playing: playing == null ? false : bool.tryParse(playing) ?? false,
      index: index == null ? -1 : index.runtimeType == int ? index : int.parse(index.toString()),
      playUrl: json['playUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "activated": activated,
      "playing": playing,
      "index": index,
      "playUrl": playUrl,
    };
  }
}
