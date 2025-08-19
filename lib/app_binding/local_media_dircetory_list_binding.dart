
import 'package:get/get.dart';
import 'package:source_player/getx_controller/media_library/local_media_directory_list_controller.dart';

class LocalMediaDirectoryListBinding extends Binding {
  @override
  List<Bind> dependencies() => [Bind.lazyPut(() => LocalMediaDirectoryListController())];
}