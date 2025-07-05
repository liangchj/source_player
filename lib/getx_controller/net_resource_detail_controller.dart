import 'package:flutter_dynamic_api/flutter_dynamic_api.dart';
import 'package:flutter_dynamic_api/models/dynamic_params_model.dart';
import 'package:get/get.dart';
import 'package:source_player/models/video_model.dart';

import '../cache/db/current_configs.dart';
import '../models/loading_state_model.dart';
import '../utils/net_request_utils.dart';

class NetResourceDetailController extends GetxController {
  final String resourceId;
  NetResourceDetailController(this.resourceId);

  var loadingState = LoadingStateModel().obs;
  var videoModel = Rx<VideoModel?>(null);
  NetApiModel? detailApi;
  @override
  void onInit() {
    loadingState(
      loadingState.value.copyWith(
        loading: true,
        loadedSuc: false,
        errorMsg: null,
      ),
    );
    detailApi = CurrentConfigs.currentApi!.netApiMap["detailApi"];
    if (detailApi == null) {
      loadingState(loadingState.value.copyWith(
        loading: false,
        loadedSuc: false,
        errorMsg: "未配置详情接口",
      ));
    }
    else if (resourceId.isEmpty) {
      loadingState(loadingState.value.copyWith(
        loading: false,
        loadedSuc: false,
        errorMsg: "传入的资源id为空!",
      ));
    }
    else {
      loadResourceDetail();
    }
    super.onInit();
  }

  // 加载资源详情
  Future<void> loadResourceDetail() async {
    loadingState(
      loadingState.value.copyWith(
        loading: true,
        loadedSuc: false,
        errorMsg: null,
      ),
    );
    Map<String, dynamic> params = {};
    var dynamicParams = detailApi!.requestParams.dynamicParams;
    if (dynamicParams == null || !dynamicParams.keys.contains("id")) {
      params["id"] = resourceId;
    } else {
      DynamicParamsModel idParams = dynamicParams["id"]!;
      params[idParams.requestKey] = resourceId;
    }
    try {
      DefaultResponseModel<VideoModel> res = await NetRequestUtils.loadResource<VideoModel>(
        detailApi!,
        VideoModel.fromJson,
        params: params,
      );
      if (res.model != null && res.model!.id == resourceId) {
        videoModel(res.model);
      }
      print("资源信息: ${videoModel.value?.toJson()}");
    } catch (e) {
      loadingState(loadingState.value.copyWith(loading: false, loadedSuc: false, errorMsg: "加载资源报错：${e.toString()}" ,));
    }
    loadingState(loadingState.value.copyWith(loading: false, loadedSuc: true, errorMsg: null,));
  }
}
