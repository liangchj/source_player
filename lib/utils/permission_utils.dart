import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:source_player/utils/logger_utils.dart';

class PermissionUtils {
  /// 检测是否有权限
  /// [permissionList] 权限申请列表
  /// [onPermissionCallback] 权限申请是否成功
  static Future<void> checkPermission({
    required List<Permission> permissionList,
    required ValueChanged onPermissionCallback,
  }) async {
    ///一个新待申请权限列表
    List<Permission> newPermissionList = [];
    Map<Permission, PermissionStatus> permissionStatusMap = {};

    ///遍历当前权限申请列表
    for (Permission permission in permissionList) {
      PermissionStatus status = await permission.status;
      LoggerUtils.logger.d("status: $status，$permission");

      ///如果不是允许状态就添加到新的申请列表中
      if (!status.isGranted) {
        newPermissionList.add(permission);
        permissionStatusMap[permission] = status;
      }
    }

    ///如果需要重新申请的列表不是空的
    if (permissionStatusMap.isNotEmpty) {
      PermissionStatus permissionStatus = await requestPermission(
        newPermissionList,
      );
      LoggerUtils.logger.d("permissionStatus: $permissionStatus");
      switch (permissionStatus) {
        /// 没授权默认是这个，也保不准特殊情况是表示拒绝的，最好是先请求权限后用于判断
        case PermissionStatus.denied:
          onPermissionCallback(PermissionStateEnum.denied);
          break;

        /// 允许状态
        case PermissionStatus.granted:
          onPermissionCallback(PermissionStateEnum.allow);
          break;

        /// 被操作系统拒绝，例如家长控制等
        case PermissionStatus.restricted:

        /// 被限制了部分功能，适用于部分权限，例如相册的
        case PermissionStatus.limited:

        /// 这个权限表示永久拒绝，不显示弹窗，用户可以手动调节（也有可能是系统关闭了该权限导致的）
        case PermissionStatus.permanentlyDenied:
          openAppSettings();
          onPermissionCallback(PermissionStateEnum.waitingSetting);
          break;
        case PermissionStatus.provisional:
          // TODO: Handle this case.
          throw UnimplementedError();
      }
    } else {
      onPermissionCallback(PermissionStateEnum.allow);
    }
  }

  /// 获取新列表中的权限 如果有一项不合格就返回false
  static Future<PermissionStatus> requestPermission(
    List<Permission> permissionList,
  ) async {
    Map<Permission, PermissionStatus> statuses = await permissionList.request();
    bool isShown = await Permission.contacts.shouldShowRequestRationale;
    PermissionStatus currentPermissionStatus = PermissionStatus.granted;
    statuses.forEach((key, value) {
      if (!value.isGranted) {
        currentPermissionStatus = value;
        return;
      }
    });
    return currentPermissionStatus;
  }
}

enum PermissionStateEnum {
  allow,
  waitingSetting,
  denied,
}
