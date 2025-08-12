
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlayerBottomUIItemModel {
  final ControlType type;
  final double fixedWidth; // 固定宽度（动态控件可设为0）
  final int priority; // 优先级（数字越大越先显示）
  final Widget child; // 控件UI
  var visible = true.obs;

  PlayerBottomUIItemModel({
    required this.type,
    required this.fixedWidth,
    required this.priority,
    required this.child,
    bool? visible,
  }) {
    this.visible(visible ?? true);
  }
}


// 控件类型枚举（用于区分不同功能的控件）
enum ControlType {
  play,       // 播放/暂停/重新播放
  next,       // 下一个视频
  danmaku, // 弹幕开关
  sendDanmaku, // 发送弹幕
  danmakuSetting, // 弹幕设置
  chapter,    // 章节选择
  speed,      // 倍数播放
  exitOrEntryFullscreen,      // 全屏/退出全屏
}