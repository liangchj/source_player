import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../pages/media_library_home_page.dart';
import '../pages/net_resource_home_page.dart';
import '../pages/personal_home_page.dart';

class HomeController extends GetxController with GetSingleTickerProviderStateMixin {
  var appTitle = "网络资源".obs;
  final List<BottomNavigationBarItem> bottomTabList = [
    const BottomNavigationBarItem(label: "网络视频", icon: Icon(Icons.home)),
    const BottomNavigationBarItem(
      label: "媒体库",
      icon: Icon(Icons.video_collection_rounded),
    ),
    const BottomNavigationBarItem(
      label: "我的",
      icon: Icon(Icons.people_alt_rounded),
    ),
  ];
  late List<Widget> tabPageList;
  // var currentTabIndex = 0.obs;
  late TabController tabController;

  @override
  void onInit() {
    tabPageList = [
      const NetResourceHomePage(),
      const MediaLibraryHomePage(),
      const PersonalHomePage(),
    ];
    tabController = TabController(length: tabPageList.length, vsync: this);
    /*ever(currentTabIndex, (index) {
      tabController.index = index;
    });*/


    super.onInit();
  }
}
