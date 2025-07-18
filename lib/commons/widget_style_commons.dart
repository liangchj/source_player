
import 'package:flutter/material.dart';

class WidgetStyleCommons {
  // 主色调
  static const Color mainColor = Color(0xFF65F4FD);
  // 视频卡片宽度
  static double videoCardWidth = 240.0;
  // 视频卡片比例
  static double videoCardAspectRatio = 16 / 10;

  static double bottomSheetHeaderHeight = 45;

  // 间距
  static double safeSpace = 12;
  // 卡片间距
  static const double cardSpace = 8;

  // 图片圆角
  static const Radius imgRadius = Radius.circular(10);

  static const BorderRadius mdRadius = BorderRadius.all(imgRadius);

  // 标题文字大小
  static const double titleFontSize = 18;

  // 播放源
  static const double playSourceGridMaxWidth = 120;
  static const double playSourceGridRatio = 2 / 1;
  static const double playSourceHeight = 40;

  // 章节信息
  static const double chapterHeight = 60;
  static const double chapterGridMaxWidth = 120;
  static const double chapterGridRatio = 2 / 1;
  static const double chapterBorderWidth = 1;
  static const double chapterBorderRadius = 6.0;
  static const EdgeInsets chapterPadding = EdgeInsets.symmetric(horizontal: 6, vertical: 2);
  static const Color chapterBackgroundColor = Color(0xFFD1D5D5);
  static const Color chapterTextColor = Colors.black;
  static const Color chapterTextActivatedColor = mainColor;
}