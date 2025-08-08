import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:source_player/widgets/clickable_button_widget.dart';

import '../../commons/widget_style_commons.dart';
import '../../getx_controller/net_resource_detail_controller.dart';
import '../../utils/auto_compute_sliver_grid_count.dart';
import '../../player/widgets/chapter/chapter_widget.dart';

class ChapterLayoutWidget extends StatefulWidget {
  const ChapterLayoutWidget({
    super.key,
    required this.controller,
    this.onClose,
    this.singleHorizontalScroll = false,
    this.listVerticalScroll = true,
    this.isGrid = false,
    this.bottomSheet = false,
    this.createChapterScrollController = false,
    this.createChapterGroupScrollController = false,
  });
  final NetResourceDetailController controller;
  final VoidCallback? onClose;
  final bool singleHorizontalScroll;
  final bool listVerticalScroll;
  final bool isGrid;
  final bool bottomSheet;
  final bool createChapterScrollController;
  final bool createChapterGroupScrollController;

  @override
  State<ChapterLayoutWidget> createState() => _ChapterLayoutWidgetState();
}

class _ChapterLayoutWidgetState extends State<ChapterLayoutWidget> {
  NetResourceDetailController get controller => widget.controller;
  ScrollController? _chapterGroupScrollController;
  ListObserverController? _chapterGroupObserverController;
  late int _chapterGroupIndex;

