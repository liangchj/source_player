import 'package:flutter/material.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:source_player/player/iplayer.dart';

import '../commons/widget_style_commons.dart';
import 'controller/player_controller.dart';
import 'media_kit_player.dart';
import 'models/bottom_ui_control_item_model.dart';

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
    if (widget.controller == null) {
      Get.delete<PlayerController>();
      _playerController = Get.put(PlayerController());
    } else {
      _playerController = widget.controller!;
    }
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
    return PopScope(
      key: _playerController.playerState.playerWidgetKey,
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          FullScreen.setFullScreen(false);
          _playerController.fullscreenUtils.unlockOrientation();
          return;
        }
        if (_playerController.interceptPop.value) {
          _playerController.hideUIByKeyList(
            _playerController.uiState.interceptRouteUIKeyList,
          );
        } else {
          FullScreen.setFullScreen(false);
          _playerController.fullscreenUtils.unlockOrientation();
          Navigator.pop(context);
        }
      },
      child: _playerWidget(),
    );
  }

  Widget _playerWidget() {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          _playerController.fullScreenWidthChange(constraints.maxWidth);
          final availableWidth =
              constraints.maxWidth - WidgetStyleCommons.safeSpace * 2; // 减去左右边距
          final sortControls =
              _playerController.fullscreenBottomUIItemList
                  .where((item) => item.type != ControlType.none)
                  .toList()
                ..sort((a, b) => a.priority.compareTo(b.priority));
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
            () => _playerController.playerState.playerView.value ?? Container(),
          );
        },
      ),
    );
  }
}
