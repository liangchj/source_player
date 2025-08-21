import 'package:source_player/models/resource_chapter_model.dart';

class ChapterGroupModel {
  final String id;
  final String name;
  final List<ResourceChapterModel> chapterList;

  ChapterGroupModel({
    required this.id,
    required this.name,
    required this.chapterList,
  }); // 具体章节
}
