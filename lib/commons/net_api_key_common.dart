/// 默认的api key
class NetApiKeyCommon {
  // 苹果maccms默认key
  static Map<String,  dynamic> maccms = {
    "listApi": {
      "requestParams": {
        // 静态参数
        "staticParams": {
          "ac": "list",
          // 因为不是所有的api都支持wd参数（搜素关键字），所以需要自定义参数
        },
        // 动态参数
        "dynamicParams": {
          "page": "pg",
          "pageSize": "limit",
          "totalPage": "pagecount",
          "totalCount": "total",
          "typeIds": "type_id",
          "parentTypeIds": "type_id_1"
        }
      },
      "responseParams": {
        "statusCodeKey": "code",
        "successStatusCode": "1",
        "resDataKey": "list",
        "resMsg": "msg",
        "resultKeyMap": {
          "id": "vod_id", // 资源id
          "enName": "vod_en", // 资源名称（英文名称或拼音）
          "name": "vod_name", // 资源名称
          "typeIdList": "type_id", // 资源类型Id列表
          "typeNameList": "type_name", // 资源类型名称列表
          "parentTypeId": "type_id_1", // 父级类型id
          "classList": "vod_class", // 分类列表
          "coverUrl": "vod_pic", // 资源预览图（缩略图）
          "blurb": "vod_blurb", // 简介/描述
          "detailContent": "vod_content", // 详细内容介绍
          "directorList": "vod_director", // 导演
          "actorList": "vod_actor", // 主演
          "serial": "vod_remarks", // 资源连载数量（集数）
          "total": "vod_total", // 资源数量（集数）
          "duration": "vod_remarks", // 资源时长
          "score": "vod_score", // 资源分数
          "area": "vod_area", // 资源地区
          "languageList": "vod_lang", // 资源语言
          "year": "vod_year", // 资源年份
          "version": "vod_version", // 资源季度
          "addTime": "vod_time_add", // 资源添加时间
          "modTime": "vod_time", // 资源更新时间
          // 分页信息
          "page": "page",
          "pageSize": "limit",
          "totalPage": "pagecount",
          "totalCount": "total",
        }
      }
    }
  };
}