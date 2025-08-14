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
    this.showBorder = true,
    this.unActivatedTextColor,
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
  final bool showBorder;
  final Color? unActivatedTextColor;

  @override
  Widget build(BuildContext context) {
    ShapeBorder? shape;
    late Color textFontColor;
    if (activated) {
      if (showBorder) {
      shape = RoundedRectangleBorder(
        //边框颜色
          side: BorderSide(
            color: WidgetStyleCommons.primaryColor,
            width: WidgetStyleCommons.chapterBorderWidth,
          ),
          //边框圆角
          borderRadius: BorderRadius.all(
            Radius.circular(WidgetStyleCommons.chapterBorderRadius),
          ));
      }

      textFontColor = WidgetStyleCommons.primaryColor;
    } else {
      if (showBorder) {
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
      }
      textFontColor = unActivatedTextColor ?? WidgetStyleCommons.chapterTextColor;
    }
    return MaterialButton(
      color: activated ? textFontColor.withValues(alpha: 0.2) : null,
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
