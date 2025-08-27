import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'getx_controller/theme_controller.dart';
import 'hive/storage.dart';
import 'http/dio_utils.dart';
import 'pages/app_home_page.dart';
import 'route/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化SharedPreferences
  // SharedPreferencesCache();
  await GStorage.init();
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

  // 初始化主题控制器（全局单例，用Get.put确保随处可获取）
  Get.put(ThemeController());

  runApp(
    Obx(() {
      final themeController = Get.find<ThemeController>(); // 获取主题控制器
      return GetMaterialApp(
        debugShowCheckedModeBanner: false, // 不显示debug标记
        // 绑定控制器生成的主题（状态变化时自动更新）
        theme: themeController.lightTheme,
        darkTheme: themeController.darkTheme,
        themeMode: themeController.themeMode.value,
        getPages: AppPages.pages,
        scrollBehavior: const TouchBehaviour(),
        home: const AppHomePage(),
      );
    }),
  );
}

class SourceVideoPlayerApp extends StatelessWidget {
  const SourceVideoPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: const AppHomePage(),
    );
  }
}

class TouchBehaviour extends ScrollBehavior {
  const TouchBehaviour();

  @override
  Set<PointerDeviceKind> get dragDevices => PointerDeviceKind.values.toSet();
}
