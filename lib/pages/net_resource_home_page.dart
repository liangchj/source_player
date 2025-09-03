import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:source_player/pages/api_select_list_page.dart';
import '../getx_controller/net_resource_home_controller.dart';
import '../widgets/error_hit_widget.dart';
import '../widgets/loading_widget.dart';

class NetResourceHomePage extends StatefulWidget {
  const NetResourceHomePage({super.key});

  @override
  State<NetResourceHomePage> createState() => _NetResourceHomePageState();
}

class _NetResourceHomePageState extends State<NetResourceHomePage>
    with AutomaticKeepAliveClientMixin {
  final NetResourceHomeController controller = Get.put(
    NetResourceHomeController(),
  );

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(() {
      if (controller.activatedApiConfigLoadingState.value.loading ||
          controller.apiConfigLoadingState.value.loading) {
        return const Center(
          child: LoadingWidget(textWidget: Text("加载api配置中...")),
        );
      }
      if (!controller.activatedApiConfigLoadingState.value.loadedSuc) {
        return ErrorHitWidget(
          errorMsg:
              "加载api配置失败：${controller.activatedApiConfigLoadingState.value.errorMsg}；${controller.apiConfigLoadingState.value.errorMsg}",
          refreshButtonTitle: "重新加载api",
        );
      }
      return Scaffold(
        appBar: AppBar(
          title: InkWell(
            onTap: () {
              Get.to(() => ApiSelectListPage());
            },
            child: Obx(
              () => Text(
                controller.activatedApi.value == null
                    ? controller
                              .activatedApiConfigLoadingState
                              .value
                              .errorMsg ??
                          "（未设置）"
                    : controller.activatedApi.value?.apiBaseModel.name ?? "（空）",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.start,
              ),
            ),
          ),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          ],
          toolbarHeight: 36,
        ),
        body: controller.activatedApi.value == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("未设置api"),
                    TextButton(
                      onPressed: () {
                        Get.to(() => ApiSelectListPage());
                      },
                      child: Text("点击设置"),
                    ),
                  ],
                ),
              )
            : _buildResource(),
      );
    });
  }

  Widget _buildResource() {
    return Obx(() {
      if (controller.typeLoadingState.value.loading) {
        return const Center(
          child: LoadingWidget(textWidget: Text("加载视频类型中...")),
        );
      }
      if (!controller.typeLoadingState.value.loadedSuc) {
        return ErrorHitWidget(
          errorMsg: "加载视频类型失败：${controller.typeLoadingState.value.errorMsg}",
          refreshButtonTitle: "重新加载",
          onRefresh: () {
            controller.loadInfo();
          },
        );
      }
      if (controller.videoTypeList.isEmpty) {
        return Center(child: Text("当前api无数据"));
      }
      if (controller.tabController.value == null) {
        return ErrorHitWidget(
          errorMsg: "构建失败，请重试！",
          refreshButtonTitle: "重新构建",
          onRefresh: () {
            controller.createTabBarViews();
          },
        );
      }
      return DefaultTabController(
        length: controller.videoTypeList.length,
        child: Column(
          children: [
            SizedBox(
              height: 42,
              width: double.infinity,
              child: TabBar(
                padding: EdgeInsets.only(top: 0),
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                controller: controller.tabController.value,
                tabs: controller.videoTypeList
                    .map((e) => Tab(text: e.name))
                    .toList(),
              ),
            ),
            Expanded(child: _buildTypeResourceList()),
          ],
        ),
      );
    });
  }

  // 构建类型下的资源列表
  Widget _buildTypeResourceList() {
    return TabBarView(
      controller: controller.tabController.value,
      children: controller.typeTabBarViews,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
