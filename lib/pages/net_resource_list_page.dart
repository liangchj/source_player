import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:source_player/commons/widget_style_commons.dart';
import 'package:source_player/models/video_model.dart';
import 'package:source_player/models/video_type_model.dart';
import 'package:source_player/widgets/video_card_widget.dart';

import '../cache/current_configs.dart';
import '../getx_controller/net_resource_list_controller.dart';
import '../widgets/custom_first_page_error.dart';
import '../widgets/error_hit_widget.dart';
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
      "api_${CurrentConfigs.currentApi?.apiBaseModel.enName ?? DateTime.now()}_parentTypeId_${widget.videoType.id}";
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
      body:
          // 资源下条件类型
          Obx(
            () => controller.filterCriteriaLoadingState.value.loading
                ? const Center(
                    child: LoadingWidget(textWidget: Text("分类加载中...")),
                  )
                : controller.filterCriteriaLoadingState.value.loadedSuc
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FilterCriteriaWidget(
                        getxTag: getxTag,
                        verticalPadding: 8.0,
                        controller: controller,
                      ),
                      Expanded(child: _buildResourceList()),
                    ],
                  )
                : ErrorHitWidget(
                    errorMsg:
                        controller.filterCriteriaLoadingState.value.errorMsg ??
                        "分类加载失败",
                    refreshButtonTitle: "重新加载分类",
                    onRefresh: () async {
                      await controller.loadFilterCriteriaList();
                      if (controller
                          .filterCriteriaLoadingState
                          .value
                          .loadedSuc) {
                        controller.pagingController.refresh();
                      }
                    },
                  ),
          ),
    );
  }

  Widget _buildResourceList() {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(
        horizontal: WidgetStyleCommons.safeSpace,
      ),
      child: RefreshIndicator(
        onRefresh: () async => controller.onRefresh(),
        child: PagingListener(
          controller: controller.pagingController,
          builder: (context, state, fetchNextPage) => CustomScrollView(
            slivers: [
              PagedSliverGrid<int, VideoModel>(
                key: ValueKey('paged_sliver_grid_${controller.videoType.id}'),
                state: state,
                fetchNextPage: fetchNextPage,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  childAspectRatio: 3 / 4,
                  crossAxisSpacing: WidgetStyleCommons.safeSpace,
                  mainAxisSpacing: WidgetStyleCommons.safeSpace,
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
                  newPageErrorIndicatorBuilder: (context) => CustomNewPageError(
                    pagingController: controller.pagingController,
                  ),
                  noItemsFoundIndicatorBuilder: (context) => SizedBox(
                    width: double.infinity,
                    child: Center(child: Text("---没有数据---")),
                  ),
                ),
              ),
              // 没有更多数据提示
              if (!state.hasNextPage && !state.isLoading && state.pages != null && state.pages!.isNotEmpty && state.pages![0].isNotEmpty)
                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 48,
                    child: Center(child: Text("---没有更多了---")),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
