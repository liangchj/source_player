
import 'package:flutter/material.dart';

class WidgetStyleCommons {
  // 主色调
  static const Color primaryColor = Color(0xFFB1ECE9);
  static const Color primaryContainer = Color(0xFF43C8C5); // 深色
  // 次色调
  static const Color secondaryColor = Color(0xFF9EBCB9);
  static const Color secondaryContainer = Color(0xFF748886); // 深色
  static const Color errorColor = Color(0xFFB00020); // 错误红色
  static const Color scaffoldBackground = Color(0xFFF5F5F5); // 背景灰

  // 文字颜色
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textOnPrimary = Color(0xFFFFFFFF); // 主色上的文字

  // 交互状态颜色
  static final Color hoverColor = primaryColor.withValues(alpha: 0.1); // 10% 不透明度的主色
  static final Color splashColor = secondaryColor.withValues(alpha: 0.1); // 10% 不透明度的次色调
  static final Color highlightColor = primaryColor.withValues(alpha: 0.05); // 5% 不透明度的紫色
  static final Color focusColor = secondaryColor.withValues(alpha: 0.1); // 10% 不透明度的次色调

  static const Color activatedTextColor = primaryColor;

  // 边框宽度
  static const double borderWidth = 1.0;
  // 边框圆角
  static const double borderRadius = 6.0;

  // 默认的图标颜色
  static const Color iconColor = Colors.white;
  // 图标选中颜色
  static const Color iconActivatedColor = primaryColor;

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
  static const int chapterGroupCount = 50;
  static const double chapterHeight = 50;
  static const double chapterGridMaxWidth = 120;
  static const double chapterGridRatio = 2 / 1;
  static const double chapterBorderWidth = 1;
  static const double chapterBorderRadius = 6.0;
  static const EdgeInsets chapterPadding = EdgeInsets.symmetric(horizontal: 6, vertical: 2);
  static const Color chapterBackgroundColor = Color(0xFFD1D5D5);
  static const Color chapterTextColor = Colors.black;
  static const Color chapterTextActivatedColor = primaryColor;



}