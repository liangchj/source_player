import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:source_player/player/iplayer.dart';

import '../commons/widget_style_commons.dart';
import 'controller/player_controller.dart';
import 'media_kit_player.dart';

class PlayerView extends StatefulWidget {
  const PlayerView({
    super.key,
    this.controller,
    this.player,
    this.onCreatePlayerController,
  });
  final PlayerController? controller;
  final IPlayer? player;
  final Function(PlayerController)? onCreatePlayerController;

  @override
  State<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> {
  late PlayerController _playerController;
  late final IPlayer player;

  @override
  void initState() {
    _playerController = widget.controller ?? Get.put(PlayerController());
    if (widget.player == null) {
      MediaKit.ensureInitialized();
    }
    player = widget.player ?? MediaKitPlayer();
    _playerController.player(player);
    widget.onCreatePlayerController?.call(_playerController);
    super.initState();
  }

  @override
  void dispose() {
    _playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _playerController.playerState.verticalPlayerWidgetKey,
      child: Obx(
        () => _playerController.playerState.isFullscreen.value
            ? Container()
            : Container(child: _playerController.playerState.playerView.value),
      ),
    );
  }
}

class FullscreenPlayerPage extends StatelessWidget {
  final PlayerController controller = Get.find<PlayerController>();

  FullscreenPlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BackButtonListener(
      onBackButtonPressed: () {
        // 执行退出全屏逻辑
        controller.fullscreenUtils.toggleFullscreen();
        return Future.value(true); // 表示已经处理了返回事件
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          // 只有当没有真正 pop 时才执行自定义逻辑
          if (!didPop) {
            // 执行退出全屏逻辑
            controller.fullscreenUtils.toggleFullscreen();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: LayoutBuilder(builder: (context, constraints) {
            final availableWidth = constraints.maxWidth - WidgetStyleCommons.safeSpace * 2; // 减去左右边距
            final sortControls = controller.fullscreenBottomUIItemList.toList()..sort((a, b) => a.priority.compareTo(b.priority));
            double currentWidth = 0.0;
            for (final control in sortControls) {
              final needWidth = currentWidth + control.fixedWidth;
              if (needWidth <= availableWidth) {
                control.visible(true);
                currentWidth = needWidth;
              } else {
                control.visible(false);
              }
            }
            return Obx(
                  () => controller.playerState.playerView.value ?? Container(),
            );
          }),
        ),
      ),
    );
  }
}
