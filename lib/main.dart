import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'cache/shared_preferences_cache.dart';
import 'http/dio_utils.dart';
import 'pages/app_home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化SharedPreferences
  SharedPreferencesCache();
  // 初始化dio
  DioUtils();

  runApp(
    GetMaterialApp(
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AppHomePage(),
    );
  }
}
