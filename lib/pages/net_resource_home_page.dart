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
    return Obx(
      () => Scaffold(
        body: controller.loading.value
            ? const Center(child: LoadingWidget(textWidget: Text("资源加载中...")))
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return Obx(
      () => controller.errorMsg.isEmpty
          ? Center(child: Text("加载api成功，${CurrentConfigs.currentApi?.apiBaseModel.name}"))
          : Center(child: Text("加载api失败：${controller.errorMsg.value}")),
    );
  }
}
