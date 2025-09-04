import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:source_player/player/models/play_source_option_model.dart';

import '../../commons/widget_style_commons.dart';
import '../commons/player_commons.dart';
import '../controller/player_controller.dart';
import '../widgets/chapter/chapter_list.dart';
import '../widgets/resource_source/source_api.dart';
import '../widgets/resource_source/source_group.dart';

class FullscreenChapterListUI extends GetView<PlayerController> {
  const FullscreenChapterListUI({super.key, this.bottomSheet = false});
  final bool bottomSheet;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return !bottomSheet
        ? Container(
            width: PlayerCommons.chapterUIDefaultWidth.clamp(
              screenWidth * 0.3,
              screenWidth * 0.8,
            ),
            height: double.infinity,
            color: PlayerCommons.playerUIBackgroundColor,
            padding: EdgeInsets.all(WidgetStyleCommons.safeSpace),
            child: ChapterList(option: PlaySourceOptionModel(isGrid: true)),
          )
        : ChapterList(option: PlaySourceOptionModel(isGrid: true));
  }
}
