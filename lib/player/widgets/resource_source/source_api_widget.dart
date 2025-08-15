import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:source_player/player/controller/player_controller.dart';

import '../../../commons/widget_style_commons.dart';
import '../../../utils/auto_compute_sliver_grid_count.dart';
import '../../../widgets/clickable_button_widget.dart';
import '../../models/resource_state_model.dart';

/// 资源api排版
class SourceApiWidget extends StatefulWidget {
  const SourceApiWidget({
    super.key,
    this.onClose,
    this.singleHorizontalScroll = false,
    this.listVerticalScroll = true,
    this.isGrid = false,
    this.isSelect = false,
    this.bottomSheet = false,
    this.onDispose,
  });
  final VoidCallback? onClose;
  final bool singleHorizontalScroll;
  final bool listVerticalScroll;
  final bool isGrid;
  final bool isSelect;
  final bool bottomSheet;
  final Function(int)? onDispose;

  @override
  State<SourceApiWidget> createState() => _SourceApiWidgetState();
}

class _SourceApiWidgetState extends State<SourceApiWidget> {
  late PlayerController controller;
  ScrollController? _scrollController;
  ListObserverController? _observerController;
  GridObserverController? _gridObserverController;
  late int _activatedIndex;
  @override
  void initState() {
    controller = Get.find<PlayerController>();
    _activatedIndex =
        controller.resourceState.state.apiActivatedState.value?.index ?? 0;

    _scrollController = ScrollController();

    if (widget.isGrid) {
      _gridObserverController = GridObserverController(
        controller: _scrollController,
      )..initialIndex = _activatedIndex;
    } else {
      _observerController = ListObserverController(
        controller: _scrollController,
      )..initialIndex = _activatedIndex;
    }

    super.initState();
  }

  @override
  void dispose() {
    if (_scrollController != null &&
        (controller.resourceState.state.apiActivatedState.value?.index ?? 0) !=
            _activatedIndex) {
      widget.onDispose?.call(
        controller.resourceState.state.apiActivatedState.value?.index ?? 0,
      );
    }
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        if (controller.resourceState.videoModel.value == null || controller.resourceState.playSourceList.isEmpty
          || (controller.resourceState.playSourceList.length == 1 && controller.resourceState.playSourceList.first.api == null)
        ) {
          return Container();
        }
        return Column(
          children: [
            _createHeader(context),
            widget.bottomSheet
                ? _bottomSheetList(context)
                : widget.isSelect
                ? _selectList(context)
                : widget.singleHorizontalScroll
                ? _horizontalScroll(context)
                : _list(context),
          ],
        );
      },
    );
  }

  Widget _createHeader(BuildContext context) {
    final theme = Theme.of(context);
    List<Widget> lefts = [
      if (widget.isSelect)
        Expanded(
          child: Row(
            children: [
              Text("播放源："),
              Expanded(
                child: Obx(() {
                  return Text(
                    controller
                            .resourceState
                            .showApiSource
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
        )
      else
        Text("播放源："),
    ];
    List<Widget> rights = [
      if (widget.singleHorizontalScroll || widget.isSelect)
        TextButton(
          onPressed: () {
            controller.netResourceDetailController?.bottomSheetController =
                controller.netResourceDetailController?.childKey.currentState
                    ?.showBottomSheet(
                      backgroundColor: Colors.transparent,
                      (context) => Container(
                        color: Colors.white,
                        child: Center(
                          child: SourceApiWidget(
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
                    );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text("${controller.resourceState.playSourceList.length}源"),
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
        border: widget.singleHorizontalScroll || widget.isSelect
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

  Widget _selectList(BuildContext context) {
    return Container();
  }

  // 列表方式
  Widget _listView(BuildContext context) {
    return Obx(() {
      int activatedIndex =
          controller.resourceState.state.apiActivatedState.value?.index ?? 0;
      return ListViewObserver(
        controller: _observerController,
        child: ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(
            horizontal: WidgetStyleCommons.safeSpace,
            vertical: WidgetStyleCommons.safeSpace,
          ),
          itemCount: controller.resourceState.playSourceList.length,
          itemBuilder: (context, index) {
            final item = controller.resourceState.playSourceList[index];
            return SizedBox(
              height: 44,
              child: ClickableButtonWidget(
                text: item.api?.apiBaseModel.name ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                activated: index == activatedIndex,
                isCard: false,
                onClick: () {
                  controller.resourceState.state.apiActivatedState(
                    controller.resourceState.state.apiActivatedState.value
                            ?.copyWith(index: index) ??
                        ActivatedStateModel(
                          index: index,
                          activatedIndex: index,
                        ),
                  );
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
      int activatedIndex =
          controller.resourceState.state.apiActivatedState.value?.index ?? 0;
      return GridViewObserver(
        controller: _gridObserverController,
        child: GridView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: WidgetStyleCommons.safeSpace,
            vertical: WidgetStyleCommons.safeSpace,
          ),
          controller: _scrollController,
          itemCount: controller.resourceState.playSourceList.length,
          gridDelegate: SliverGridDelegateWithExtentAndRatio(
            crossAxisSpacing: WidgetStyleCommons.safeSpace,
            mainAxisSpacing: WidgetStyleCommons.safeSpace,
            maxCrossAxisExtent: WidgetStyleCommons.playSourceGridMaxWidth,
            childAspectRatio: WidgetStyleCommons.playSourceGridRatio,
          ),
          itemBuilder: (context, index) {
            final item = controller.resourceState.playSourceList[index];
            return ClickableButtonWidget(
              text: item.api?.apiBaseModel.name ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              activated: index == activatedIndex,
              isCard: false,
              textAlign: TextAlign.center,
              onClick: () {
                controller.resourceState.state.apiActivatedState(
                  controller.resourceState.state.apiActivatedState.value
                          ?.copyWith(index: index) ??
                      ActivatedStateModel(index: index, activatedIndex: index),
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
      height: WidgetStyleCommons.playSourceHeight,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.mouse,
            PointerDeviceKind.touch,
          },
        ),
        child: Obx(() {
          int activatedIndex =
              controller.resourceState.state.apiActivatedState.value?.index ??
              0;
          return ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: controller.resourceState.playSourceList.length,
            itemBuilder: (context, index) {
              final item = controller.resourceState.playSourceList[index];
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
                    onClick: () {
                      controller.resourceState.state.apiActivatedState(
                        controller.resourceState.state.apiActivatedState.value
                                ?.copyWith(index: index) ??
                            ActivatedStateModel(
                              index: index,
                              activatedIndex: index,
                            ),
                      );
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
