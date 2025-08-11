import 'package:get/get.dart';

class ResourceStateModel {
  // 当前选择的网站源
  var apiActivatedState = Rx<ActivatedStateModel?>(null);

  // 当前选择的资源组
  var sourceGroupActivatedState = Rx<SourceGroupActivatedStateModel?>(null);

  // 当前选择的资源组下章节组数量
  var activatedChapterGroup = RxInt(-1);
  // 当前展示的资源组下章节组数量
  var showChapterGroup = RxInt(-1);

  // 当前选择的资源组下章节组
  var chapterGroupActivatedState = Rx<ChapterGroupActivatedStateModel?>(null);

  // 当前选择的章节索引
  var chapterActivatedIndex = RxInt(-1);

  ResourceStateModel({
    Rx<ActivatedStateModel?>? apiActivatedState,
    Rx<SourceGroupActivatedStateModel?>? sourceGroupActivatedState,
    int? activatedChapterGroup,
    int? showChapterGroup,
    Rx<ChapterGroupActivatedStateModel?>? chapterGroupActivatedState,
    int? chapterActivatedIndex,
  }) {
    this.apiActivatedState(apiActivatedState?.value);
    this.sourceGroupActivatedState(sourceGroupActivatedState?.value);
    this.activatedChapterGroup(activatedChapterGroup);
    this.showChapterGroup(showChapterGroup);
    this.chapterGroupActivatedState(chapterGroupActivatedState?.value);
    this.chapterActivatedIndex(chapterActivatedIndex);
  }
}

class ActivatedStateModel {
  final int index;
  final int activatedIndex;

  ActivatedStateModel({required this.index, required this.activatedIndex});

  ActivatedStateModel copyWith({int? index, int? activatedIndex}) {
    return ActivatedStateModel(
      index: index ?? this.index,
      activatedIndex: activatedIndex ?? this.activatedIndex,
    );
  }
}

class SourceGroupActivatedStateModel extends ActivatedStateModel {
  final ActivatedStateModel apiState;

  SourceGroupActivatedStateModel({
    required super.index,
    required super.activatedIndex,
    required this.apiState,
  });

  @override
  SourceGroupActivatedStateModel copyWith({
    int? index,
    int? activatedIndex,
    ActivatedStateModel? apiState,
  }) {
    return SourceGroupActivatedStateModel(
      index: index ?? super.index,
      activatedIndex: activatedIndex ?? this.activatedIndex,
      apiState: apiState ?? this.apiState,
    );
  }
}

class ChapterGroupActivatedStateModel extends ActivatedStateModel {
  final SourceGroupActivatedStateModel sourceGroupState;

  ChapterGroupActivatedStateModel({
    required super.index,
    required super.activatedIndex,
    required this.sourceGroupState,
  });

  @override
  ChapterGroupActivatedStateModel copyWith({
    int? index,
    int? activatedIndex,
    SourceGroupActivatedStateModel? sourceGroupState,
  }) {
    return ChapterGroupActivatedStateModel(
      index: index ?? super.index,
      activatedIndex: activatedIndex ?? this.activatedIndex,
      sourceGroupState: sourceGroupState ?? this.sourceGroupState,
    );
  }
}

/*class SourceActivatedStateModel {
  final int? apiIndex;
  final int? sourceGroupIndex;
  final int? chapterGroupIndex;
  final int? chapterIndex;

  SourceActivatedStateModel({
    this.apiIndex,
    this.sourceGroupIndex,
    this.chapterGroupIndex,
    this.chapterIndex,
  });
}

class ApiStateModel {
  final int index;
  final int activatedIndex;

  ApiStateModel({required this.index, required this.activatedIndex});
}

class SourceGroupStateModel {
  final int index;
  final SourceActivatedStateModel activatedState;
  final SourceActivatedStateModel showState;

  SourceGroupStateModel({
    required this.index,
    required this.activatedState,
    required this.showState,
  });
}

class ChapterGroupStateModel {
  final int index;
  final SourceActivatedStateModel activatedState;
  final SourceActivatedStateModel showState;

  ChapterGroupStateModel({
    required this.index,
    required this.activatedState,
    required this.showState,
  });
}*/
