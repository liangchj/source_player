import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../commons/widget_style_commons.dart';
import '../../getx_controller/net_resource_detail_controller.dart';
import '../../utils/auto_compute_sliver_grid_count.dart';
import '../clickable_button_widget.dart';

class PlaySourceApiWidget extends StatelessWidget {
  const PlaySourceApiWidget({
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
        : singleHorizontalScroll ? _horizontalScroll(context)
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
              child: Text("播放源(${controller.videoModel.value?.playSourceList?.length ?? 0})："),
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
                "播放源(${controller.videoModel.value?.playSourceList?.length ?? 0})",
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
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(
        vertical: WidgetStyleCommons.safeSpace,
        horizontal: WidgetStyleCommons.safeSpace,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Text("播放源(${controller.videoModel.value?.playSourceList?.length ?? 0})："),
                Expanded(
                  child: Obx(() {
                    return Text(
                      controller
                              .sourceChapterState
                              .currentPlayedSource
                              ?.api!
                              .apiBaseModel
                              .name ??
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
                      child: PlaySourceApiWidget(
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
              "切换播放源(${controller.videoModel.value?.playSourceList?.length ?? 0})",
            ),
          ),
        ],
      ),
    );
  }

  // 列表方式
  Widget _listView(BuildContext context) {
    return ListView.builder(
      controller: controller.playSourceApiScrollController,
      padding: EdgeInsets.symmetric(
        horizontal: WidgetStyleCommons.safeSpace,
        vertical: WidgetStyleCommons.safeSpace,
      ),
      itemCount: controller.videoModel.value?.playSourceList?.length ?? 0,
      itemBuilder: (context, index) {
        final item = controller.videoModel.value?.playSourceList?[index];
        return Obx(
          () => SizedBox(
            height: 44,
            child: ClickableButtonWidget(
              text: item?.api?.apiBaseModel.name ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              activated:
                  index ==
                  controller.sourceChapterState.playedSourceApiIndex.value,
              isCard: false,
              onClick: () {
                controller.sourceChapterState.playedSourceApiIndex(index);
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
        itemCount: controller.videoModel.value?.playSourceList?.length ?? 0,
        gridDelegate: SliverGridDelegateWithExtentAndRatio(
          crossAxisSpacing: WidgetStyleCommons.safeSpace,
          mainAxisSpacing: WidgetStyleCommons.safeSpace,
          maxCrossAxisExtent: WidgetStyleCommons.playSourceGridMaxWidth,
          childAspectRatio: WidgetStyleCommons.playSourceGridRatio,
        ),
        itemBuilder: (context, index) {
          return Obx(() {
            final item = controller.videoModel.value?.playSourceList?[index];
            return ClickableButtonWidget(
              text: item?.api?.apiBaseModel.name ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              activated:
                  index ==
                  controller.sourceChapterState.playedSourceApiIndex.value,
              isCard: false,
              textAlign: TextAlign.center,
              onClick: () {
                controller.sourceChapterState.playedSourceApiIndex(index);
              },
            );
          });
        },
      );
    });
  }

  // 横向滚动
  Widget _horizontalScroll(BuildContext context) {
    var themeData = Theme.of(context);
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(
        vertical: WidgetStyleCommons.safeSpace,
        horizontal: WidgetStyleCommons.safeSpace,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsetsGeometry.symmetric(
                  vertical: WidgetStyleCommons.safeSpace,
                ),
                child: Text("播放源(${controller.videoModel.value?.playSourceList?.length ?? 0})："),
              ),
              Expanded(child: Container()),
            ],
          ),
          SizedBox(
            width: double.infinity,
            height: WidgetStyleCommons.playSourceHeight,
            // height: 40,
            child: Scrollbar(
              controller: controller.playSourceApiScrollController,
              child: ListView.builder(
                controller: controller.playSourceApiScrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount:
                    controller.videoModel.value?.playSourceList?.length ?? 0,
                itemBuilder: (context, index) {
                  final item =
                      controller.videoModel.value?.playSourceList?[index];
                  return Obx(() {
                    return Container(
                      margin: EdgeInsets.only(
                        right: WidgetStyleCommons.safeSpace,
                      ),
                      child: AspectRatio(
                        aspectRatio: WidgetStyleCommons.playSourceGridRatio,
                        child: ClickableButtonWidget(
                          text: item?.api?.apiBaseModel.name ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          activated:
                              index ==
                              controller
                                  .sourceChapterState
                                  .playedSourceApiIndex
                                  .value,
                          isCard: false,
                          textAlign: TextAlign.center,
                          onClick: () {
                            controller.sourceChapterState.playedSourceApiIndex(
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
      ),
    );
  }
}
