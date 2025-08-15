import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:source_player/pages/media_library_home_page.dart';

import '../getx_controller/home_controller.dart';

class AppHomePage extends StatefulWidget {
  const AppHomePage({super.key});

  @override
  State<AppHomePage> createState() => _AppHomePageState();
}

class _AppHomePageState extends State<AppHomePage> {
  final HomeController controller = Get.put(HomeController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          scrollbars: false,
          dragDevices: {
            PointerDeviceKind.mouse,
            PointerDeviceKind.touch,
          },
        ),
        child: TabBarView(
          // 你现有的 TabBarView 配置
          physics: const NeverScrollableScrollPhysics(),
          controller: controller.tabController,
          children: controller.tabPageList,
        ),
      ),
      /*body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: controller.tabController,
        children: controller.tabPageList,
      ),*/
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: controller.currentIndex.value,
        type: BottomNavigationBarType.fixed,
        items: controller.bottomTabList,
        // selectedFontSize: AppConstants.textSize,
        onTap: (pageIndex) {
          controller.currentIndex.value = pageIndex;
          controller.tabController.index = pageIndex;
        },
      )),
     /* bottomNavigationBar: BottomNavigationBar(
        currentIndex: controller.tabController.index,
        type: BottomNavigationBarType.fixed,
        items: controller.bottomTabList,
        // selectedFontSize: AppConstants.textSize,
        onTap: (pageIndex) => controller.tabController.index = pageIndex,
      ),*/
    );
  }
}
