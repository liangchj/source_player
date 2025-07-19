import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../commons/widget_style_commons.dart';
import '../../getx_controller/net_resource_detail_controller.dart';
import '../../utils/auto_compute_sliver_grid_count.dart';
import '../clickable_button_widget.dart';

class PlaySourceGroupWidget extends StatelessWidget {
  const PlaySourceGroupWidget({
    super.key,
    required this.controller,
    this.onClose,
    this.singleHorizontalScroll = false,
    this.listVerticalScroll = true,
    this.isGrid = false,
    this.isSelect = false,
    this.bottomSheet = false,
  });
  final NetResourceDetailController controller;
  final VoidCallback? onClose;
  final bool singleHorizontalScroll;
  final bool listVerticalScroll;
  final bool isGrid;
  final bool isSelect;
  final bool bottomSheet;

  @override
  Widget build(BuildContext context) {
    return bottomSheet
        ? _bottomSheetList(context)
        : isSelect
        ? _selectList(context)
        : singleHorizontalScroll
        ? _horizontalScroll(context)
        : _list(context);
  }

  Widget _list(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: EdgeInsetsGeometry.symmetric(
                vertical: WidgetStyleCommons.safeSpace,
              ),
              child: Text(
                "播放组(${controller.sourceChapterState.currentPlayedSourceGroupList.length})：",
              ),
            ),
            Expanded(child: Container()),
          ],
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(
              vertical: WidgetStyleCommons.safeSpace,
              horizontal: WidgetStyleCommons.safeSpace,
            ),
            child: isGrid ? _gridView(context) : _listView(context),
          ),
        ),
      ],
    );
  }

  // bottomSheet弹出内容
  Widget _bottomSheetList(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          height: 45,
          padding: EdgeInsets.symmetric(
            horizontal: WidgetStyleCommons.safeSpace,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.dividerColor.withValues(alpha: 0.1),
              ),
            ),
          ),
          child: Row(
            children: [
              Text(
                "播放组(${controller.sourceChapterState.currentPlayedSourceGroupList.length})",
              ),
              const Spacer(),
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
        ),
        Expanded(child: isGrid ? _gridView(context) : _listView(context)),
      ],
    );
  }

  Widget _selectList(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Text(
                "播放组(${controller.sourceChapterState.currentPlayedSourceGroupList.length})：",
              ),
              Expanded(
                child: Obx(() {
                  return Text(
                    controller
                            .sourceChapterState
                            .currentPlayedSourceGroup
                            ?.name ??
                        "无",
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                  );
                }),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () {
            controller.bottomSheetController = controller
                .childKey
                .currentState
                ?.showBottomSheet(
                  backgroundColor: Colors.transparent,
                  (context) => Container(
                    color: Colors.white,
                    child: PlaySourceGroupWidget(
                      controller: controller,
                      onClose: () =>
                          controller.bottomSheetController?.close(),
                      isSelect: true,
                      bottomSheet: true,
                      isGrid: true,
                    ),
                  ),
                );
          },
          child: Text(
            "切换播放组(${controller.sourceChapterState.currentPlayedSourceGroupList.length})",
          ),
        ),
      ],
    );
  }

  // 列表方式
  Widget _listView(BuildContext context) {
    return ListView.builder(
      controller: controller.playSourceGroupScrollController,
      padding: EdgeInsets.symmetric(
        horizontal: WidgetStyleCommons.safeSpace,
        vertical: WidgetStyleCommons.safeSpace,
      ),
      itemCount:
          controller.sourceChapterState.currentPlayedSourceGroupList.length,
      itemBuilder: (context, index) {
        final item = controller.sourceChapterState.currentPlayedSourceGroupList[index];
        return Obx(
          () => SizedBox(
            height: 44,
            child: ClickableButtonWidget(
              text: item.name ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              activated:
                  index ==
                  controller.sourceChapterState.playedSourceGroupIndex.value,
              isCard: false,
              onClick: () {
                controller.sourceChapterState.playedSourceGroupIndex(index);
              },
            ),
          ),
        );
      },
    );
  }

  // 列表方式
  Widget _gridView(BuildContext context) {
    return Obx(() {
      return GridView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: WidgetStyleCommons.safeSpace,
          vertical: WidgetStyleCommons.safeSpace,
        ),
        controller: ScrollController(),
        itemCount:
            controller.sourceChapterState.currentPlayedSourceGroupList.length,
        gridDelegate: SliverGridDelegateWithExtentAndRatio(
          crossAxisSpacing: WidgetStyleCommons.safeSpace,
          mainAxisSpacing: WidgetStyleCommons.safeSpace,
          maxCrossAxisExtent: WidgetStyleCommons.playSourceGridMaxWidth,
          childAspectRatio: WidgetStyleCommons.playSourceGridRatio,
        ),
        itemBuilder: (context, index) {
          return Obx(() {
            final item = controller.sourceChapterState.currentPlayedSourceGroupList[index];
            return ClickableButtonWidget(
              text: item.name ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              activated:
                  index ==
                  controller.sourceChapterState.playedSourceGroupIndex.value,
              isCard: false,
              textAlign: TextAlign.center,
              onClick: () {
                controller.sourceChapterState.playedSourceGroupIndex(index);
              },
            );
          });
        },
      );
    });
  }

  // 横向滚动
  Widget _horizontalScroll(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Padding(
              padding: EdgeInsetsGeometry.symmetric(
                vertical: WidgetStyleCommons.safeSpace,
              ),
              child: Text(
                "播放组(${controller.sourceChapterState.currentPlayedSourceGroupList.length})：",
              ),
            ),
            Expanded(child: Container()),
          ],
        ),
        SizedBox(
          width: double.infinity,
          height: WidgetStyleCommons.playSourceHeight,
          // height: 40,
          child: Scrollbar(
            controller: controller.playSourceGroupScrollController,
            child: ListView.builder(
              controller: controller.playSourceGroupScrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: controller
                  .sourceChapterState
                  .currentPlayedSourceGroupList
                  .length,
              itemBuilder: (context, index) {
                final item = controller.sourceChapterState.currentPlayedSourceGroupList[index];
                return Obx(() {
                  return Container(
                    margin: EdgeInsets.only(
                      right: WidgetStyleCommons.safeSpace,
                    ),
                    child: AspectRatio(
                      aspectRatio: WidgetStyleCommons.playSourceGridRatio,
                      child: ClickableButtonWidget(
                        text: item.name ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        activated:
                            index ==
                            controller
                                .sourceChapterState
                                .playedSourceGroupIndex
                                .value,
                        isCard: false,
                        textAlign: TextAlign.center,
                        onClick: () {
                          controller.sourceChapterState.playedSourceGroupIndex(
                            index,
                          );
                        },
                      ),
                    ),
                  );
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
