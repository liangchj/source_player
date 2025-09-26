import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';
import 'package:get/get.dart';
import 'package:source_player/player/controller/player_controller.dart';
import '../state/player_state.dart';

class FullscreenUtils {
  final PlayerController controller;

  FullscreenUtils(this.controller);

  PlayerState get playerState => controller.playerState;

  void toggleFullscreen({bool exit = false}) {
    bool playing = controller.player.value?.playing ?? false;
    if (controller.player.value != null && playing) {
      controller.player.value!.pause();
    }
    if (playerState.isFullscreen.value || exit) {
      bool fullscreen = playerState.isFullscreen.value;
      exitFullscreen();
      if (fullscreen && !controller.onlyFullscreen && playing) {
        controller.player.value!.play();
      }
    } else {
      enterFullscreen();
      if (playing) {
        controller.player.value!.play();
      }
    }
    /*if (exit) {
      playerState.isFullscreen(false);
    } else {
      playerState.isFullscreen.toggle();
    }*/
  }

  void enterFullscreen() {
    FullScreen.setFullScreen(true);
    playerState.isFullscreen(true);
    lockLandscapeOrientation();
  }

  void lockLandscapeOrientation() {
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
    FullScreen.setFullScreen(false);
    if (!playerState.isFullscreen.value || controller.onlyFullscreen) {
      if (controller.onlyFullscreen) {
        controller.pause();
        controller.player.value?.onDisposePlayer();
      }
      Navigator.of(Get.context!).pop();
    }
    playerState.isFullscreen(false);
    unlockOrientation();
  }

  // 恢复竖屏
  void unlockOrientation() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
    // 恢复竖屏
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }
}

class PlayerFullscreenRoute extends PageRouteBuilder {
  final Widget fullscreenPage; // 全屏页面
  final Offset position;
  final Size size;

  PlayerFullscreenRoute({
    required this.fullscreenPage,
    required this.position,
    required this.size,
  }) : super(
         // 1. 补充必传的 pageBuilder（核心修复点）
         pageBuilder:
             (
               BuildContext context,
               Animation<double> animation,
               Animation<double> secondaryAnimation,
             ) => fullscreenPage, // 直接返回全屏页面作为路由内容
         // 2. 保持原有动画配置
         transitionDuration: const Duration(milliseconds: 300),
         reverseTransitionDuration: const Duration(milliseconds: 300),
         opaque: false, // 避免闪屏
       );

  // 3. 保持原有的过渡动画逻辑（复用放大效果）
  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final screenSize = MediaQuery.of(context).size;
    final animationValue = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOut,
    );

    return AnimatedBuilder(
      animation: animationValue,
      builder: (context, child) {
        final currentSize = Size.lerp(size, screenSize, animationValue.value)!;

        final currentPosition = Offset.lerp(
          position,
          Offset.zero,
          animationValue.value,
        )!;

        return Stack(
          children: [
            Opacity(
              opacity: animationValue.value,
              child: Container(color: Colors.black),
            ),
            Positioned(
              left: currentPosition.dx,
              top: currentPosition.dy,
              width: currentSize.width,
              height: currentSize.height,
              child: ClipRect(child: child),
            ),
          ],
        );
      },
      child: child,
    );
  }
}
