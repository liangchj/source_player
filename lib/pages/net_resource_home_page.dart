import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../cache/db/current_configs.dart';
import '../getx_controller/net_resource_home_controller.dart';
import '../widgets/loading_widget.dart';

class NetResourceHomePage extends StatefulWidget {
  const NetResourceHomePage({super.key});

  @override
  State<NetResourceHomePage> createState() => _NetResourceHomePageState();
}

class _NetResourceHomePageState extends State<NetResourceHomePage>
    with AutomaticKeepAliveClientMixin {
  final NetResourceHomeController controller = Get.put(
    NetResourceHomeController(),
  );
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(
      () => controller.loading.value
          ? const Center(child: LoadingWidget(textWidget: Text("加载api配置中...")))
          : !controller.apiConfigLoadSuc.value
          ? Center(child: Text("加载api配置失败：${controller.errorMsg.value}"))
          : Column(
              children: [
                _customAppBar(),
                Expanded(
                  child: _buildTypeTabBar(content: _buildTypeResourceList()),
                ),
              ],
            ),
    );
  }

  // 自定义头部
  Widget _customAppBar() {
    return Container(
      height: 50,
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(CurrentConfigs.currentApi?.apiBaseModel.name ?? ""),
          _customAppBarRightButtons(),
        ],
      ),
    );
  }

  // 头部右边按钮
  Widget _customAppBarRightButtons() {
    return Row(
      children: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
      ],
    );
  }

  // 构建类型
  Widget _buildTypeTabBar({Widget? content}) {
    return Obx(() {
      if (controller.typeLoading.value) {
        return const Center(
          child: LoadingWidget(textWidget: Text("加载视频类型中...")),
        );
      }
      if (!controller.typeLoadSuc.value) {
        return Center(child: Text("加载视频类型失败：${controller.errorMsg.value}"));
      }
      if (controller.topTypeList.isEmpty) {
        return Center(child: Text("当前api无数据"));
      }
      if (controller.tabController.value == null) {
        return Center(child: Text("构建失败，请重试！"));
      }

      return DefaultTabController(
        length: controller.topTypeList.length,
        child: Column(
          children: [
            SizedBox(
              height: 42,
              width: double.infinity,
              child: TabBar(
                padding: EdgeInsets.only(top: 0),
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                controller: controller.tabController.value,
                tabs: controller.topTypeList
                    .map((e) => Tab(text: e.name))
                    .toList(),
              ),
            ),
            Expanded(child: content ?? Container()),
          ],
        ),
      );
    });
  }

  // 构建类型下的资源列表
  Widget _buildTypeResourceList() {
    return TabBarView(
        controller: controller.tabController.value,
        children: controller.typeTabBarViews);
  }

  @override
  bool get wantKeepAlive => true;
}
