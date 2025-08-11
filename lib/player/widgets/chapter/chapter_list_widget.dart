import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import '../../../commons/widget_style_commons.dart';
import '../../../utils/auto_compute_sliver_grid_count.dart';
import '../../../widgets/chapter/chapter_layout_widget.dart';
import '../../controller/player_controller.dart';
import 'chapter_group_widget.dart';
import 'chapter_widget.dart';

class ChapterListWidget extends StatefulWidget {
  const ChapterListWidget({
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
  State<ChapterListWidget> createState() => _ChapterListWidgetState();
}

class _ChapterListWidgetState extends State<ChapterListWidget> {
  late PlayerController controller;

  ScrollController? _scrollController;
  ListObserverController? _observerController;
  GridObserverController? _gridObserverController;
  late int _activatedIndex;

  bool _showBottomSheet = false;

  bool _chapterClicked = false;

  @override
  void initState() {
    controller = Get.find<PlayerController>();
    _activatedIndex = controller.resourceState.chapterGroupActivatedChapterIndex;
    int initialIndex = _activatedIndex > 0 ? _activatedIndex : 0;
    _scrollController = ScrollController();
    if (widget.isGrid) {
      _gridObserverController = GridObserverController(
        controller: _scrollController,
      )..initialIndex = initialIndex;
    } else {
      _observerController = ListObserverController(
        controller: _scrollController,
      )..initialIndex = initialIndex;
    }

    everAll([
      controller.resourceState.state.apiActivatedState,
      controller.resourceState.state.sourceGroupActivatedState,
      controller.resourceState.state.chapterGroupActivatedState], (val) {
      if (_chapterClicked) {
        _chapterClicked = false;
        return;
      }
      int index = controller.resourceState.chapterGroupActivatedChapterIndex;
      if (index < 0) {
        index = 0;
      }
      if (!_showBottomSheet) {
        _gridObserverController?.jumpTo(index: index, isFixedHeight: true);
        _observerController?.jumpTo(index: index, isFixedHeight: true);
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    int index = controller.resourceState.chapterGroupActivatedChapterIndex;
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
      () => controller.resourceState.showChapter.value
          ? Column(
            children: [
              _createHeader(context),
              ChapterGroupWidget(
                singleHorizontalScroll: true,
              ),
              widget.bottomSheet
                  ? _bottomSheetList(context)
                  : widget.singleHorizontalScroll
                  ? _horizontalScroll(context)
                  : _list(context),
            ],
          )
          : Container(),
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
          _observerController?.jumpTo(
            index: controller.resourceState.state.chapterActivatedIndex.value,
            isFixedHeight: true,
          );
          _gridObserverController?.jumpTo(
            index: controller.resourceState.state.chapterActivatedIndex.value,
            isFixedHeight: true,
          );
        },
      ),
    ];
    List<Widget> rights = [
      IconButton(
        tooltip: controller.resourceState.chapterAsc.value ? "正序" : "倒叙",
        icon: controller.resourceState.chapterAsc.value
            ? Icon(Icons.upgrade_rounded)
            : Icon(Icons.download_rounded),
        style: ButtonStyle(padding: WidgetStateProperty.all(EdgeInsets.zero)),
        onPressed: () {
          controller.resourceState.chapterAsc(
            !controller.resourceState.chapterAsc.value,
          );
        },
      ),
      if (widget.singleHorizontalScroll)
        TextButton(
          onPressed: () {
            _showBottomSheet = true;
            controller.netResourceDetailController?.bottomSheetController =
                controller.netResourceDetailController?.childKey.currentState
                    ?.showBottomSheet(
                      backgroundColor: Colors.transparent,
                      (context) => Container(
                        color: Colors.white,
                        child: Center(
                          child: ChapterListWidget(
                            onClose: () {
                              controller
                                  .netResourceDetailController
                                  ?.bottomSheetController
                                  ?.close();
                              _showBottomSheet = false;
                            },
                            bottomSheet: true,
                            isGrid: true,
                            onDispose: (index) {
                                _gridObserverController?.jumpTo(
                                  index: index,
                                  isFixedHeight: true,
                                );
                                _observerController?.jumpTo(
                                  index: index,
                                  isFixedHeight: true,
                                );
                            },
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
                  Text("${controller.resourceState.showChapterList.length}集"),
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
      var list = controller.resourceState.chapterAsc.value
          ? controller.resourceState.showChapterGroupChapterList
          : controller.resourceState.showChapterGroupChapterList.reversed
                .toList();
      int activeIndex = controller.resourceState.activatedChapterIndex;
      return ListViewObserver(
        controller: _observerController,
        child: ListView.builder(
          controller: _scrollController,
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
                  _chapterClicked = true;
                  controller.resourceState.state.chapterActivatedIndex(
                    item.index,
                  );
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
      var list = controller.resourceState.chapterAsc.value
          ? controller.resourceState.showChapterGroupChapterList
          : controller.resourceState.showChapterGroupChapterList.reversed
                .toList();
      int activeIndex = controller.resourceState.activatedChapterIndex;
      return GridViewObserver(
        controller: _gridObserverController,
        child: GridView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: WidgetStyleCommons.safeSpace,
            vertical: WidgetStyleCommons.safeSpace,
          ),
          controller: _scrollController,
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
                _chapterClicked = true;
                controller.resourceState.state.chapterActivatedIndex(
                  item.index,
                );
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
        controller: _scrollController,
        child: Obx(() {
          var list = controller.resourceState.chapterAsc.value
              ? controller.resourceState.showChapterGroupChapterList
              : controller.resourceState.showChapterGroupChapterList.reversed
                    .toList();
          int activeIndex = controller.resourceState.activatedChapterIndex;
          return ListViewObserver(
            controller: _observerController,
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount:
                  controller.resourceState.showChapterGroupChapterList.length,
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
                        _chapterClicked = true;
                        controller.resourceState.state.chapterActivatedIndex(
                          item.index,
                        );
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
}
