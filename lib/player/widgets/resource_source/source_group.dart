import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import '../../../commons/widget_style_commons.dart';
import '../../../utils/auto_compute_sliver_grid_count.dart';
import '../../../widgets/clickable_button_widget.dart';
import '../../controller/player_controller.dart';
import '../../models/play_source_option_model.dart';

class SourceGroup extends StatefulWidget {
  const SourceGroup({super.key, required this.option});
  final PlaySourceOptionModel option;

  @override
  State<SourceGroup> createState() => _SourceGroupState();
}

class _SourceGroupState extends State<SourceGroup> {
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
    _activatedIndex = controller.resourcePlayState.apiGroupActivatedIndex.value;
    if (!option.isSelect) {
      int initialIndex = _activatedIndex >= 0 ? _activatedIndex : 0;
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
    }
    super.initState();
  }

  @override
  void dispose() {
    int index = controller.resourcePlayState.apiGroupActivatedIndex.value;
    if (index < 0) {
      index = 0;
    }
    if (_scrollController != null && index != _activatedIndex) {
      option.onDispose?.call(index);
    }
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.resourcePlayState.sourceGroupList.length > 1
          ? DefaultTextStyle(
              style: TextStyle(
                color: controller.playerState.isFullscreen.value
                    ? Colors.white
                    : Colors.black,
              ),
              child: Column(
                children: [
                  _createHeader(context),
                  option.bottomSheet
                      ? _bottomSheetList(context)
                      : option.isSelect
                      ? _selectList(context)
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
      if (option.isSelect)
        Expanded(
          child: Obx(() {
            return Text(
              "播放组：${controller.resourcePlayState.activatedSourceGroup?.name ?? "无"}",
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
            );
          }),
        )
      else
        Expanded(
          child: Text(
            controller.playerState.isFullscreen.value
                ? "播放组(${controller.resourcePlayState.sourceGroupList.length})："
                : "播放组：",
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
          ),
        ),
    ];
    List<Widget> rights = [
      if (!controller.playerState.isFullscreen.value &&
          (option.singleHorizontalScroll || option.isSelect))
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
                          child: SourceGroup(
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
                "${controller.resourcePlayState.sourceGroupList.length}组",
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
        border: option.singleHorizontalScroll || option.isSelect
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

  Widget _selectList(BuildContext context) {
    return Container();
  }

  // 列表方式
  Widget _listView(BuildContext context) {
    return Obx(() {
      int activatedIndex =
          controller.resourcePlayState.apiGroupActivatedIndex.value;
      return ListViewObserver(
        controller: _observerController,
        child: ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(
            horizontal: WidgetStyleCommons.safeSpace,
            vertical: WidgetStyleCommons.safeSpace,
          ),
          itemCount: controller.resourcePlayState.sourceGroupList.length,
          itemBuilder: (context, index) {
            final item = controller.resourcePlayState.sourceGroupList[index];
            return SizedBox(
              height: 44,
              child: ClickableButtonWidget(
                key: ValueKey(
                  "source_group_${option.bottomSheet}_listView_${controller.resourcePlayState.apiActivatedIndex.value}_$index",
                ),
                text: item.name ?? "未知分组",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                activated: index == activatedIndex,
                unActivatedTextColor: controller.playerState.isFullscreen.value
                    ? Colors.white
                    : Colors.black,
                isCard: false,
                onClick: () {
                  controller.resourcePlayState.apiGroupActivatedIndex.value =
                      index;
                },
              ),
            );
          },
        ),
      );
    });
  }

  // 列表（grid）方式
  Widget _gridView(BuildContext context) {
    return Obx(() {
      int activatedIndex =
          controller.resourcePlayState.apiGroupActivatedIndex.value;
      return GridViewObserver(
        controller: _gridObserverController,
        child: GridView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: WidgetStyleCommons.safeSpace,
            vertical: WidgetStyleCommons.safeSpace,
          ),
          controller: _scrollController,
          itemCount: controller.resourcePlayState.sourceGroupList.length,
          gridDelegate: SliverGridDelegateWithExtentAndRatio(
            crossAxisSpacing: WidgetStyleCommons.safeSpace,
            mainAxisSpacing: WidgetStyleCommons.safeSpace,
            maxCrossAxisExtent: WidgetStyleCommons.playSourceGridMaxWidth,
            childAspectRatio: WidgetStyleCommons.playSourceGridRatio,
          ),
          itemBuilder: (context, index) {
            final item = controller.resourcePlayState.sourceGroupList[index];
            return ClickableButtonWidget(
              key: ValueKey(
                "source_group_${option.bottomSheet}_gridView_${controller.resourcePlayState.apiActivatedIndex.value}_$index",
              ),
              text: item.name ?? "未知分组",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              activated: index == activatedIndex,
              isCard: false,
              textAlign: TextAlign.center,
              unActivatedTextColor: controller.playerState.isFullscreen.value
                  ? Colors.white
                  : Colors.black,
              onClick: () {
                controller.resourcePlayState.apiGroupActivatedIndex.value =
                    index;
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
      height: WidgetStyleCommons.playSourceHeight,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
        ),
        child: Obx(() {
          int activatedIndex =
              controller.resourcePlayState.apiGroupActivatedIndex.value;
          return ListViewObserver(
            controller: _observerController,
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: controller.resourcePlayState.sourceGroupList.length,
              itemBuilder: (context, index) {
                final item =
                    controller.resourcePlayState.sourceGroupList[index];
                return Container(
                  margin: EdgeInsets.only(right: WidgetStyleCommons.safeSpace),
                  child: AspectRatio(
                    aspectRatio: WidgetStyleCommons.playSourceGridRatio,
                    child: ClickableButtonWidget(
                      key: ValueKey(
                        "source_group_${option.bottomSheet}_horizontalScroll_${controller.resourcePlayState.apiActivatedIndex.value}_$index",
                      ),
                      text: item.name ?? "未知分组",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      activated: index == activatedIndex,
                      isCard: false,
                      textAlign: TextAlign.center,
                      unActivatedTextColor:
                          controller.playerState.isFullscreen.value
                          ? Colors.white
                          : Colors.black,
                      onClick: () {
                        controller
                                .resourcePlayState
                                .apiGroupActivatedIndex
                                .value =
                            index;
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
