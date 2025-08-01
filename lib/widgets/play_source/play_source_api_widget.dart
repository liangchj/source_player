import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import '../../commons/widget_style_commons.dart';
import '../../getx_controller/net_resource_detail_controller.dart';
import '../../utils/auto_compute_sliver_grid_count.dart';
import '../clickable_button_widget.dart';

class PlaySourceApiWidget extends StatefulWidget {
  const PlaySourceApiWidget({
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
  State<PlaySourceApiWidget> createState() => _PlaySourceApiWidgetState();
}

class _PlaySourceApiWidgetState extends State<PlaySourceApiWidget> {
  NetResourceDetailController get controller => widget.controller;
  ScrollController? _scrollController;
  ListObserverController? _observerController;
  GridObserverController? _gridObserverController;
  late int _activatedIndex;

  @override
  void initState() {
    _activatedIndex = controller.sourceChapterState.playedSourceApiIndex.value;
    if (widget.createScrollController ||
        widget.isGrid ||
        controller.playSourceApiScrollController == null) {
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

    ever(controller.sourceChapterState.playedSourceApiIndex, (value) {

    });

    super.initState();
  }

  @override
  void dispose() {
    if (_scrollController != null &&
        controller.sourceChapterState.playedSourceApiIndex.value !=
            _activatedIndex) {
      controller.playSourceApiObserverController?.jumpTo(
        index: controller.sourceChapterState.playedSourceApiIndex.value,
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
              Text("播放源："),
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
        )
      else
        Text("播放源："),
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
                      child: PlaySourceApiWidget(
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
                    "${controller.videoModel.value?.playSourceList?.length ?? 0}源",
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
          controller.sourceChapterState.playedSourceApiIndex.value;
      return ListViewObserver(
        controller:
            _observerController ?? controller.playSourceApiObserverController,
        child: ListView.builder(
          controller:
              _scrollController ?? controller.playSourceApiScrollController,
          padding: EdgeInsets.symmetric(
            horizontal: WidgetStyleCommons.safeSpace,
            vertical: WidgetStyleCommons.safeSpace,
          ),
          itemCount: controller.videoModel.value?.playSourceList?.length ?? 0,
          itemBuilder: (context, index) {
            final item = controller.videoModel.value?.playSourceList?[index];
            return SizedBox(
              height: 44,
              child: ClickableButtonWidget(
                text: item?.api?.apiBaseModel.name ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                activated: index == activatedIndex,
                isCard: false,
                onClick: () {
                  controller.sourceChapterState.playedSourceApiIndex(index);
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
          controller.sourceChapterState.playedSourceApiIndex.value;
      return GridViewObserver(
        controller: _gridObserverController,
        child: GridView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: WidgetStyleCommons.safeSpace,
            vertical: WidgetStyleCommons.safeSpace,
          ),
          controller:
              _scrollController ?? controller.playSourceApiScrollController,
          itemCount: controller.videoModel.value?.playSourceList?.length ?? 0,
          gridDelegate: SliverGridDelegateWithExtentAndRatio(
            crossAxisSpacing: WidgetStyleCommons.safeSpace,
            mainAxisSpacing: WidgetStyleCommons.safeSpace,
            maxCrossAxisExtent: WidgetStyleCommons.playSourceGridMaxWidth,
            childAspectRatio: WidgetStyleCommons.playSourceGridRatio,
          ),
          itemBuilder: (context, index) {
            final item = controller.videoModel.value?.playSourceList?[index];
            return ClickableButtonWidget(
              text: item?.api?.apiBaseModel.name ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              activated: index == activatedIndex,
              isCard: false,
              textAlign: TextAlign.center,
              onClick: () {
                controller.sourceChapterState.playedSourceApiIndex(index);
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
            _scrollController ?? controller.playSourceApiScrollController,
        child: Obx(() {
          int activatedIndex =
              controller.sourceChapterState.playedSourceApiIndex.value;
          return ListView.builder(
            controller:
                _scrollController ?? controller.playSourceApiScrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: controller.videoModel.value?.playSourceList?.length ?? 0,
            itemBuilder: (context, index) {
              final item = controller.videoModel.value?.playSourceList?[index];
              return Container(
                margin: EdgeInsets.only(right: WidgetStyleCommons.safeSpace),
                child: AspectRatio(
                  aspectRatio: WidgetStyleCommons.playSourceGridRatio,
                  child: ClickableButtonWidget(
                    text: item?.api?.apiBaseModel.name ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    activated: index == activatedIndex,
                    isCard: false,
                    textAlign: TextAlign.center,
                    onClick: () {
                      controller.sourceChapterState.playedSourceApiIndex(index);
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
