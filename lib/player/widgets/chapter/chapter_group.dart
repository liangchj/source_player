import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import '../../../commons/widget_style_commons.dart';
import '../../../widgets/clickable_button_widget.dart';
import '../../controller/player_controller.dart';
import '../../models/play_source_option_model.dart';

class ChapterGroup extends StatefulWidget {
  const ChapterGroup({super.key, required this.option});
  final PlaySourceOptionModel option;

  @override
  State<ChapterGroup> createState() => _ChapterGroupState();
}

class _ChapterGroupState extends State<ChapterGroup> {
  PlaySourceOptionModel get option => widget.option;
  late PlayerController controller;
  ScrollController? _scrollController;
  ListObserverController? _observerController;
  late int _activatedIndex;
  @override
  void initState() {
    controller = Get.find<PlayerController>();
    _activatedIndex =
        controller.resourcePlayState.chapterGroupActivatedIndex.value;
    int initialIndex = _activatedIndex >= 0 ? _activatedIndex : 0;
    _scrollController = ScrollController();
    _observerController = ListObserverController(controller: _scrollController)
      ..initialIndex = initialIndex;

    super.initState();
  }

  @override
  void dispose() {
    int index = controller.resourcePlayState.chapterGroupActivatedIndex.value;
    index = index >= 0 ? index : 0;
    if (_scrollController != null && index != _activatedIndex) {
      option.onDispose?.call(index);
    }
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.resourcePlayState.chapterGroupList.length > 1
          ? DefaultTextStyle(
              style: TextStyle(
                color: controller.playerState.isFullscreen.value
                    ? Colors.white
                    : Colors.black,
              ),
              child: Padding(
                padding: EdgeInsets.only(top: controller.playerState.isFullscreen.value ? WidgetStyleCommons.safeSpace : 0),
                child: _chapterGroup(context),
              ),
            )
          : Container(),
    );
  }

  // 章节分组显示
  Widget _chapterGroup(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: WidgetStyleCommons.safeSpace,
        right: WidgetStyleCommons.safeSpace,
        bottom: WidgetStyleCommons.safeSpace / 2,
      ),
      width: double.infinity,
      height: WidgetStyleCommons.chapterHeight,
      child: Obx(() {
        var list = controller.resourcePlayState.chapterAsc.value
            ? controller.resourcePlayState.chapterGroupList
            : controller.resourcePlayState.chapterGroupList.reversed.toList();
        int activeIndex =
            controller.resourcePlayState.chapterGroupActivatedIndex.value;
        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            scrollbars: false,
            dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
          ),
          child: ListViewObserver(
            controller: _observerController,
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: list.length,
              itemBuilder: (context, index) {
                var item = list[index];
                int realIndex = controller.resourcePlayState.chapterAsc.value
                    ? index
                    : list.length - index - 1;
                return Container(
                  margin: EdgeInsets.only(right: WidgetStyleCommons.safeSpace),
                  child: AspectRatio(
                    aspectRatio: WidgetStyleCommons.chapterGridRatio,
                    child: ClickableButtonWidget(
                      key: ValueKey("chapterGroup_${controller.resourcePlayState.apiActivatedIndex.value}-${controller.resourcePlayState.apiGroupActivatedIndex.value}-$realIndex"),
                      text: item.name,
                      textAlign: TextAlign.center,
                      activated: realIndex == activeIndex,
                      isCard: true,
                      unActivatedTextColor:
                          controller.playerState.isFullscreen.value
                          ? Colors.white
                          : Colors.black,
                      onClick: () {
                        controller
                                .resourcePlayState
                                .chapterGroupActivatedIndex
                                .value =
                            realIndex;
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }
}
