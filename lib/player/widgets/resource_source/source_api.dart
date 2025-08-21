import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:source_player/player/controller/player_controller.dart';

import '../../../commons/widget_style_commons.dart';
import '../../../models/play_source_model.dart';
import '../../../utils/auto_compute_sliver_grid_count.dart';
import '../../../widgets/clickable_button_widget.dart';
import '../../models/play_source_option_model.dart';
import '../../models/resource_state_model.dart';

/// 资源api排版
class SourceApi extends StatefulWidget {
  const SourceApi({super.key, required this.option});
  final PlaySourceOptionModel option;

  @override
  State<SourceApi> createState() => _SourceApiState();
}

class _SourceApiState extends State<SourceApi> {
  PlaySourceOptionModel get option => widget.option;
  late PlayerController controller;
  ScrollController? _scrollController;
  ListObserverController? _observerController;
  GridObserverController? _gridObserverController;
  late int _activatedIndex;
  @override
  void initState() {
    controller = Get.find<PlayerController>();
    _activatedIndex = controller.resourcePlayState.apiActivatedIndex.value;
    if (!option.isSelect) {
      _scrollController = ScrollController();

      if (option.isGrid) {
        _gridObserverController = GridObserverController(
          controller: _scrollController,
        )..initialIndex = _activatedIndex;
      } else {
        _observerController = ListObserverController(
          controller: _scrollController,
        )..initialIndex = _activatedIndex;
      }
    }

    super.initState();
  }

  @override
  void dispose() {
    if (_scrollController != null &&
        controller.resourcePlayState.apiActivatedIndex.value !=
            _activatedIndex) {
      option.onDispose?.call(
        controller.resourcePlayState.apiActivatedIndex.value,
      );
    }
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.resourcePlayState.createApiWidget) {
        return Container();
      }
      return DefaultTextStyle(
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
      );
    });
  }

  Widget _createHeader(BuildContext context) {
    final theme = Theme.of(context);
    List<Widget> lefts = [
      if (option.isSelect)
        Expanded(
          child: Row(
            children: [
              Text("播放源："),
              Expanded(
                child: Obx(() {
                  return Text(
                    controller
                            .resourcePlayState
                            .playSourceList
                            .value![controller
                                .resourcePlayState
                                .apiActivatedIndex
                                .value]
                            .api
                            ?.apiBaseModel
                            .name ??
                        "无",
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                  );
                }),
              ),
            ],
          ),
        )
      else
        Text(
          controller.playerState.isFullscreen.value
              ? "播放源(${controller.resourcePlayState.playSourceList.value!.length})："
              : "播放源：",
        ),
    ];
    List<Widget> rights = [
      if (!controller.playerState.isFullscreen.value &&
          (option.singleHorizontalScroll || option.isSelect))
        TextButton(
          onPressed: () {
            controller.netResourceDetailController?.bottomSheetController =
                controller.netResourceDetailController?.childKey.currentState
                    ?.showBottomSheet(
                      backgroundColor: Colors.transparent,
                      (context) => Container(
                        color: Colors.white,
                        child: Center(
                          child: SourceApi(
                            option: PlaySourceOptionModel(
                              onClose: () {
                                controller
                                    .netResourceDetailController
                                    ?.bottomSheetController
                                    ?.close();
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
                  Text(
                    "${controller.resourcePlayState.playSourceList.value!.length}源",
                  ),
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
      int activatedIndex = controller.resourcePlayState.apiActivatedIndex.value;
      return ListViewObserver(
        controller: _observerController,
        child: ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(
            horizontal: WidgetStyleCommons.safeSpace,
            vertical: WidgetStyleCommons.safeSpace,
          ),
          itemCount: controller.resourcePlayState.playSourceList.value!.length,
          itemBuilder: (context, index) {
            final item =
                controller.resourcePlayState.playSourceList.value![index];
            return SizedBox(
              height: 44,
              child: ClickableButtonWidget(
                text: item.api?.apiBaseModel.name ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                activated: index == activatedIndex,
                isCard: false,
                unActivatedTextColor: controller.playerState.isFullscreen.value
                    ? Colors.white
                    : Colors.black,
                onClick: () {
                  controller.resourcePlayState.apiActivatedIndex.value = index;
                },
              ),
            );
          },
        ),
      );
    });
  }

  // 列表（网格）方式
  Widget _gridView(BuildContext context) {
    return Obx(() {
      int activatedIndex = controller.resourcePlayState.apiActivatedIndex.value;
      return GridViewObserver(
        controller: _gridObserverController,
        child: GridView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: WidgetStyleCommons.safeSpace,
            vertical: WidgetStyleCommons.safeSpace,
          ),
          controller: _scrollController,
          itemCount: controller.resourcePlayState.playSourceList.value!.length,
          gridDelegate: SliverGridDelegateWithExtentAndRatio(
            crossAxisSpacing: WidgetStyleCommons.safeSpace,
            mainAxisSpacing: WidgetStyleCommons.safeSpace,
            maxCrossAxisExtent: WidgetStyleCommons.playSourceGridMaxWidth,
            childAspectRatio: WidgetStyleCommons.playSourceGridRatio,
          ),
          itemBuilder: (context, index) {
            final item =
                controller.resourcePlayState.playSourceList.value![index];
            return ClickableButtonWidget(
              text: item.api?.apiBaseModel.name ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              activated: index == activatedIndex,
              isCard: false,
              textAlign: TextAlign.center,
              unActivatedTextColor: controller.playerState.isFullscreen.value
                  ? Colors.white
                  : Colors.black,
              onClick: () {
                controller.resourcePlayState.apiActivatedIndex.value = index;
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
              controller.resourcePlayState.apiActivatedIndex.value;
          return ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount:
                controller.resourcePlayState.playSourceList.value!.length,
            itemBuilder: (context, index) {
              final item =
                  controller.resourcePlayState.playSourceList.value![index];
              return Container(
                margin: EdgeInsets.only(right: WidgetStyleCommons.safeSpace),
                child: AspectRatio(
                  aspectRatio: WidgetStyleCommons.playSourceGridRatio,
                  child: ClickableButtonWidget(
                    text: item.api?.apiBaseModel.name ?? "",
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
                      controller.resourcePlayState.apiActivatedIndex.value =
                          index;
                    },
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
