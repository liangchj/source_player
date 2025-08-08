
import 'package:get/get.dart';

import '../../models/play_source_group_model.dart';
import '../../models/play_source_model.dart';
import '../../models/resource_chapter_model.dart';
import '../../models/video_model.dart';
import '../models/resource_state_model.dart';

class ResourceState {
  var videoModel = Rx<VideoModel?>(null);

  var chapterAsc = true.obs;

  var state = Rx<ResourceStateModel>(ResourceStateModel(
    sourceApiPlayingIndex: -1,
    sourceApiActivatedIndex: -1,
    sourceGroupPlayingIndex: -1,
    sourceGroupActivatedIndex: -1,
    chapterGroupPlayingIndex: -1,
    chapterGroupActivatedIndex: -1,
    chapterActivatedIndex: -1,
  ));

  // =============== 资源api START ===============
  List<PlaySourceModel> get playSourceList {
    return videoModel.value?.playSourceList ?? [];
  }

  // 获取当前播放的网站源
  PlaySourceModel? get currentPlayingSource {
    List<PlaySourceModel>? playSourceList = videoModel.value?.playSourceList;
    if (playSourceList == null || playSourceList.isEmpty) {
      return null;
    }
    return playSourceList[state.value.sourceApiPlayingIndex];
  }
  // 获取当前展示的网站源
  PlaySourceModel? get currentActivatedSource {
    List<PlaySourceModel>? playSourceList = videoModel.value?.playSourceList;
    if (playSourceList == null || playSourceList.isEmpty) {
      return null;
    }
    return playSourceList[state.value.sourceApiActivatedIndex];
  }
  // =============== 资源api END ===============


  // =============== 资源api下的资源组 START ===============
  //  获取当前播放网站源下的资源组列表（供资源组选择器使用）
  List<PlaySourceGroupModel> get currentPlayingSourceGroupList {
    return currentPlayingSource?.playSourceGroupList ?? [];
  }

  //  获取当前展示的网站源下的资源组列表（供资源组选择器使用）
  List<PlaySourceGroupModel> get currentActivatedSourceGroupList {
    return currentActivatedSource?.playSourceGroupList ?? [];
  }

  // 获取当前播放的资源组
  PlaySourceGroupModel? get currentPlayingSourceGroup {
    var list = currentPlayingSourceGroupList;
    return list.length > state.value.sourceGroupPlayingIndex ? list[state.value.sourceGroupPlayingIndex] : null;
  }

  // 获取当前展示的资源组
  PlaySourceGroupModel? get currentActivatedSourceGroup {
    var list = currentActivatedSourceGroupList;
    return list.length > state.value.sourceGroupActivatedIndex ? list[state.value.sourceGroupActivatedIndex] : null;
  }
  // =============== 资源api下的资源组 END ===============

  // =============== 资源api下的资源组下的章节组 START ===============
  //  获取当前播放的章节组
  /*List<String> get currentPlayingChapterGroupNameList {
    *//*int count = currentPlayedChapterList.length;
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
    return list;*//*
  }*/

  // =============== 资源api下的资源组下的章节组 END ===============

  // =============== 资源api下的资源组下的章节组下的章节 START ===============
  // 获取当前播放资源组下的章节列表（供章节选择器使用）
  List<ResourceChapterModel> get currentPlayingChapterList {
    return currentPlayingSourceGroup?.chapterList ?? [];
  }

  // 获取当前展示资源组下的章节列表（供章节选择器使用）
  List<ResourceChapterModel> get currentActivatedChapterList {
    return currentActivatedSourceGroup?.chapterList ?? [];
  }

  // =============== 资源api下的资源组下的章节组下的章节 END ===============
}

