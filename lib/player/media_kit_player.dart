import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:source_player/player/controller/player_controller.dart';
import 'package:source_player/player/iplayer.dart';

import 'ui/player_ui.dart';

class MediaKitPlayer extends IPlayer {
  late PlayerController _playerController;
  late final Player _player;
  late VideoController _videoController;
  MediaKitPlayer() {
    _player = Player();
    _videoController = VideoController(_player);
    _playerController = Get.find<PlayerController>();
  }

  // 播放器初始化
  @override
  Future<void> onInitPlayer() async {
    try {
      /*_videoController.player.open(
        Media(_playerController.playerState.playUrl),
        // Media("https://user-images.githubusercontent.com/28951144/229373695-22f88f13-d18f-4288-9bf1-c3e078d83722.mp4"),
        play: _playerController.playerState.autoPlay,
      );*/
      _videoController.player.setPlaylistMode(PlaylistMode.none);
      _playerController.playerState.playerView(
        Obx(
          () => Video(
            controller: _videoController,
            fit: _playerController.playerState.fit.value == null
                ? BoxFit.contain
                : BoxFit.values.firstWhereOrNull(
                        (e) =>
                            e.name ==
                            _playerController.playerState.fit.value?.name,
                      ) ??
                      BoxFit.contain,
            aspectRatio:
                _playerController.playerState.aspectRatio.value ??
                _playerController.playerState.videoAspectRatio,
            controls: (state) {
              return Scaffold(
                backgroundColor: Colors.transparent,
                body: PlayerUI(),
              );
            },
          ),
        ),
      );
      updateState();
    } catch (e) {
      _playerController.playerState.playerView(Container());
    }
  }

  @override
  Future<void> onDisposePlayer() async {
    _playerController.playerState.playerView(Container());
    return await _player.dispose();
  }

  @override
  Future<void> play() async {
    return await _player.play();
  }

  @override
  Future<void> pause() async {
    return await _player.pause();
  }

  @override
  Future<void> stop() async {
    return await _player.stop();
  }

  @override
  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
    await for (final _ in _player.stream.position.take(1)) {}
    await Future.delayed(const Duration(milliseconds: 100));
    await for (final _ in _player.stream.position.take(1)) {}
  }

  @override
  Future<void> setPlaySpeed(double speed) async {
    return await _player.setRate(speed);
  }

  @override
  bool get playing => _player.state.playing;

  @override
  bool get buffering => _player.state.buffering;

  @override
  bool get finished => _player.state.completed;

  @override
  void updateState() {
    // 监听错误信息
    PlayerStream stream = _videoController.player.stream;

    stream.videoParams.listen((value) {
      if (value.aspect != null) {
        _playerController.playerState.videoAspectRatio = value.aspect!;
      }
    });
    stream.error.listen((String? error) {
      // 视频是否加载错误
      _playerController.playerState.errorMsg(error ?? "");
    });

    stream.duration.distinct().listen((value) {
      if (value.compareTo(Duration.zero) != 0) {
        _playerController.playerState.isInitialized(true);
      }
      _playerController.playerState.duration(value);
    });

    stream.playing.listen((value) {
      _playerController.playerState.isPlaying(value);
      if (value) {
        _playerController.playerState.errorMsg(null);
      }
    });

    stream.buffering.listen((value) {
      _playerController.playerState.isBuffering(value);
    });

    stream.completed.listen((value) {
      _playerController.playerState.isFinished(value);
    });

    stream.rate.listen(
      (value) => _playerController.playerState.playSpeed(value),
    );

    // 监听进度
    stream.position.listen((Duration? position) {
      if (position != null && !_playerController.playerState.isSeeking.value) {
        var state = _videoController.player.state;
        bool isFinished = state.completed;
        // 监听是否播放完成
        _playerController.playerState.isFinished(isFinished);

        if (isFinished) {
          _playerController.playerState.positionDuration(position);
        } else {
          _playerController.playerState.positionDuration(
            Duration(seconds: position.inSeconds),
          );
        }
      }
    });
  }

  @override
  Future<void> changeVideoUrl({bool autoPlay = true}) async {
    await _videoController.player.stop();
    if (_playerController.resourceState.chapterUrl.isNotEmpty) {
    // if (_playerController.playerState.playUrl.isNotEmpty) {
      try {
        await _videoController.player.open(
          Media(_playerController.resourceState.chapterUrl),
          // Media(_playerController.playerState.playUrl),
          play: autoPlay,
        );
      } catch (e) {
        _playerController.playerState.errorMsg("播放链接异常：${e.toString()}");
      }
    } else {
      _playerController.playerState.errorMsg("播放链接为空");
    }
  }
}
