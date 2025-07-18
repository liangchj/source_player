import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:source_player/commons/widget_style_commons.dart';
import 'package:source_player/widgets/chapter/chapter_widget.dart';

import '../../getx_controller/net_resource_detail_controller.dart';
import '../../utils/auto_compute_sliver_grid_count.dart';

class ChapterListWidget extends StatelessWidget {
  const ChapterListWidget({
    super.key,
    required this.controller,
    this.fontColor,
    this.singleHorizontalScroll = false,
    this.onClose,
  });
  final NetResourceDetailController controller;
  final Color? fontColor;
  final bool singleHorizontalScroll;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // return resourceGridViewLayout();
    // return resourceNormalLayout();
    if (singleHorizontalScroll) {
      return _singleHorizontalScroll(theme);
    }
    return _resourceGridViewLayout(theme);
  }

  Widget _createHeader(ThemeData theme, {bool singleHorizontalScroll = false}) {
    List<Widget> lefts = singleHorizontalScroll ? [
      Text("选集"),
    ] : [
      Text("选集"),
      SizedBox(
        width: 34,
        height: 34,
        child: IconButton(
          tooltip: '跳至顶部',
          icon: Icon(Icons.vertical_align_top),
          style: ButtonStyle(
            padding: WidgetStateProperty.all(EdgeInsets.zero),
          ),
          onPressed: () {},
        ),
      ),
      SizedBox(
        width: 34,
        height: 34,
        child: IconButton(
          tooltip: '跳至底部',
          icon: Icon(Icons.vertical_align_bottom),
          style: ButtonStyle(
            padding: WidgetStateProperty.all(EdgeInsets.zero),
          ),
          onPressed: () {},
        ),
      ),
      SizedBox(
        width: 34,
        height: 34,
        child: IconButton(
          tooltip: '跳至当前',
          icon: Icon(Icons.my_location),
          style: ButtonStyle(
            padding: WidgetStateProperty.all(EdgeInsets.zero),
          ),
          onPressed: () {},
        ),
      ),
    ];
    return Container(
      height: 45,
      padding: EdgeInsets.symmetric(horizontal: WidgetStyleCommons.safeSpace),
      decoration: BoxDecoration(
        border: singleHorizontalScroll ? null : Border(
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          ...lefts,
          const Spacer(),
          Obx(
            () => SizedBox(
              width: 34,
              height: 34,
              child: IconButton(
                tooltip: controller.sourceChapterState.chapterAsc.value
                    ? "正序"
                    : "倒叙",
                icon: controller.sourceChapterState.chapterAsc.value
                    ? Icon(Icons.upgrade_rounded)
                    : Icon(Icons.download_rounded),
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(EdgeInsets.zero),
                ),
                onPressed: () {
                  controller.sourceChapterState.chapterAsc(
                    !controller.sourceChapterState.chapterAsc.value,
                  );
                },
              ),
            ),
          ),
          if (singleHorizontalScroll)
            TextButton(
              onPressed: () {
                controller.bottomSheetController = controller
                    .childKey
                    .currentState
                    ?.showBottomSheet(
                  backgroundColor: Colors.transparent,
                      (context) => Container(
                                          color: Colors.white,
                                          child: Center(
                      child: ChapterListWidget(
                        controller: controller,
                        onClose: () {
                          controller.bottomSheetController?.close();
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
                      Text(
                        "${controller.sourceChapterState.currentPlayedChapterList.length}集",
                      ),

                      Icon(Icons.keyboard_arrow_right_rounded),
                    ],
                  ),
                ],
              ),
            ),
          if (onClose != null)
            SizedBox(
              width: 34,
              height: 34,
              child: IconButton(
                tooltip: '关闭',
                icon: Icon(Icons.close),
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(EdgeInsets.zero),
                ),
                onPressed: onClose,
              ),
            ),
        ],
      ),
    );
  }

  Widget _singleHorizontalScroll(ThemeData theme) {
    return Column(
      children: [
        _createHeader(theme, singleHorizontalScroll:  true),
        Container(
          padding: EdgeInsets.symmetric(vertical: WidgetStyleCommons.cardSpace, horizontal: WidgetStyleCommons.safeSpace),
          width: double.infinity,
          height: WidgetStyleCommons.chapterHeight,
          child: ListViewObserver(
            controller: controller.chapterObserverController,
            child: Scrollbar(
              controller: controller.chapterScrollController,
              child: ListView.builder(
                controller: controller.chapterScrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount:
                    controller.sourceChapterState.currentPlayedChapterList.length,
                itemBuilder: (context, index) {
                  return Obx(() {
                    var list = controller.sourceChapterState.chapterAsc.value
                        ? controller.sourceChapterState.currentPlayedChapterList
                        : controller
                        .sourceChapterState
                        .currentPlayedChapterList
                        .reversed
                        .toList();
                    var item = list[index];
                    controller.showBottomSheet(true);
                    return Container(
                      margin: EdgeInsets.only(right: WidgetStyleCommons.safeSpace),
                      child: AspectRatio(
                        aspectRatio: WidgetStyleCommons.chapterGridRatio,
                        child: ChapterWidget(
                          chapter: item,
                          activated: item.index ==
                              controller.sourceChapterState.chapterIndex.value,
                          isCard: true,
                          onClick: () {
                            controller.sourceChapterState.chapterIndex(item.index);
                          },
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 资源章节网格排版
  Widget _resourceGridViewLayout(ThemeData theme) {
    return Material(
      child: Column(
        children: [
          _createHeader(theme),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: WidgetStyleCommons.safeSpace,
                horizontal: WidgetStyleCommons.safeSpace,
              ),
              child: Obx(() {
                var chapterList =
                    controller.sourceChapterState.currentPlayedChapterList;
                if (chapterList.isEmpty) {
                  return Container();
                }
                // return Container();
                int len = chapterList.length;
                bool chapterAsc =
                    controller.sourceChapterState.chapterAsc.value;

                return GridView.builder(
                  controller: ScrollController(),
                  itemCount: len,
                  gridDelegate: SliverGridDelegateWithExtentAndRatio(
                    crossAxisSpacing: WidgetStyleCommons.safeSpace,
                    mainAxisSpacing: WidgetStyleCommons.safeSpace,
                    maxCrossAxisExtent: WidgetStyleCommons.chapterGridMaxWidth,
                    childAspectRatio: WidgetStyleCommons.chapterGridRatio,
                  ),
                  itemBuilder: (context, index) {
                    return Obx(() {
                      // var ascIndex = chapterAsc ? index : len - index - 1;
                      // var e = chapterList[ascIndex];
                      var list = controller.sourceChapterState.chapterAsc.value
                          ? controller.sourceChapterState.currentPlayedChapterList
                          : controller
                          .sourceChapterState
                          .currentPlayedChapterList
                          .reversed
                          .toList();
                      var item = list[index];
                      return ChapterWidget(
                        chapter: item,
                        activated: item.index ==
                            controller.sourceChapterState.chapterIndex.value,
                        isCard: true,
                        onClick: () {
                          controller.sourceChapterState.chapterIndex(item.index);
                        },
                      );
                    });
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  /*
  /// 普通列表排版
  Widget resourceNormalLayout() {
    double fontSize = 18;
    return Obx(() {
      if (chapterList == null || chapterList!.isEmpty) {
        return Container();
      }

      int len = chapterList!.length;
      bool chapterAsc = controller.chapterAsc.value;

      return ListView.builder(
        key: Key('${controller.selectedChapterIndex.value}'),
        prototypeItem: const ListTile(title: Text("章节")),
        itemCount: len,
        itemBuilder: (context, index) {
          var ascIndex = chapterAsc ? index : len - index - 1;
          ResourceChapterModel chapterModel = chapterList![ascIndex];
          double iconOpacity = chapterModel.playing ? 1.0 : 0;
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
            child: TextButtonWidget(
              mainAxisAlignment: MainAxisAlignment.start,
              text: chapterModel.name,
              activated: chapterModel.activated,
              fontColor:  fontColor ?? Colors.black,
              fn: () {
                if (!chapterModel.activated) {
                  controller.selectedChapter(chapterModel.index);
                }
              },
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              left: Icon(
                Icons.play_arrow_rounded,
                size: fontSize,
                color: Colors.redAccent.withOpacity(iconOpacity),
              ),
            ),
          );
        },
      );
    });
  }*/
}
