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
      _videoController.player.open(
        Media(_playerController.playerState.playUrl),
        // Media("https://user-images.githubusercontent.com/28951144/229373695-22f88f13-d18f-4288-9bf1-c3e078d83722.mp4"),
        play: _playerController.playerState.autoPlay,
      );
      _playerController.playerState.playerView(
          Video(
            controller: _videoController,
            controls: (state) {
              return Scaffold(
                backgroundColor: Colors.transparent,
                body: PlayerUI(),
              );
            },
          )
      );
      updateState();
    } catch(e) {
      print(e);
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
  Future<void> seekTo(Duration position) {
    // TODO: implement seekTo
    throw UnimplementedError();
  }

  @override
  Future<void> setPlaySpeed(double speed) {
    // TODO: implement setPlaySpeed
    throw UnimplementedError();
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

    stream.duration.listen((value) {
      if (value.compareTo(Duration.zero) != 0) {
        // _playerController.playerState.initialized(true);
      }
      // _playerController.playerState.duration(value);
    });

    stream.playing.listen((value) {
      _playerController.playerState.isPlaying(value);
      if (value) {
        // _playerController.playerState.errorMsg("");
      }
    });

    stream.completed.listen((value) {
      _playerController.playerState.isFinished(value);
    });
  }
}
