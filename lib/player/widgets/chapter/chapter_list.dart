import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import '../../../commons/widget_style_commons.dart';
import '../../../utils/auto_compute_sliver_grid_count.dart';
import '../../../widgets/chapter/chapter_layout_widget.dart';
import '../../controller/player_controller.dart';
import '../../models/play_source_option_model.dart';
import 'chapter_group_widget.dart';
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

  bool _chapterClicked = false;

  @override
  void initState() {
    controller = Get.find<PlayerController>();
    _activatedIndex = controller.resourcePlayState.chapterActivatedIndex.value;
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

    super.initState();
  }

  @override
  void dispose() {
    int index = controller.resourcePlayState.chapterActivatedIndex.value;
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
                  ChapterGroupWidget(singleHorizontalScroll: true),
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
        onPressed: () {},
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text("${controller.resourcePlayState.chapterCount}集"),
                  Icon(Icons.keyboard_arrow_right_rounded),
                ],
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
      child: Row(children: [...lefts, const Spacer(), ...rights]),
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
        child: option.isGrid ? _gridView(context) : _listView(context),
      ),
    );
  }

  // bottomSheet弹出内容
  Widget _bottomSheetList(BuildContext context) {
    return Expanded(
      child: option.isGrid ? _gridView(context) : _listView(context),
    );
  }

  // 列表方式
  Widget _listView(BuildContext context) {
    return Obx(() {
      var list = controller.resourcePlayState.chapterAsc.value
          ? controller.resourcePlayState.chapterList
          : controller.resourcePlayState.chapterList.reversed.toList();
      int activeIndex =
          controller.resourcePlayState.chapterActivatedIndex.value;
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
                unActivatedTextColor: controller.playerState.isFullscreen.value
                    ? Colors.white
                    : Colors.black,
                onClick: () {
                  _chapterClicked = true;
                  controller.resourcePlayState.chapterActivatedIndex.value =
                      item.index;
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
      var list = controller.resourcePlayState.chapterAsc.value
          ? controller.resourcePlayState.chapterList
          : controller.resourcePlayState.chapterList.reversed.toList();
      int activeIndex =
          controller.resourcePlayState.chapterActivatedIndex.value;
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
              unActivatedTextColor: controller.playerState.isFullscreen.value
                  ? Colors.white
                  : Colors.black,
              onClick: () {
                _chapterClicked = true;
                controller.resourcePlayState.chapterActivatedIndex.value =
                    item.index;
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
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
        ),
        child: Obx(() {
          var list = controller.resourcePlayState.chapterAsc.value
              ? controller.resourcePlayState.chapterList
              : controller.resourcePlayState.chapterList.reversed.toList();
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
                      chapter: item,
                      activated: item.index == activeIndex,
                      isCard: true,
                      unActivatedTextColor:
                          controller.playerState.isFullscreen.value
                          ? Colors.white
                          : Colors.black,
                      onClick: () {
                        _chapterClicked = true;
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
