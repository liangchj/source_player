import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:source_player/commons/widget_style_commons.dart';

import '../../getx_controller/net_resource_detail_controller.dart';


class ResourceDetailInfoWidget extends StatefulWidget {
  const ResourceDetailInfoWidget({super.key, required this.controller});
  final NetResourceDetailController controller;

  @override
  State<ResourceDetailInfoWidget> createState() => _ResourceDetailInfoWidgetState();
}

class _ResourceDetailInfoWidgetState extends State<ResourceDetailInfoWidget> with SingleTickerProviderStateMixin {
  late TabController _tabController ;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      if (widget.controller.videoModel.value == null) {
        return const Center(child: Text("获取资源为空"));
      }
      return RepaintBoundary(
        child: Scaffold(
          body: Padding(
            padding: EdgeInsets.symmetric(
              // vertical: WidgetStyleCommons.safeSpace,
              horizontal: WidgetStyleCommons.safeSpace,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 头部
                _createHeader(),
                Expanded(child: TabBarView(
                    controller: _tabController,
                    children: [
                  _createBody(theme),
                ])),
              ],
            ),
          ),
        ),
      );
    });
  }

  // 创建头部
  _createHeader() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      margin: EdgeInsets.only(bottom: WidgetStyleCommons.safeSpace),
      child: Row(
        children: [
          Expanded(child: TabBar(
            controller: _tabController,
            dividerHeight: 0,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            dividerColor: Colors.transparent,
            indicator: const BoxDecoration(),
            tabs: const [Tab(text: '详情')],
            onTap: (index) {
              if (!_tabController.indexIsChanging) {
                if (index == 0) {
                  _scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                }
              }
            },
          )),
          IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }

  _createBody(ThemeData theme) {
    return ListView(
      controller: _scrollController,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 导演
            Row(
              children: [
                Text("导演："),
                Expanded(
                  child: Text(
                    widget.controller.videoModel.value!.directorList?.join(" ") ?? "无",
                  ),
                ),
              ],
            ),
            // 主演
            Row(
              children: [
                Text("主演："),
                Expanded(
                  child: Text(
                    widget.controller.videoModel.value!.actorList?.join(" ") ?? "无",
                  ),
                ),
              ],
            ),
            // 评分
            Row(
              children: [
                Text("评分："),
                Expanded(
                  child: Text(
                    widget.controller.videoModel.value!.score?.toString() ?? "无",
                  ),
                ),
              ],
            ),
            // 语言
            Row(
              children: [
                Text("语言："),
                Expanded(
                  child: Text(
                    widget.controller.videoModel.value!.languageList?.join(" ") ?? "无",
                  ),
                ),
              ],
            ),
            // 地区
            Row(
              children: [
                Text("地区："),
                Expanded(child: Text(widget.controller.videoModel.value!.area ?? "无")),
              ],
            ),
            // 年份
            Row(
              children: [
                Text("年份："),
                Expanded(child: Text(widget.controller.videoModel.value!.year ?? "无")),
              ],
            ),
            // 类型
            Row(
              children: [
                Text("类型："),
                Expanded(
                  child: Text(
                    widget.controller.videoModel.value!.classList?.join(" ") ?? "无",
                  ),
                ),
              ],
            )
          ],
        ),
        SizedBox(height: WidgetStyleCommons.safeSpace),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '简介：',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            SelectableText(widget.controller.videoModel.value!.detailContent ?? ""),
          ],
        ),
      ],
    );
  }
}
