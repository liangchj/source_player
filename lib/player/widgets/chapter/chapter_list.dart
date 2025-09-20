import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import '../../../commons/widget_style_commons.dart';
import '../../../utils/auto_compute_sliver_grid_count.dart';
import '../../controller/player_controller.dart';
import '../../models/play_source_option_model.dart';
import 'chapter_group.dart';
import 'chapter_widget.dart';

class ChapterList extends StatefulWidget {
  const ChapterList({super.key, required this.option});
  final PlaySourceOptionModel option;

  @override
  State<ChapterList> createState() => _ChapterListState();
}

class _ChapterListState extends State<ChapterList> {
  PlaySourceOptionModel get option => widget.option;
  late PlayerController controller;

  ScrollController? _scrollController;
  ListObserverController? _observerController;
  GridObserverController? _gridObserverController;
  late int _activatedIndex;

  bool _showBottomSheet = false;

  @override
  void initState() {
    controller = Get.find<PlayerController>();
    _activatedIndex =
        controller.resourcePlayState.chapterGroupActivatedChapterIndex;
    int initialIndex = _activatedIndex > 0 ? _activatedIndex : 0;
    _scrollController = ScrollController();
    if (option.isGrid) {
      _gridObserverController = GridObserverController(
        controller: _scrollController,
      )..initialIndex = initialIndex;
    } else {
      _observerController = ListObserverController(
        controller: _scrollController,
      )..initialIndex = initialIndex;
    }

    everAll(
      [
        controller.resourcePlayState.apiActivatedIndex,
        controller.resourcePlayState.apiGroupActivatedIndex,
        controller.resourcePlayState.chapterGroupActivatedIndex,
      ],
      (val) {
        int index =
            controller.resourcePlayState.chapterGroupActivatedChapterIndex;
        if (index == 0 && !controller.resourcePlayState.chapterAsc.value) {
          index = controller.resourcePlayState.chapterGroupChapterList.length;
        }
        if (index < 0) {
          index = 0;
        }
        if (!_showBottomSheet) {
          _gridObserverController?.jumpTo(index: index, isFixedHeight: true);
          _observerController?.jumpTo(index: index, isFixedHeight: true);
        }
      },
    );

    super.initState();
  }

