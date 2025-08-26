import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../cache/db/cache_const.dart';
import '../cache/shared_preferences_cache.dart';

class ThemeController extends GetxController {
  // 1. 响应式状态：主题色种子（用户选择的颜色）、主题模式
  final Rx<Color> selectedColorSeed = Colors.green.obs; // 默认绿色
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs; // 默认深色模式

  // 2. 生成Light主题（根据当前selectedColorSeed）
  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: selectedColorSeed.value, // 用响应式颜色种子
    // 可补充其他主题配置（如TextButtonTheme），确保基于colorScheme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: selectedColorSeed.value, // 跟随主题色
      ),
    ),
  );

  // 3. 生成Dark主题（同理，基于selectedColorSeed）
  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black, // 深色模式背景
    colorScheme: ColorScheme.fromSeed(
      seedColor: selectedColorSeed.value,
      brightness: Brightness.dark,
      surface: Colors.black,
      onSurface: Colors.white,
    ),
    // 按钮主题跟随深色模式+主题色
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: selectedColorSeed.value),
    ),
  );

  // 4. 初始化：从SharedPreferences读取保存的主题配置
  @override
  void onInit() async {
    super.onInit();

    // 读取保存的主题色种子（默认绿色）
    final savedColorValue = await SharedPreferencesCache.asyncPrefs.getInt(
      CacheConst.colorSeedKey,
    );
    if (savedColorValue != null) {
      selectedColorSeed.value = Color(savedColorValue);
    }
    // 读取保存的主题模式（默认深色）
    final savedThemeMode = await SharedPreferencesCache.asyncPrefs.getInt(
      CacheConst.themeModeKey,
    );
    if (savedThemeMode != null) {
      themeMode.value = ThemeMode.values[savedThemeMode];
    }
  }

  // 5. 更新主题色（供用户选择颜色时调用）
  Future<void> updateThemeColor(Color newColor) async {
    selectedColorSeed.value = newColor;
    // 保存到SharedPreferences
    await SharedPreferencesCache.asyncPrefs.setInt(
      CacheConst.colorSeedKey,
      newColor.toARGB32(),
    );
  }

  // 7. 切换主题模式（亮/暗/系统，可选）
  Future<void> toggleThemeMode(ThemeMode newMode) async {
    themeMode.value = newMode;
    await SharedPreferencesCache.asyncPrefs.setInt(
      CacheConst.themeModeKey,
      newMode.index,
    );
  }
}
