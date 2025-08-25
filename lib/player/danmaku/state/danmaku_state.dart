import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../commons/icon_commons.dart';
import '../models/danmaku_alpha_ratio_model.dart';
import '../models/danmaku_area_model.dart';
import '../models/danmaku_filter_type_model.dart';
import '../models/danmaku_font_size_model.dart';
import '../models/danmaku_item_model.dart';
import '../models/danmaku_peed_model.dart';

class DanmakuState {
  // 弹幕组件
  final Rx<Widget?> danmakuView = Rx<Widget?>(null);

  int prevSendSecond = -1;

  // 弹幕文件路径
  final Rx<Map<String, bool>?> danmakuFilePathMap = Rx<Map<String, bool>?>(null);

  bool get allPathReady {
    if (danmakuFilePathMap.value == null || danmakuFilePathMap.value!.isEmpty) {
      return true;
    }
    return danmakuFilePathMap.value!.values.every((element) => element);
  }

  // 弹幕列表
  final Rx<Map<int, List<DanmakuItemModel>>> danmakuMap = Rx<Map<int, List<DanmakuItemModel>>>({});

  // 弹幕文件读取去重
  final RxBool readFileDeduplication = true.obs;

  // 错误信息
  final Rx<String> errorMsg = "".obs;

  final Rx<List<String>> parseFileErrorMsg = Rx<List<String>>([]);

  // 是否已经初始化
  final RxBool isInitialized = false.obs;

  // 是否启动弹幕
  final RxBool isVisible = true.obs;


  // 时间调整
  final RxDouble adjustTime = 0.0.obs;

  // ui显示更新
  final RxDouble uiShowAdjustTime = 0.0.obs;

  // 设置
  // 不透明度
  final Rx<DanmakuAlphaRatioModel> danmakuAlphaRatio = DanmakuAlphaRatioModel(
    min: 0,
    max: 100,
    ratio: 100,
  ).obs;

  // 显示区域["1/4屏", "半屏", "3/4屏", "满屏", "无限"]，选择下标，默认半屏（下标1）
  final Rx<DanmakuAreaModel> danmakuArea = DanmakuAreaModel(
    danmakuAreaItemList: [
      DanmakuAreaItemModel(area: 0.25, name: "1/4屏"),
      DanmakuAreaItemModel(area: 0.5, name: "半屏"),
      DanmakuAreaItemModel(area: 0.75, name: "3/4屏"),
      DanmakuAreaItemModel(area: 1.0, name: "满屏"),
      DanmakuAreaItemModel(area: 1.0, name: "无限", filter: false),
    ],
    areaIndex: 3,
  ).obs;

  // 弹幕字体大小，显示百分比， 区间[20, 200]
  final Rx<DanmakuFontSizeModel> danmakuFontSize = DanmakuFontSizeModel(
    size: 16.0,
    min: 20,
    max: 200,
    ratio: 80,
  ).obs;

  // 弹幕播放速度（最终速度仍需要与视频速度计算而得）
  final Rx<DanmakuSpeedModel> danmakuSpeed = DanmakuSpeedModel(
    min: 3.0,
    max: 12.0,
    speed: 6,
  ).obs;

  // 弹幕过滤类型
  final danmakuFilterTypeList = [
    DanmakuFilterTypeModel(
      enName: "repeat",
      chName: "重复",
      modeList: [],
      openImageIcon: IconCommons.danmakuRepeatOpen,
      closeImageIcon: IconCommons.danmakuRepeatClose,
    ),
    DanmakuFilterTypeModel(
      enName: "fixedTop",
      chName: "顶部",
      modeList: [5],
      openImageIcon: IconCommons.danmakuTopOpen,
      closeImageIcon: IconCommons.danmakuTopClose,
    ),
    DanmakuFilterTypeModel(
      enName: "fixedBottom",
      chName: "底部",
      modeList: [4],
      openImageIcon: IconCommons.danmakuBottomOpen,
      closeImageIcon: IconCommons.danmakuBottomClose,
    ),
    DanmakuFilterTypeModel(
      enName: "scroll",
      chName: "滚动",
      modeList: [1, 2, 3, 6],
      openImageIcon: IconCommons.danmakuScrollOpen,
      closeImageIcon: IconCommons.danmakuScrollClose,
    ),
    DanmakuFilterTypeModel(
      enName: "color",
      chName: "彩色",
      modeList: [],
      openImageIcon: IconCommons.danmakuColorOpen,
      closeImageIcon: IconCommons.danmakuColorClose,
    ),
  ];



}
