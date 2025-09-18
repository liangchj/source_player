import 'dart:io';

import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:source_player/hive/hive_models/collect/collect_resource.dart';
import 'package:source_player/hive/hive_models/danmaku/danmaku_paths.dart';
import 'package:source_player/hive/hive_models/subtitle/subtitle_path.dart';

import 'hive_models/history/play_history.dart';
import 'hive_models/resource/video_resource.dart';

class GStorage {
  static late Box<CollectResource> collectResources;
  static late Box<PlayHistory> histories;
  static late Box<DanmakuPaths> danmakuPaths;
  static late Box<SubtitlePath> subtitlePaths;
  static late final Box<dynamic> setting;

  static Future init() async {
    final Directory dir = await getApplicationSupportDirectory();
    final String path = dir.path;
    await Hive.initFlutter('$path/hive');
    Hive.registerAdapter(VideoResourceAdapter());
    Hive.registerAdapter(CollectResourceAdapter());
    Hive.registerAdapter(PlayHistoryAdapter());
    Hive.registerAdapter(DanmakuPathsAdapter());
    Hive.registerAdapter(SubtitlePathAdapter());
    collectResources = await Hive.openBox('collectibles');
    histories = await Hive.openBox('histories');
    danmakuPaths = await Hive.openBox('danmakuPaths');
    subtitlePaths = await Hive.openBox('subtitlePaths');
    setting = await Hive.openBox('setting');
  }

  static void close() {
    collectResources
      ..compact()
      ..close();
    histories
      ..compact()
      ..close();
    danmakuPaths
      ..compact()
      ..close();
    subtitlePaths
      ..compact()
      ..close();
    setting
      ..compact()
      ..close();
  }
}

class SettingBoxKey {
  static const String cachePrev = "source_player",
      colorSeedKey = "theme_color_seed",
      themeModeKey = "theme_mode",
          /// api缓存key，app中手动添加部分
      customAddApiKey =
          "custom_add_api",
          /// 当前配置选择的api
          currentApiKey =
          "activated_api",
      playDirectoryList = "play_directory_list";
}
