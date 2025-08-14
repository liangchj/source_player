import 'package:flutter/material.dart';

import '../commons/widget_style_commons.dart';

class AppThemeModel {
  // 创建亮色主题
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true, // 启用 Material 3
      colorScheme: _colorScheme,
      textTheme: _textTheme,
      scaffoldBackgroundColor: WidgetStyleCommons.scaffoldBackground,
      appBarTheme: _appBarTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      textButtonTheme: _textButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      cardTheme: _cardTheme,
      dialogTheme: _dialogTheme,
      chipTheme: _chipTheme,
      tabBarTheme: _tabBarTheme,
      floatingActionButtonTheme: _floatingActionButtonTheme,
      bottomNavigationBarTheme: _bottomNavigationBarTheme,
      checkboxTheme: _checkboxTheme,
      radioTheme: _radioTheme,
      switchTheme: _switchTheme,
      sliderTheme: _sliderTheme,
      tooltipTheme: _tooltipTheme,
      dividerTheme: _dividerTheme,
      progressIndicatorTheme: _progressIndicatorTheme,
      listTileTheme: _listTileTheme,
      snackBarTheme: _snackBarTheme,
      bottomSheetTheme: _bottomSheetTheme,
      popupMenuTheme: _popupMenuTheme,
    );
  }

  // 创建暗色主题
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true, // 启用 Material 3
      colorScheme: _colorScheme.copyWith(
        brightness: Brightness.dark,
        surface: Colors.grey[900]!,
        onSurface: Colors.white,
      ),
      textTheme: _textTheme.apply(
        displayColor: Colors.white,
        bodyColor: Colors.white70,
      ),
      scaffoldBackgroundColor: Colors.grey[900]!,
      appBarTheme: _appBarTheme.copyWith(
        backgroundColor: Colors.grey[900]!,
        foregroundColor: Colors.white,
      ),
      // 其他组件主题可以类似地调整
    );
  }

  // 颜色方案 (Material 3 规范)
  static const ColorScheme _colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: WidgetStyleCommons.primaryColor,
    onPrimary: WidgetStyleCommons.textOnPrimary,
    primaryContainer: WidgetStyleCommons.primaryContainer,
    onPrimaryContainer: WidgetStyleCommons.textOnPrimary,
    secondary: WidgetStyleCommons.secondaryColor,
    onSecondary: Colors.black,
    secondaryContainer: WidgetStyleCommons.secondaryContainer,
    onSecondaryContainer: Colors.black,
    tertiary: WidgetStyleCommons.primaryColor,
    onTertiary: Colors.white,
    error: WidgetStyleCommons.errorColor,
    onError: Colors.white,
    surface: Colors.white,
    onSurface: WidgetStyleCommons.textPrimary,
    surfaceContainerHighest: Color(0xFFE7E0EC),
    onSurfaceVariant: Color(0xFF49454F),
    outline: Color(0xFF79747E),
  );

  // 文本主题 (Material 3 规范)
  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      color: WidgetStyleCommons.textPrimary,
    ),
    displayMedium: TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      color: WidgetStyleCommons.textPrimary,
    ),
    displaySmall: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: WidgetStyleCommons.textPrimary,
    ),
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w400,
      color: WidgetStyleCommons.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w400,
      color: WidgetStyleCommons.textPrimary,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      color: WidgetStyleCommons.textPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      color: WidgetStyleCommons.textPrimary,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: WidgetStyleCommons.textPrimary,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: WidgetStyleCommons.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      color: WidgetStyleCommons.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: WidgetStyleCommons.textPrimary,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      color: WidgetStyleCommons.textSecondary,
    ),
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: WidgetStyleCommons.textOnPrimary,
    ),
    labelMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: WidgetStyleCommons.textOnPrimary,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: WidgetStyleCommons.textOnPrimary,
    ),
  );

  // 应用栏主题
  static const AppBarTheme _appBarTheme = AppBarTheme(
    backgroundColor: WidgetStyleCommons.primaryColor,
    foregroundColor: WidgetStyleCommons.textOnPrimary,
    elevation: 4,
    centerTitle: true,
    scrolledUnderElevation: 4,
    iconTheme: IconThemeData(color: WidgetStyleCommons.textOnPrimary),
    actionsIconTheme: IconThemeData(color: WidgetStyleCommons.textOnPrimary),
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: WidgetStyleCommons.textOnPrimary,
    ),
  );

  // 悬浮按钮主题
  static final FloatingActionButtonThemeData _floatingActionButtonTheme =
      FloatingActionButtonThemeData(
        backgroundColor: WidgetStyleCommons.primaryColor,
        foregroundColor: WidgetStyleCommons.textOnPrimary,
        splashColor: WidgetStyleCommons.splashColor,
        hoverColor: WidgetStyleCommons.hoverColor,
      );

  // 底部导航栏主题
  static const BottomNavigationBarThemeData _bottomNavigationBarTheme =
      BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: WidgetStyleCommons.primaryColor,
        unselectedItemColor: WidgetStyleCommons.textSecondary,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 12),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      );

  // 输入框装饰主题 (最新API)
  static final InputDecorationTheme
  _inputDecorationTheme = InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),

    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF79747E)),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: WidgetStyleCommons.primaryColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: WidgetStyleCommons.errorColor),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: WidgetStyleCommons.errorColor, width: 2),
    ),
    contentPadding: EdgeInsets.symmetric(
      horizontal: WidgetStyleCommons.safeSpace * 4 / 3,
      vertical: WidgetStyleCommons.safeSpace,
    ),
    labelStyle: TextStyle(color: WidgetStyleCommons.textSecondary),
    hintStyle: TextStyle(color: Color(0xFFBDBDBD)),
    floatingLabelStyle: TextStyle(color: WidgetStyleCommons.primaryColor),
    errorStyle: TextStyle(color: WidgetStyleCommons.errorColor),
  );

  // 卡片主题
  static const CardThemeData _cardTheme = CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    margin: EdgeInsets.all(8),
    color: Colors.white,
    surfaceTintColor: Colors.transparent,
  );

  // 对话框主题
  static const DialogThemeData _dialogTheme = DialogThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: WidgetStyleCommons.textPrimary,
    ),
    contentTextStyle: TextStyle(
      fontSize: 16,
      color: WidgetStyleCommons.textPrimary,
    ),
  );

  // 标签栏主题
  static const TabBarThemeData _tabBarTheme = TabBarThemeData(
    labelColor: WidgetStyleCommons.primaryColor,
    unselectedLabelColor: WidgetStyleCommons.textSecondary,
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(width: 3, color: WidgetStyleCommons.primaryColor),
    ),
    indicatorSize: TabBarIndicatorSize.tab,
    labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    unselectedLabelStyle: TextStyle(fontSize: 14),
    dividerColor: Colors.transparent,
  );

  // 复选框主题
  static CheckboxThemeData get _checkboxTheme => CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) {
        return WidgetStyleCommons.primaryColor;
      }
      return Colors.grey;
    }),
    checkColor: WidgetStateProperty.all(WidgetStyleCommons.textOnPrimary),
    side: const BorderSide(color: Colors.grey),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  );

  // 单选按钮主题
  static RadioThemeData get _radioTheme => RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) {
        return WidgetStyleCommons.primaryColor;
      }
      return Colors.grey;
    }),
  );

  // 开关主题
  static SwitchThemeData get _switchTheme => SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) {
        return WidgetStyleCommons.primaryColor;
      }
      return Colors.grey;
    }),
    trackColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) {
        return WidgetStyleCommons.primaryColor.withValues(alpha: 0.5);
      }
      return Colors.grey.withValues(alpha: 0.5);
    }),
    trackOutlineColor: WidgetStateProperty.resolveWith<Color>((states) {
      return Colors.transparent;
    }),
  );

  // 滑块主题
  static SliderThemeData get _sliderTheme => SliderThemeData(
    activeTrackColor: WidgetStyleCommons.primaryColor,
    inactiveTrackColor: WidgetStyleCommons.primaryColor.withValues(alpha: 0.3),
    thumbColor: WidgetStyleCommons.primaryColor,
    overlayColor: WidgetStyleCommons.primaryColor.withValues(alpha: 0.2),
    valueIndicatorColor: WidgetStyleCommons.primaryColor,
    valueIndicatorTextStyle: const TextStyle(
      color: WidgetStyleCommons.textOnPrimary,
    ),
  );

  // 提示工具主题
  static final TooltipThemeData _tooltipTheme = TooltipThemeData(
    decoration: BoxDecoration(
      color: Color(0xFF616161),
      borderRadius: BorderRadius.all(Radius.circular(4)),
    ),
    textStyle: TextStyle(color: Colors.white, fontSize: 14),
    padding: EdgeInsets.all(WidgetStyleCommons.safeSpace * 2 / 3),
  );

  // 分割线主题
  static const DividerThemeData _dividerTheme = DividerThemeData(
    color: Color(0xFFE0E0E0),
    thickness: 1,
    space: 16,
  );

  // 进度指示器主题
  static final ProgressIndicatorThemeData
  _progressIndicatorTheme = ProgressIndicatorThemeData(
    color: WidgetStyleCommons.primaryColor,
    linearTrackColor: WidgetStyleCommons.primaryColor.withValues(alpha: 0.2),
    circularTrackColor: WidgetStyleCommons.primaryColor.withValues(alpha: 0.2),
  );

  // 悬浮按钮主题 (最新API)
  static ElevatedButtonThemeData get _elevatedButtonTheme =>
      ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
              backgroundColor: WidgetStyleCommons.primaryColor,
              foregroundColor: WidgetStyleCommons.textOnPrimary,
              padding: EdgeInsets.symmetric(
                vertical: WidgetStyleCommons.safeSpace * 4 / 3,
                horizontal: WidgetStyleCommons.safeSpace * 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              // 水波纹效果
              splashFactory: InkRipple.splashFactory,
              surfaceTintColor: Colors.transparent,
              elevation: 2,
              shadowColor: Colors.black26,
            ).copyWith(
              // 覆盖悬停和聚焦状态
              overlayColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.hovered)) {
                  return WidgetStyleCommons.hoverColor;
                }
                if (states.contains(WidgetState.focused) ||
                    states.contains(WidgetState.pressed)) {
                  return WidgetStyleCommons.splashColor;
                }
                return Colors.transparent;
              }),
            ),
      );

  // 文字按钮主题 (最新API)
  static TextButtonThemeData get _textButtonTheme => TextButtonThemeData(
    style:
        TextButton.styleFrom(
          foregroundColor: WidgetStyleCommons.primaryColor,
          padding: EdgeInsets.symmetric(
            vertical: WidgetStyleCommons.safeSpace,
            horizontal: WidgetStyleCommons.safeSpace * 4 / 3,
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          // 水波纹效果
          splashFactory: InkRipple.splashFactory,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.hovered)) {
              return WidgetStyleCommons.hoverColor;
            }
            if (states.contains(WidgetState.focused) ||
                states.contains(WidgetState.pressed)) {
              return WidgetStyleCommons.splashColor;
            }
            return Colors.transparent;
          }),
        ),
  );

  // 轮廓按钮主题 (最新API)
  static OutlinedButtonThemeData get _outlinedButtonTheme =>
      OutlinedButtonThemeData(
        style:
            OutlinedButton.styleFrom(
              foregroundColor: WidgetStyleCommons.primaryColor,
              padding: EdgeInsets.symmetric(
                vertical: WidgetStyleCommons.safeSpace,
                horizontal: WidgetStyleCommons.safeSpace * 2,
              ),
              side: BorderSide(color: WidgetStyleCommons.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              // 水波纹效果
              splashFactory: InkRipple.splashFactory,
            ).copyWith(
              overlayColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.hovered)) {
                  return WidgetStyleCommons.hoverColor;
                }
                if (states.contains(WidgetState.focused) ||
                    states.contains(WidgetState.pressed)) {
                  return WidgetStyleCommons.splashColor;
                }
                return Colors.transparent;
              }),
            ),
      );

  // 标签主题
  static ChipThemeData get _chipTheme => ChipThemeData(
    backgroundColor: Color(0xFFE0E0E0),
    deleteIconColor: WidgetStyleCommons.textSecondary,
    disabledColor: Color(0xFFEEEEEE),
    selectedColor: WidgetStyleCommons.primaryColor,
    secondarySelectedColor: WidgetStyleCommons.primaryColor,
    padding: EdgeInsets.symmetric(
      vertical: WidgetStyleCommons.safeSpace / 2,
      horizontal: WidgetStyleCommons.safeSpace,
    ),
    shape: StadiumBorder(),
    labelStyle: TextStyle(color: WidgetStyleCommons.textPrimary),
    secondaryLabelStyle: TextStyle(color: WidgetStyleCommons.textOnPrimary),
    brightness: Brightness.light,
    elevation: 0,
    pressElevation: 1,
    showCheckmark: true,
    checkmarkColor: WidgetStyleCommons.textOnPrimary,
    side: BorderSide.none,
  );
  // 列表项主题
  static final ListTileThemeData _listTileTheme = ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(
      horizontal: WidgetStyleCommons.safeSpace * 4 / 3,
      vertical: WidgetStyleCommons.safeSpace * 2 / 3,
    ),
    minLeadingWidth: 24,
    minVerticalPadding: WidgetStyleCommons.safeSpace * 2 / 3,
    tileColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    selectedColor: WidgetStyleCommons.primaryColor.withValues(alpha: 0.1),
    selectedTileColor: WidgetStyleCommons.primaryColor.withValues(alpha: 0.1),
    iconColor: WidgetStyleCommons.textSecondary,
    textColor: WidgetStyleCommons.textPrimary,
  );

  // 底部弹出层主题
  static const BottomSheetThemeData _bottomSheetTheme = BottomSheetThemeData(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    elevation: 8,
    modalElevation: 16,
    showDragHandle: true,
  );

  // 弹出菜单主题
  static const PopupMenuThemeData _popupMenuTheme = PopupMenuThemeData(
    color: Colors.white,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    elevation: 4,
    textStyle: TextStyle(fontSize: 14, color: WidgetStyleCommons.textPrimary),
  );

  // 消息条主题
  static const SnackBarThemeData _snackBarTheme = SnackBarThemeData(
    backgroundColor: Color(0xFF323232),
    contentTextStyle: TextStyle(color: Colors.white),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    behavior: SnackBarBehavior.floating,
    elevation: 6,
    showCloseIcon: true,
    closeIconColor: Colors.white,
  );
}
