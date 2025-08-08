import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import '../../../commons/widget_style_commons.dart';
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
  bool _needCreateLayout = false;
  late int _activatedIndex;
  @override
  void initState() {
    controller = Get.find<PlayerController>();
    _activatedIndex = controller.resourceState.state.value.chapterGroupActivatedIndex;
    _needCreateLayout = controller.resourceState.state.value.chapterGroup > 0;
    if (_needCreateLayout) {
      _scrollController = ScrollController();
      _observerController = ListObserverController(
        controller: _scrollController,
      )..initialIndex = _activatedIndex;
    }

    super.initState();
  }

  @override
  void dispose() {
    if (_scrollController != null &&
        controller.resourceState.state.value.sourceApiActivatedIndex !=
            _activatedIndex) {
      widget.onDispose?.call(
        controller.resourceState.state.value.sourceApiActivatedIndex,
      );
    }
    _scrollController?.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    if (!_needCreateLayout) {
      return Container();
    }
    return Container(
    );
    /*return Container(
      padding: EdgeInsets.only(
        left: WidgetStyleCommons.safeSpace,
        right: WidgetStyleCommons.safeSpace,
        bottom: WidgetStyleCommons.safeSpace / 2,
      ),
      width: double.infinity,
      height: WidgetStyleCommons.chapterHeight,
      child: Obx(() {
        var list = controller.resourceState.chapterAsc.value
            ? controller.resourceState.chapterGroupNameList
            : controller.resourceState.chapterGroupNameList.reversed
            .toList();
        int activeIndex = controller.sourceChapterState.chapterGroupIndex.value;
        // int activeIndex = controller.sourceChapterState.currentActivatedChapterGroupIndex;
        return Scrollbar(
          controller: controller.chapterGroupScrollController,
          child: ListViewObserver(
            controller:
            _chapterGroupObserverController ??
                controller.chapterGroupObserverController,
            child: ListView.builder(
              controller: controller.chapterGroupScrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: list.length,
              itemBuilder: (context, index) {
                var item = list[index];
                int realIndex = controller.sourceChapterState.chapterAsc.value
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
                        controller.sourceChapterState.chapterGroupIndex(
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
    );*/
  }
}