  ScrollController? _chapterScrollController;
  ListObserverController? _chapterObserverController;
  GridObserverController? _chapterGridObserverController;
  late int _currentChapterIndex;
  @override
  void initState() {
    _chapterGroupIndex = controller.sourceChapterState.chapterGroupIndex.value;
    if (widget.createChapterGroupScrollController) {
      _chapterGroupScrollController = ScrollController();
      _chapterGroupObserverController = ListObserverController(
        controller: _chapterGroupScrollController,
      )..initialIndex = _chapterGroupIndex;
    }

    _currentChapterIndex = controller.sourceChapterState.chapterIndex.value;
    if (widget.createChapterScrollController || widget.isGrid) {
      _chapterScrollController = ScrollController();
      int activatedIndex =
          controller.sourceChapterState.chapterGroupActivatedChapterIndex;
      if (activatedIndex < 0) {
        activatedIndex = 0;
      }
      if (widget.isGrid) {
        _chapterGridObserverController = GridObserverController(
          controller: _chapterScrollController,
        )..initialIndex = activatedIndex;
      } else {
        _chapterObserverController = ListObserverController(
          controller: _chapterScrollController,
        )..initialIndex = activatedIndex;
      }
    }

    /*ever(controller.sourceChapterState.selectedSourceGroupIndex, (value) {
      int jumpToIndex = -1;
      if (controller.sourceChapterState.playedSourceApiIndex.value != controller.sourceChapterState.selectedSourceApiIndex.value) {
        jumpToIndex = 0;
      } else {
        jumpToIndex = controller.sourceChapterState.chapterGroupActivatedIndex;
      }
      if (jumpToIndex < 0) {
        if (jumpToIndex == -1) {
          return;
        }
        jumpToIndex = 0;
      }
      if (widget.bottomSheet) {
        _chapterGroupObserverController?.jumpTo(
          index: jumpToIndex,
          isFixedHeight: true,
        );
      } else {
        controller.chapterGroupObserverController?.jumpTo(
          index: jumpToIndex,
          isFixedHeight: true,
        );
      }
    });*/

    ever(controller.sourceChapterState.chapterGroupIndex, (value) {
      int jumpToChapterIndex =
          controller.sourceChapterState.chapterGroupActivatedChapterIndex;
      if (jumpToChapterIndex < 0 || jumpToChapterIndex > WidgetStyleCommons.chapterGroupCount) {
        jumpToChapterIndex = 0;
      }
      if (widget.bottomSheet) {
        if (widget.isGrid) {
          _chapterGridObserverController?.jumpTo(
            index: jumpToChapterIndex,
            isFixedHeight: true,
          );
        } else {
          _chapterObserverController?.jumpTo(
            index: jumpToChapterIndex,
            isFixedHeight: true,
          );
        }
      } else {
        controller.chapterObserverController?.jumpTo(
          index: jumpToChapterIndex,
          isFixedHeight: true,
        );
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    if (_chapterGroupScrollController != null &&
        _chapterGroupIndex !=
            controller.sourceChapterState.chapterGroupIndex.value) {
      controller.chapterGroupObserverController?.jumpTo(
        index: controller.sourceChapterState.chapterGroupIndex.value,
        isFixedHeight: true,
      );
    }
    if (((_chapterGridObserverController != null ||
                _chapterObserverController != null) &&
            _currentChapterIndex !=
                controller.sourceChapterState.chapterIndex.value) ||
        (widget.bottomSheet &&
            _chapterGroupIndex !=
                controller.sourceChapterState.chapterGroupIndex.value)) {
      int jumpToChapterIndex =
          controller.sourceChapterState.chapterGroupActivatedChapterIndex;
      if (jumpToChapterIndex < 0) {
        jumpToChapterIndex = 0;
      }
      controller.chapterObserverController?.jumpTo(
        index: jumpToChapterIndex,
        isFixedHeight: true,
      );
    }

    _chapterGroupScrollController?.dispose();
    _chapterScrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _createHeader(context),
        Padding(
          padding: EdgeInsets.only(
            top: widget.bottomSheet
                ? WidgetStyleCommons.safeSpace
                : WidgetStyleCommons.safeSpace / 2,
          ),
          child: Obx(
            () => controller.sourceChapterState.chapterGroup.value > 1
                ? _chapterGroup(context)
                : Container(),
          ),
        ),
        widget.bottomSheet
            ? _bottomSheetList(context)
            : widget.singleHorizontalScroll
            ? _horizontalScroll(context)
            : _list(context),
      ],
    );
  }

  Widget _createHeader(BuildContext context) {
    final theme = Theme.of(context);
    List<Widget> lefts = [
      Text("章节："),
      IconButton(
        tooltip: '跳至顶部',
        icon: Icon(Icons.vertical_align_top),
        style: ButtonStyle(padding: WidgetStateProperty.all(EdgeInsets.zero)),
        onPressed: () {},
      ),
      IconButton(
        tooltip: '跳至底部',
        icon: Icon(Icons.vertical_align_bottom),
        style: ButtonStyle(padding: WidgetStateProperty.all(EdgeInsets.zero)),
        onPressed: () {},
      ),
      IconButton(
        tooltip: '跳至当前',
        icon: Icon(Icons.my_location),
        style: ButtonStyle(padding: WidgetStateProperty.all(EdgeInsets.zero)),
        onPressed: () {
          controller.chapterObserverController?.jumpTo(
            index: controller.sourceChapterState.chapterIndex.value,
            isFixedHeight: true,
          );
        },
      ),
    ];
    List<Widget> rights = [
      IconButton(
        tooltip: controller.sourceChapterState.chapterAsc.value ? "正序" : "倒叙",
        icon: controller.sourceChapterState.chapterAsc.value
            ? Icon(Icons.upgrade_rounded)
            : Icon(Icons.download_rounded),
        style: ButtonStyle(padding: WidgetStateProperty.all(EdgeInsets.zero)),
        onPressed: () {
          controller.sourceChapterState.chapterAsc(
            !controller.sourceChapterState.chapterAsc.value,
          );
        },
      ),
      if (widget.singleHorizontalScroll)
        TextButton(
          onPressed: () {
            controller.bottomSheetController = controller.childKey.currentState
                ?.showBottomSheet(
                  backgroundColor: Colors.transparent,
                  (context) => Container(
                    color: Colors.white,
                    child: Center(
                      child: ChapterLayoutWidget(
                        controller: controller,
                        onClose: () {
                          controller.bottomSheetController?.close();
                        },
                        bottomSheet: true,
                        isGrid: true,
                        createChapterScrollController: true,
                      ),
                    ),
                  ),
                );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "${controller.sourceChapterState.currentPlayedChapterList.length}集",
                  ),
                  Icon(Icons.keyboard_arrow_right_rounded),
                ],
              ),
            ],
          ),
        ),
      if (widget.onClose != null)
        IconButton(
          tooltip: '关闭',
          icon: Icon(Icons.close),
          style: ButtonStyle(padding: WidgetStateProperty.all(EdgeInsets.zero)),
          onPressed: widget.onClose,
        ),
    ];
    return Container(
      height: WidgetStyleCommons.bottomSheetHeaderHeight,
      padding: EdgeInsets.symmetric(horizontal: WidgetStyleCommons.safeSpace),
      decoration: BoxDecoration(
        border: widget.singleHorizontalScroll
            ? null
            : Border(
                bottom: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.1),
                ),
              ),
      ),
      child: Row(children: [...lefts, const Spacer(), ...rights]),
    );
  }

  Widget _list(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsetsGeometry.symmetric(
          vertical: WidgetStyleCommons.safeSpace,
          horizontal: WidgetStyleCommons.safeSpace,
        ),
        child: widget.isGrid ? _gridView(context) : _listView(context),
      ),
    );
  }

  // bottomSheet弹出内容
  Widget _bottomSheetList(BuildContext context) {
    return Expanded(
      child: widget.isGrid ? _gridView(context) : _listView(context),
    );
  }

  // 列表方式
  Widget _listView(BuildContext context) {
    return Obx(() {
      var list = controller.sourceChapterState.chapterAsc.value
          ? controller.sourceChapterState.currentChapterGroupList
          : controller.sourceChapterState.currentChapterGroupList.reversed
                .toList();
      int activeIndex = controller.sourceChapterState.currentActivatedChapterIndex;
      return ListViewObserver(
        controller:
            _chapterObserverController ?? controller.chapterObserverController,
        child: ListView.builder(
          controller:
              _chapterScrollController ?? controller.chapterScrollController,
          padding: EdgeInsets.symmetric(
            horizontal: WidgetStyleCommons.safeSpace,
            vertical: WidgetStyleCommons.safeSpace,
          ),
          itemCount: list.length,
          itemBuilder: (context, index) {
            var item = list[index];
            return Container(
              padding: EdgeInsets.symmetric(
                vertical: WidgetStyleCommons.safeSpace / 2,
              ),
              height: WidgetStyleCommons.chapterHeight,
              child: ChapterWidget(
                chapter: item,
                activated: item.index == activeIndex,
                isCard: true,
                onClick: () {
                  controller.sourceChapterState.chapterIndex(item.index);
                },
              ),
            );
          },
        ),
      );
    });
  }

  // 列表方式（grid）
  Widget _gridView(BuildContext context) {
    return Obx(() {
      var list = controller.sourceChapterState.chapterAsc.value
          ? controller.sourceChapterState.currentChapterGroupList
          : controller.sourceChapterState.currentChapterGroupList.reversed
                .toList();
      int activeIndex = controller.sourceChapterState.currentActivatedChapterIndex;
      return GridViewObserver(
        controller: _chapterGridObserverController,
        child: GridView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: WidgetStyleCommons.safeSpace,
            vertical: WidgetStyleCommons.safeSpace,
          ),
          controller:
              _chapterScrollController ?? controller.chapterScrollController,
          itemCount: list.length,
          gridDelegate: SliverGridDelegateWithExtentAndRatio(
            crossAxisSpacing: WidgetStyleCommons.safeSpace,
            mainAxisSpacing: WidgetStyleCommons.safeSpace,
            maxCrossAxisExtent: WidgetStyleCommons.chapterGridMaxWidth,
            childAspectRatio: WidgetStyleCommons.chapterGridRatio,
          ),
          itemBuilder: (context, index) {
            var item = list[index];
            return ChapterWidget(
              chapter: item,
              activated: item.index == activeIndex,
              isCard: true,
              onClick: () {
                controller.sourceChapterState.chapterIndex(item.index);
              },
            );
          },
        ),
      );
    });
  }

  // 横向滚动
  Widget _horizontalScroll(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: WidgetStyleCommons.safeSpace),
      width: double.infinity,
      height: WidgetStyleCommons.chapterHeight,
      child: Scrollbar(
        controller:
            _chapterScrollController ?? controller.chapterScrollController,
        child: Obx(() {
          var list = controller.sourceChapterState.chapterAsc.value
              ? controller.sourceChapterState.currentChapterGroupList
              : controller.sourceChapterState.currentChapterGroupList.reversed
                    .toList();
          int activeIndex = controller.sourceChapterState.currentActivatedChapterIndex;
          return ListViewObserver(
            controller:
                _chapterObserverController ??
                controller.chapterObserverController,
            child: ListView.builder(
              controller:
                  _chapterScrollController ??
                  controller.chapterScrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount:
                  controller.sourceChapterState.currentChapterGroupList.length,
              itemBuilder: (context, index) {
                var item = list[index];
                return Container(
                  margin: EdgeInsets.only(right: WidgetStyleCommons.safeSpace),
                  child: AspectRatio(
                    aspectRatio: WidgetStyleCommons.chapterGridRatio,
                    child: ChapterWidget(
                      chapter: item,
                      activated: item.index == activeIndex,
                      isCard: true,
                      onClick: () {
                        controller.sourceChapterState.chapterIndex(item.index);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
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
        var list = controller.sourceChapterState.chapterAsc.value
            ? controller.sourceChapterState.chapterGroupNameList
            : controller.sourceChapterState.chapterGroupNameList.reversed
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
    );
  }
}
