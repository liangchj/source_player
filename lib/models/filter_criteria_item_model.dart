import 'package:flutter_dynamic_api/flutter_dynamic_api.dart';

class FilterCriteriaItemModel extends FilterCriteriaParamsModel {
  bool activated;

  FilterCriteriaItemModel({
    this.activated = false,
    required super.value,
    required super.label,
    super.parentValue,
  });
}
