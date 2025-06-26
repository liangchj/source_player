import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:source_player/models/video_type_model.dart';

import '../getx_controller/net_resource_list_controller.dart';
import '../models/filter_criteria_list_model.dart';

class FilterCriteriaWidget extends StatelessWidget {
  const FilterCriteriaWidget({
    super.key,
    required this.getxTag,
    this.activeTextColor,
    this.activeBackgroundColor,
    this.horizontalPadding,
    this.verticalPadding,
    this.textHorizontalPadding,
    this.textVerticalPadding,
    this.textBorderRadius,
    required this.controller,
  });
  final String getxTag;
  final Color? activeTextColor;
  final Color? activeBackgroundColor;
  final double? horizontalPadding;
  final double? verticalPadding;
  final double? textHorizontalPadding;
  final double? textVerticalPadding;
  final BorderRadiusGeometry? textBorderRadius;
  final NetResourceListController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          children: controller.filterCriteriaList.map((item) {
            String updateId = "getx_id_${item.enName}";
            return GetBuilder<NetResourceListController>(
                id: updateId,
                tag: getxTag,
                builder: (_) => _createCriteriaListWidget(
                    controller: controller,
                    filterCriteriaModel: item,
                    updateId: updateId));
          }).toList(),
        ));
  }

  Widget _createCriteriaListWidget(
      {required NetResourceListController controller,
      required FilterCriteriaListModel filterCriteriaModel,
      required String updateId}) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: verticalPadding ?? 0, horizontal: horizontalPadding ?? 6.0),
      child: Row(
        children: [
          // Text("${filterCriteriaModel.name}："),
          Expanded(
              child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: filterCriteriaModel.filterCriteriaItemList.map((e) {
                return InkWell(
                  onTap: () {
                    if (!e.activated) {
                      e.activated = true;
                      // 不支持多选就需要将其他选中取消
                      if (filterCriteriaModel.multiples == null || !filterCriteriaModel.multiples!) {
                        for (var element
                            in filterCriteriaModel.filterCriteriaItemList) {
                          if (element.value != e.value) {
                            element.activated = false;
                          }
                        }
                      }
                      controller.update([updateId]);
                      controller.loadResourceList(
                          parentType: VideoTypeModel(
                        id: e.value,
                        name: e.label,
                      ));
                    }
                  },
                  child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: textVerticalPadding ?? 4.0,
                          horizontal: textHorizontalPadding ?? 8.0),
                      decoration: BoxDecoration(
                          color: e.activated
                              ? activeBackgroundColor ?? Colors.black12
                              : null,
                          borderRadius: textBorderRadius ??
                              const BorderRadius.all(Radius.circular(4.0))),
                      child: Text(
                        e.label,
                        style: TextStyle(
                            color: e.activated
                                ? activeTextColor ?? Colors.green
                                : null),
                      )),
                );
              }).toList(),
            ),
          ))
        ],
      ),
    );
  }
}
