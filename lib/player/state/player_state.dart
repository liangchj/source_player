import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlayerState {
  // 添加 GlobalKey 用于获取指定 widget
  final verticalPlayerWidgetKey = GlobalKey();

  final playerWidgetKey = GlobalKey();

  // 视频播放比例
  var playerAspectRatio = (16 / 9.0).obs;

  // 视频本身的比例
  var videoAspectRatio = 1.0.obs;

  bool autoPlay = false;

  // 播放器
  var playerView = Rx<Widget?>(Container());

  // 全屏
  var isFullscreen = false.obs;

  // 错误信息
  var errorMsg = "".obs;

  // 视频已初始化
  var isInitialized = true.obs;
  // 播放中
  var isPlaying = false.obs;
  // 缓冲中
  var isBuffering = false.obs;
  // 进度跳转中
  var isSeeking = false.obs;

  // 已结束
  var isFinished = false.obs;

  // 播放速度： ['0.25x', '0.5x', '0.75x', '1.0x', '1.25x', '1.5x', '1.75x', '2.0x']
  var playSpeed = 1.0.obs;


  // 总时长
  var duration = Duration.zero.obs;
  // 当前播放时长
  var positionDuration = Duration.zero.obs;

  // 缓存时长
  var bufferedDuration = Duration.zero.obs;



  // 拖动进度时播放状态
  bool beforeSeekToIsPlaying = false;
  // 拖动中
  var isDragging = false.obs;
  // 拖动进度时的播放位置
  Duration dragProgressPositionDuration = Duration.zero;
  // 播放进度拖动秒数
  var draggingSecond = 0.obs;
  // 前一次拖动剩余值（每次更新只获取整数部分更新，剩下的留给后面更新）
  double draggingSurplusSecond = 0.0;


  // 当前音量值（使用百分比）
  var volume = 0.obs;
  // 当前音量值（使用百分比）
  var brightness = 0.obs;
  // 纵向滑动剩余值（每次更新只获取整数部分更新，剩下的留给后面更新）
  double verticalDragSurplus = 0.0;
  var isVolumeDragging = false.obs; // 音量拖动中
  var isBrightnessDragging = false.obs; // 亮度拖动中




  String playUrl = "asset://assets/video/test.mp4";




}