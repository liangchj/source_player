import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dynamic_api/flutter_dynamic_api.dart';

import '../cache/db/current_configs.dart';
import '../commons/public_commons.dart';
import '../http/dio_utils.dart';

class NetRequestUtils {
  // 获取列表数据
  static Future<PageModel<T>> loadPageResource<T>(
    NetApiModel api,
    T Function(Map<String, dynamic>) fromJson, {
    Map<String, dynamic>? headers,
    Map<String, dynamic>? params,
  }) async {
    String baseUrl = api.useBaseUrl
        ? CurrentConfigs.currentApi!.apiBaseModel.baseUrl
        : "";
    String url = baseUrl + api.path;
    Map<String, dynamic> queryParams = {...params ?? {}};

    Map<String, dynamic>? staticParams = api.requestParams.staticParams;
    if (staticParams != null && staticParams.isNotEmpty) {
      queryParams.addAll({...staticParams});
    }
    Options options = Options(
      // 响应流上前后两次接受到数据的间隔，单位为毫秒。
      receiveTimeout: PublicCommons.netLoadTimeOutDuration,
    );
    try {
      var res = await DioUtils().get(
        url,
        params: params,
        options: options,
        extra: {"customError": ""},
        shouldRethrow: true,
      );
      var data = res.data;
      Map<String, dynamic> dataMap = {};
      if (data is Map<String, dynamic>) {
        dataMap = data;
      } else if (data is String) {
        try {
          dataMap = jsonDecode(data);
        } catch (e) {
          throw Exception("结果转换成json报错：\n${e.toString()}");
        }
      }

      PageModel<T> result;

      if (api.responseParams.resultConvertJsFn == null ||
          api.responseParams.resultConvertJsFn!.isEmpty) {
        result = DefaultResponseParser(
          fromJson,
        ).listDataParseFromJson(dataMap, api);
      } else {
        result = DefaultResponseParser(
          fromJson,
        ).listDataParseFromJsonAndJsFn(dataMap, api);
      }
      return result;
    } on DioException catch (e) {
      throw Exception("api连接异常，请检查！\n${e.message}");
    } catch (e) {
      if (e.toString().startsWith("结果转换成json报错：")) {
        throw Exception(e);
      }
      throw Exception("api连接异常，请检查！$e");
    }
  }
  /// 获取单个
  static Future<DefaultResponseModel<T>> loadResource<T>(
      NetApiModel api,
      T Function(Map<String, dynamic>) fromJson, {
        Map<String, dynamic>? headers,
        Map<String, dynamic>? params,
      }) async {
    String baseUrl = api.useBaseUrl
        ? CurrentConfigs.currentApi!.apiBaseModel.baseUrl
        : "";
    String url = baseUrl + api.path;
    Map<String, dynamic> queryParams = {...params ?? {}};

    Map<String, dynamic>? staticParams = api.requestParams.staticParams;
    if (staticParams != null && staticParams.isNotEmpty) {
      queryParams.addAll({...staticParams});
    }
    Options options = Options(
      // 响应流上前后两次接受到数据的间隔，单位为毫秒。
      receiveTimeout: PublicCommons.netLoadTimeOutDuration,
    );
    try {
      var res = await DioUtils().get(
        url,
        params: params,
        options: options,
        extra: {"customError": ""},
        shouldRethrow: true,
      );
      var data = res.data;
      Map<String, dynamic> dataMap = {};
      if (data is Map<String, dynamic>) {
        dataMap = data;
      } else if (data is String) {
        try {
          dataMap = jsonDecode(data);
        } catch (e) {
          throw Exception("结果转换成json报错：\n${e.toString()}");
        }
      }

      DefaultResponseModel<T> result;

      if (api.responseParams.resultConvertJsFn == null ||
          api.responseParams.resultConvertJsFn!.isEmpty) {
        result = DefaultResponseParser(
          fromJson,
        ).detailParseFromJson(dataMap, api);
      } else {
        result = DefaultResponseParser(
          fromJson,
        ).detailParseFromDynamic(dataMap, api);
      }
      return result;
    } on DioException catch (e) {
      throw Exception("api连接异常，请检查！\n${e.message}");
    } catch (e) {
      if (e.toString().startsWith("结果转换成json报错：")) {
        throw Exception(e);
      }
      throw Exception("api连接异常，请检查！$e");
    }
  }
}
