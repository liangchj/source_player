import 'package:flutter/material.dart';
import 'package:flutter_dynamic_api/flutter_dynamic_api.dart';
import 'package:get/get.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import '../cache/current_configs.dart';
import '../getx_controller/net_resource_home_controller.dart';

class ApiSelectListPage extends StatefulWidget {
  const ApiSelectListPage({super.key, });

  @override
  State<ApiSelectListPage> createState() => _ApiSelectListPageState();
}

class _ApiSelectListPageState extends State<ApiSelectListPage> {
  late final NetResourceHomeController controller;
  final _activeApi = Rx<ApiConfigModel?>(null);
  late ListObserverController observerController;
  late ScrollController scrollController;
  @override
  void initState() {
    controller = Get.find<NetResourceHomeController>();
    scrollController = ScrollController();
    observerController = ListObserverController();
    _activeApi(controller.currentApi.value);
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text("设置API"),
        actions: [
          TextButton(onPressed: () {}, child: Text("新增")),
          TextButton(
              onPressed: () {
                Navigator.of(context).maybePop();
              },
              child: Text("取消")),
          TextButton(
              onPressed: () {
                /*ApiConfig.getInstance().setApiConfig(
                    key: controller.currentApiKey.value,
                    json: ApiConfig.getInstance()
                        .allApiJson[controller.currentApiKey.value]);
                Get.find<NetResourceHomeController>().loadingApiConfig();
                Get.back();*/
                // CurrentConfigs.currentApi = _activeApi.value;
                // CurrentConfigs.updateCurrentApiInfo();
                CurrentConfigs.updateCurrentApi(_activeApi.value);
                controller.currentApi(_activeApi.value);
                Get.back();
              },
              child: Text("确定")),
        ],
      ),
      body: Obx(
        () {
          String currentApiName = _activeApi.value?.apiBaseModel.enName ?? "";
          return ListView.builder(
            itemCount: CurrentConfigs.enNameToApiMap.keys.length,
            itemBuilder: (ctx, index) {
              String key = CurrentConfigs.enNameToApiMap.keys.elementAt(index);
              var apiModel = CurrentConfigs.enNameToApiMap[key];
              return InkWell(
                onTap: () {
                  _activeApi(apiModel);
                },
                child: ListTile(
                  selectedColor: Colors.red,
                  selected: key == currentApiName,
                  leading: Opacity(
                    opacity: key == currentApiName ? 1.0 : 0.0,
                    child: Icon(Icons.check_outlined),
                  ),
                  title: Text(
                    apiModel?.apiBaseModel.name ?? key,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // trailing: IconButton(
                  //   onPressed: () {},
                  //   icon: Icon(Icons.edit_rounded),
                  // ),
                ),
              );
            },
          );
        }
      ),
    );
  }
}
