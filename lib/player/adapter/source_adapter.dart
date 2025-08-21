import 'package:flutter/material.dart';

import '../models/chapter_item_model.dart';
import '../models/play_source_option_model.dart';
import '../models/playable_model.dart';

abstract class SourceAdapter {
  late ValueChanged<PlayableModel> onPlay;

  List<ChapterItemModel> getChapterList();
  List<Widget> sourceUIList({
    PlaySourceOptionModel? apiOption,
    PlaySourceOptionModel? apiGroupOption,
    PlaySourceOptionModel? chapterGroupOption,
    PlaySourceOptionModel? chapterOption,
  });
}
