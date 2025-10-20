import 'package:hive/hive.dart';
part 'episodeInfo.g.dart';
@HiveType(typeId: 2)
class EpisodeInfo {
  @HiveField(0)
  final int episode;

  @HiveField(1, defaultValue: '')
  final String title;

  @HiveField(2)
  String resourcePath;

  @HiveField(3)
  final String? coverPath;

  @HiveField(4)
  final int totalDuration;
  @HiveField(5)
  int positionInMilli;

  Duration get position => Duration(milliseconds: positionInMilli);

  set position(Duration d) => positionInMilli = d.inMilliseconds;

  int get progress => (positionInMilli * 100.0 / totalDuration).toInt();

  EpisodeInfo(
      this.episode,
      this.title,
      this.resourcePath,
      this.coverPath,
      this.totalDuration,
      this.positionInMilli,
      );

  @override
  String toString() {
    return 'Episode ${episode.toString()}, position $position, progress $progress%';
  }
}