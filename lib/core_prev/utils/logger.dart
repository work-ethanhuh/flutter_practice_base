// lib/core/utils/logger.dart
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// 로그 레벨
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// 앱 전역 Logger
///
/// - debug: 개발용 상세 로그
/// - info: 주요 흐름
/// - warning: 잠재적 문제
/// - error: 예외 / 장애
class AppLogger {
  AppLogger._();

  /// 로그 출력 여부
  /// 기본: debug 모드에서만 출력
  static bool enableLog = kDebugMode;

  /// 최소 출력 레벨
  static LogLevel minimumLevel = LogLevel.debug;

  // --------------------
  // Public APIs
  // --------------------

  static void d(
    String message, {
    String? tag,
    Object? data,
  }) {
    _log(
      level: LogLevel.debug,
      message: message,
      tag: tag,
      data: data,
    );
  }

  static void i(
    String message, {
    String? tag,
    Object? data,
  }) {
    _log(
      level: LogLevel.info,
      message: message,
      tag: tag,
      data: data,
    );
  }

  static void w(
    String message, {
    String? tag,
    Object? data,
  }) {
    _log(
      level: LogLevel.warning,
      message: message,
      tag: tag,
      data: data,
    );
  }

  static void e(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? tag,
    Object? data,
  }) {
    _log(
      level: LogLevel.error,
      message: message,
      tag: tag,
      data: data,
      error: error,
      stackTrace: stackTrace,
    );
  }

  // --------------------
  // Internal
  // --------------------

  static void _log({
    required LogLevel level,
    required String message,
    String? tag,
    Object? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!enableLog) return;
    if (level.index < minimumLevel.index) return;

    final time = DateTime.now().toIso8601String();
    final levelLabel = _label(level);

    final buffer = StringBuffer()
      ..write('[$time]')
      ..write('[$levelLabel]');

    if (tag != null) {
      buffer.write('[$tag]');
    }

    buffer.write(' $message');

    if (data != null) {
      buffer.write('\n  data: $data');
    }

    if (error != null) {
      buffer.write('\n  error: $error');
    }

    developer.log(
      buffer.toString(),
      name: 'APP',
      level: _developerLevel(level),
      error: error,
      stackTrace: stackTrace,
    );
  }

  static String _label(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARN';
      case LogLevel.error:
        return 'ERROR';
    }
  }

  static int _developerLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
    }
  }
}