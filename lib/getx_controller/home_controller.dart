import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:source_player/utils/permission_utils.dart';

import '../cache/current_configs.dart';
import '../commons/public_commons.dart';
import '../pages/media_library_home_page.dart';
import '../pages/net_resource_home_page.dart';
import '../pages/personal_home_page.dart';
import '../utils/logger_utils.dart';

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
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
  final currentIndex = 0.obs;

  final Rx<PermissionStateEnum> permissionStateEnum = Rx<PermissionStateEnum>(PermissionStateEnum.allow);

  bool isWaitingPermissionSetting = false;

  @override
  void onInit() {
    // CurrentConfigs.statusBarHeight = Get.statusBarHeight;
    CurrentConfigs.statusBarHeight = MediaQuery.of(Get.context!).padding.top;
    tabPageList = [
      const NetResourceHomePage(),
      const MediaLibraryHomePage(),
      const PersonalHomePage(),
    ];
    tabController = TabController(length: tabPageList.length, vsync: this);

    requestPermission();

    super.onInit();
  }

  Future<void> requestPermission() async {
    await PermissionUtils.checkPermission(
      permissionList: PublicCommons.permissionList,
      onPermissionCallback: (value) {
        permissionStateEnum.value = value;
      },
    );

    if (permissionStateEnum.value!= PermissionStateEnum.allow) {
      await PermissionUtils.checkPermission(
        permissionList: PublicCommons.requiredPermissionList,
        onPermissionCallback: (value) {
          permissionStateEnum.value = value;
        },
      );
      if (permissionStateEnum.value != PermissionStateEnum.allow) {
        isWaitingPermissionSetting = true;
        openAppSettings();
      }
    }
  }

  _handleAfterPermissionSetting() async {
    isWaitingPermissionSetting = false;
    await PermissionUtils.checkPermission(
      permissionList: PublicCommons.requiredPermissionList,
      onPermissionCallback: (value) {
        permissionStateEnum.value = value;
      },
    );
  }

  /// 在退出程序时，发出询问的回调（IOS、Android 都不支持）
  /// 响应 [AppExitResponse.exit] 将继续终止，响应 [AppExitResponse.cancel] 将取消终止。
  Future<AppExitResponse> onExitRequested() async {
    LoggerUtils.logger.d('---onExitRequested');
    return AppExitResponse.exit;
  }

  /// 可见，并且可以响应用户操作时的回调
  /// 比如应用从后台调度到前台时，在 onShow() 后面 执行
  /// 注意：这个回调，初始化时 不执行
  onResume() {
    LoggerUtils.logger.d('---onResume');
    if (isWaitingPermissionSetting) {
      _handleAfterPermissionSetting();
    }
  }
}
