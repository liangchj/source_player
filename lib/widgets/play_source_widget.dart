import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:source_player/commons/widget_style_commons.dart';

import '../getx_controller/net_resource_detail_controller.dart';

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
      child:
          Column(
            children: [
              _createApiWidget(),
              if (widget.controller.videoModel.value == null ||
                  widget.controller.videoModel.value!.playSourceList == null ||
                  widget.controller.videoModel.value!.playSourceList!.isEmpty)
                Container()

            ],
          ),
    );
  }

  // 创建播放api源
  Widget _createApiWidget() {
    return Row(
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
                  var playSourceList =
                      widget.controller.videoModel.value?.playSourceList ?? [];

                  var activated = playSourceList.firstWhereOrNull(
                    (e) => e.activated,
                  );

                  return Text(
                    activated == null ? "无" : activated.api.apiBaseModel.name,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                  );
                }),
              ),
            ],
          ),
        ),
        TextButton(onPressed: () {}, child: Text("切换播放源(${widget.controller.videoModel.value?.playSourceList?.length??0})")),
      ],
    );
  }

  Widget _createPlaySourceGroup() {
    return Row(
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
                  var playSourceList =
                      widget.controller.videoModel.value?.playSourceList ?? [];
                  if (playSourceList.isEmpty) {
                    return Container();
                  }
                  var group = playSourceList.firstWhereOrNull(
                        (e) => e.activated,
                  ) ?? playSourceList.first;
                  var activated = group.playSourceGroupList.isEmpty ? null : group.playSourceGroupList.firstWhereOrNull((e)=> e.activated) ?? group.playSourceGroupList.first;
                  return Text(
                    activated == null ? "" : activated.name,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                  );
                }),
              )
            ],
          ),
        ),
        TextButton(
            onPressed: () {

            },
            child: Text("切换播放组", )),
      ],
    );
  }
}
