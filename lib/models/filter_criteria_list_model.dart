import 'package:flutter_dynamic_api/flutter_dynamic_api.dart';

import 'filter_criteria_item_model.dart';

class FilterCriteriaListModel extends FilterCriteriaModel {
  final List<FilterCriteriaItemModel> filterCriteriaItemList;

  FilterCriteriaListModel({
    required super.enName,
    required super.name,
    required super.requestKey,
    required this.filterCriteriaItemList,
    super.multiples,
  });
}
