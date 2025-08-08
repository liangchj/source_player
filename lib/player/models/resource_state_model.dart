

class ResourceStateModel {
  // 当前选择的网站源索引
  int sourceApiPlayingIndex;
  // 当前展示的网站源索引（未选择当前资源下的具体章节）
  int sourceApiActivatedIndex;
  // 当前选择的资源组索引
  int sourceGroupPlayingIndex;
  // 当前展示的资源组索引（未选择当前资源下的具体章节）
  int sourceGroupActivatedIndex;

  // 当前选择的资源组下章节组数量
  int chapterGroup;
  // 当前选择的资源组下章节组索引
  int chapterGroupPlayingIndex;
  // 当前展示的资源组下章节组索引（未选择当前资源下的具体章节）
  int chapterGroupActivatedIndex;


  // 当前选择的章节索引
  int chapterActivatedIndex;

  ResourceStateModel({
    required this.sourceApiPlayingIndex,
    required this.sourceApiActivatedIndex,
    required this.sourceGroupPlayingIndex,
    required this.sourceGroupActivatedIndex,
    this.chapterGroup = 0,
    required this.chapterGroupPlayingIndex,
    required this.chapterGroupActivatedIndex,
    required this.chapterActivatedIndex,
  });

  ResourceStateModel copyWith({
    int? sourceApiPlayingIndex,
    int? sourceApiActivatedIndex,
    int? sourceGroupPlayingIndex,
    int? sourceGroupActivatedIndex,
    int? chapterGroup,
    int? chapterGroupPlayingIndex,
    int? chapterGroupActivatedIndex,
    int? chapterActivatedIndex,
  }) {
    return ResourceStateModel(
      sourceApiPlayingIndex: sourceApiPlayingIndex ?? this.sourceApiPlayingIndex,
      sourceApiActivatedIndex: sourceApiActivatedIndex ?? this.sourceApiActivatedIndex,
      sourceGroupPlayingIndex: sourceGroupPlayingIndex ?? this.sourceGroupPlayingIndex,
      sourceGroupActivatedIndex: sourceGroupActivatedIndex ?? this.sourceGroupActivatedIndex,
      chapterGroup: chapterGroup ?? this.chapterGroup,
      chapterGroupPlayingIndex: chapterGroupPlayingIndex ?? this.chapterGroupPlayingIndex,
      chapterGroupActivatedIndex: chapterGroupActivatedIndex ?? this.chapterGroupActivatedIndex,
      chapterActivatedIndex: chapterActivatedIndex ?? this.chapterActivatedIndex,
    );
  }

}