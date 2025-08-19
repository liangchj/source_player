
import 'package:get/get.dart';

import '../getx_controller/media_library/media_list_controller.dart';

class MediaListBinding extends Binding {
  @override
  List<Bind> dependencies() => [Bind.lazyPut(() => MediaListController())];
}