import 'package:flutter/material.dart';

class TextButtonWidget extends StatelessWidget {
  const TextButtonWidget({
    super.key,
    required this.text,
    this.activated = false,
    this.fontSize,
    this.padding,
    this.borderWidth = 1.0,
    required this.fn,
    this.fontColor = Colors.black,
    this.fontColorActivated = Colors.redAccent,
    this.borderColor = Colors.grey,
    this.borderColorActivated = Colors.redAccent,
    this.playBorderWidthActivated,
    this.borderRadius = 6.0,
    this.maxLines,
    this.overflow,
    this.left,
    this.right,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  final String text;
  final bool activated;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final double borderWidth;
  final Function fn;
  // 文字颜色
  final Color fontColor;
  final Color fontColorActivated;
  // 边框样式
  // 边框颜色
  final Color borderColor;
  final Color borderColorActivated;
  // 边框宽度
  final double? playBorderWidthActivated;
  // 边框圆角
  final double borderRadius;
  final int? maxLines;
  final TextOverflow? overflow;

  final Widget? left;
  final Widget? right;

  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    late ShapeBorder shape;
    late Color textFontColor;
    if (activated) {
      shape = RoundedRectangleBorder(
          //边框颜色
          side: BorderSide(
            color: borderColorActivated,
            width: playBorderWidthActivated ?? borderWidth * 1.5,
          ),
          //边框圆角
          borderRadius: BorderRadius.all(
            Radius.circular(borderRadius),
          ));
      textFontColor = fontColorActivated;
    } else {
      shape = RoundedRectangleBorder(
          //边框颜色
          side: BorderSide(
            color: borderColor,
            width: borderWidth,
          ),
          //边框圆角
          borderRadius: BorderRadius.all(
            Radius.circular(borderRadius),
          ));
      textFontColor = fontColor;
    }

    return MaterialButton(
      padding: padding ?? const EdgeInsets.all(0),
      //边框样式
      shape: shape,
      onPressed: () => fn.call(),
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        children: [
          left ?? Container(),
          Text(
            text,
            maxLines: maxLines,
            overflow: overflow,
            style: TextStyle(fontSize: fontSize, color: textFontColor),
          ),
          right ?? Container(),
        ],
      ),
    );
  }
}
