import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import '../../controller/player_controller.dart';

class ChapterListWidget extends StatefulWidget {
  const ChapterListWidget({
    super.key,
    this.onClose,
    this.singleHorizontalScroll = false,
    this.listVerticalScroll = true,
    this.isGrid = false,
    this.bottomSheet = false,
    this.onDispose,
  });
  final VoidCallback? onClose;
  final bool singleHorizontalScroll;
  final bool listVerticalScroll;
  final bool isGrid;
  final bool bottomSheet;
  final Function(int)? onDispose;

  @override
  State<ChapterListWidget> createState() => _ChapterListWidgetState();
}

class _ChapterListWidgetState extends State<ChapterListWidget> {
  late PlayerController controller;
  ScrollController? _chapterGroupScrollController;
  ListObserverController? _chapterGroupObserverController;
  bool _needCreateChapterGroupLayout = false;
  late int _chapterGroupIndex;

  ScrollController? _chapterScrollController;
  ListObserverController? _chapterObserverController;
  GridObserverController? _chapterGridObserverController;
  late int _chapterIndex;

  @override
  void initState() {
    controller = Get.find<PlayerController>();
    _chapterGroupIndex = controller.resourceState.state.value.chapterGroupActivatedIndex;
    _chapterIndex = controller.resourceState.state.value.chapterActivatedIndex;
    _needCreateChapterGroupLayout = controller.resourceState.state.value.chapterGroup > 0;
    if (_needCreateChapterGroupLayout) {
      _chapterGroupScrollController = ScrollController();
      _chapterGroupObserverController = ListObserverController(
        controller: _chapterGroupScrollController,
      )..initialIndex = _chapterGroupIndex;
    }

    _chapterScrollController = ScrollController();
    int activatedIndex = 0;
    if (widget.isGrid) {
      _chapterGridObserverController = GridObserverController(
        controller: _chapterScrollController,
      )..initialIndex = activatedIndex;
    } else {
      _chapterObserverController = ListObserverController(
        controller: _chapterScrollController,
      )..initialIndex = activatedIndex;
    }

    super.initState();
  }

  @override
  void dispose() {
    _chapterGroupScrollController?.dispose();
    _chapterScrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
