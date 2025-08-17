
import 'package:flutter/material.dart';
import 'package:source_player/models/resource_chapter_model.dart';

import '../../../commons/widget_style_commons.dart';

class ChapterWidget extends StatelessWidget {
  const ChapterWidget({super.key, required this.chapter, required this.activated, this.isCard = false, this.onClick, this.left, this.right, this.unActivatedTextColor,});
  final ResourceChapterModel chapter;
  final bool activated;
  final bool isCard;
  final VoidCallback? onClick;
  final Widget? left;
  final Widget? right;
  final Color? unActivatedTextColor;


  @override
  Widget build(BuildContext context) {
    late ShapeBorder shape;
    late Color textFontColor;
    if (activated) {
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
      textFontColor = unActivatedTextColor ?? WidgetStyleCommons.chapterTextColor;
    }
    return MaterialButton(
      //边框样式
      shape: shape,
      onPressed: () => onClick?.call(),
      child: Padding(
        padding: WidgetStyleCommons.chapterPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (left != null) left!,
            Expanded(
              child: Text(
                chapter.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
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
