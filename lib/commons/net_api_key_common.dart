/// 默认的api key
class NetApiDefaultKeyCommon {

  // 苹果maccms默认key
  // 动态请求参数
  static Map<String,  Map<String,  dynamic>> maccmsListDynamicRequestParams = {
    "page": {"requestKey": "pg"},
    "pageSize": {"requestKey": "limit"},
    "typeId": {"requestKey": "t", "dataSource": "filterCriteria", "filterCriteria": {
      "enName": "typeId", "name": "全部"
    }},
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
        // "dynamicParams": {}
      },
      "responseParams": {
        ...maccmsResponseBaseKeys,
        "resDataKey": "class",
        "resultConvertDyFn": {
          "dynamicFunctionEnum": "js",
          "fn": 'function convertJson(map){let statusCode=map["code"]+"";if(statusCode!=="1"){return{"statusCode":statusCode,"data":[],"msg":"请求失败"}}let topTypeId=map["topTypeId"]||"";let typeList=[];let classMap={};let list=map["class"]||[];for(let item of list){let parentId=item["type_pid"]+"";let typeId=item["type_id"]+"";let name=item["type_name"]+"";if(parentId===topTypeId){typeList.push({id:typeId,name:name,parentId:parentId});continue}let childList=classMap[parentId]||[];childList.push({value:typeId,label:name,parentValue:parentId});classMap[parentId]=childList}for(let item of typeList){let classList=classMap[item["id"]]||[];item["childType"]={"enName":"typeId","name":"类型","filterCriteriaItemList":classList}}return{"statusCode":statusCode,"data":typeList}}'
        }
        /*"resultKeyMap": {
          "id": "type_id",
          "name": "type_name",
          "parentId": "type_pid",
        }*/
      },
      "extendMap": {
        "topTypeId": "0"
      }
    },
    "listApi": {
      "path": "",
      "requestParams": {
        "headerParams": {},
        // 静态参数
        "staticParams": {
          "ac": "detail",
          // 因为不是所有的api都支持wd参数（搜素关键字），所以需要自定义参数
        },
        // 动态参数
        "dynamicParams": {
          ...maccmsListDynamicRequestParams,
          "year": {
            "requestKey": "y",
            "dataSource": "filterCriteria",
            "filterCriteria": {
              "enName": "year",
              "name": "年份",
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
          }
        }
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
    },
    "detailApi": {
      "path": "",
      "requestParams": {
        "staticParams": {"ac": "detail"},
        "dynamicParams": {"id": {"requestKey": "ids"}}
      },
      "responseParams": {
        "resDataKey": "list",
        ...maccmsResponseBaseKeys,
        "resultKeyMap": {
          ...maccmsResponseVideoKeys,
        }
      }
    },
    "searchApi": {
      "path": "",
      "requestParams": {
        "staticParams": {"ac": "detail"},
        "dynamicParams": {
          ...maccmsListDynamicRequestParams,
          "keyword": {
            "requestKey": "wd"
          }
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