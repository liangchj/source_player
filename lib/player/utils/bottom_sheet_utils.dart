
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomSheetUtils {
  static void openBottomSheet(Widget widget, {bool closeBtnShow = true, Color backgroundColor = Colors.white}) {
    Get.closeAllBottomSheets();
    Widget bottomsheet = closeBtnShow ? widget
        : Stack(
      children: [
        Padding(padding: const EdgeInsets.only(bottom: 50.0), child: widget),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            color: backgroundColor,
            child: Column(
              children: [
                Container(height: 6, color: Colors.grey.withValues(alpha: 0.1)),
                TextButton(
                  onPressed: () {
                    //关闭对话框
                    bool open = Get.isBottomSheetOpen ?? false;
                    if (open) {
                      Get.closeAllBottomSheets();
                    }
                  },
                  child: Text("取消",),
                ),
              ],
            ),
          ),
        ),
      ],
    );
    Get.bottomSheet(
      bottomsheet,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(10),
          topEnd: Radius.circular(10),
        ),
      ),
    );
  }
}