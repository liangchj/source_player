import 'package:flutter_dynamic_api/flutter_dynamic_api.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:source_player/models/loading_state_model.dart';
import 'package:source_player/models/video_model.dart';
import 'package:source_player/models/video_type_model.dart';

import '../cache/db/current_configs.dart';
import '../models/filter_criteria_item_model.dart';
import '../models/filter_criteria_list_model.dart';
import '../utils/net_request_utils.dart';

class NetResourceListController extends GetxController {
  final VideoTypeModel videoType;
  NetResourceListController(this.videoType);

  var isRefreshing = false.obs;

  var filterCriteriaLoadingState = LoadingStateModel().obs;

  /// 过滤条件列表
  var filterCriteriaList = <FilterCriteriaListModel>[].obs;

  var toastList = <String>[].obs;

  late PagingController<int, VideoModel> pagingController;
  // 资源列表
  var resourceListErrorMsg = "".obs;

  @override
  void onInit() {
    loadFilterCriteriaList();
    filterCriteriaLoadingState(LoadingStateModel(
      loading: false,
      loadedSuc: true,
      errorMsg: filterCriteriaLoadingState.value.errorMsg,
    ));

    pagingController = PagingController<int, VideoModel>(
      getNextPageKey: (PagingState<int, VideoModel> state) {
        if (!state.hasNextPage || state.lastPageIsEmpty) return null;
        return state.nextIntPageKey;
      },
      fetchPage: (int pageKey) async {
        // await Future.delayed(Duration(milliseconds: 3000));
        return await loadTypeResource(pageKey);
      },
    );
    super.onInit();
  }

  changeFilterCriteria() {
    pagingController.refresh();
  }

  /// 加载过滤列表
  Future<void> loadFilterCriteriaList() async {
    NetApiModel? typeListApi =
        CurrentConfigs.currentApi!.netApiMap["typeListApi"];
    if (typeListApi == null ||
        typeListApi.filterCriteriaList == null ||
        typeListApi.filterCriteriaList!.isEmpty) {
      return;
    }
    addTypeFilterCriteria(typeListApi);
    for (var filterCriteria in typeListApi.filterCriteriaList!) {
      if (filterCriteria.enName == "type") {
        continue;
      }
      List<FilterCriteriaParamsModel>? filterCriteriaParamsList;
      if (filterCriteria.netApi != null) {
        try {
          var loadPageResource = await NetRequestUtils.loadPageResource(
            filterCriteria.netApi!,
            FilterCriteriaParamsModel.fromJson,
          );
          filterCriteriaParamsList = loadPageResource.modelList;
        } catch (e) {
          toastList.add(e.toString());
          continue;
        }
      } else if (filterCriteria.filterCriteriaParamsList != null &&
          filterCriteria.filterCriteriaParamsList!.isNotEmpty) {
        filterCriteriaParamsList = filterCriteria.filterCriteriaParamsList;
      } else {
        continue;
      }

      if (filterCriteriaParamsList != null &&
          filterCriteriaParamsList.isNotEmpty) {
        filterCriteriaParamsList = filterCriteriaParamsList;
        filterCriteriaList.add(
          FilterCriteriaListModel(
            enName: filterCriteria.enName,
            name: filterCriteria.name,
            filterCriteriaItemList: [
              FilterCriteriaItemModel(value: "", label: "全部", activated: true),
              ...filterCriteriaParamsList.map(
                (e) => FilterCriteriaItemModel(
                  value: e.value,
                  label: e.label,
                  activated: false,
                ),
              ),
            ],
            multiples: filterCriteria.multiples ?? false,
            requestKey: filterCriteria.requestKey,
          ),
        );
      }
    }
  }

  /// 添加类型过滤条件
  void addTypeFilterCriteria(NetApiModel typeListApi) {
    var childTypeList = CurrentConfigs.currentApiVideoTypeMap[videoType.id];
    if (childTypeList != null && childTypeList.isNotEmpty) {
      var typeFilterCriteria = typeListApi.filterCriteriaList?.firstWhereOrNull(
        (e) => e.enName == "type",
      );
      if (typeFilterCriteria != null) {
        List<FilterCriteriaItemModel> filterCriteriaItemList = [
          FilterCriteriaItemModel(
            value: videoType.id,
            label: "全部",
            activated: true,
          ),
        ];
        filterCriteriaItemList.addAll(
          childTypeList
              .map(
                (e) => FilterCriteriaItemModel(
                  value: e.id,
                  label: e.name,
                  activated: false,
                ),
              )
              .toList(),
        );
        FilterCriteriaListModel filterCriteriaModel = FilterCriteriaListModel(
          enName: "typeId",
          name: "类型",
          filterCriteriaItemList: filterCriteriaItemList,
          multiples: typeFilterCriteria.multiples ?? false,
          requestKey: typeFilterCriteria.requestKey,
        );
        filterCriteriaList.add(filterCriteriaModel);
      }
    }
  }

  Future<void> onRefresh() async {
    isRefreshing(true);
    pagingController.value = pagingController.value.copyWith(
      isLoading: false,
      error: null,
    );
    List<VideoModel> list = await loadTypeResource(1);
    if (resourceListErrorMsg.isNotEmpty) {
      pagingController.value = pagingController.value.copyWith(
        pages: [list],
        keys: [1],
        isLoading: false,
        error: null,
      );
    } else {
      pagingController.value = pagingController.value.copyWith(
        isLoading: false,
      );
    }
    isRefreshing(false);
  }

  Future<List<VideoModel>> loadTypeResource(
    int page, {
    int limit = 20,
    String? search,
  }) async {
    List<VideoModel> list = [];
    try {
      print("加载中：${pagingController.value.keys}");
      Map<String, dynamic> params = {};
      var dynamicParams = CurrentConfigs.listApi!.requestParams.dynamicParams;
      if (dynamicParams == null) {
        params["page"] = page;
      } else {
        for (var entry in dynamicParams.entries) {
          String value = entry.value;
          dynamic paramValue;
          switch (entry.key) {
            case "page":
              paramValue = page;
              break;
            case "pageSize":
              paramValue = limit;
              break;
            case "parentTypeId":
              FilterCriteriaListModel? typeFilterCriteria = filterCriteriaList
                  .firstWhereOrNull((e) => e.enName == "typeId");
              if (typeFilterCriteria != null) {
                var childTypeId = typeFilterCriteria.filterCriteriaItemList
                    .firstWhereOrNull((e) => e.activated)
                    ?.value;
                if (childTypeId != null && childTypeId.toString().isNotEmpty) {
                  break;
                }
              }
              paramValue = videoType.id;
              break;
            default:
              FilterCriteriaListModel? filterCriteria = filterCriteriaList
                  .firstWhereOrNull((e) => e.enName == entry.key);
              if (filterCriteria != null) {
                paramValue = filterCriteria.filterCriteriaItemList
                    .firstWhereOrNull((e) => e.activated)
                    ?.value;
              }
              break;
          }
          if (paramValue != null) {
            params[value] = paramValue;
          }
        }
      }
      var res = await NetRequestUtils.loadPageResource<VideoModel>(
        CurrentConfigs.listApi!,
        VideoModel.fromJson,
        params: params,
      );
      if (isRefreshing.value) {
        pagingController.value = pagingController.value.copyWith(
          pages: null,
          keys: null,
          hasNextPage: res.page < res.totalPage,
        );
      } else {
        pagingController.value = pagingController.value.copyWith(
          hasNextPage: res.page < res.totalPage,
        );
      }
      list = res.modelList ?? [];
    } catch (e) {
      resourceListErrorMsg(e.toString());
    }
    return list;
  }
}
