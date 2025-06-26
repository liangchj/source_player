/// 默认的api key
class NetApiDefaultKeyCommon {

  // 苹果maccms默认key
  // 动态请求参数
  static Map<String,  dynamic> maccmsListDynamicRequestParams = {
    "page": "pg",
    "pageSize": "limit",
    "typeId": "type_id",
    "parentTypeId": "type_id_1"
  };
  // 响应结果基本key
  static Map<String,  dynamic> maccmsResponseBaseKeys = {
    "statusCodeKey": "code",
    "successStatusCode": "1",
    "resMsg": "msg",
  };
  // 响应结果分页key
  static Map<String,  dynamic> maccmsResponsePageKeys = {
    "page": "page",
    "pageSize": "limit",
    "totalPage": "pagecount",
    "totalCount": "total",
  };
  // 响应结果视频信息key
  static Map<String,  dynamic> maccmsResponseVideoKeys = {
    "id": "vod_id", // 资源id
    "enName": "vod_en", // 资源名称（英文名称或拼音）
    "name": "vod_name", // 资源名称
    "typeId": "type_id", // 资源类型Id列表
    "typeName": "type_name", // 资源类型名称
    "parentTypeId": "type_id_1", // 父级类型id
    "classList": "vod_class", // 分类列表
    "coverUrl": "vod_pic", // 资源预览图（缩略图）
    "blurb": "vod_blurb", // 简介/描述
    "detailContent": "vod_content", // 详细内容介绍
    "directorList": "vod_director", // 导演
    "actorList": "vod_actor", // 主演
    "remark": "vod_remarks", // 资源连载数量（集数）
    "total": "vod_total", // 资源数量（集数）
    "duration": "vod_duration", // 资源时长
    "score": "vod_score", // 资源分数
    "area": "vod_area", // 资源地区
    "languageList": "vod_lang", // 资源语言
    "year": "vod_year", // 资源年份
    "version": "vod_version", // 资源季度
    "addTime": "vod_time_add", // 资源添加时间
    "modTime": "vod_time", // 资源更新时间
  };
  static Map<String,  dynamic> maccms = {
    "typeListApi": {
      "path": "",
      "requestParams": {
        "headerParams": {},
        // 静态参数
        "staticParams": {
          "ac": "list",
          "t": "-1"
        },
        // 动态参数
        "dynamicParams": maccmsListDynamicRequestParams
      },
      "responseParams": {
        ...maccmsResponseBaseKeys,
        "resDataKey": "class",
        "resultKeyMap": {
          "id": "type_id",
          "name": "type_name",
          "parentId": "type_pid",
        }
      },
      "filterCriteriaList": [
        {
          "enName": "type",
          "name": "类型",
          "requestKey": "t",
          // 动态传入
        },
        {
          "enName": "year",
          "name": "年份",
          "requestKey": "time",
          "filterCriteriaParamsList": [
            {
              "value": '2022',
              "label": '2022',
            },
            {
              "value": '2021',
              "label": '2021',
            },
            {
              "value": '2020',
              "label": '2020',
            },
            {
              "value": '2019',
              "label": '2019',
            },
            {
              "value": '2018',
              "label": '2018',
            }
          ]
        }
      ],
      "extendMap": {
        "typeFilterCriteria":  {
          "enName": "type",
          "name": "类型",
          "requestKey": "t",
          "multiples": false
        }
      }
    },
    "listApi": {
      "path": "",
      "requestParams": {
        "headerParams": {},
        // 静态参数
        "staticParams": {
          "ac": "list",
          // 因为不是所有的api都支持wd参数（搜素关键字），所以需要自定义参数
        },
        // 动态参数
        "dynamicParams": maccmsListDynamicRequestParams
      },
      "responseParams": {
        ...maccmsResponseBaseKeys,
        "resDataKey": "list",
        "resultKeyMap": {
          ...maccmsResponseVideoKeys,
          // 分页信息
          ...maccmsResponsePageKeys
        }
      },
      /*"filterCriteriaList": [
        {
          "enName": "type",
          "name": "类型",
          "requestKey": "t",
          "netApi": {
            "path": "",
            "requestParams": {
              "headerParams": {},
              "staticParams": {"ac": "list"},
              "dynamicParams": {
                "parentTypeId": "{{VideoModel.id}}"
              }
            },
            "responseParams": {
              ...maccmsResponseBaseKeys,
              "resDataKey": "class",
              "resultConvertJsFn": "function convertJson(typeJson) { if (!typeJson) { typeJson = {}; } let typeList = typeJson[\"class\"] || []; let newList = []; for (let i in typeList) { let item = typeList[i]; newList.push({\"value\": item[\"type_id\"], \"label\": item[\"type_name\"], \"parentValue\": item[\"type_pid\"]});} typeJson[\"class\"] = newList;  return typeJson; } "
            }
          }
        }
      ]*/
    },
    "detailApi": {
      "path": "",
      "requestParams": {
        "staticParams": {"ac": "detail"},
        "dynamicParams": {"ids": "ids"}
      },
      "responseParams": {
        "resDataKey": "list",
        ...maccmsResponseBaseKeys,
      }
    },
    "searchApi": {
      "path": "",
      "requestParams": {
        "staticParams": {"ac": "detail"},
        "dynamicParams": {
          ...maccmsListDynamicRequestParams,
          "keyword": "wd"
        }
      },
      "responseParams": {
        "resDataKey": "list",
        ...maccmsResponseBaseKeys,
        ...maccmsResponsePageKeys,
      }
    }
  };

  // 列表api key
  static Map<String,  Map<String,  dynamic>> apiKeys = {
    "maccms": maccms,
  };
}