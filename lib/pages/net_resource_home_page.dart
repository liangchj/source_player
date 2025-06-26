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

class _NetResourceHomePageState extends State<NetResourceHomePage> {
  final NetResourceHomeController controller = Get.put(
    NetResourceHomeController(),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _loadApiConfig());
  }

  Widget _loadApiConfig() {
    return Obx(
      () => controller.loading.value
          ? const Center(child: LoadingWidget(textWidget: Text("加载api配置中...")))
          : controller.apiConfigLoadSuc.value
          ? _loadTypeList()
          : Center(child: Text("加载api配置失败：${controller.errorMsg.value}")),
    );
  }

  Widget _loadTypeList() {
    return Obx(
      () => DefaultTabController(
        length: controller.topTypeList.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              CurrentConfigs.currentApi?.apiBaseModel.name ?? "未配置api",
            ),
            bottom: TabBar(
              padding: EdgeInsets.only(top: 0),
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              controller: controller.tabController,
              tabs:
                  controller.typeLoading.value || !controller.typeLoadSuc.value
                  ? []
                  : controller.topTypeList.map((e) => Tab(text: e.name)).toList(),
            ),
          ),
          body: controller.typeLoading.value
              ? const Center(
                  child: LoadingWidget(textWidget: Text("加载视频类型中...")),
                )
              : controller.typeLoadSuc.value
              ? TabBarView(children: controller.typeTabBarViews)
              : Center(child: Text("加载视频类型失败：${controller.errorMsg.value}")),
        ),
      ),
    );
  }
}
