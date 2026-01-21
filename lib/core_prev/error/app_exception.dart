// lib/core/error/app_exception.dart

/// 앱 공통 예외 타입
enum AppExceptionType {
  network,        // 네트워크 단절/연결 문제
  timeout,        // 연결/응답 타임아웃
  cancelled,      // 요청 취소
  unauthorized,   // 401
  forbidden,      // 403
  notFound,       // 404
  server,         // 5xx
  badRequest,     // 400 (또는 서버가 "요청이 잘못됨"으로 내려준 케이스)
  parsing,        // 응답 파싱/포맷 문제
  unknown,        // 그 외
}

/// 앱 공통 예외 (Repository/Usecase/UI까지 전달 가능)
class AppException implements Exception {
  const AppException({
    required this.type,
    required this.message,
    this.statusCode,
    this.code,
    this.details,
  });

  final AppExceptionType type;

  /// 사용자/로그 모두에 쓸 “요약 메시지”
  final String message;

  /// HTTP status code (있으면)
  final int? statusCode;

  /// 서버가 내려주는 에러 코드가 있다면 (예: "AUTH_001")
  final String? code;

  /// 디버깅/로깅용 (response body, payload 등)
  final Object? details;

  /// UI에서 바로 쓰기 좋은 기본 문구
  String get displayMessage {
    switch (type) {
      case AppExceptionType.network:
        return '네트워크 연결을 확인해 주세요.';
      case AppExceptionType.timeout:
        return '요청 시간이 초과되었습니다. 잠시 후 다시 시도해 주세요.';
      case AppExceptionType.cancelled:
        return '요청이 취소되었습니다.';
      case AppExceptionType.unauthorized:
        return '로그인이 필요합니다.';
      case AppExceptionType.forbidden:
        return '접근 권한이 없습니다.';
      case AppExceptionType.notFound:
        return '요청한 정보를 찾을 수 없습니다.';
      case AppExceptionType.server:
        return '서버에 문제가 발생했습니다. 잠시 후 다시 시도해 주세요.';
      case AppExceptionType.badRequest:
        return '요청이 올바르지 않습니다.';
      case AppExceptionType.parsing:
        return '데이터 처리 중 문제가 발생했습니다.';
      case AppExceptionType.unknown:
        return '알 수 없는 오류가 발생했습니다.';
    }
  }

  @override
  String toString() {
    return 'AppException(type: $type, statusCode: $statusCode, code: $code, message: $message, details: $details)';
  }

  // 편의 생성자들
  factory AppException.network([String? message, Object? details]) =>
      AppException(type: AppExceptionType.network, message: message ?? 'Network error', details: details);

  factory AppException.timeout([String? message, Object? details]) =>
      AppException(type: AppExceptionType.timeout, message: message ?? 'Timeout', details: details);

  factory AppException.cancelled([String? message, Object? details]) =>
      AppException(type: AppExceptionType.cancelled, message: message ?? 'Cancelled', details: details);

  factory AppException.unauthorized({String? message, int? statusCode, Object? details}) => AppException(
        type: AppExceptionType.unauthorized,
        message: message ?? 'Unauthorized',
        statusCode: statusCode,
        details: details,
      );

  factory AppException.forbidden({String? message, int? statusCode, Object? details}) => AppException(
        type: AppExceptionType.forbidden,
        message: message ?? 'Forbidden',
        statusCode: statusCode,
        details: details,
      );

  factory AppException.notFound({String? message, int? statusCode, Object? details}) => AppException(
        type: AppExceptionType.notFound,
        message: message ?? 'Not found',
        statusCode: statusCode,
        details: details,
      );

  factory AppException.server({String? message, int? statusCode, Object? details}) => AppException(
        type: AppExceptionType.server,
        message: message ?? 'Server error',
        statusCode: statusCode,
        details: details,
      );

  factory AppException.badRequest({String? message, int? statusCode, Object? details}) => AppException(
        type: AppExceptionType.badRequest,
        message: message ?? 'Bad request',
        statusCode: statusCode,
        details: details,
      );

  factory AppException.parsing([String? message, Object? details]) =>
      AppException(type: AppExceptionType.parsing, message: message ?? 'Parsing error', details: details);

  factory AppException.unknown([String? message, Object? details]) =>
      AppException(type: AppExceptionType.unknown, message: message ?? 'Unknown error', details: details);
}