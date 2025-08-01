import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import '../../commons/widget_style_commons.dart';
import '../../getx_controller/net_resource_detail_controller.dart';
import '../../utils/auto_compute_sliver_grid_count.dart';
import '../clickable_button_widget.dart';

class PlaySourceGroupWidget extends StatefulWidget {
  const PlaySourceGroupWidget({
    super.key,
    required this.controller,
    this.onClose,
    this.singleHorizontalScroll = false,
    this.listVerticalScroll = true,
    this.isGrid = false,
    this.isSelect = false,
    this.bottomSheet = false,
    this.createScrollController = false,
  });
  final NetResourceDetailController controller;
  final VoidCallback? onClose;
  final bool singleHorizontalScroll;
  final bool listVerticalScroll;
  final bool isGrid;
  final bool isSelect;
  final bool bottomSheet;
  final bool createScrollController;

  @override
  State<PlaySourceGroupWidget> createState() => _PlaySourceGroupWidgetState();
}

class _PlaySourceGroupWidgetState extends State<PlaySourceGroupWidget> {
  NetResourceDetailController get controller => widget.controller;
  ScrollController? _scrollController;
  ListObserverController? _observerController;
  GridObserverController? _gridObserverController;
  late int _activatedIndex;

  @override
  void initState() {
    _activatedIndex =
        controller.sourceChapterState.playedSourceGroupIndex.value;

    if (widget.createScrollController || widget.isGrid) {
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
    }

    super.initState();
  }

  @override
  void dispose() {
    if (_scrollController != null &&
        controller.sourceChapterState.playedSourceGroupIndex.value !=
            _activatedIndex) {
      controller.playSourceApiObserverController?.jumpTo(
        index: controller.sourceChapterState.playedSourceGroupIndex.value,
        isFixedHeight: true,
      );
    }
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
  }

  Widget _createHeader(BuildContext context) {
    final theme = Theme.of(context);
    List<Widget> lefts = [
      if (widget.isSelect)
        Expanded(
          child: Row(
            children: [
              Text("播放组："),
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
        )
      else
        Text("播放组："),
    ];
    List<Widget> rights = [
      if (widget.singleHorizontalScroll || widget.isSelect)
        TextButton(
          onPressed: () {
            controller.bottomSheetController = controller.childKey.currentState
                ?.showBottomSheet(
                  backgroundColor: Colors.transparent,
                  (context) => Container(
                    color: Colors.white,
                    child: Center(
                      child: PlaySourceGroupWidget(
                        controller: controller,
                        onClose: () {
                          controller.bottomSheetController?.close();
                        },
                        bottomSheet: true,
                        isGrid: true,
                        createScrollController: true,
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
                    "${controller.sourceChapterState.currentPlayedSourceGroupList.length}组",
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
          controller.sourceChapterState.playedSourceGroupIndex.value;
      return ListViewObserver(
        controller:
            _observerController ?? controller.playSourceApiObserverController,
        child: ListView.builder(
          controller:
              _scrollController ?? controller.playSourceGroupScrollController,
          padding: EdgeInsets.symmetric(
            horizontal: WidgetStyleCommons.safeSpace,
            vertical: WidgetStyleCommons.safeSpace,
          ),
          itemCount:
              controller.sourceChapterState.currentPlayedSourceGroupList.length,
          itemBuilder: (context, index) {
            final item = controller
                .sourceChapterState
                .currentPlayedSourceGroupList[index];
            return SizedBox(
              height: 44,
              child: ClickableButtonWidget(
                text: item.name ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                activated: index == activatedIndex,
                isCard: false,
                onClick: () {
                  controller.sourceChapterState.playedSourceGroupIndex(index);
                },
              ),
            );
          },
        ),
      );
    });
  }

  // 列表方式
  Widget _gridView(BuildContext context) {
    return Obx(() {
      int activatedIndex =
          controller.sourceChapterState.playedSourceGroupIndex.value;
      return GridViewObserver(
        controller: _gridObserverController,
        child: GridView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: WidgetStyleCommons.safeSpace,
            vertical: WidgetStyleCommons.safeSpace,
          ),
          controller:
              _scrollController ?? controller.playSourceGroupScrollController,
          itemCount:
              controller.sourceChapterState.currentPlayedSourceGroupList.length,
          gridDelegate: SliverGridDelegateWithExtentAndRatio(
            crossAxisSpacing: WidgetStyleCommons.safeSpace,
            mainAxisSpacing: WidgetStyleCommons.safeSpace,
            maxCrossAxisExtent: WidgetStyleCommons.playSourceGridMaxWidth,
            childAspectRatio: WidgetStyleCommons.playSourceGridRatio,
          ),
          itemBuilder: (context, index) {
            final item = controller
                .sourceChapterState
                .currentPlayedSourceGroupList[index];
            return ClickableButtonWidget(
              text: item.name ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              activated: index == activatedIndex,
              isCard: false,
              textAlign: TextAlign.center,
              onClick: () {
                controller.sourceChapterState.playedSourceGroupIndex(index);
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
      child: Scrollbar(
        controller:
            _scrollController ?? controller.playSourceGroupScrollController,
        child: Obx(() {
          int activatedIndex =
              controller.sourceChapterState.playedSourceGroupIndex.value;
          return ListViewObserver(
            controller:
                _observerController ??
                controller.playSourceApiObserverController,
            child: ListView.builder(
              controller:
                  _scrollController ??
                  controller.playSourceGroupScrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: controller
                  .sourceChapterState
                  .currentPlayedSourceGroupList
                  .length,
              itemBuilder: (context, index) {
                final item = controller
                    .sourceChapterState
                    .currentPlayedSourceGroupList[index];
                return Container(
                  margin: EdgeInsets.only(right: WidgetStyleCommons.safeSpace),
                  child: AspectRatio(
                    aspectRatio: WidgetStyleCommons.playSourceGridRatio,
                    child: ClickableButtonWidget(
                      text: item.name ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      activated: index == activatedIndex,
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
              },
            ),
          );
        }),
      ),
    );
  }
}
