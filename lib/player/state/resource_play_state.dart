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
  final playSourceList = Rx<List<PlaySourceModel>?>(null);

  // 播放列表
  final chapterList = Rx<List<ResourceChapterModel>?>(null);

  bool get createApiWidget {
    return !(playSourceList.value == null || playSourceList.value!.isEmpty ||
        (playSourceList.value!.length == 1 &&
            playSourceList.value!.first.api == null));
  }

  // 激活的播放源
  PlaySourceModel? get activatedApi {
    return playSourceList.value == null || playSourceList.value!.isEmpty ? null : playSourceList.value![apiActivatedIndex.value];
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

  // 章节组
  List<ChapterGroupModel> get chapterGroupList {
    List<ResourceChapterModel> chapters = [];
    if (playSourceList.value == null || playSourceList.value!.isEmpty) {
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
    int groupCount = (chapters.length / WidgetStyleCommons.chapterGroupCount).ceil();
    for (int i = 0; i < groupCount; i++) {
      int start = i * WidgetStyleCommons.chapterGroupCount + 1;
      int end = start + WidgetStyleCommons.chapterGroupCount - 1;
      if (end > chapters.length) {
        end = chapters.length;
      }
      String name = "${start.toString()}至${end.toString()}";
      list.add(ChapterGroupModel(id: i.toString(), name: name, chapterList: chapters.sublist(start - 1, end)));
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
    if (playSourceList.value == null || playSourceList.value!.isEmpty) {
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

}
