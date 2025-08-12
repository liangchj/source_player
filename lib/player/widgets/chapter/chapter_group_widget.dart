import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import '../../../commons/widget_style_commons.dart';
import '../../../widgets/clickable_button_widget.dart';
import '../../controller/player_controller.dart';

class ChapterGroupWidget extends StatefulWidget {
  const ChapterGroupWidget({
    super.key,
    this.onClose,
    this.singleHorizontalScroll = false,
    this.listVerticalScroll = true,
    this.isGrid = false,
    this.bottomSheet = false,
    this.onDispose,
  });
  final VoidCallback? onClose;
  final bool singleHorizontalScroll;
  final bool listVerticalScroll;
  final bool isGrid;
  final bool bottomSheet;
  final Function(int)? onDispose;

  @override
  State<ChapterGroupWidget> createState() => _ChapterGroupWidgetState();
}

class _ChapterGroupWidgetState extends State<ChapterGroupWidget> {
  late PlayerController controller;
  ScrollController? _scrollController;
  ListObserverController? _observerController;
  late int _activatedIndex;
  @override
  void initState() {
    controller = Get.find<PlayerController>();
    _activatedIndex = controller.resourceState.activatedChapterGroupIndex;
    int initialIndex = _activatedIndex >= 0 ? _activatedIndex : 0;
    _scrollController = ScrollController();
    _observerController = ListObserverController(controller: _scrollController)
      ..initialIndex = initialIndex;

    everAll([
      controller.resourceState.state.apiActivatedState,
      controller.resourceState.state.sourceGroupActivatedState], (val) {
      int index = controller.resourceState.activatedChapterGroupIndex;
      if (index < 0) {
        index = 0;
      }
      _observerController?.jumpTo(index: index, isFixedHeight: true);
    });
    super.initState();
  }

  @override
  void dispose() {
    int index = controller.resourceState.activatedChapterGroupIndex;
    index = index >= 0 ? index : 0;
    if (_scrollController != null && index != _activatedIndex) {
      widget.onDispose?.call(index);
    }
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.resourceState.state.showChapterGroup > 1
          ? _chapterGroup(context)
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
        var list = controller.resourceState.chapterAsc.value
            ? controller.resourceState.showChapterGroupNameList
            : controller.resourceState.showChapterGroupNameList.reversed
                  .toList();
        int activeIndex = controller.resourceState.activatedChapterGroupIndex;
        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.mouse,
              PointerDeviceKind.touch,
            },
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
                int realIndex = controller.resourceState.chapterAsc.value
                    ? index
                    : list.length - index - 1;
                return Container(
                  margin: EdgeInsets.only(right: WidgetStyleCommons.safeSpace),
                  child: AspectRatio(
                    aspectRatio: WidgetStyleCommons.chapterGridRatio,
                    child: ClickableButtonWidget(
                      text: item,
                      textAlign: TextAlign.center,
                      activated: realIndex == activeIndex,
                      isCard: true,
                      onClick: () {
                        controller.resourceState.updateChapterGroupStateByIndex(
                          realIndex,
                        );
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
