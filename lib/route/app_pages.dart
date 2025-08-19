

import 'package:get/get.dart';
import 'package:source_player/main.dart';

import '../app_binding/local_media_dircetory_list_binding.dart';
import '../app_binding/media_list_binding.dart';
import '../pages/mdeia_library/local_media_directory_list_page.dart';
import '../pages/mdeia_library/media_list_page.dart';
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
  ];
}