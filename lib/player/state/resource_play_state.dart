import 'package:get/get.dart';

import '../../commons/widget_style_commons.dart';
import '../../models/play_source_group_model.dart';
import '../../models/play_source_model.dart';
import '../../models/resource_chapter_model.dart';
import '../../models/video_model.dart';
import '../models/chapter_group_model.dart';
import '../models/resource_play_state_model.dart';

class ResourcePlayState {
  var chapterAsc = true.obs;

  // 激活状态（当前展示的索引，用于UI高亮）
  final RxInt apiActivatedIndex = RxInt(-1);
  final RxInt apiGroupActivatedIndex = RxInt(-1);
  final RxInt chapterGroupActivatedIndex = RxInt(-1);
  final RxInt chapterActivatedIndex = RxInt(-1);

  // 播放状态（复合对象，决定当前播放的内容）
  final Rx<ResourcePlayStateModel> resourcePlayingState =
      const ResourcePlayStateModel(
        apiIndex: -1,
        apiGroupIndex: -1,
        chapterGroupIndex: -1,
        chapterIndex: -1,
      ).obs;


  // 多级缓存：记录每个上级分组对应的下级激活索引
  // 1. api索引 → 该api下最后激活的apiGroup索引
  final Map<int, int> _apiToApiGroupCache = {};

  // 2. "api索引+apiGroup索引" → 该组合下最后激活的chapterGroup索引
  final Map<String, int> _apiGroupToChapterGroupCache = {};

  // 3. "api索引+apiGroup索引+chapterGroup索引" → 该组合下最后激活的chapter索引
  final Map<String, int> _chapterGroupToChapterCache = {};

  void initEver() {
    everAll([videoModel, chapterList], (val) {
      if (playStateModel == null) {
        _apiToApiGroupCache[0] = 0;
        _apiGroupToChapterGroupCache["0-0"] = 0;
        _chapterGroupToChapterCache["0-0-0"] = 0;
        apiActivatedIndex.value = 0;
        apiGroupActivatedIndex.value = 0;
        chapterGroupActivatedIndex.value = 0;
        chapterActivatedIndex.value = 0;
      } else {
        _apiToApiGroupCache[playStateModel!.apiIndex] = playStateModel!.apiGroupIndex;
        _apiGroupToChapterGroupCache["${playStateModel!.apiIndex}-${playStateModel!.apiGroupIndex}"] = playStateModel!.chapterGroupIndex;
        _chapterGroupToChapterCache["${playStateModel!.apiIndex}-${playStateModel!.apiGroupIndex}-${playStateModel!.chapterGroupIndex}"] = playStateModel!.chapterIndex;
        apiActivatedIndex.value = playStateModel!.apiIndex;
        apiGroupActivatedIndex.value = playStateModel!.apiGroupIndex;
        chapterGroupActivatedIndex.value = playStateModel!.chapterGroupIndex;
        chapterActivatedIndex.value = playStateModel!.chapterIndex;
      }
    });
    ever(apiActivatedIndex, (val) {
      int apiGroupCacheActivatedIndex = _apiToApiGroupCache[val] ?? -1;

      if (chapterGroupActivatedIndex.value >= 0) {
        _apiToApiGroupCache[val] = apiGroupActivatedIndex.value;
      }

      apiGroupActivatedIndex.value = apiGroupCacheActivatedIndex;
    });
    ever(apiGroupActivatedIndex, (val) {
      int chapterGroupCacheActivatedIndex =
          _apiGroupToChapterGroupCache["${apiActivatedIndex.value}-$val"] ?? -1;
      if (chapterGroupActivatedIndex.value >= 0) {
        _apiGroupToChapterGroupCache["${apiActivatedIndex.value}-$val"] =
            chapterGroupActivatedIndex.value;
      }

      chapterGroupActivatedIndex.value = chapterGroupCacheActivatedIndex;
    });
    ever(chapterGroupActivatedIndex, (val) {
      int chapterCacheActivatedIndex =
          _chapterGroupToChapterCache["${apiActivatedIndex.value}-${apiGroupActivatedIndex.value}-$val"] ??
          -1;
      if (chapterActivatedIndex.value >= 0) {
        _chapterGroupToChapterCache["${apiActivatedIndex.value}-${apiGroupActivatedIndex.value}-$val"] =
            chapterCacheActivatedIndex;
      }
      chapterActivatedIndex.value = chapterCacheActivatedIndex;
    });
    ever(chapterActivatedIndex, (val) {
      if (val >= 0) {
        onChapterTapped();
      }
    });
  }

  // 点击章节时：将激活状态同步到播放状态
  void onChapterTapped() {
    resourcePlayingState.value = ResourcePlayStateModel(
      apiIndex: apiActivatedIndex.value,
      apiGroupIndex: apiGroupActivatedIndex.value,
      chapterGroupIndex: chapterGroupActivatedIndex.value,
      chapterIndex: chapterActivatedIndex.value,
    );

    // activatedChapter = "";

    _apiToApiGroupCache.clear();
    _apiToApiGroupCache[apiActivatedIndex.value] = apiGroupActivatedIndex.value;
    _apiGroupToChapterGroupCache.clear();
    _apiGroupToChapterGroupCache["${apiActivatedIndex.value}-${apiGroupActivatedIndex.value}"] =
        chapterGroupActivatedIndex.value;
    _chapterGroupToChapterCache.clear();
    _chapterGroupToChapterCache["${apiActivatedIndex.value}-${apiGroupActivatedIndex.value}-${chapterGroupActivatedIndex.value}"] =
        chapterActivatedIndex.value;
  }

