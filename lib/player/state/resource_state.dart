import 'package:get/get.dart';

import '../../commons/widget_style_commons.dart';
import '../../models/play_source_group_model.dart';
import '../../models/play_source_model.dart';
import '../../models/resource_chapter_model.dart';
import '../../models/video_model.dart';
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
      int index = state.sourceGroupActivatedState.value?.index ?? 0;
      // 当前组源api下标与显示的api下标相同时，则可以默认选中
      if (state.sourceGroupActivatedState.value?.apiState.index == val.index) {
        if (index < 0) {
          index = 0;
        }
        state.sourceGroupActivatedState(
          state.sourceGroupActivatedState.value!.copyWith(
            activatedIndex: index,
            apiState: val,
          ),
        );
      } else {
        index = -1;
        state.sourceGroupActivatedState(
          state.sourceGroupActivatedState.value!.copyWith(
            index: index,
            apiState: val,
          ),
        );
      }
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
      } else {
        int index =
            state.chapterGroupActivatedState.value?.index ?? 0;
        // 当前资源组下标与显示的资源组下标相同时，则可以默认选中
        if (state.chapterGroupActivatedState.value?.sourceGroupState.index ==
            val.index) {
          if (index < 0) {
            index = 0;
          }
          state.chapterGroupActivatedState(
            state.chapterGroupActivatedState.value!.copyWith(
              activatedIndex: index,
              sourceGroupState: val,
            ),
          );
        } else {
          index = -1;
          /*state.chapterGroupActivatedState(
            state.chapterGroupActivatedState.value!.copyWith(
              index: index,
            ),
          );*/
        }
      }

      if (state.chapterGroupActivatedState.value?.index ==
          state.chapterGroupActivatedState.value?.activatedIndex) {
        int length = activatedChapterList.length;
        int group = (length / WidgetStyleCommons.chapterGroupCount).ceil();
        if (group < 1) {
          group = 1;
        }
        state.showChapterGroup(group);
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
    ever(state.chapterGroupActivatedState, (val) {
      if (val == null) {
        return;
      }
      if (val.index == val.activatedIndex) {
        state.activatedChapterGroup(state.showChapterGroup.value);
        if (state.chapterActivatedIndex < 0) {
          state.chapterActivatedIndex(0);
        }
      }
    });

    // 当选择新的章节时，自动切换资源api、资源组、章节组
    ever(state.chapterActivatedIndex, (val) {
      ActivatedStateModel apiState = state.apiActivatedState.value!.copyWith(
        activatedIndex: state.apiActivatedState.value!.index,
      );
      if (apiState.index != state.apiActivatedState.value!.activatedIndex) {
        state.apiActivatedState(apiState);
      }

      int sourceGroupIndex = activatedSourceGroupIndex;
      SourceGroupActivatedStateModel sourceGroupActivatedStateModel =
      state.sourceGroupActivatedState.value!.copyWith(
        index: sourceGroupIndex >= 0 ? sourceGroupIndex : 0,
        activatedIndex: sourceGroupIndex >= 0 ? sourceGroupIndex : 0,
        apiState: apiState,
      );
      if (sourceGroupIndex < 0 || sourceGroupIndex != state.sourceGroupActivatedState.value?.activatedIndex) {
        state.sourceGroupActivatedState(sourceGroupActivatedStateModel);
      }

      int chapterGroupIndex = activatedChapterGroupIndex;
      ChapterGroupActivatedStateModel chapterGroupActivatedStateModel = state.chapterGroupActivatedState.value!.copyWith(
        index: chapterGroupIndex >= 0 ? chapterGroupIndex : 0,
        activatedIndex: chapterGroupIndex >= 0 ? chapterGroupIndex : 0,
        sourceGroupState: sourceGroupActivatedStateModel,
      );
      if (chapterGroupIndex != state.chapterGroupActivatedState.value?.activatedIndex) {
        state.chapterGroupActivatedState(chapterGroupActivatedStateModel);
      }

    });
  }

  // =============== 资源api START ===============
  List<PlaySourceModel> get playSourceList {
    return videoModel.value?.playSourceList ?? [];
  }

  // 获取当前播放的网站源
  PlaySourceModel? get activatedApiSource {
    List<PlaySourceModel>? playSourceList = videoModel.value?.playSourceList;
    var index = state.apiActivatedState.value?.activatedIndex ?? 0;
    if (index < 0 || playSourceList == null || playSourceList.isEmpty) {
      return null;
    }
    return playSourceList[index];
  }

  // 获取当前展示的网站源
  PlaySourceModel? get showApiSource {
    List<PlaySourceModel>? playSourceList = videoModel.value?.playSourceList;
    var index = state.apiActivatedState.value?.index ?? 0;
    if (index < 0 || playSourceList == null || playSourceList.isEmpty) {
      return null;
    }
    return playSourceList[index];
  }
  // =============== 资源api END ===============

  // =============== 资源api下的资源组 START ===============
  int get activatedSourceGroupIndex {
    int apiIndex = state.apiActivatedState.value?.index ?? 0;
    int groupApiIndex =
        state.sourceGroupActivatedState.value?.apiState.index ?? 0;
    return groupApiIndex == apiIndex
        ? (state.sourceGroupActivatedState.value?.index ?? 0)
        : -1;
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
    return activatedIndex >= 0 && list.length > activatedIndex ? list[activatedIndex] : null;
  }

  // 获取当前展示的资源组
  PlaySourceGroupModel? get showSourceGroup {
    var list = showSourceGroupList;
    int index = state.sourceGroupActivatedState.value?.index ?? 0;
    return index >= 0 && list.length > index ? list[index] : null;
  }

  void updateSourceGroupStateByIndex(int index) {
    var apiState =
    state.apiActivatedState.value ??
    ActivatedStateModel(index: 0, activatedIndex: 0);
    state.sourceGroupActivatedState(
      state.sourceGroupActivatedState.value?.copyWith(index: index, apiState: apiState) ??
          SourceGroupActivatedStateModel(
            index: index,
            activatedIndex: index,
            apiState: apiState,
          ),
    );
  }

  // =============== 资源api下的资源组 END ===============

  // =============== 资源api下的资源组下的章节组 START ===============

  int get activatedChapterGroupIndex {
    int sourceIndex = activatedSourceGroupIndex;
    if (sourceIndex < 0) {
      return -1;
    }
    int sourceGroupIndex = state.sourceGroupActivatedState.value?.index ?? 0;
    int chapterGroupSourceGroupIndex =
        state.chapterGroupActivatedState.value?.sourceGroupState.index ?? 0;
    return chapterGroupSourceGroupIndex == sourceGroupIndex
        ? state.chapterGroupActivatedState.value?.index ?? 0
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
    var sourceGroupState = state.sourceGroupActivatedState.value ??
        SourceGroupActivatedStateModel(
          index: 0,
          activatedIndex: 0,
          apiState:
          state.apiActivatedState.value ??
              ActivatedStateModel(index: 0, activatedIndex: 0),
        );
    state.chapterGroupActivatedState(
      state.chapterGroupActivatedState.value?.copyWith(index: index, sourceGroupState: sourceGroupState) ??
          ChapterGroupActivatedStateModel(
            index: index,
            activatedIndex: index,
            sourceGroupState: sourceGroupState,
          ),
    );
  }

  // =============== 资源api下的资源组下的章节组 END ===============

  // =============== 资源api下的资源组下的章节组下的章节 START ===============
  int get activatedChapterIndex {
    bool apiActivated = state.apiActivatedState.value?.index == state.apiActivatedState.value?.activatedIndex;
    if (!apiActivated) {
      return -1;
    }
    bool sourceGroupActivated = state.sourceGroupActivatedState.value?.index == state.sourceGroupActivatedState.value?.activatedIndex;
    if (!sourceGroupActivated) {
      return -1;
    }
    bool chapterGroupActivated = state.chapterGroupActivatedState.value?.index == state.chapterGroupActivatedState.value?.activatedIndex;
    if (!chapterGroupActivated) {
      return -1;
    }

    int chapterGroupIndex = activatedChapterGroupIndex;
    if (chapterGroupIndex < 0) {
      return -1;
    }

    int chapterGroupSourceGroupIndex = activatedChapterGroupIndex;
    return chapterGroupSourceGroupIndex >= 0
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
    var index = state.showChapterGroup.value;
    if (index <= 1) {
      return showChapterList;
    }
    int chapterGroupIndex = activatedChapterGroupIndex;
    if (chapterGroupIndex < 0) {
      chapterGroupIndex = 0;
    }
    // int chapterGroupIndex = state.chapterGroupActivatedState.value?.index ?? 0;
    List<ResourceChapterModel> list = showChapterList;

    int start = chapterGroupIndex * WidgetStyleCommons.chapterGroupCount;
    int end = start + WidgetStyleCommons.chapterGroupCount;
    if (end > list.length) {
      end = list.length;
    }
    return list.sublist(start, end);
  }

  // 当前激活的章节中对应激活的章节下标（本组下标，不是全章节下标）
  int get chapterGroupActivatedChapterIndex {
    int index = activatedChapterIndex;
    if (index < 0) {
      return index;
    }
    int chapterGroupIndex = activatedChapterGroupIndex;
    if (chapterGroupIndex < 0) {
      return -1;
    }
    // chapterGroupIndex从0开始
    if (state.showChapterGroup.value <= 1) {
      return index;
    }
    // 因为chapterGroupIndex从0开始，因此不需要先减1再计算
    return index - (chapterGroupIndex * WidgetStyleCommons.chapterGroupCount);
  }

  String get chapterUrl {
    int index = state.chapterActivatedIndex.value;
    return index >= 0 ? activatedChapterList[index].playUrl ?? "" : "";
  }


  bool get haveNext {
    int index = state.chapterActivatedIndex.value;
    return index < activatedChapterList.length - 1;
  }

  // =============== 资源api下的资源组下的章节组下的章节 END ===============
}
