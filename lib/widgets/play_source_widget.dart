import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:source_player/commons/widget_style_commons.dart';

import '../getx_controller/net_resource_detail_controller.dart';
import 'chapter_list_widget.dart';

class PlaySourceWidget extends StatefulWidget {
  const PlaySourceWidget({super.key, required this.controller});
  final NetResourceDetailController controller;

  @override
  State<PlaySourceWidget> createState() => _PlaySourceWidgetState();
}

class _PlaySourceWidgetState extends State<PlaySourceWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: WidgetStyleCommons.safeSpace),
      child: Column(
        children: [
          _createApiWidget(),
          // if (widget.controller.videoModel.value == null ||
          //     widget.controller.videoModel.value!.playSourceList == null ||
          //     widget.controller.videoModel.value!.playSourceList!.isEmpty)
          //   Container()
          // else
          _createPlaySourceGroup(),
          ChapterListWidget(controller: widget.controller),
        ],
      ),
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
                  onPressed: () {},
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
}
