

import 'package:flutter/material.dart';

class PlayerCommons {

  // 文本文字
  // 文本文字颜色
  static const Color textColor = Colors.white;
  static const Color textBlackColor = Colors.black;

  // 图标大小
  static const double iconSize = 26.0;

  static const Icon settingIcon = Icon(
    Icons.more_vert_rounded,
    size: iconSize,
    color: Colors.white,
  );

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
  static const Icon entryFullscreenIcon = Icon(
    Icons.fullscreen_rounded,
    size: iconSize,
    color: Colors.white,
  );
  // 退出全屏图标
  static const Icon exitFullscreenIcon = Icon(
    Icons.fullscreen_exit_rounded,
    size: iconSize,
    color: Colors.white,
  );



  // 播放器信息
  // ui背景色
  static Color playerUIBackgroundColor = Colors.black.withOpacity(0.8);

  // ui动画时长
  static Duration  playerUIAnimationDuration = const Duration(milliseconds: 300);

  // 音量和亮度ui显示时长
  static const Duration volumeOrBrightnessUIShowDuration =
  Duration(milliseconds: 1000);

  static const Duration progressUIShowDuration =
  Duration(milliseconds: 1000);

  // 进度条
  // 高度
  static const double progressBarHeight = 4.0;
  // 滑块圆角
  static const double progressBarThumbRadius = 8.0;
  // 滑块内部圆角
  static const double progressBarThumbInnerRadius = 3.0;
  // 滑块外部颜色
  static Color progressBarThumbOverlayColor =
  Colors.redAccent.withOpacity(0.24);
  static Color progressBarThumbOverlayShapeColor =
  Colors.redAccent.withOpacity(0.5);
  // 滑块滑动或选中时显示外围的圆角
  static const double progressBarThumbOverlayColorShapeRadius = 16.0;



  static const List<double> playSpeedList = [
    0.25,
    0.50,
    0.75,
    1.00,
    1.25,
    1.50,
    1.75,
    2.00
  ];
  // 播放倍数 未选中时颜色
  static const Color playSpeedTextColor = Colors.white;

  // 播放速度默认宽度
  static const double speedSettingUIDefaultWidth = 150.0;

  static const double chapterUIDefaultWidth = 300.0;

  // 音量和亮度UI大小
  static const Size volumeOrBrightnessUISize = Size(80, 70);
  static const Size playProgressUISize = Size(100, 70);
}