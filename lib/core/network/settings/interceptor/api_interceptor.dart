import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../utils/logger.dart';

const String accessTokenKey = 'ACCESS_TOKEN_KEY';

/// Dio Request, Response, Error시 가로채기
/// Request시 onRequest를 가로채어, accessToken이 필요한 API Url인 경우 헤더에 accessToken을 대체해서 Request 처리 한다.
class ApiInterceptor extends Interceptor {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final bool enableLogger;
  final bool needToken;
  ApiInterceptor({this.enableLogger = false, this.needToken = true});

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // 요청 헤더
    // 헤더에 accessToken가 있는 경우 인증 토큰 필요 API
    // ApiService 클래스에 Headers 어노테이션으로 정의 되어 있음.
    if (needToken) {
      // 실제 토큰 대체
      final token = await storage.read(key: accessTokenKey);
      options.headers.addAll({'authorization': 'Bearer $token'});
    }

    addRequestLog(options);

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    addResponseLog(response);
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 인증 처리가 AccessToken / RefreshToken 사용시
    // 여기서 인증 오류(Status 401)인 경우 AccessToken 만료시 RefreshToken 으로 AccessToken 재발급 처리를 한다.
    // AccessToken 재발급 후 AccessToken과 RefreshToken을 secure storage에 다시 기록후
    // 헤더에 AccessToken을 대체하고 다시 요청한다.(fetch)

    // When using AccessToken / RefreshToken for authentication processing
    // If there is an authentication error (Status 401) here,
    // the AccessToken is reissued using RefreshToken when the AccessToken expires.

    /***********************************************/

    // if (needToken) {
    //   final isStatus401 = err.response?.statusCode == 401;
    //   final isPathRefresh = err.requestOptions.path == '/auth/token';

    //   // AccessToken 재발급
    //   if (isStatus401 && !isPathRefresh) {
    //     final dio = Dio();
    //     try {
    //       final resp = await dio.post(
    //         'AccessToken 재발급 url',
    //         options: Options(
    //           headers: {'authorization': 'Bearer $refreshToken'},
    //         ),
    //       );

    //       // 재발급 받은 AccessToken 등록
    //       final accessToken = resp.data['accessToken'];

    //       // AccessToken 만료로 요청 실패 했던 옵션
    //       final options = err.requestOptions;
    //       // 재발급 AccessToken 으로 교체
    //       options.headers.addAll({'authorization': 'Bearer $accessToken'});
    //       // secure storage에 다시 보관
    //       await storage.write(key: ACCESS_TOKEN_KEY, value: accessToken);

    //       final response = await dio.fetch(options);

    //       return handler.resolve(response);
    //     } catch (e) {
    //       return handler.reject(err);
    //     }
    //   }
    // }

    addErrorLog(err);

    super.onError(err, handler);
  }

  addRequestLog(RequestOptions options) {
    if (enableLogger == false) {
      return;
    }
    String printLog = '[REQUEST] [${options.method}] ${options.uri}\n';
    printLog += '\n[Header]';
    if (options.headers.isNotEmpty) {
      printLog += '\n${options.headers}';
    } else {
      printLog += ' : empty';
    }
    if (options.queryParameters.isNotEmpty) {
      printLog += '\n[Query]';
      printLog += '\n${printPrettyJson(options.queryParameters)}';
    } else {
      if (options.headers.isNotEmpty) {
        printLog += '\n';
      } else {
        printLog += ' / ';
      }
      printLog += '[Query] : empty';
    }
    if (options.data != null) {
      printLog += '\n[Body]';
      printLog += '\n${printPrettyJson(options.data)}';
    } else {
      if (options.queryParameters.isNotEmpty) {
        printLog += '\n';
      } else {
        printLog += ' / ';
      }
      printLog += '[Body] : empty';
    }
    AppLogger.d(printLog);
  }

  addResponseLog(Response response) {
    if (enableLogger == false) {
      return;
    }
    String printLog =
        '[RESPONSE] [${response.requestOptions.method}] ${response.requestOptions.uri}\n';
    printLog += '\n[Header]';
    printLog += '\n${response.headers}';
    printLog += '\n[Body]';
    if (response.data.isNotEmpty) {
      printLog += '\n';
      printLog += printPrettyJson(response.data);
    } else {
      printLog += ' : empty';
    }

    AppLogger.d(printLog);
  }

  addErrorLog(DioException error) {
    if (enableLogger == false) {
      return;
    }
    String printLog =
        '[ERROR] [${error.requestOptions.method}] ${error.requestOptions.uri}\n';
    // ignore: unrelated_type_equality_checks
    if (error == DioExceptionType.connectionTimeout) {
      printLog += '\n[DioTimeout]';
      printLog += '\n${error.error}';
    }
    printLog += '[ErrorDescript]';
    printLog += '\n[Path]';
    printLog += '\n${error.requestOptions.baseUrl}${error.requestOptions.path}';
    printLog += '\n[StatusCode]';
    printLog += '\n${error.response?.statusCode ?? ''}';
    printLog += '\n[Header]';
    printLog += '\n${error.response?.headers ?? ''}';
    printLog += '\n[Body]';
    printLog += '\n${error.response?.data ?? ''}';
    AppLogger.e(printLog);
  }

  dynamic innerParser(dynamic data) {
    try {
      if (data == null) {
        return 'null';
      }

      if (data is List) {
        final dynamicList = [];
        for (var item in data) {
          dynamicList.add(innerParser(item));
        }
        return dynamicList;
      }

      if (data is Map) {
        final map = <String, dynamic>{};
        for (var key in data.keys) {
          map[key] = innerParser(data[key]);
        }
        return map;
      }

      if (data is String) {
        return data;
      }

      if (data is int || data is double) {
        return data;
      }

      return data.toString();
    } catch (e) {
      AppLogger.e('Parsing Error!!!');
      AppLogger.e('$e');
      return 'Error parsing data';
    }
  }

  printPrettyJson(dynamic data) {
    var encoder = const JsonEncoder.withIndent('  ');
    final jsonString = encoder.convert(innerParser(data));
    return jsonString;
  }
}
