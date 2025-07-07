import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../getx_controller/net_resource_detail_controller.dart';
import '../getx_controller/player_controller.dart';
import '../widgets/loading_widget.dart' show LoadingWidget;

/// 网络资源详情页面
/// 涉及到icon的，若使用系统的icon，统一使用rounded结尾的
class NetResourceDetailPage extends StatefulWidget {
  const NetResourceDetailPage({super.key, required this.resourceId});

  final String resourceId;

  @override
  State<NetResourceDetailPage> createState() => _NetResourceDetailPageState();
}

class _NetResourceDetailPageState extends State<NetResourceDetailPage> with TickerProviderStateMixin {
  /// 横向padding
  final double horizontalPadding = 14.0;

  /// 纵向padding
  final double verticalPadding = 10.0;

  /// 二级文字字体大小
  final double secondaryTextFontSize = 12.0;
  final double secondaryTextHorizontalPadding = 8.0;
  late NetResourceDetailController controller;

  final double _playerAspectRatio = 9/ 16.0;
  final double _minPlayerHeight = 60;

  final PlayerController playerController = PlayerController();
  late TabController _tabController;
  @override
  void initState() {
    print("entry initState");
    controller = Get.put(NetResourceDetailController(widget.resourceId), tag: widget.resourceId);
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.disposeId(widget.resourceId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("渲染");
    return Scaffold(
      // appBar: AppBar(leading: BackButton()),
      body: Obx(
        () => controller.loadingState.value.loading
            ? const Center(
                child: SizedBox(
                  height: 500,
                  child: LoadingWidget(textWidget: Text("资源加载中...")),
                ),
              )
            :
            !controller.loadingState.value.loadedSuc
          ? Center(
              child: Text("资源加载失败: ${controller.loadingState.value.errorMsg}"),
            )
            : controller.videoModel.value == null
            ? const Center(child: Text("获取资源为空"))
            // : SizedBox(width: double.infinity, child: _createDetailAndPlay()),
        : _createDetailScrollView(),
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
      headerSliverBuilder: (BuildContext c, bool f) {
        return [
          SliverAppBar(
            automaticallyImplyLeading: false,
            expandedHeight: MediaQuery.of(context).size.width * _playerAspectRatio,
            collapsedHeight: playerController.playing.value
                        ? MediaQuery.of(context).size.width * _playerAspectRatio
                        : _minPlayerHeight,
            floating: false,
            pinned: true,
            flexibleSpace: Stack(
              children: [
                Positioned.fill(child: _createPlayer(),),
              ]
            ),
          ),
        ];
      },
      pinnedHeaderSliverHeightBuilder: () {
        return pinnedHeaderHeight;
      },
      body: Column(
        children: [
          _createTabBar(),
          Expanded(child: TabBarView(
              controller: _tabController,
              children: [
                _createDetailView(),
                _createCommentView(),
          ])),
          ]
      ),
    );
  }
  // 创建tabBar
  Widget _createTabBar() {
    return TabBar(
        controller: _tabController,
        tabs: [
      Tab(text: "简介"),
      Tab(text: "评论"),
    ]);
  }

  // 创建详情
  Widget _createDetailView() {
    return Column(
      children: [
        _createResourceDetailInfo(),
        // 资源播放控件按钮
        _createResourceControlBtn(),
        // 资源播放信息
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            /*child: ResourceFromChapterWidget(controller: controller,
            apiLayout: ResourceFromLayout.select,
              apiModuleLayout: ResourceFromLayout.select,
              chapterScrollDirection: Axis.horizontal,
              chapterTopWidgetList: [
                ChapterSortButton(controller: controller,),
                ChapterTotalAndOpenListIcon(controller: controller,)
              ],
            ),*/
          ),
        ),
        ]
    );
  }

  Widget _createCommentView () {
    return Column(
      children: [
        Text("评论信息")
      ],
    );
  }

  Widget _createDetailAndPlay() {
    return DefaultTabController(
      length: 1,
      child: Column(
        children: [
          TabBar(tabs: [
            Tab(text: "资源信息")
          ]),
          Expanded(child: TabBarView(children: [
            // 资源信息
            _createResourceDetailInfo(),
            // 资源播放控件按钮
            _createResourceControlBtn(),
            // 资源播放信息
            // Expanded(
            //   child: Padding(
            //     padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            //     /*child: ResourceFromChapterWidget(controller: controller,
            //     apiLayout: ResourceFromLayout.select,
            //       apiModuleLayout: ResourceFromLayout.select,
            //       chapterScrollDirection: Axis.horizontal,
            //       chapterTopWidgetList: [
            //         ChapterSortButton(controller: controller,),
            //         ChapterTotalAndOpenListIcon(controller: controller,)
            //       ],
            //     ),*/
            //   ),
            // ),
          ]))
        ],
      ),
    );
  }

