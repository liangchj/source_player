
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:source_player/player/ui/player_speed_ui.dart';

import '../commons/player_commons.dart';
import '../controller/player_controller.dart';
// 顶部UI
class PlayerTopUI extends GetView<PlayerController> {
  const PlayerTopUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // 背景渐变效果
      decoration: BoxDecoration(gradient: PlayerCommons.topUILinearGradient),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 返回按钮
          IconButton(
              onPressed: () {
                controller.fullscreenUtils.toggleFullscreen();
              },
              icon: const Icon(Icons.arrow_back_ios_new_rounded)),
          // 标题
          Expanded(child: Text(
            "标题",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )),
          // 右边控制栏
          _buildVerticalScreenTopRight(),
        ],
      ),
    );
  }


  // 垂直屏幕显示内容
  _buildVerticalScreenTopRight() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // 最右边的按钮
        IconButton(
            onPressed: () {
              openPlayerSettingUI();
            },
            icon: PlayerCommons.settingIcon),
      ],
    );
  }

  // 打开设置
  void openPlayerSettingUI() {
    controller
        .hideUIByKeyList(controller.uiState.overlayUIMap.keys.toList());
    verticalScreenSetting();
  }


  // 竖屏设置
  verticalScreenSetting() {
    openBottomSheet(SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Column(
              children: [Icon(Icons.favorite_border_rounded), Text("收藏")],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Column(
              children: [Icon(Icons.file_download_rounded), Text("缓存")],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: InkWell(
              onTap: () {
                //关闭对话框
                bool open = Get.isBottomSheetOpen ?? false;
                if (open) {
                  Get.closeAllBottomSheets();
                }
                openBottomSheet(const PlayerSpeedUI());
              },
              child: const Column(
                children: [Icon(Icons.fast_forward_rounded), Text("倍数播放")],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Column(
              children: [Icon(Icons.link_rounded), Text("复制链接")],
            ),
          ),
        ],
      ),
    ));
  }

  /// 打开底部窗口
  openBottomSheet(Widget widget) {
    Get.bottomSheet(
        Stack(children: [
          // SingleChildScrollView(child: widget,),
          Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: widget,
          ),
          Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    Container(
                      height: 6,
                      color: Colors.grey.withOpacity(0.1),
                    ),
                    TextButton(
                        onPressed: () {
                          //关闭对话框
                          bool open = Get.isBottomSheetOpen ?? false;
                          if (open) {
                            Get.closeAllBottomSheets();
                          }
                        },
                        child: const Text("取消"))
                  ],
                ),
              ))
        ]),
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadiusDirectional.only(
                topStart: Radius.circular(10), topEnd: Radius.circular(10))));
  }

}