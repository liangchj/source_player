
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:source_player/getx_controller/media_library/local_media_directory_list_controller.dart';
import 'package:source_player/route/app_routes.dart';

import '../../widgets/directory_item_widget.dart';

class LocalMediaDirectoryListPage extends GetView<LocalMediaDirectoryListController> {
  const LocalMediaDirectoryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("本地视频列表"),
        actions: [
          IconButton(
              onPressed: () => {}, icon: const Icon(Icons.search_rounded)),
          IconButton(
              onPressed: () => {}, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: Obx(() {
        if (controller.loadingState.value.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        /*else if (controller.permissionStateEnum == PermissionStateEnum.waitingSetting) {
          return Center(
            child: Text(controller.loadingState.value.errorMsg ?? "等待前往设置页面打开权限并授权"),
          );
        }
        else if (controller.permissionStateEnum == PermissionStateEnum.denied) {
          return Center(
            child: Text(controller.loadingState.value.errorMsg ?? "权限被拒绝"),
          );
        }*/
        else {
          var videoDirectoryList = controller.localVideoDirectoryList;
          return videoDirectoryList.isEmpty
              ? const Center(
            child: Text("没有视频"),
          )
              :  ListView.builder(
                  itemExtent: 66,
                  itemCount: videoDirectoryList.length,
                  itemBuilder: (context, index) {
                    var fileDirectoryModel = videoDirectoryList[index];
                    return DirectoryItemWidget(
                      directoryModel: fileDirectoryModel,
                      onTap: () {
                        Get.toNamed(AppRoutes.mediaList, arguments: fileDirectoryModel);
                    },
                    );
                  });
        }
      }),

    );
  }
}