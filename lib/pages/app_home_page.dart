import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    return Obx(() {
      return Scaffold(
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: controller.tabController,
          children: controller.tabPageList,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.currentTabIndex.value,
          type: BottomNavigationBarType.fixed,
          items: controller.bottomTabList,
          // selectedFontSize: AppConstants.textSize,
          onTap: (pageIndex) => controller.currentTabIndex(pageIndex),
        ),
      );
    });
  }
}
