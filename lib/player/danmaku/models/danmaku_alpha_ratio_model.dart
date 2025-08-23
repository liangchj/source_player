class DanmakuAlphaRatioModel {
  final double min;
  final double max;
  double? _ratio;

  DanmakuAlphaRatioModel({
    required this.min,
    required this.max,
    required double ratio,
  }) {
    _ratio = ratio.round().toDouble();
  }
  double get ratio => _ratio ?? min;
  set ratio(double d) {
    _ratio = d.round().toDouble();
  }
}
