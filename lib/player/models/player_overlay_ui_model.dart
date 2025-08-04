import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/logger_utils.dart';

class PlayerOverlayUIModel {
  final String key;
  var ui = Rx<Widget?>(null);
  var visible = false.obs;
  Widget? child;
  bool useAnimationController;
  AnimationController? animateController;
  Tween? tween;
  Duration? animationDuration;
  Widget Function(PlayerOverlayUIModel) widgetCallback;

  PlayerOverlayUIModel({
    required this.key,
    this.child,
    this.useAnimationController = false,
    this.animateController,
    this.tween,
    this.animationDuration,
    required this.widgetCallback,
  });

  Animation? get animation => tween != null && animateController != null
      ? tween!.animate(animateController!)
      : null;

  bool get useAnimate =>
      useAnimationController &&
      animateController != null &&
      animation != null &&
      ui.value != null;
}

class PlayerUITransition {
  static Widget playerUISlideTransition(PlayerOverlayUIModel uiModel) {
    try {
      return uiModel.useAnimate
          ? SlideTransition(
              position: uiModel.animation as Animation<Offset>,
              child: uiModel.ui.value ?? Container(),
            )
          : Container();
    } catch (e) {
      LoggerUtils.logger.e("创建${uiModel.key}的ui报错：$e");
      return Container();
    }
  }

  static Widget playerUIOpacityAnimation(PlayerOverlayUIModel uiModel) {
    try {
      return uiModel.useAnimate
          ? MyOpacityTransition(
              animationOpacity: uiModel.animation as Animation<Opacity>,
              child: uiModel.ui.value ?? Container(),
            )
          : Container();
    } catch (e) {
      LoggerUtils.logger.e("创建${uiModel.key}的ui报错：$e");
      return Container();
    }
  }
}

class MyOpacityTransition extends AnimatedWidget {
  const MyOpacityTransition({
    super.key,
    required this.animationOpacity,
    required this.child,
  }) : super(listenable: animationOpacity);

  final Animation<Opacity> animationOpacity;
  final Widget child;

  Animation<Opacity> get opacityFactor => listenable as Animation<Opacity>;

  @override
  Widget build(BuildContext context) {
    return Opacity(opacity: opacityFactor.value.opacity, child: child);
  }
}
