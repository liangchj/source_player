
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomSheetDialogUtils {
  static void openBottomSheet(Widget widget, {bool closeBtnShow = true, Color backgroundColor = Colors.white, bool closeOtherBottomSheet = true}) {
    if (closeOtherBottomSheet) {
      closeBottomSheet();
    }
    Widget bottomsheet = closeBtnShow ?
        Stack(
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
                    closeBottomSheet();
                  },
                  child: Text("取消",),
                ),
              ],
            ),
          ),
        ),
      ],
    ) : widget;
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


  static void closeBottomSheet() {
    bool open = Get.isBottomSheetOpen ?? false;
    if (open) {
      Get.closeAllBottomSheets();
    }
  }

  static void closeDialog({String? id}) {
    bool open = Get.isDialogOpen ?? false;
    if (open) {
      if (id == null) {
        Get.closeAllDialogs();
      } else {
        Get.closeDialog(id: id);
      }
    }
  }

  static void closeBottomSheetAndDialog({String? id}) {
    bool openBottomSheet = Get.isBottomSheetOpen ?? false;
    bool openDialog = Get.isDialogOpen ?? false;
    if (openBottomSheet || openDialog) {
      Get.closeAllDialogsAndBottomSheets(id);
    }
  }
}