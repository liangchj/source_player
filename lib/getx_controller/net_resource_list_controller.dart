import 'package:flutter_dynamic_api/flutter_dynamic_api.dart';
import 'package:get/get.dart';
import 'package:source_player/models/video_type_model.dart';

import '../cache/db/current_configs.dart';
import '../models/filter_criteria_item_model.dart';
import '../models/filter_criteria_list_model.dart';
import '../utils/net_request_utils.dart';

class NetResourceListController extends GetxController {
  final VideoTypeModel videoType;
  NetResourceListController(this.videoType);

  var filterCriteriaLoading = true.obs;
  var filterCriteriaLoadedSuc = false.obs;
  var filterCriteriaErrorMsg = "".obs;

  /// 过滤条件列表
  var filterCriteriaList = <FilterCriteriaListModel>[].obs;

  var toastList = <String>[].obs;

  @override
  void onInit() {
    loadFilterCriteriaList();
    filterCriteriaLoading(false);
    filterCriteriaLoadedSuc(true);
    super.onInit();
  }

  loadResourceList({VideoTypeModel? parentType}) {}

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
      var typeFilterCriteria = typeListApi.filterCriteriaList?.firstWhere(
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
          enName: videoType.enName ?? videoType.name,
          name: videoType.name,
          filterCriteriaItemList: filterCriteriaItemList,
          multiples: typeFilterCriteria.multiples ?? false,
          requestKey: typeFilterCriteria.requestKey,
        );
        filterCriteriaList.add(filterCriteriaModel);
      }
    }
  }

  Future<List<FilterCriteriaParamsModel>> getFilterCriteria(
    NetApiModel netApi,
  ) async {
    var loadPageResource = await NetRequestUtils.loadPageResource(
      netApi,
      FilterCriteriaParamsModel.fromJson,
    );
    return [];
  }
}
