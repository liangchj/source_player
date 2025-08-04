import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:source_player/player/controller/player_controller.dart';

import '../player_view.dart';
import '../state/player_state.dart';

class FullscreenUtils {
  final PlayerController controller;

  FullscreenUtils(this.controller);

  PlayerState get playerState => controller.playerState;

  OverlayEntry? fullscreenOverlay;

  void toggleFullscreen({BuildContext? context}) {
    bool playing = controller.player.value?.playing ?? false;
    if (controller.player.value != null && playing) {
      controller.player.value!.pause();
    }
    if (playerState.isFullscreen.value) {
      exitFullscreen();
    } else {
      enterFullscreen(context ?? Get.context!);
      if (playing) {
        controller.player.value!.play();
      }
    }
    playerState.isFullscreen.toggle();
  }

  void enterFullscreen(BuildContext context) {
    // 处理只有全屏的特殊情况
    if (controller.onlyFullscreen) {
      _enterFullscreenForLocalVideo();
      return;
    }

    OverlayState? overlay;
    try {
      overlay = Overlay.of(context, rootOverlay: true);
    } catch (e) {}

    try {
      // 如果失败，尝试使用 Navigator 获取上下文
      final navigatorContext = Navigator.of(context).context;
      overlay = Overlay.of(navigatorContext, rootOverlay: true);
    } catch (e) {}

    try {
      // 使用 GetX 提供的 overlayContext
      if (Get.overlayContext != null) {
        overlay = Overlay.of(Get.overlayContext!, rootOverlay: true);
      }
    } catch (e) {}
    if (overlay != null) {
      _enterWithOverlay(context, overlay);
    } else {
      throw Exception("无法获取OverlayState");
    }
  }

  // 本地视频全屏处理
  void _enterFullscreenForLocalVideo() {
    // 直接跳转到全屏页面（无需位置计算）
    Get.to(
      () => FullscreenPlayerPage(),
      transition: Transition.fade,
      duration: const Duration(milliseconds: 300),
    );

    // 锁定横屏
    _lockLandscapeOrientation();
  }

  void _enterWithOverlay(BuildContext context, OverlayState overlay) {
    final RenderBox renderBox =
        playerState.verticalPlayerWidgetKey.currentContext?.findRenderObject()
            as RenderBox;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    fullscreenOverlay = OverlayEntry(
      builder: (context) => AnimatedFullscreenOverlay(
        position: position,
        size: size,
        child: FullscreenPlayerPage(),
      ),
    );

    overlay.insert(fullscreenOverlay!);
    _lockLandscapeOrientation();
  }

  void _lockLandscapeOrientation() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void exitFullscreen() {
    // 移除Overlay
    fullscreenOverlay?.remove();
    fullscreenOverlay = null;

    if (!playerState.isFullscreen.value || controller.onlyFullscreen) {
      if (controller.onlyFullscreen) {
        controller.pause();
        controller.player.value?.onDisposePlayer();
      }
      Get.back();
    }
    _unlockOrientation();
  }

  // 恢复竖屏
  void _unlockOrientation() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
    // 恢复竖屏
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }
}

// 动画化全屏覆盖层
class AnimatedFullscreenOverlay extends StatelessWidget {
  final Offset position;
  final Size size;
  final Widget child;

  const AnimatedFullscreenOverlay({
    super.key,
    required this.position,
    required this.size,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: screenSize.width,
      height: screenSize.height,
      color: Colors.black,
      child: child,
    );
  }
}
