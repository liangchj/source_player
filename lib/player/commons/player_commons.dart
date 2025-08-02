

import 'package:flutter/material.dart';

class PlayerCommons {
  // 图标大小
  static const double iconSize = 26.0;

  // 渐变色
  static List<Color> gradientBackground = [
    Colors.black54,
    Colors.black45,
    Colors.black38,
    Colors.black26,
    Colors.black12,
    Colors.transparent
  ];
  // 顶部UI渐变色
  static final LinearGradient topUILinearGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: gradientBackground);

  // 顶部UI渐变色
  static final LinearGradient bottomUILinearGradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: gradientBackground);

  // ui背景色
  static Color backgroundColor = Colors.black.withOpacity(0.8);


  // 进入全屏图标
  static const Icon entryFullScreenIcon = Icon(
    Icons.fullscreen_rounded,
    size: iconSize,
    color: Colors.white,
  );
  // 退出全屏图标
  static const Icon exitFullScreenIcon = Icon(
    Icons.fullscreen_exit_rounded,
    size: iconSize,
    color: Colors.white,
  );
}