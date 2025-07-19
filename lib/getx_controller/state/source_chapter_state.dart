
import 'package:get/get.dart';
import 'package:source_player/commons/widget_style_commons.dart';

import '../../models/play_source_group_model.dart';
import '../../models/play_source_model.dart';
import '../../models/resource_chapter_model.dart';
import '../net_resource_detail_controller.dart';

class SourceChapterState {
  final NetResourceDetailController controller;

  SourceChapterState(this.controller);

  // 当前播放
  // 当前播放的网站源索引
  var playedSourceApiIndex = 0.obs;
  // 当前播放的资源组索引
  var playedSourceGroupIndex = 0.obs;
  // 当前播放的章节索引
  var chapterIndex = 0.obs;

  var chapterAsc = true.obs;

  // 当前选中（仅显示选中，不是正在播放的，只有选中章节后才变成播放）
  // 当前选中显示的网站源索引
  var selectedSourceApiIndex = 0.obs;
  // 当前选中的资源组索引
  var selectedSourceGroupIndex = 0.obs;

  // 有多少组章节
  var chapterGroup = 1.obs;
  var chapterGroupIndex = 0.obs;


  // 1. 获取当前播放的网站源
  PlaySourceModel? get currentPlayedSource {
    List<PlaySourceModel>? playSourceList = controller.videoModel.value?.playSourceList;
    if (playSourceList == null || playSourceList.isEmpty) {
      return null;
    }
    return playSourceList[playedSourceApiIndex.value];
  }

  // 2. 获取当前播放网站源下的资源组列表（供资源组选择器使用）
  List<PlaySourceGroupModel> get currentPlayedSourceGroupList {
    return currentPlayedSource?.playSourceGroupList ?? [];
  }

  // 3. 获取当前播放的资源组
  PlaySourceGroupModel? get currentPlayedSourceGroup {
    var list = currentPlayedSourceGroupList;
    return list.length > playedSourceGroupIndex.value ? currentPlayedSourceGroupList[playedSourceGroupIndex.value] : null;
  }

  // 4. 获取当前播放资源组下的章节列表（供章节选择器使用）
  List<ResourceChapterModel> get currentPlayedChapterList {
    return currentPlayedSourceGroup?.chapterList ?? [];
  }

  // 5. 获取当前播放（选中）的章节
  ResourceChapterModel? get currentChapter {
    var list = currentPlayedChapterList;
    return list.length > chapterIndex.value ? currentPlayedChapterList[chapterIndex.value] : null;
  }

  // 当前播放的章节组名称
  String get currentChapterGroupName {
    int start = chapterGroupIndex.value * chapterGroup.value;
    int end = start + WidgetStyleCommons.chapterGroupCount - 1;
    return "$start至$end";
  }

  List<String> get chapterGroupNameList {
    int count = currentPlayedChapterList.length;
    List<String> list = [];
    for (int i = 0; i < chapterGroup.value; i++) {
      int start = i * WidgetStyleCommons.chapterGroupCount + 1;
      int end = start + WidgetStyleCommons.chapterGroupCount - 1;
      if (end > count) {
        end = count;
      }
      String name = "${start.toString()}至${end.toString()}";
      list.add(name);
    }
    return list;
  }

  // 当前选中的章节组
  List<ResourceChapterModel> get currentChapterGroupList {
    var list = currentPlayedChapterList;
    if (chapterGroup.value <= 1) {
      return list;
    }
    int start = chapterGroupIndex.value * WidgetStyleCommons.chapterGroupCount;
    int end = start + WidgetStyleCommons.chapterGroupCount;
    if (end > list.length) {
      end = list.length;
    }
    return list.sublist(start, end);
  }
}