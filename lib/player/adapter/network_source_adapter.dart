import 'package:flutter/material.dart';
import 'package:source_player/player/models/chapter_item_model.dart';
import 'package:source_player/player/models/playable_model.dart';

import '../models/play_source_option_model.dart';
import '../widgets/resource_source/source_api.dart';
import 'source_adapter.dart';

class NetworkSourceAdapter implements SourceAdapter {
  NetworkSourceAdapter({required this.onPlay});
  @override
  ValueChanged<PlayableModel> onPlay;

  @override
  List<ChapterItemModel> getChapterList() {
    return [];
  }

  @override
  List<Widget> sourceUIList({
    PlaySourceOptionModel? apiOption,
    PlaySourceOptionModel? apiGroupOption,
    PlaySourceOptionModel? chapterGroupOption,
    PlaySourceOptionModel? chapterOption,
  }) {

    return [
      SourceApi(option: apiOption ?? PlaySourceOptionModel()),
    ];
  }
}
