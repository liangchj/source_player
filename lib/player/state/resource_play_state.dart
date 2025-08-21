import 'package:get/get.dart';

import '../../commons/widget_style_commons.dart';
import '../../models/play_source_group_model.dart';
import '../../models/play_source_model.dart';
import '../../models/resource_chapter_model.dart';
import '../models/chapter_group_model.dart';
import '../models/resource_play_state_model.dart';

class ResourcePlayState {
  var chapterAsc = true.obs;

  // 激活状态（当前展示的索引，用于UI高亮）
  final RxInt apiActivatedIndex = 0.obs;
  final RxInt apiGroupActivatedIndex = 0.obs;
  final RxInt chapterGroupActivatedIndex = 0.obs;
  final RxInt chapterActivatedIndex = 0.obs;

  // 播放状态（复合对象，决定当前播放的内容）
  final Rx<ResourcePlayStateModel> resourcePlayingState = const ResourcePlayStateModel(
    apiIndex: 0,
    apiGroupIndex: 0,
    chapterGroupIndex: 0,
    chapterIndex: 0,
  ).obs;

  // 点击章节时：将激活状态同步到播放状态
  void onChapterTapped() {
    resourcePlayingState.value = ResourcePlayStateModel(
      apiIndex: apiActivatedIndex.value,
      apiGroupIndex: apiGroupActivatedIndex.value,
      chapterGroupIndex: chapterGroupActivatedIndex.value,
      chapterIndex: chapterActivatedIndex.value,
    );
  }


  // 播放源列表
  final playSourceList = <PlaySourceModel>[].obs;

  /*PlaySourceModel? get playingApi {
    return playSourceList.isEmpty ? null : playSourceList[resourcePlayingState.value.apiIndex];
  }*/
  // 激活的播放源
  PlaySourceModel? get activatedApi {
    return playSourceList.isEmpty ? null : playSourceList.value[apiActivatedIndex.value];
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
    return sourceGroupList[apiGroupActivatedIndex.value];
  }

  List<ChapterGroupModel> get chapterGroupList {
    if (activatedSourceGroup == null) {
      return [];
    }
    var chapterList = activatedSourceGroup!.chapterList;
    List<ChapterGroupModel> list = [];

    int groupCount = (chapterList.length / WidgetStyleCommons.chapterGroupCount).ceil();
    for (int i = 0; i < groupCount; i++) {
      int start = i * WidgetStyleCommons.chapterGroupCount + 1;
      int end = start + WidgetStyleCommons.chapterGroupCount - 1;
      if (end > chapterList.length) {
        end = chapterList.length;
      }
      String name = "${start.toString()}至${end.toString()}";
      list.add(ChapterGroupModel(id: i.toString(), name: name, chapterList: chapterList.sublist(start - 1, end)));
    }
    return list;
  }

  // 激活的章节组
  ChapterGroupModel? get activatedChapterGroup {
    if (chapterGroupList.isEmpty) {
      return null;
    }
    return chapterGroupList[chapterGroupActivatedIndex.value];
  }

  int get chapterCount {
    if (activatedSourceGroup == null) {
      return 0;
    }
    return activatedSourceGroup!.chapterList.length;
  }

  List<ResourceChapterModel> get chapterList {
    if (activatedChapterGroup == null) {
      return [];
    }
    return activatedChapterGroup!.chapterList;
  }

}