  ResourcePlayStateModel? playStateModel;

  final videoModel = Rx<VideoModel?>(null);

  // 播放列表
  final chapterList = Rx<List<ResourceChapterModel>?>(null);

  List<PlaySourceModel>? get playSourceList {
    if (videoModel.value == null) {
      return null;
    }
    return videoModel.value!.playSourceList;
  }

  bool get createApiWidget {
    return !(playSourceList == null ||
        playSourceList!.isEmpty ||
        (playSourceList!.length == 1 && playSourceList!.first.api == null));
  }

  // 激活的播放源
  PlaySourceModel? get activatedApi {
    return playSourceList == null || playSourceList!.isEmpty
        ? null
        : playSourceList![apiActivatedIndex.value];
  }

  // 播放源组列表
  List<PlaySourceGroupModel> get sourceGroupList {
    if (activatedApi == null) {
      return [];
    }
    return activatedApi!.playSourceGroupList;
  }

  // 激活的播放源组
  PlaySourceGroupModel? get activatedSourceGroup {
    if (sourceGroupList.isEmpty) {
      return null;
    }
    var index = apiGroupActivatedIndex.value;
    if (index < 0) {
      index = 0;
    }
    return sourceGroupList[index];
  }

  // 章节组
  List<ChapterGroupModel> get chapterGroupList {
    List<ResourceChapterModel> chapters = [];
    if (playSourceList == null || playSourceList!.isEmpty) {
      chapters = chapterList.value ?? [];
    } else {
      if (activatedSourceGroup == null) {
        return [];
      }
      chapters = activatedSourceGroup!.chapterList;
    }
    if (chapters.isEmpty) {
      return [];
    }

    List<ChapterGroupModel> list = [];
    int groupCount = (chapters.length / WidgetStyleCommons.chapterGroupCount)
        .ceil();
    for (int i = 0; i < groupCount; i++) {
      int start = i * WidgetStyleCommons.chapterGroupCount + 1;
      int end = start + WidgetStyleCommons.chapterGroupCount - 1;
      if (end > chapters.length) {
        end = chapters.length;
      }
      String name = "${start.toString()}至${end.toString()}";
      list.add(
        ChapterGroupModel(
          id: i.toString(),
          name: name,
          chapterList: chapters.sublist(start - 1, end),
        ),
      );
    }
    return list;
  }

  // 激活的章节组
  ChapterGroupModel? get activatedChapterGroup {
    if (chapterGroupList.isEmpty) {
      return null;
    }
    var index = chapterGroupActivatedIndex.value;
    if (index < 0) {
      index = 0;
    }
    return chapterGroupList[index];
  }

  int get chapterCount {
    if (playSourceList == null || playSourceList!.isEmpty) {
      return chapterList.value?.length ?? 0;
    } else {
      if (activatedSourceGroup == null) {
        return 0;
      }
      return activatedSourceGroup!.chapterList.length;
    }
  }

  List<ResourceChapterModel> get chapterGroupChapterList {
    if (activatedChapterGroup == null) {
      return [];
    }
    return activatedChapterGroup!.chapterList;
  }

  List<ResourceChapterModel> get activatedChapterList {
    if (playSourceList == null || playSourceList!.isEmpty) {
      return chapterList.value ?? [];
    } else {
      var api = playSourceList![resourcePlayingState.value.apiIndex];
      var playSourceGroupList = api.playSourceGroupList;
      return playSourceGroupList[resourcePlayingState.value.apiGroupIndex]
          .chapterList;
    }
  }

  int get maxChapterTitleLen {
    int max = 0;
    for (var value in activatedChapterList) {
      var length = value.name.length;
      if (length > max) {
        max = length;
      }
    }
    return max;
  }

  ResourceChapterModel? get activatedChapter {
    List<ResourceChapterModel> chapters = activatedChapterList;
    return chapters[resourcePlayingState.value.chapterIndex];
  }

  String get playTitle {
    String title = activatedChapter?.name ?? "";
    if (videoModel.value != null) {
      String name = videoModel.value!.name;
      if (name.isEmpty) {
        name = videoModel.value!.enName ?? "";
      }
      if (name.isNotEmpty) {
        title = "$name${title.isEmpty ? "" : "[$title]"}";
      }
    }
    return title;
  }

  // 当前激活的章节中对应激活的章节下标（本组下标，不是全章节下标）
  int get chapterGroupActivatedChapterIndex {
    if (chapterActivatedIndex.value <= 0) {
      return -1;
    }
    var chapterIndex = resourcePlayingState.value.chapterIndex;

    // 因为chapterGroupIndex从0开始，因此不需要先减1再计算
    return chapterIndex -
        (resourcePlayingState.value.chapterGroupIndex *
            WidgetStyleCommons.chapterGroupCount);
  }

  bool get haveNext {
    List<ResourceChapterModel> chapters = activatedChapterList;
    return resourcePlayingState.value.chapterIndex < chapters.length - 1;
  }
}
