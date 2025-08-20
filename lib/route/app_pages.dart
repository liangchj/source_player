

import 'package:get/get.dart';
import 'package:source_player/app_binding/search_danmaku_subtitle_binding.dart';
import 'package:source_player/main.dart';
import 'package:source_player/pages/search_danmaku_subtitle_page.dart';

import '../app_binding/local_media_directory_list_binding.dart';
import '../app_binding/media_list_binding.dart';
import '../pages/media_library/local_media_directory_list_page.dart';
import '../pages/media_library/media_list_page.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.index, page: () => const SourceVideoPlayerApp()),
    GetPage(
      name: AppRoutes.localMediaDirectoryList,
      page: () => const LocalMediaDirectoryListPage(),
      binding: LocalMediaDirectoryListBinding(),
    ),
    GetPage(
      name: AppRoutes.mediaList,
      page: () => const MediaListPage(),
      binding: MediaListBinding(),
    ),
    GetPage(
      name: AppRoutes.searchDanmakuSubtitle,
      page: () => const SearchDanmakuSubtitlePage(),
      binding: SearchDanmakuSubtitleBinding(),
    ),
  ];
}