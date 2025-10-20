import 'package:hive/hive.dart';

import '../resource/episodeInfo.dart';
import '../resource/video_resource.dart';
part 'play_history.g.dart';
@HiveType(typeId: 1)
class PlayHistory {
  @HiveField(0)
  final VideoResource resource;

  @HiveField(1)
  final Map<int, EpisodeInfo> episodeInfo;

  @HiveField(2)
  int lastPlayEpisode;

  @HiveField(3)
  DateTime lastPlayTime;

  PlayHistory(this.resource, this.episodeInfo, this.lastPlayEpisode, this.lastPlayTime);
}

