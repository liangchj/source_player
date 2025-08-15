import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:source_player/commons/widget_style_commons.dart';

import 'cache/shared_preferences_cache.dart';
import 'http/dio_utils.dart';
import 'models/app_theme_model.dart';
import 'pages/app_home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化SharedPreferences
  SharedPreferencesCache();
  // 初始化dio
  DioUtils();
  await Future.wait(
    [
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
      ),
      SystemChrome.setPreferredOrientations(
        [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ],
      ),
    ],
  );
  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false, // 不显示debug标记
      // getPages: AppPages.pages,
      home: const SourceVideoPlayerApp(),
    ),
  );
}

class SourceVideoPlayerApp extends StatelessWidget {
  const SourceVideoPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '源视频',
      scrollBehavior: const TouchBehaviour(),
      theme: ThemeData(
        // 使用ColorScheme定义主要颜色体系
        colorScheme: ColorScheme.fromSeed(
          seedColor: WidgetStyleCommons.primaryColor,
          secondary: WidgetStyleCommons.primaryColor.withValues(alpha: 0.5),
        ).copyWith(
          primary: WidgetStyleCommons.primaryColor,
          secondary: WidgetStyleCommons.primaryColor.withValues(alpha: 0.5),
          surface: Colors.white, // 背景色
          onSurface: Colors.black, // 背景色上的文字颜色
        ),

        // 水波纹颜色
        splashColor: WidgetStyleCommons.primaryColor.withValues(alpha: 0.5),

        // 高亮颜色（点击时的背景色）
        highlightColor: WidgetStyleCommons.primaryColor.withValues(alpha: 0.3),

        // 悬停颜色
        hoverColor: WidgetStyleCommons.primaryColor.withValues(alpha: 0.1),

        // 焦点颜色
        focusColor: WidgetStyleCommons.primaryColor.withValues(alpha: 0.2),

        // 按钮主题
        buttonTheme: ButtonThemeData(
          buttonColor: WidgetStyleCommons.primaryColor,
          textTheme: ButtonTextTheme.primary,
        ),

        // 文本按钮主题
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all<Color>(WidgetStyleCommons.primaryColor),
            overlayColor: WidgetStateProperty.all<Color>(WidgetStyleCommons.primaryColor.withValues(alpha: 0.1)),
          ),
        ),

        // 填充按钮主题
        filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(WidgetStyleCommons.primaryColor),
          ),
        ),

        // 浮动按钮主题
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: WidgetStyleCommons.primaryColor,
          foregroundColor: Colors.white,
        ),

        // 卡片主题
        cardTheme: CardThemeData(
          color: Colors.white,
          shadowColor: WidgetStyleCommons.primaryColor.withValues(alpha: 0.2),
        ),

        // 导航栏主题
        appBarTheme: AppBarTheme(
          backgroundColor: WidgetStyleCommons.primaryColor,
          foregroundColor: Colors.white,
        ),

        // 使用InkRipple水波纹效果
        splashFactory: InkRipple.splashFactory,

        // 其他组件的主题设置
        iconTheme: IconThemeData(
          color: WidgetStyleCommons.primaryColor,
        ),
      ),
      /*theme: AppThemeModel.lightTheme(),
      darkTheme: AppThemeModel.darkTheme(),
      themeMode: ThemeMode.system,*/
      debugShowCheckedModeBanner: false, // 不显示debug标记
      home: const AppHomePage(),
    );
  }
}

class TouchBehaviour extends ScrollBehavior {
  const TouchBehaviour();

  @override
  Set<PointerDeviceKind> get dragDevices => PointerDeviceKind.values.toSet();
}
