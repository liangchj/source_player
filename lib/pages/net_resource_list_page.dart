import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:source_player/models/video_type_model.dart';

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
            () => controller.filterCriteriaLoading.value
                ? const Center(
                    child: SizedBox(
                      height: 500,
                      child: LoadingWidget(textWidget: Text("配置加载中...")),
                    ),
                  )
                : controller.filterCriteriaLoadedSuc.value
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
                        Text(controller.filterCriteriaErrorMsg.value),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
