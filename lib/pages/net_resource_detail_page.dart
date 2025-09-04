import 'dart:ui';

import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:source_player/player/ui/player_top_ui.dart';
import 'package:source_player/utils/logger_utils.dart';
import 'package:source_player/widgets/resource_detail/resource_detail_info_widget.dart';

import '../commons/widget_style_commons.dart';
import '../getx_controller/net_resource_detail_controller.dart';
import '../player/models/play_source_option_model.dart';
import '../player/widgets/chapter/chapter_list.dart';
import '../player/widgets/resource_source/source_api.dart';
import '../player/widgets/resource_source/source_group.dart';
import '../widgets/loading_widget.dart' show LoadingWidget;

/// 网络资源详情页面
/// 涉及到icon的，若使用系统的icon，统一使用rounded结尾的
class NetResourceDetailPage extends StatefulWidget {
  const NetResourceDetailPage({super.key, required this.resourceId});

  final String resourceId;

  @override
  State<NetResourceDetailPage> createState() => _NetResourceDetailPageState();
}

class _NetResourceDetailPageState extends State<NetResourceDetailPage>
    with TickerProviderStateMixin {
  /// 二级文字字体大小
  final double secondaryTextFontSize = 12.0;
  late NetResourceDetailController controller;

  final double _playerAspectRatio = 9 / 16.0;
  final double _minPlayerHeight = 60;

  @override
  void initState() {
    LoggerUtils.logger.d("entry initState");
    controller = Get.put(
      NetResourceDetailController(widget.resourceId),
      tag: widget.resourceId,
    );
    controller.nestedScrollController?.addListener(listener);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.disposeId(widget.resourceId);
    controller.nestedScrollController?.removeListener(listener);
    super.dispose();
  }

  void listener() {
    LoggerUtils.logger.d(
      "listener， offset:${controller.nestedScrollController?.offset}, "
      "position：${controller.nestedScrollController?.position}, "
      "initialScrollOffset：${controller.nestedScrollController?.initialScrollOffset}"
      "keepScrollOffset：${controller.nestedScrollController?.keepScrollOffset}",
    );
    /*if (controller.nestedScrollController.position.pixels >= 100) {
      controller.showBottomSheet(true);
    } else {
      controller.showBottomSheet(false);
    }*/
  }

  @override
  Widget build(BuildContext context) {
    LoggerUtils.logger.d("渲染");
    return PopScope(
      canPop: controller.canPopScope(),
      child: Obx(
        () => Scaffold(
          appBar:
              controller.loadingState.value.loading ||
                  !controller.loadingState.value.loadedSuc ||
                  controller.videoModel.value == null
              ? AppBar(leading: BackButton())
              : null,
          body: controller.loadingState.value.loading
              ? const Center(
                  child: SizedBox(
                    height: 500,
                    child: LoadingWidget(textWidget: Text("资源加载中...")),
                  ),
                )
              : !controller.loadingState.value.loadedSuc
              ? Center(
                  child: Text(
                    "资源加载失败: ${controller.loadingState.value.errorMsg}",
                  ),
                )
              : controller.videoModel.value == null
              ? const Center(child: Text("获取资源为空"))
              : SafeArea(top: true, child: _createDetailScrollView()),
        ),
      ),
    );
  }

  Widget _createDetailScrollView() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double pinnedHeaderHeight =
        //statusBar height
        statusBarHeight +
        //pinned SliverAppBar height in header
        kToolbarHeight;
    return ExtendedNestedScrollView(
      key: controller.scrollKey,
      controller: controller.nestedScrollController,
      onlyOneScrollInBody: true,

      // physics: const NeverScrollableScrollPhysics(),
      /*physics: const NeverScrollableScrollPhysics(
        parent: ClampingScrollPhysics(),
      ),*/
      headerSliverBuilder: (BuildContext c, bool f) {
        double height = MediaQuery.of(context).size.width * _playerAspectRatio;
        return [
          Obx(() {
            return SliverAppBar(
              automaticallyImplyLeading: false,
              expandedHeight: height,
              collapsedHeight:
                  controller
                          .playerController
                          .value
                          ?.playerState
                          .isPlaying
                          .value ??
                      false
                  ? height
                  : _minPlayerHeight,
              floating: false,
              pinned: true,
              flexibleSpace: Stack(
                children: [
                  Positioned.fill(child: _createPlayer()),
                  Positioned.fill(
                    child: Obx(
                      () =>
                          controller.playerController.value != null &&
                              !controller
                                  .playerController
                                  .value!
                                  .playerState
                                  .isPlaying
                                  .value &&
                              height -
                                      controller
                                          .extendedNestedScrollViewOffset
                                          .value <=
                                  pinnedHeaderHeight
                          ? Container(
                              color: Colors.black,
                              height: double.infinity,
                            )
                          : Container(),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    right: 0,
                    child: Obx(
                      () =>
                          controller.playerController.value != null &&
                              !controller
                                  .playerController
                                  .value!
                                  .playerState
                                  .isPlaying
                                  .value &&
                              controller.extendedNestedScrollViewOffset.value >
                                  pinnedHeaderHeight
                          ? Container(
                              color: Colors.black,
                              child: PlayerTopUI(pauseScroll: true),
                            )
                          : Container(),
                    ),
                  ),
                ],
              ),
            );
          }),
        ];
      },
      pinnedHeaderSliverHeightBuilder: () {
        var offset = controller.nestedScrollController?.offset;
        // 检查是否正在播放
        final isPlaying =
            controller.playerController.value?.playerState.isPlaying.value ??
            false;

        if (isPlaying) {
          // 播放时固定返回最大高度
          return MediaQuery.of(context).size.width * _playerAspectRatio;
        } else if (controller.bottomSheetController != null) {
          return (MediaQuery.of(context).size.width * _playerAspectRatio -
                  controller.nestedScrollController!.offset)
              .clamp(_minPlayerHeight, double.infinity);
        }
        controller.extendedNestedScrollViewOffset(offset);
        return kToolbarHeight;
      },
      body: Scaffold(
        key: controller.childKey,
        body: Column(
          children: [
            _createTabBar(),
            Expanded(
              child: TabBarView(
                controller: controller.tabController,
                children: [_createDetailView(), _createCommentView()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 创建tabBar
  Widget _createTabBar() {
    return TabBar(controller: controller.tabController, tabs: controller.tabs);
  }

  // 创建详情
  Widget _createDetailView() {
    return ListView(
      children: [
        _createResourceDetailInfo(),
        // 创建资源播放控件按钮
        _createResourceControlBtn(),

        Obx(
          () => controller.playerController.value == null
              ? Container()
              : SourceApi(option: PlaySourceOptionModel(isSelect: true)),
        ),
        Obx(
          () => controller.playerController.value == null
              ? Container()
              : SourceGroup(
                  option: PlaySourceOptionModel(singleHorizontalScroll: true),
                ),
        ),
        Obx(
          () => controller.playerController.value == null
              ? Container()
              : ChapterList(
                  option: PlaySourceOptionModel(singleHorizontalScroll: true),
                ),
        ),
      ],
    );
  }

  Widget _createCommentView() {
    return Column(children: [Text("评论信息")]);
  }

  /// 创建播放器
  _createPlayer() {
    return Obx(() => controller.playerWidget.value ?? Container());
  }

  /// 资源信息
  _createResourceDetailInfo() {
    return Obx(() {
      if (controller.videoModel.value == null) {
        return const Center(child: Text("获取资源为空"));
      }
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: WidgetStyleCommons.safeSpace,
          horizontal: WidgetStyleCommons.safeSpace,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                bottom: WidgetStyleCommons.safeSpace / 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      controller.videoModel.value!.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      controller.bottomSheetController = controller
                          .childKey
                          .currentState
                          ?.showBottomSheet(
                            backgroundColor: Colors.transparent,
                            (context) => Container(
                              color: Colors.white,
                              child: ResourceDetailInfoWidget(
                                controller: controller,
                              ),
                            ),
                          );
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "详情",
                          style: TextStyle(
                            color: Theme.of(Get.context!).primaryColor,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_right_rounded,
                          size: secondaryTextFontSize * 1.5,
                          color: Theme.of(Get.context!).primaryColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  scrollbars: false,
                  dragDevices: {
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.touch,
                  },
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 评分
                      Text(
                        controller.videoModel.value!.score != null
                            ? "${controller.videoModel.value!.score}分"
                            : "暂无",
                        style: TextStyle(fontSize: secondaryTextFontSize),
                      ),
                      // 地区
                      Container(
                        padding: EdgeInsets.only(
                          left: WidgetStyleCommons.safeSpace / 2,
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                right: WidgetStyleCommons.safeSpace / 2,
                              ),
                              child: Text(
                                "|",
                                style: TextStyle(
                                  fontSize: secondaryTextFontSize,
                                ),
                              ),
                            ),
                            Text(
                              controller.videoModel.value!.area != null
                                  ? "${controller.videoModel.value!.area}"
                                  : "地区缺失",
                              style: TextStyle(fontSize: secondaryTextFontSize),
                            ),
                          ],
                        ),
                      ),
                      // 时间
                      Container(
                        padding: EdgeInsets.only(
                          left: WidgetStyleCommons.safeSpace / 2,
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                right: WidgetStyleCommons.safeSpace / 2,
                              ),
                              child: Text(
                                "|",
                                style: TextStyle(
                                  fontSize: secondaryTextFontSize,
                                ),
                              ),
                            ),
                            Text(
                              controller.videoModel.value!.year != null
                                  ? "${controller.videoModel.value!.year}"
                                  : "时间缺失",
                              style: TextStyle(fontSize: secondaryTextFontSize),
                            ),
                          ],
                        ),
                      ),

                      // 类型
                      Container(
                        padding: EdgeInsets.only(
                          left: WidgetStyleCommons.safeSpace / 2,
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                right: WidgetStyleCommons.safeSpace / 2,
                              ),
                              child: Text(
                                "|",
                                style: TextStyle(
                                  fontSize: secondaryTextFontSize,
                                ),
                              ),
                            ),
                            Text(
                              "${controller.videoModel.value!.classList == null ? '未知类型' : controller.videoModel.value!.classList?.join(' ')}",
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: secondaryTextFontSize),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                controller.videoModel.value!.detailContent ?? '',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    });
  }

  // 资源播放控件按钮
  _createResourceControlBtn() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(
            horizontal: WidgetStyleCommons.safeSpace,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth - WidgetStyleCommons.safeSpace * 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Icon(Icons.favorite_outline_rounded, size: 30),
                        Text("收藏"),
                      ],
                    ),
                  ),
                  onTap: () {},
                ),
                InkWell(
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Icon(Icons.downloading_rounded, size: 30),
                        Text("下载"),
                      ],
                    ),
                  ),
                  onTap: () {},
                ),
                InkWell(
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Icon(Icons.share_rounded, size: 30),
                        Text("分享"),
                      ],
                    ),
                  ),
                  onTap: () {},
                ),
                InkWell(
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Icon(Icons.link_rounded, size: 30),
                        Text("链接"),
                      ],
                    ),
                  ),
                  onTap: () {
                    // logger.d("当前播放章节：${playingChapterIndex.value}，链接：${playUrl.value}");
                    var chapterUrl = controller
                        .playerController
                        .value
                        ?.resourcePlayState
                        .activatedChapter
                        ?.playUrl;
                    LoggerUtils.logger.d("当前播放章节链接：$chapterUrl");
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
