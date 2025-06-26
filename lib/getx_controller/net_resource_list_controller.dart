import 'package:flutter_dynamic_api/flutter_dynamic_api.dart';
import 'package:get/get.dart';
import 'package:source_player/models/video_type_model.dart';

import '../cache/db/current_configs.dart';
import '../models/filter_criteria_item_model.dart';
import '../models/filter_criteria_list_model.dart';

class NetResourceListController extends GetxController {
  final VideoTypeModel videoType;
  NetResourceListController(this.videoType);

  var filterCriteriaLoading = true.obs;
  var filterCriteriaLoadedSuc = false.obs;
  var filterCriteriaErrorMsg = "".obs;

  /// 过滤条件列表
  var filterCriteriaList = <FilterCriteriaListModel>[].obs;

  @override
  void onInit() {
    loadFilterCriteriaList();
    filterCriteriaLoading(false);
    filterCriteriaLoadedSuc(true);
    super.onInit();
  }

  loadResourceList({VideoTypeModel? parentType}) {}


  void loadFilterCriteriaList() {

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
      if (filterCriteria.filterCriteriaParamsList != null && filterCriteria.filterCriteriaParamsList!.isNotEmpty) {
        filterCriteriaList.add(FilterCriteriaListModel(
          enName: filterCriteria.enName,
          name: filterCriteria.name,
          filterCriteriaItemList: [
            FilterCriteriaItemModel(
              value: "",
              label: "全部",
              activated: true,
            ),
            ...filterCriteria.filterCriteriaParamsList!.map((e) => FilterCriteriaItemModel(
              value: e.value,
              label: e.label,
              activated: false,
            ))
          ],
          multiples: filterCriteria.multiples ?? false,
          requestKey: filterCriteria.requestKey,
        ));
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
          )
        ];
        filterCriteriaItemList.addAll(childTypeList.map((e) => FilterCriteriaItemModel(
          value: e.id,
          label: e.name,
          activated: false,
        )).toList());
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
}
