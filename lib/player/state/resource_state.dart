import 'package:get/get.dart';

import '../../commons/widget_style_commons.dart';
import '../../models/play_source_group_model.dart';
import '../../models/play_source_model.dart';
import '../../models/resource_chapter_model.dart';
import '../../models/video_model.dart';
import '../controller/player_controller.dart';
import '../models/resource_state_model.dart';

class ResourceState {

  var videoModel = Rx<VideoModel?>(null);

  var showChapter = true.obs;

  var chapterAsc = true.obs;

  var state = ResourceStateModel();

  initEver() {
    ever(videoModel, (val) {
      state.apiActivatedState(ActivatedStateModel(index: 0, activatedIndex: 0));
    });
    // 当前播放资源api状态变动
    ever(state.apiActivatedState, (val) {
      if (val == null) {
        state.apiActivatedState(null);
        return;
      }
      if (state.sourceGroupActivatedState.value == null) {
        state.sourceGroupActivatedState(
          SourceGroupActivatedStateModel(
            index: 0,
            activatedIndex: 0,
            apiState: val,
          ),
        );
        return;
      }
      int index =
          state.sourceGroupActivatedState.value!.index;
      // 当前组源api下标与显示的api下标相同时，则可以默认选中
      if (state.sourceGroupActivatedState.value?.apiState.index == val.index) {
        if (index < 0) {
          index = 0;
        }
        state.sourceGroupActivatedState(
          state.sourceGroupActivatedState.value!.copyWith(activatedIndex: index),
        );
      } else {
        index = -1;
      }
      /*state.sourceGroupActivatedState(
        state.sourceGroupActivatedState.value!.copyWith(index: activatedIndex),
      );*/
    });
    // 当前播放资源api下的资源组状态变动
    ever(state.sourceGroupActivatedState, (val) {
      if (val == null) {
        state.sourceGroupActivatedState(null);
        return;
      }
      if (state.chapterGroupActivatedState.value == null) {
        state.chapterGroupActivatedState(
          ChapterGroupActivatedStateModel(
            index: 0,
            activatedIndex: 0,
            sourceGroupState: val,
          ),
        );
        return;
      }
      int activatedIndex = val.activatedIndex;
      // 当前资源组下标与显示的资源组下标相同时，则可以默认选中
      if (state.chapterGroupActivatedState.value?.sourceGroupState.index ==
          val.index) {
        if (activatedIndex < 0) {
          activatedIndex = 0;
        }
      } else {
        activatedIndex = -1;
      }
      state.chapterGroupActivatedState(
        state.chapterGroupActivatedState.value!.copyWith(index: activatedIndex),
      );

      if (state.chapterGroupActivatedState.value?.index ==
          state.chapterGroupActivatedState.value?.activatedIndex) {
        int length = activatedChapterList.length;
        int group = (length / WidgetStyleCommons.chapterGroupCount).ceil();
        if (group < 1) {
          group = 1;
        }
        state.activatedChapterGroup(group);
      } else {
        int length = showChapterList.length;
        int group = (length / WidgetStyleCommons.chapterGroupCount).ceil();
        if (group < 1) {
          group = 1;
        }
        state.showChapterGroup(group);
      }
    });

    // 当前播放资源api下的资源组下的章节组状态变动
    ever(state.chapterGroupActivatedState, (val) {});


    // 当选择新的章节时，自动切换资源api、资源组、章节组
    ever(state.chapterActivatedIndex, (val) {
      state.apiActivatedState(state.apiActivatedState.value?.copyWith(
        activatedIndex: state.apiActivatedState.value?.index ?? 0,
      ));
      state.sourceGroupActivatedState(
        state.sourceGroupActivatedState.value?.copyWith(
          activatedIndex: state.sourceGroupActivatedState.value?.index ?? 0,
        ),
      );
      state.chapterGroupActivatedState(
        state.chapterGroupActivatedState.value?.copyWith(
          activatedIndex: state.chapterGroupActivatedState.value?.index ?? 0,
        ),
      );
    });
  }

  // =============== 资源api START ===============
  List<PlaySourceModel> get playSourceList {
    return videoModel.value?.playSourceList ?? [];
  }

  // 获取当前播放的网站源
  PlaySourceModel? get activatedApiSource {
    List<PlaySourceModel>? playSourceList = videoModel.value?.playSourceList;
    if (playSourceList == null || playSourceList.isEmpty) {
      return null;
    }
    return playSourceList[state.apiActivatedState.value?.activatedIndex ?? 0];
  }

  // 获取当前展示的网站源
  PlaySourceModel? get showApiSource {
    List<PlaySourceModel>? playSourceList = videoModel.value?.playSourceList;
    if (playSourceList == null || playSourceList.isEmpty) {
      return null;
    }
    return playSourceList[state.apiActivatedState.value?.index ?? 0];
  }
  // =============== 资源api END ===============

  // =============== 资源api下的资源组 START ===============
  int get activatedSourceGroupIndex {
    int apiIndex = state.apiActivatedState.value?.index ?? 0;
    int groupApiIndex = state.sourceGroupActivatedState.value?.apiState.index ?? 0;
    return groupApiIndex == apiIndex ? (state.sourceGroupActivatedState.value?.index ?? 0) : -1;
  }

