import 'package:get/get.dart';
import 'package:source_player/getx_controller/search_danmaku_subtitle_controller.dart';

class SearchDanmakuSubtitleBinding extends Binding {
  @override
  List<Bind> dependencies() => [
    Bind.lazyPut(() => SearchDanmakuSubtitleController()),
  ];
}
