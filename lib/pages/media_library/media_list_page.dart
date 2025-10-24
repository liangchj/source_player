import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:source_player/getx_controller/media_library/media_list_controller.dart';

import '../../models/media_file_model.dart';
import '../../widgets/custom_first_page_error.dart';
import '../../widgets/media_item_widget.dart';

class MediaListPage extends GetView<MediaListController> {
  const MediaListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.folder?.path ?? "未传入目录"),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)),
          IconButton(onPressed: () => controller.pagingController.refresh(), icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: controller.folder == null
          ? Center(
              child: Text(controller.loadingState.value.errorMsg ?? "传入的路径为空"),
            )
          : Column(
              children: [
                _defaultHeaderWidget(controller.folder?.name ?? ""),
                Expanded(child: _buildRefreshIndicator()),
              ],
            ),
    );
  }

  RefreshIndicator _buildRefreshIndicator() {
    return RefreshIndicator(
      onRefresh: () async => controller.onRefresh(),
      child: PagingListener(
        controller: controller.pagingController,
        builder: (context, state, fetchNextPage) =>
            _customScrollView(state, fetchNextPage),
      ),
    );
  }

  CustomScrollView _customScrollView(
    PagingState<int, Rx<MediaFileModel>> state,
    NextPageCallback fetchNextPage,
  ) {
    return CustomScrollView(
      slivers: [
        // 如果正在刷新，显示刷新 header
        /*if (state.isLoading && controller.isRefresh)
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 60,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),*/

        PagedSliverList<int, Rx<MediaFileModel>>.separated(
          state: state,
          fetchNextPage: fetchNextPage,
          itemExtent: 48,
          builderDelegate: PagedChildBuilderDelegate(
            animateTransitions: true,
            itemBuilder: (context, item, index) => MediaItemWidget(
              fileModel: item,
              onTap: () => controller.playVideo(item.value),
            ),
            // _mediaListTile(item),
            firstPageErrorIndicatorBuilder: (context) => CustomFirstPageError(
              pagingController: controller.pagingController,
            ),
            newPageErrorIndicatorBuilder: (context) => CustomNewPageError(
              pagingController: controller.pagingController,
            ),
          ),
          separatorBuilder: (context, index) => const Divider(),
        ),
        // 没有更多数据提示
        if (!state.hasNextPage && !state.isLoading)
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: Center(child: Text("---没有更多了---")),
            ),
          ),
      ],
    );
  }

  Widget _defaultHeaderWidget(String dirName) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: Get.width,
        // 标题名称与列表的padding
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.2), //边框颜色
            width: 1, //边框宽度
          ), // 边色与边宽度
          color: Colors.white, // 底色
          boxShadow: [
            BoxShadow(
              blurRadius: 10, //阴影范围
              spreadRadius: 0.1, //阴影浓度
              color: Colors.grey.withValues(alpha: 0.2), //阴影颜色
            ),
          ],
        ),
        child: Text(
          "$dirName(${controller.folder?.fileNumber ?? 0}个视频)",
          textAlign: TextAlign.left,
        ),
      ),
    );
  }
}