  // 获取当前播放网站源下的资源组列表（供资源组选择器使用）
  List<PlaySourceGroupModel> get activatedSourceGroupList {
    return activatedApiSource?.playSourceGroupList ?? [];
  }

  //  获取当前展示的网站源下的资源组列表（供资源组选择器使用）
  List<PlaySourceGroupModel> get showSourceGroupList {
    return showApiSource?.playSourceGroupList ?? [];
  }

  // 获取当前播放的资源组
  PlaySourceGroupModel? get activatedSourceGroup {
    var list = activatedSourceGroupList;
    int activatedIndex =
        state.sourceGroupActivatedState.value?.activatedIndex ?? 0;
    return list.length > activatedIndex ? list[activatedIndex] : null;
  }

  // 获取当前展示的资源组
  PlaySourceGroupModel? get showSourceGroup {
    var list = showSourceGroupList;
    int index = state.sourceGroupActivatedState.value?.index ?? 0;
    return list.length > index ? list[index] : null;
  }

  void updateSourceGroupStateByIndex(int index) {
    state.sourceGroupActivatedState(
      state.sourceGroupActivatedState.value?.copyWith(index: index) ??
          SourceGroupActivatedStateModel(
            index: index,
            activatedIndex: index,
            apiState:
                state.apiActivatedState.value ??
                ActivatedStateModel(index: 0, activatedIndex: 0),
          ),
    );
  }

  // =============== 资源api下的资源组 END ===============

  // =============== 资源api下的资源组下的章节组 START ===============

  int get activatedChapterGroupIndex {
    int sourceGroupIndex = state.sourceGroupActivatedState.value?.index ?? 0;
    int chapterGroupSourceGroupIndex =
        state.chapterGroupActivatedState.value?.index ?? 0;
    return chapterGroupSourceGroupIndex == sourceGroupIndex
        ? chapterGroupSourceGroupIndex
        : -1;
  }

  //  获取当前播放的章节组
  List<String> get activatedChapterGroupNameList {
    int count = activatedChapterList.length;
    List<String> list = [];
    for (int i = 0; i < state.activatedChapterGroup.value; i++) {
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

  //  获取展示播放的章节组
  List<String> get showChapterGroupNameList {
    int count = showChapterList.length;
    List<String> list = [];
    for (int i = 0; i < state.showChapterGroup.value; i++) {
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

  void updateChapterGroupStateByIndex(int index) {
    state.chapterGroupActivatedState(
      state.chapterGroupActivatedState.value?.copyWith(activatedIndex: index) ??
          ChapterGroupActivatedStateModel(
            index: index,
            activatedIndex: index,
            sourceGroupState:
                state.sourceGroupActivatedState.value ??
                SourceGroupActivatedStateModel(
                  index: 0,
                  activatedIndex: 0,
                  apiState:
                      state.apiActivatedState.value ??
                      ActivatedStateModel(index: 0, activatedIndex: 0),
                ),
          ),
    );
  }

  // =============== 资源api下的资源组下的章节组 END ===============

  // =============== 资源api下的资源组下的章节组下的章节 START ===============
  int get activatedChapterIndex {
    int chapterGroupSourceGroupIndex =
        state.chapterGroupActivatedState.value?.index ?? 0;
    int chapterGroupSourceGroupActivatedIndex =
        state.chapterGroupActivatedState.value?.activatedIndex ?? 0;
    return chapterGroupSourceGroupIndex == chapterGroupSourceGroupActivatedIndex
        ? state.chapterActivatedIndex.value
        : -1;
  }

  // 获取当前播放资源组下的章节列表（供章节选择器使用）
  List<ResourceChapterModel> get activatedChapterList {
    return activatedSourceGroup?.chapterList ?? [];
  }

  // 获取当前播放资源组下的章节组下的章节列表（供章节选择器使用）
  List<ResourceChapterModel> get activatedChapterGroupChapterList {
    int chapterGroupIndex = activatedChapterGroupIndex;
    if (chapterGroupIndex <= 1) {
      return activatedChapterList;
    }

    List<ResourceChapterModel> list = activatedChapterList;

    int start = chapterGroupIndex * WidgetStyleCommons.chapterGroupCount;
    int end = start + WidgetStyleCommons.chapterGroupCount;
    if (end > list.length) {
      end = list.length;
    }
    return list.sublist(start, end);
  }

  // 获取当前展示资源组下的章节列表（供章节选择器使用）
  List<ResourceChapterModel> get showChapterList {
    return showSourceGroup?.chapterList ?? [];
  }

  // 获取当前展示资源组下的章节组下的章节列表（供章节选择器使用）
  List<ResourceChapterModel> get showChapterGroupChapterList {
    int chapterGroupIndex = state.chapterGroupActivatedState.value?.index ?? 0;
    if (chapterGroupIndex <= 1) {
      return showChapterList;
    }
    List<ResourceChapterModel> list = showChapterList;

    int start = chapterGroupIndex * WidgetStyleCommons.chapterGroupCount;
    int end = start + WidgetStyleCommons.chapterGroupCount;
    if (end > list.length) {
      end = list.length;
    }
    return list.sublist(start, end);
  }

  // =============== 资源api下的资源组下的章节组下的章节 END ===============
}
