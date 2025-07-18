import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:source_player/commons/widget_style_commons.dart';
import 'package:source_player/widgets/text_button_widget.dart';

import '../getx_controller/net_resource_detail_controller.dart';
import 'chapter/chapter_list_widget.dart';
import 'clickable_button_widget.dart';

class PlaySourceWidget extends StatefulWidget {
  const PlaySourceWidget({super.key, required this.controller, this.onClose, this.listShow = false,});
  final NetResourceDetailController controller;
  final VoidCallback? onClose;
  final bool listShow;

  @override
  State<PlaySourceWidget> createState() => _PlaySourceWidgetState();
}

class _PlaySourceWidgetState extends State<PlaySourceWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.listShow ? _listWidget(context) : Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: WidgetStyleCommons.safeSpace),
          child: _createApiWidget(),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: WidgetStyleCommons.safeSpace),
          child: _createPlaySourceGroup(),
        ),
        ChapterListWidget(controller: widget.controller, singleHorizontalScroll: true, )
      ],
    );
  }

  // 创建播放api源
  Widget _createApiWidget() {
    return Obx(
      () => widget.controller.sourceChapterState.currentPlayedSource?.api == null
          ? Container()
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsetsGeometry.symmetric(
                          vertical: WidgetStyleCommons.safeSpace,
                        ),
                        child: Text("播放源："),
                      ),
                      Expanded(
                        child: Obx(() {
                          return Text(
                            widget
                                    .controller
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
                    widget.controller.bottomSheetController = widget.controller
                        .childKey
                        .currentState
                        ?.showBottomSheet(
                      backgroundColor: Colors.transparent,
                          (context) => Container(
                        color: Colors.white,
                        child: Center(
                          child: PlaySourceWidget(controller: widget.controller,
                            onClose: () => widget.controller.bottomSheetController?.close(),
                            listShow: true,
                          ),
                        ),
                      ),
                    );
                  },
                  child: Text(
                    "切换播放源(${widget.controller.videoModel.value?.playSourceList?.length ?? 0})",
                  ),
                ),
              ],
            ),
    );
  }

  // 资源组
  Widget _createPlaySourceGroup() {
    return Obx(
      () =>
          widget
                  .controller
                  .sourceChapterState
                  .currentPlayedSourceGroupList
                  .length >
              1
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsetsGeometry.symmetric(
                          vertical: WidgetStyleCommons.safeSpace,
                        ),
                        child: Text("播放组："),
                      ),
                      Expanded(
                        child: Obx(() {
                          /*if (widget.controller.sourceChapterState.currentPlaySourceGroupList.isEmpty) {
                    return Container();
                  }*/
                          return Text(
                            widget
                                    .controller
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
                  onPressed: () {},
                  child: Text(
                    "切换播放组(${widget.controller.sourceChapterState.currentPlayedSourceGroupList.length})",
                  ),
                ),
              ],
            )
          : Container(),
    );
  }

  Widget _listWidget(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          height: 45,
          padding: EdgeInsets.symmetric(horizontal: WidgetStyleCommons.safeSpace),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
            ),
          ),
          child: Row(
            children: [
              Text("播放源(${widget.controller.videoModel.value?.playSourceList?.length ?? 0})："),
              const Spacer(),
              if (widget.onClose != null)
                SizedBox(
                  width: 34,
                  height: 34,
                  child: IconButton(
                    tooltip: '关闭',
                    icon: Icon(Icons.close),
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(EdgeInsets.zero),
                    ),
                    onPressed: widget.onClose,
                  ),
                ),
            ],
          ),
        ),

        Expanded(child: ListView.builder(
          controller: ScrollController(),
            padding: EdgeInsets.symmetric(horizontal: WidgetStyleCommons.safeSpace, vertical: WidgetStyleCommons.safeSpace),
            itemCount: widget.controller.videoModel.value?.playSourceList?.length ?? 0,
            itemBuilder: (context, index) {
              final item = widget.controller.videoModel.value?.playSourceList?[index];

              return Obx(() => SizedBox(
                height: 44,
                child: ClickableButtonWidget(
                  text: item?.api?.apiBaseModel.name ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  activated: index == widget.controller.sourceChapterState.playedSourceApiIndex.value,
                  isCard: false,
                  onClick: () {
                    // widget.controller.playSource(item);
                    widget.controller.sourceChapterState.playedSourceApiIndex(index);
                  },
                ),
              ));
            }),)
      ],
    );
  }
}
