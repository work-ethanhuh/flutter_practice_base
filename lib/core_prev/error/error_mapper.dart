// lib/core/error/error_mapper.dart

import 'package:dio/dio.dart';

import 'app_exception.dart';

class ErrorMapper {
  /// 어떤 레이어에서든 catch한 error를 AppException으로 통일
  static AppException map(Object error, [StackTrace? stackTrace]) {
    // 이미 AppException이면 그대로 사용
    if (error is AppException) return error;

    // Dio (v5+)
    if (error is DioException) {
      return _fromDio(error);
    }

    // 파싱/포맷 문제
    if (error is FormatException) {
      return AppException.parsing(error.message, error);
    }

    // 나머지
    return AppException.unknown(error.toString(), error);
  }

  static AppException _fromDio(DioException e) {
    // 요청 취소
    if (e.type == DioExceptionType.cancel) {
      return AppException.cancelled('Request cancelled', e);
    }

    // 타임아웃들
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return AppException.timeout('Request timeout', e);
    }

    // 네트워크 연결 문제 (비행기모드/와이파이 끊김 등)
    if (e.type == DioExceptionType.connectionError) {
      return AppException.network('Connection error', e);
    }

    // 응답을 받았으나 statusCode가 에러인 케이스
    final response = e.response;
    final statusCode = response?.statusCode;
    final data = response?.data;

    if (statusCode != null) {
      final extracted = _extractServerMessageAndCode(data);

      switch (statusCode) {
        case 400:
          return AppException(
            type: AppExceptionType.badRequest,
            message: extracted.message ?? 'Bad request',
            statusCode: statusCode,
            code: extracted.code,
            details: data ?? e,
          );
        case 401:
          return AppException(
            type: AppExceptionType.unauthorized,
            message: extracted.message ?? 'Unauthorized',
            statusCode: statusCode,
            code: extracted.code,
            details: data ?? e,
          );
        case 403:
          return AppException(
            type: AppExceptionType.forbidden,
            message: extracted.message ?? 'Forbidden',
            statusCode: statusCode,
            code: extracted.code,
            details: data ?? e,
          );
        case 404:
          return AppException(
            type: AppExceptionType.notFound,
            message: extracted.message ?? 'Not found',
            statusCode: statusCode,
            code: extracted.code,
            details: data ?? e,
          );
        default:
          if (statusCode >= 500) {
            return AppException(
              type: AppExceptionType.server,
              message: extracted.message ?? 'Server error',
              statusCode: statusCode,
              code: extracted.code,
              details: data ?? e,
            );
          }
          return AppException(
            type: AppExceptionType.unknown,
            message: extracted.message ?? 'HTTP error',
            statusCode: statusCode,
            code: extracted.code,
            details: data ?? e,
          );
      }
    }

    // Dio 내부 기타 케이스 (예: badCertificate 등)
    return AppException.unknown('Network request failed', e);
  }

  /// 서버 에러 바디에서 message/code를 뽑아내는 “유연한” 추출기
  /// - 서버 스펙 확정되면 여기만 고치면 됨
  static ({String? message, String? code}) _extractServerMessageAndCode(Object? data) {
    if (data is Map) {
      // 흔한 케이스들: {message: "..."} / {msg: "..."} / {error: {message: ...}} / {code: "..."}
      String? pickString(dynamic v) => v is String && v.trim().isNotEmpty ? v : null;

      final message =
          pickString(data['message']) ??
          pickString(data['msg']) ??
          pickString(data['errorMessage']) ??
          (data['error'] is Map ? pickString((data['error'] as Map)['message']) : null);

      final code =
          pickString(data['code']) ??
          pickString(data['errorCode']) ??
          (data['error'] is Map ? pickString((data['error'] as Map)['code']) : null);

      return (message: message, code: code);
    }

    // String 바디로 오는 경우
    if (data is String && data.trim().isNotEmpty) {
      return (message: data, code: null);
    }

    return (message: null, code: null);
  }
}