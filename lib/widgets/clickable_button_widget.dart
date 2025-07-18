import 'package:flutter/material.dart';

import '../commons/widget_style_commons.dart';

class ClickableButtonWidget extends StatelessWidget {
  const ClickableButtonWidget({
    super.key,
    required this.text,
    required this.activated,
    required this.isCard,
    this.onClick,
    this.left,
    this.right,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.padding,
  });
  final String text;
  final bool activated;
  final bool isCard;
  final VoidCallback? onClick;
  final Widget? left;
  final Widget? right;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    late ShapeBorder shape;
    late Color textFontColor;
    if (activated) {
      shape = RoundedRectangleBorder(
        //边框颜色
          side: BorderSide(
            color: WidgetStyleCommons.mainColor,
            width: WidgetStyleCommons.chapterBorderWidth,
          ),
          //边框圆角
          borderRadius: BorderRadius.all(
            Radius.circular(WidgetStyleCommons.chapterBorderRadius),
          ));
      textFontColor = WidgetStyleCommons.chapterTextActivatedColor;
    } else {
      shape = RoundedRectangleBorder(
        //边框颜色
          side: BorderSide(
            color: WidgetStyleCommons.chapterBackgroundColor,
            width: WidgetStyleCommons.chapterBorderWidth,
          ),
          //边框圆角
          borderRadius: BorderRadius.all(
            Radius.circular(WidgetStyleCommons.chapterBorderRadius),
          ));
      textFontColor = WidgetStyleCommons.chapterTextColor;
    }
    return MaterialButton(
      //边框样式
      shape: shape,
      onPressed: () => onClick?.call(),
      child: Padding(
        padding: padding ?? EdgeInsetsGeometry.all(0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (left != null) left!,
            Expanded(
              child: Text(
                text,
                maxLines: maxLines,
                overflow: overflow,
                textAlign: textAlign,
                style: TextStyle(color: textFontColor),
              ),
            ),
            if (right != null) right!,
          ],
        ),
      ),
    );
  }
}
