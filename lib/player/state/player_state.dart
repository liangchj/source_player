import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlayerState {
  // 添加 GlobalKey 用于获取指定 widget
  final verticalPlayerWidgetKey = GlobalKey();

  final playerWidgetKey = GlobalKey();

  bool autoPlay = false;

  // 播放器
  var playerView = Rx<Widget?>(Container());

  var fullScreen = false.obs;

  var playing = false.obs;
  var buffering = false.obs;
  var finished = false.obs;

  // 错误信息
  var errorMsg = "".obs;

  // 视频播放比例
  var playerAspectRatio = (16 / 9.0).obs;

  // 视频本身的比例
  var videoAspectRatio = 1.0.obs;


  String playUrl = "asset://assets/video/test.mp4";


}