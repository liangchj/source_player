
import 'dart:ui';

import 'package:get/get.dart';

import 'package:source_player/utils/logger_utils.dart';

import '../../models/directory_model.dart';
import '../../models/loading_state_model.dart';

import 'package:photo_manager/photo_manager.dart';

class LocalMediaDirectoryListController extends GetxController {
  var loadingState = LoadingStateModel().obs;
  var localVideoDirectoryList = <DirectoryModel>[].obs;


  PermissionState? permissionState;

  @override
  void onInit() {
    getLocalMediaList();
    super.onInit();
  }


  void getLocalMediaList() async {
    loadingState(loadingState.value.copyWith(
      loading: true,
      errorMsg: null,
      loadedSuc: false,
      isRefresh: false,
      data: null,
    ));

    permissionState = await PhotoManager.requestPermissionExtend(
      requestOption: PermissionRequestOption(
        androidPermission: AndroidPermission(
          type: RequestType.video,
          mediaLocation: false,
        ),
      )
    );
    print(permissionState);

    if (permissionState == PermissionState.denied) {
      loadingState(loadingState.value.copyWith(
        loading: false,
        errorMsg: "权限被拒绝",
        loadedSuc: false,
        isRefresh: false,
        data: null,
      ));
      return;
    }
    if (permissionState == PermissionState.limited) {
      loadingState(loadingState.value.copyWith(
        loading: false,
        errorMsg: "有限授权",
        loadedSuc: true,
        isRefresh: false,
        data: null,
      ));
    }
    if (permissionState == PermissionState.restricted) {
      loadingState(loadingState.value.copyWith(
        loading: false,
        errorMsg: "受限制的授权",
        loadedSuc: true,
        isRefresh: false,
        data: null,
      ));
    }
    if (permissionState == PermissionState.notDetermined) {
      loadingState(loadingState.value.copyWith(
        loading: false,
        errorMsg: "权限授权未确定",
        loadedSuc: true,
        isRefresh: false,
        data: null,
      ));
    }


    // 获取本地媒体列表
    List<AssetPathEntity> assetPathList = await PhotoManager.getAssetPathList(
      // hasAll:  true,
      // onlyAll: false, // 只获取所有媒体
      type: RequestType.video,
    );
    List<DirectoryModel> list = [];
    print(assetPathList);
    for (AssetPathEntity assetPath in assetPathList) {
      // print(assetPath.name);
      if (assetPath.isAll) {
        continue;
      }
      int assetCountAsync = await assetPath.assetCountAsync;
      list.add(DirectoryModel(path: assetPath.name, name: assetPath.name, fileNumber: assetCountAsync, assetPathEntity: assetPath));
    }
    // 4. 排序：按文件夹名称或修改时间排序
    list.sort((a, b) => a.name.compareTo(b.name));
    localVideoDirectoryList(list);

    loadingState(loadingState.value.copyWith(
      loading: false,
      errorMsg: null,
      loadedSuc: true,
      isRefresh: false,
      data: [],
    ));
  }



  /// 在退出程序时，发出询问的回调（IOS、Android 都不支持）
  /// 响应 [AppExitResponse.exit] 将继续终止，响应 [AppExitResponse.cancel] 将取消终止。
  Future<AppExitResponse> onExitRequested() async {
    LoggerUtils.logger.d('---onExitRequested');
    return AppExitResponse.exit;
  }

  /// 可见，并且可以响应用户操作时的回调
  /// 比如应用从后台调度到前台时，在 onShow() 后面 执行
  /// 注意：这个回调，初始化时 不执行
  onResume() {
    LoggerUtils.logger.d('---onResume');
    /*if (permissionStateEnum == PermissionStateEnum.waitingSetting) {
      getLocalMediaList();
    }*/
  }

  /// 可见，但无法响应用户操作时的回调
  onInactive() {
    LoggerUtils.logger.d('---onInactive');
  }

  /// 隐藏时的回调
  onHide() {
    LoggerUtils.logger.d('---onHide');
  }

  /// 显示时的回调，应用从后台调度到前台时
  onShow() {
    LoggerUtils.logger.d('---onShow');
  }

  /// 暂停时的回调
  onPause() {
    LoggerUtils.logger.d('---onPause');
  }

  /// 暂停后恢复时的回调
  onRestart() {
    LoggerUtils.logger.d('---onRestart');
  }

  /// 这两个回调，不是所有平台都支持，

  /// 当退出 并将所有视图与引擎分离时的回调（IOS 支持，Android 不支持）
  onDetach() {
    LoggerUtils.logger.d('---onDetach');
  }

}