import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:source_player/models/video_model.dart';
import 'package:source_player/models/video_type_model.dart';
import 'package:source_player/widgets/video_card_widget.dart';

import '../cache/db/current_configs.dart';
import '../getx_controller/net_resource_list_controller.dart';
import '../widgets/filter_criteria_widget.dart';
import '../widgets/loading_widget.dart';

class NetResourceListPage extends StatefulWidget {
  const NetResourceListPage({super.key, required this.videoType});
  final VideoTypeModel videoType;

  @override
  State<NetResourceListPage> createState() => _NetResourceListPageState();
}

class _NetResourceListPageState extends State<NetResourceListPage> {
  late NetResourceListController controller;
  String get getxTag =>
      "parentTypeId_${widget.videoType.id}_${CurrentConfigs.currentApi?.apiBaseModel.enName ?? DateTime.now()}";
  @override
  void initState() {
    controller = Get.put(
      NetResourceListController(widget.videoType),
      tag: getxTag,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 资源下条件类型
          Obx(
            () => controller.filterCriteriaLoadingState.value.loading
                ? const Center(
                    child: SizedBox(
                      height: 500,
                      child: LoadingWidget(textWidget: Text("配置加载中...")),
                    ),
                  )
                : controller.filterCriteriaLoadingState.value.loadedSuc
                ? FilterCriteriaWidget(
                    getxTag: getxTag,
                    verticalPadding: 8.0,
                    controller: controller,
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded),
                        Text(controller.filterCriteriaLoadingState.value.errorMsg ?? "加载失败"),
                      ],
                    ),
                  ),
          ),
          Expanded(child: _buildResourceList()),
        ],
      ),
    );
  }

  Widget _buildResourceList() {
    return Obx(() {
      if (controller.listLoadingState.value.errorMsg != null && controller.listLoadingState.value.errorMsg!.isNotEmpty) {
        return Center(
          child: Text("加载失败：${controller.listLoadingState.value.errorMsg}"),
        );
      }
      return Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 10.0),
        child: RefreshIndicator(
          // onRefresh: () async => controller.pagingController.refresh(),
          onRefresh: () async => controller.onRefresh(),
          child: PagingListener(
            controller: controller.pagingController,
            builder: (context, state, fetchNextPage) => CustomScrollView(
              slivers: [
                // 如果正在刷新，显示刷新 header
                if (state.isLoading)
                  const SliverToBoxAdapter(
                    child: SizedBox(
                      height: 60,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),

                PagedSliverGrid<int, VideoModel>(
                  state: state,
                  fetchNextPage: fetchNextPage,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    childAspectRatio: 3 / 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    maxCrossAxisExtent: 200,
                  ),
                  builderDelegate: PagedChildBuilderDelegate<VideoModel>(
                    animateTransitions: true,
                    itemBuilder: (context, item, index) =>
                        VideoCardWidget(videoModel: item),
                    /*CachedNetworkImage(
                    imageUrl: item.coverUrl!,
                    fit: BoxFit.cover,
                  ),*/
                    firstPageErrorIndicatorBuilder: (context) =>
                        CustomFirstPageError(
                          pagingController: controller.pagingController,
                        ),
                    newPageErrorIndicatorBuilder: (context) =>
                        CustomNewPageError(
                          pagingController: controller.pagingController,
                        ),
                    /*noMoreItemsIndicatorBuilder: (context) => SizedBox(
                      width: double.infinity,
                      child: Center(child: Text("---没有更多了---")),
                    ),*/
                    noItemsFoundIndicatorBuilder: (context) => SizedBox(
                      width: double.infinity,
                      child: Center(child: Text("---没有数据---")),
                    ),
                  ),
                ),
                // 没有更多数据提示
                if (!state.hasNextPage && !state.isLoading)
                  const SliverToBoxAdapter(
                    child: SizedBox(
                      height: 48,
                      child: Center(
                        child: Text("---没有更多了---"),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class CustomFirstPageError extends StatelessWidget {
  const CustomFirstPageError({super.key, required this.pagingController});

  final PagingController<Object, Object> pagingController;

  @override
  Widget build(BuildContext context) {
    return PagingListener(
      controller: pagingController,
      builder: (context, state, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '刷新失败 :(',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (state.error != null) ...[
              const SizedBox(height: 16),
              Text(state.error.toString(), textAlign: TextAlign.center),
            ],
            const SizedBox(height: 48),
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                onPressed: pagingController.refresh,
                icon: const Icon(Icons.refresh),
                label: const Text('重试', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomNewPageError extends StatelessWidget {
  const CustomNewPageError({super.key, required this.pagingController});

  final PagingController<Object, Object> pagingController;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: pagingController.fetchNextPage,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '获取下一页数据失败，是否重试?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            const Icon(Icons.refresh, size: 20),
          ],
        ),
      ),
    );
  }
}
