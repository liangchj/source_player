
// 弹幕速度
class DanmakuSpeedModel {
  final double min;
  final double max;
  double? _speed;
  double get speed => _speed ?? min;

  DanmakuSpeedModel({required this.min, required this.max, required double speed}) {
    _speed = speed.round().toDouble();
  }

  set speed(double s) {
    _speed = s.round().toDouble();
  }
}