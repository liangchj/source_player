import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OverlayEntryUtils {
  static OverlayEntry? bottomSheetOverlayEntry;
  static AnimationController? bottomSheetAnimationController;

  static void showBottomSheetOverlayEntry(
    BuildContext context,
    Widget child, {
    Duration duration = const Duration(milliseconds: 300),
    dynamic height,
    bool isDismissible = true,
  }) {
    if (bottomSheetOverlayEntry != null) return;

    final overlay = Overlay.of(context);
    bottomSheetAnimationController = AnimationController(
      vsync: Navigator.of(context),
      duration: duration,
    );
    final Animation<Offset> offsetAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: bottomSheetAnimationController!,
            curve: Curves.easeOut,
          ),
        );
    double dragOffset = 0;

    bottomSheetOverlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // 可选：点击遮罩关闭
          if (isDismissible)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => closeBottomSheetOverlayEntry(),
                child: Container(color: Colors.transparent),
              ),
            ),
          if (height is RxDouble)
            Obx(
              () => Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: height.value,
                child: AnimatedBuilder(
                  animation: bottomSheetAnimationController!,
                  builder: (context, _) => SlideTransition(
                    position: offsetAnimation,
                    child: GestureDetector(
                      onVerticalDragUpdate: (details) {
                        dragOffset += details.primaryDelta ?? 0;
                        // 只允许向下拖动
                        if (dragOffset > 0) {
                          bottomSheetAnimationController!.value =
                              1 - (dragOffset / height.value).clamp(0.0, 1.0);
                        }
                      },
                      onVerticalDragEnd: (details) {
                        // 拖动超过1/3高度自动关闭，否则弹回
                        if (dragOffset > height.value / 3) {
                          closeBottomSheetOverlayEntry();
                        } else {
                          bottomSheetAnimationController!.forward();
                        }
                        dragOffset = 0;
                      },
                      child: child,
                    ),
                  ),
                ),
              ),
            )
          else
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: height,
              child: AnimatedBuilder(
                animation: bottomSheetAnimationController!,
                builder: (context, _) => SlideTransition(
                  position: offsetAnimation,
                  child: GestureDetector(
                    onVerticalDragUpdate: (details) {
                      dragOffset += details.primaryDelta ?? 0;
                      // 只允许向下拖动
                      if (dragOffset > 0) {
                        bottomSheetAnimationController!.value =
                            1 - (dragOffset / height).clamp(0.0, 1.0);
                      }
                    },
                    onVerticalDragEnd: (details) {
                      // 拖动超过1/3高度自动关闭，否则弹回
                      if (dragOffset > height / 3) {
                        closeBottomSheetOverlayEntry();
                      } else {
                        bottomSheetAnimationController!.forward();
                      }
                      dragOffset = 0;
                    },
                    child: child,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
    overlay.insert(bottomSheetOverlayEntry!);
    bottomSheetAnimationController!.forward();
  }

  static Future<void> closeBottomSheetOverlayEntry({
    bool closeByAnimation = true,
  }) async {
    if (closeByAnimation) {
      await bottomSheetAnimationController?.reverse();
      bottomSheetOverlayEntry?.remove();
      bottomSheetOverlayEntry = null;
      bottomSheetAnimationController?.dispose();
    } else {
      bottomSheetOverlayEntry?.remove();
      bottomSheetOverlayEntry = null;
    }
  }

  void showCustomBottomSheet(BuildContext context, Widget child) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        height: MediaQuery.of(context).size.height * 0.5, // 半屏
        child: Material(elevation: 8, color: Colors.white, child: child),
      ),
    );
    overlay.insert(entry);
    // 关闭方式：entry.remove();
  }
}