  @override
  void dispose() {
    int index = controller.resourcePlayState.chapterGroupActivatedChapterIndex;
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
      () => controller.resourcePlayState.chapterCount > 1
          ? DefaultTextStyle(
              style: TextStyle(
                color: controller.playerState.isFullscreen.value
                    ? Colors.white
                    : Colors.black,
              ),
              child: Column(
                children: [
                  _createHeader(context),
                  ChapterGroup(option: PlaySourceOptionModel()),
                  option.bottomSheet
                      ? _bottomSheetList(context)
                      : option.singleHorizontalScroll
                      ? _horizontalScroll(context)
                      : _list(context),
                ],
              ),
            )
          : Container(),
    );
  }

  Widget _createHeader(BuildContext context) {
    final theme = Theme.of(context);
    List<Widget> lefts = [
      Text(
        controller.playerState.isFullscreen.value
            ? "章节(${controller.resourcePlayState.chapterCount})："
            : "章节：",
      ),
      IconButton(
        tooltip: '跳至当前',
        icon: Icon(Icons.my_location),
        style: ButtonStyle(padding: WidgetStateProperty.all(EdgeInsets.zero)),
        onPressed: () {
          controller.resourcePlayState.jumpToPlay();
        },
      ),
    ];
    List<Widget> rights = [
      IconButton(
        tooltip: controller.resourcePlayState.chapterAsc.value ? "正序" : "倒叙",
        icon: controller.resourcePlayState.chapterAsc.value
            ? Icon(Icons.upgrade_rounded)
            : Icon(Icons.download_rounded),
        style: ButtonStyle(padding: WidgetStateProperty.all(EdgeInsets.zero)),
        onPressed: () {
          controller.resourcePlayState.chapterAsc(
            !controller.resourcePlayState.chapterAsc.value,
          );
        },
      ),
      if (option.singleHorizontalScroll &&
          !controller.playerState.isFullscreen.value)
        InkWell(
          onTap: () {
            _showBottomSheet = true;
            controller.netResourceDetailController?.bottomSheetController =
                controller.netResourceDetailController?.childKey.currentState
                    ?.showBottomSheet(
                      backgroundColor: Colors.transparent,
                      (context) => Container(
                        color: Colors.white,
                        child: Center(
                          child: ChapterList(
                            option: PlaySourceOptionModel(
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
                      ),
                    );
          },
          child: Row(
            children: [
              Text(
                "${controller.resourcePlayState.chapterCount}集",
                style: TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                Icons.keyboard_arrow_right_rounded,
                color: theme.primaryColor,
              ),
            ],
          ),
        ),
      if (option.onClose != null)
        IconButton(
          tooltip: '关闭',
          icon: Icon(Icons.close),
          style: ButtonStyle(padding: WidgetStateProperty.all(EdgeInsets.zero)),
          onPressed: option.onClose,
        ),
    ];
    return Container(
      height: WidgetStyleCommons.bottomSheetHeaderHeight,
      padding: EdgeInsets.symmetric(horizontal: WidgetStyleCommons.safeSpace),
      decoration: BoxDecoration(
        border: option.singleHorizontalScroll
            ? null
            : Border(
                bottom: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.1),
                ),
              ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              scrollbars: false,
              dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: lefts),
                    Row(children: rights),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _list(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsetsGeometry.symmetric(
          vertical: WidgetStyleCommons.safeSpace,
          horizontal: controller.playerState.isFullscreen.value
              ? 0
              : WidgetStyleCommons.safeSpace,
        ),
        child:
            option.isGrid && controller.resourcePlayState.maxChapterTitleLen < 8
            ? _gridView(context)
            : _listView(context),
      ),
    );
  }

  // bottomSheet弹出内容
  Widget _bottomSheetList(BuildContext context) {
    return Expanded(
      child:
          option.isGrid && controller.resourcePlayState.maxChapterTitleLen < 8
          ? _gridView(context)
          : _listView(context),
    );
  }

  // 列表方式
  Widget _listView(BuildContext context) {
    return Obx(() {
      var list = controller.resourcePlayState.chapterAsc.value
          ? controller.resourcePlayState.chapterGroupChapterList
          : controller.resourcePlayState.chapterGroupChapterList.reversed
                .toList();
      int activeIndex =
          controller.resourcePlayState.chapterActivatedIndex.value;
      return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          scrollbars: false,
          dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
        ),
        child: ListViewObserver(
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
                  vertical: WidgetStyleCommons.safeSpace / 6,
                ),
                // height: WidgetStyleCommons.chapterHeight,
                child: ChapterWidget(
                  key: ValueKey(
                    "chapter_${option.bottomSheet}_listView_${controller.resourcePlayState.apiActivatedIndex.value}-${controller.resourcePlayState.apiGroupActivatedIndex.value}-${controller.resourcePlayState.chapterGroupActivatedIndex.value}-${item.index}",
                  ),
                  chapter: item,
                  textAlign: TextAlign.left,
                  activated: item.index == activeIndex,
                  isCard: true,
                  unActivatedTextColor:
                      controller.playerState.isFullscreen.value
                      ? Colors.white
                      : Colors.black,
                  onClick: () {
                    controller.resourcePlayState.chapterActivatedIndex.value =
                        item.index;
                  },
                ),
              );
            },
          ),
        ),
      );
    });
  }

  // 列表方式（grid）
  Widget _gridView(BuildContext context) {
    return Obx(() {
      var list = controller.resourcePlayState.chapterAsc.value
          ? controller.resourcePlayState.chapterGroupChapterList
          : controller.resourcePlayState.chapterGroupChapterList.reversed
                .toList();
      int activeIndex =
          controller.resourcePlayState.chapterActivatedIndex.value;
      return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          scrollbars: false,
          dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
        ),
        child: GridViewObserver(
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
                key: ValueKey(
                  "chapter_${option.bottomSheet}_gridView_${controller.resourcePlayState.apiActivatedIndex.value}-${controller.resourcePlayState.apiGroupActivatedIndex.value}-${controller.resourcePlayState.chapterGroupActivatedIndex.value}-${item.index}",
                ),
                chapter: item,
                activated: item.index == activeIndex,
                isCard: true,
                unActivatedTextColor: controller.playerState.isFullscreen.value
                    ? Colors.white
                    : Colors.black,
                onClick: () {
                  controller.resourcePlayState.chapterActivatedIndex.value =
                      item.index;
                },
              );
            },
          ),
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
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          scrollbars: false,
          dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
        ),
        child: Obx(() {
          var list = controller.resourcePlayState.chapterAsc.value
              ? controller.resourcePlayState.chapterGroupChapterList
              : controller.resourcePlayState.chapterGroupChapterList.reversed
                    .toList();
          int activeIndex =
              controller.resourcePlayState.chapterActivatedIndex.value;
          return ListViewObserver(
            controller: _observerController,
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: list.length,
              itemBuilder: (context, index) {
                var item = list[index];
                return Container(
                  margin: EdgeInsets.only(right: WidgetStyleCommons.safeSpace),
                  child: AspectRatio(
                    aspectRatio: WidgetStyleCommons.chapterGridRatio,
                    child: ChapterWidget(
                      key: ValueKey(
                        "chapter_horizontalScroll_${controller.resourcePlayState.apiActivatedIndex.value}-${controller.resourcePlayState.apiGroupActivatedIndex.value}-${controller.resourcePlayState.chapterGroupActivatedIndex.value}-${item.index}",
                      ),
                      chapter: item,
                      activated: item.index == activeIndex,
                      isCard: true,
                      unActivatedTextColor:
                          controller.playerState.isFullscreen.value
                          ? Colors.white
                          : Colors.black,
                      onClick: () {
                        controller
                                .resourcePlayState
                                .chapterActivatedIndex
                                .value =
                            item.index;
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
