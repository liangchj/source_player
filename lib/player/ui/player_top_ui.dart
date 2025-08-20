import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:source_player/commons/icon_commons.dart';
import 'package:source_player/player/ui/player_setting_ui.dart';

import '../../commons/widget_style_commons.dart';
import '../commons/player_commons.dart';
import '../controller/player_controller.dart';
import '../enums/player_ui_key_enum.dart';
import '../../utils/bottom_sheet_dialog_utils.dart';

// 顶部UI
class PlayerTopUI extends GetView<PlayerController> {
  const PlayerTopUI({super.key, this.pauseScroll = false});
  final bool pauseScroll;

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
            color: WidgetStyleCommons.iconColor,
            onPressed: () {
              // controller.fullscreenUtils.exitFullscreen();
              controller.fullscreenUtils.toggleFullscreen(exit: true);
            },
            // icon: const Icon(Icons.arrow_back_ios_new_rounded)),
            icon: IconCommons.backIcon,
          ),
          if (pauseScroll)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: TextButton(
                      onPressed: () {
                        if (!controller.playerState.isPlaying.value) {
                          controller.play();
                        }
                      },
                      child: Obx(() {
                        String prefix =
                            controller.playerState.isInitialized.value
                            ? "立即"
                            : controller.playerState.isFinished.value
                            ? "重新"
                            : "继续";
                        return Text("$prefix播放", style: TextStyle(color: Colors.white),);
                      }),
                    ),
                  ),
                ],
              ),
            )
          else
            // 标题
            Expanded(
              child: Obx(
                () => Text(
                  "${controller.resourceState.videoModel.value?.name}[第${controller.resourceState.state.chapterActivatedIndex.value + 1}集]",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          // 右边控制栏
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // 最右边的按钮
              IconButton(
                onPressed: () {
                  openPlayerSettingUI(context);
                },
                icon: PlayerCommons.settingIcon,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 打开设置
  void openPlayerSettingUI(BuildContext context) {
    controller.hideUIByKeyList(controller.uiState.overlayUIMap.keys.toList());
    var size = MediaQuery.of(context).size;
    if (controller.playerState.isFullscreen.value &&
        size.width < size.height &&
        size.width > 500) {
      controller.showUIByKeyList([PlayerUIKeyEnum.settingUI.name]);
      return;
    }

    BottomSheetDialogUtils.openBottomSheet(
      DefaultTextStyle(
        style: TextStyle(
          color: controller.playerState.isFullscreen.value
              ? Colors.white
              : Colors.black,
        ),
        child: Padding(
          padding: EdgeInsets.all(WidgetStyleCommons.safeSpace),
          child: PlayerSettingUI(bottomSheet: true),
        ),
      ),
      closeBtnShow: !controller.playerState.isFullscreen.value,
      backgroundColor: controller.playerState.isFullscreen.value
          ? PlayerCommons.playerUIBackgroundColor
          : Colors.white,
    );

    /*openBottomSheet(
        DefaultTextStyle(
          style: TextStyle(color: controller.playerState.isFullscreen.value ? Colors.white : Colors.black),
          child: Padding(
            padding: EdgeInsets.all(WidgetStyleCommons.safeSpace),
            child: PlayerSettingUI(bottomSheet: true,),
          ),
        )
    );*/
  }

  /// 打开底部窗口
  openBottomSheet(Widget widget) {
    Widget bottomsheet = controller.playerState.isFullscreen.value
        ? widget
        : Stack(
            children: [
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
                        color: Colors.grey.withValues(alpha: 0.1),
                      ),
                      TextButton(
                        onPressed: () {
                          //关闭对话框
                          bool open = Get.isBottomSheetOpen ?? false;
                          if (open) {
                            Get.closeAllBottomSheets();
                          }
                        },
                        child: Text("取消"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
    Get.bottomSheet(
      bottomsheet,
      // backgroundColor: Colors.white,
      backgroundColor: controller.playerState.isFullscreen.value
          ? PlayerCommons.playerUIBackgroundColor
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(10),
          topEnd: Radius.circular(10),
        ),
      ),
    );
  }
}
