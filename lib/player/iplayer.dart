abstract class IPlayer {
  // 播放器初始化
  Future<void> onInitPlayer();

  // 销毁播放器
  Future<void> onDisposePlayer();

  // 播放
  Future<void> play();
  // 暂停
  Future<void> pause();
  Future<void> stop();

  // 进度跳转
  Future<void> seekTo(Duration position);
  // 设置播放速度
  Future<void> setPlaySpeed(double speed);

  /*// 监听状态变化
  void listenerStatus();
  // 数据源变更
  bool dataSourceChange(String path);

  Future<void> changeResource();*/

  bool get playing;
  bool get buffering;
  bool get finished;


  /// 更新状态信息
  void updateState();

  void changeVideoUrl({bool autoPlay = true});
  
}
