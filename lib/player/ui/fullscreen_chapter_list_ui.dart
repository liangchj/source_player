import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:source_player/player/widgets/chapter/chapter_list_widget.dart';

import '../../commons/widget_style_commons.dart';
import '../commons/player_commons.dart';
import '../controller/player_controller.dart';
import '../widgets/resource_source/source_api_widget.dart';
import '../widgets/resource_source/source_group_widget.dart';

class FullscreenChapterListUI extends StatefulWidget {
  const FullscreenChapterListUI({super.key, this.bottomSheet = false});
  final bool bottomSheet;

  @override
  State<FullscreenChapterListUI> createState() =>
      _FullscreenChapterListUIState();
}

class _FullscreenChapterListUIState extends State<FullscreenChapterListUI> {
  late PlayerController controller;
  @override
  void initState() {
    controller = Get.find<PlayerController>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return !widget.bottomSheet
        ? Container(
            width: PlayerCommons.chapterUIDefaultWidth.clamp(
              screenWidth * 0.3,
              screenWidth * 0.8,
            ),
            height: double.infinity,
            color: PlayerCommons.playerUIBackgroundColor,
            padding: EdgeInsets.all(WidgetStyleCommons.safeSpace),
            child: Column(
              children: [
                SourceApiWidget(singleHorizontalScroll: true),

                SourceGroupWidget(singleHorizontalScroll: true),
                Expanded(child: ChapterListWidget(isGrid: true)),
              ],
            ),
          )
        : Column(
            children: [
              SourceApiWidget(singleHorizontalScroll: true),

              SourceGroupWidget(singleHorizontalScroll: true),
              Expanded(child: ChapterListWidget()),
            ],
          );
  }
}