  /// 创建播放器
  _createPlayer() {
    /*return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        return GestureDetector(
          onTap: () {
            if (height < MediaQuery.of(context).size.width * _playerAspectRatio) {
              // 点击缩小窗口时恢复默认尺寸
              // _scrollController.animateTo(0, duration: 300.ms, curve: Curves.ease);
            }
          },
          child: Stack(
            children: [
              Positioned.fill(child: Container(
                color: Colors.black,
              )), // 播放器主体
              if (height <= MediaQuery.of(context).size.width * _playerAspectRatio - 60)
                Center(child: TextButton(onPressed: (){}, child: Text("立即播放"))), // 最小化时显示播放按钮
            ],
          ),
        );
      },
    );*/

    var size = MediaQuery.of(context).size;
    double width = size.width;
    return AspectRatio(
      aspectRatio: 16 / 9.0,
      child: Container(
        color: Colors.black,
        /*child: JinPlayerView(createdPlayerGetxController: (playerGetxController) {

        }, netResourceDetailPlayController: controller, player: MediaKitPlayer(),),*/
      ),
    );
  }

  /// 资源信息
  _createResourceDetailInfo({bool showDetail = false}) {
    return Obx(() {
      if (controller.videoModel.value == null) {
        return const Center(child: Text("获取资源为空"));
      }
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: verticalPadding,
          horizontal: horizontalPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    controller.videoModel.value!.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                showDetail
                    ? IconButton(
                        onPressed: () {
                          Get.closeAllBottomSheets();
                          // Get.back();
                        },
                        icon: const Icon(Icons.close_rounded),
                      )
                    : TextButton(
                        onPressed: () {
                          double width = MediaQuery.of(context).size.width;
                          double height = MediaQuery.of(context).size.height;
                          Get.bottomSheet(
                            Container(
                              height: height - (width * 9 / 16),
                              color: Colors.white,
                              child: StreamBuilder<Object>(
                                stream: null,
                                builder: (context, snapshot) {
                                  return _createResourceDetailInfo(
                                    showDetail: true,
                                  );
                                },
                              ),
                            ),
                            isScrollControlled: true,
                          );
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "详情",
                              style: TextStyle(fontSize: secondaryTextFontSize),
                            ),
                            Icon(
                              Icons.keyboard_arrow_right_rounded,
                              size: secondaryTextFontSize * 1.5,
                            ),
                          ],
                        ),
                      ),
              ],
            ),
            if (showDetail) const Padding(padding: EdgeInsets.only(top: 8.0)),
            SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                child: Row(
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
                        left: secondaryTextHorizontalPadding,
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              right: secondaryTextHorizontalPadding,
                            ),
                            child: Text(
                              "|",
                              style: TextStyle(fontSize: secondaryTextFontSize),
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
                        left: secondaryTextHorizontalPadding,
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              right: secondaryTextHorizontalPadding,
                            ),
                            child: Text(
                              "|",
                              style: TextStyle(fontSize: secondaryTextFontSize),
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
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(
                          left: secondaryTextHorizontalPadding,
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                right: secondaryTextHorizontalPadding,
                              ),
                              child: Text(
                                "|",
                                style: TextStyle(fontSize: secondaryTextFontSize),
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
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                controller.videoModel.value!.detailContent ?? '',
                overflow: showDetail
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    });
  }

  // 资源播放控件按钮
  _createResourceControlBtn() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding,
        horizontal: horizontalPadding,
      ),
      child: SingleChildScrollView(
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
                  children: [Icon(Icons.share_rounded, size: 30), Text("分享")],
                ),
              ),
              onTap: () {},
            ),
            InkWell(
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  children: [Icon(Icons.link_rounded, size: 30), Text("链接")],
                ),
              ),
              onTap: () {
                // logger.d("当前播放章节：${playingChapterIndex.value}，链接：${playUrl.value}");
              },
            ),
          ],
        ),
      ),
    );
  }
}
