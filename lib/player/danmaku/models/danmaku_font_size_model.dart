

// 弹幕文字大小
class DanmakuFontSizeModel {
  // 基础字体大小
  final double size;
  final double min;
  final double max;
  double? _ratio;
  double get ratio => _ratio ?? min;

  DanmakuFontSizeModel(
      {this.size = 16.0,
        required this.min,
        required this.max,
        required double ratio}) {
    _ratio = ratio.round().toDouble();
  }

  DanmakuFontSizeModel copyWith({
    double? size,
    double? min,
    double? max,
    double? ratio,
  }) {
    return DanmakuFontSizeModel(
      size: size ?? this.size,
      min: min ?? this.min,
      max: max ?? this.max,
      ratio: ratio ?? this.ratio,
    );
  }

  set ratio(double d) {
    _ratio = d.round().toDouble();
  }
}