// lib/core/auth/token_storage.dart
import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// access/refresh를 묶어서 다루고 싶을 때 사용
class TokenPair {
  const TokenPair({
    required this.accessToken,
    required this.refreshToken,
  });

  final String? accessToken;
  final String? refreshToken;

  bool get hasAccessToken => (accessToken ?? '').isNotEmpty;
  bool get hasRefreshToken => (refreshToken ?? '').isNotEmpty;

  @override
  String toString() => 'TokenPair(access: ${accessToken != null ? "***" : "null"}, refresh: ${refreshToken != null ? "***" : "null"})';
}

/// 상태관리/DI와 무관하게 사용할 수 있는 인터페이스
abstract class TokenStorage {
  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();
  Future<TokenPair> readTokenPair();

  Future<void> writeAccessToken(String token);
  Future<void> writeRefreshToken(String token);
  Future<void> writeTokenPair({
    required String accessToken,
    required String refreshToken,
  });

  Future<void> deleteAccessToken();
  Future<void> deleteRefreshToken();
  Future<void> clear();

  /// 디버깅/헬스체크용
  Future<bool> hasAccessToken();
  Future<bool> hasRefreshToken();
}

/// flutter_secure_storage 기반 구현체
///
/// - key 네임스페이스(prefix) 지원: QA/Prod 분리, 멀티 테넌트 등 대응
/// - iOS/Android 옵션은 기본값으로 두고, 필요하면 확장
class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage({
    FlutterSecureStorage? storage,
    String keyPrefix = 'auth',
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _keyPrefix = keyPrefix;

  final FlutterSecureStorage _storage;
  final String _keyPrefix;

  String get _kAccess => '$_keyPrefix.access_token';
  String get _kRefresh => '$_keyPrefix.refresh_token';

  @override
  Future<String?> readAccessToken() => _storage.read(key: _kAccess);

  @override
  Future<String?> readRefreshToken() => _storage.read(key: _kRefresh);

  @override
  Future<TokenPair> readTokenPair() async {
    final access = await readAccessToken();
    final refresh = await readRefreshToken();
    return TokenPair(accessToken: access, refreshToken: refresh);
  }

  @override
  Future<void> writeAccessToken(String token) {
    return _storage.write(key: _kAccess, value: token);
  }

  @override
  Future<void> writeRefreshToken(String token) {
    return _storage.write(key: _kRefresh, value: token);
  }

  @override
  Future<void> writeTokenPair({
    required String accessToken,
    required String refreshToken,
  }) async {
    // atomic은 아니지만, 일반적으로 충분.
    // 완전 원자성을 원하면 platform-channel 레벨에서 묶어야 합니다.
    await writeAccessToken(accessToken);
    await writeRefreshToken(refreshToken);
  }

  @override
  Future<void> deleteAccessToken() => _storage.delete(key: _kAccess);

  @override
  Future<void> deleteRefreshToken() => _storage.delete(key: _kRefresh);

  @override
  Future<void> clear() async {
    await deleteAccessToken();
    await deleteRefreshToken();
  }

  @override
  Future<bool> hasAccessToken() async {
    final v = await readAccessToken();
    return (v ?? '').isNotEmpty;
  }

  @override
  Future<bool> hasRefreshToken() async {
    final v = await readRefreshToken();
    return (v ?? '').isNotEmpty;
  }
}

/// 테스트/로컬 개발용 인메모리 구현 (옵션)
class MemoryTokenStorage implements TokenStorage {
  String? _access;
  String? _refresh;

  @override
  Future<String?> readAccessToken() async => _access;

  @override
  Future<String?> readRefreshToken() async => _refresh;

  @override
  Future<TokenPair> readTokenPair() async => TokenPair(accessToken: _access, refreshToken: _refresh);

  @override
  Future<void> writeAccessToken(String token) async {
    _access = token;
  }

  @override
  Future<void> writeRefreshToken(String token) async {
    _refresh = token;
  }

  @override
  Future<void> writeTokenPair({required String accessToken, required String refreshToken}) async {
    _access = accessToken;
    _refresh = refreshToken;
  }

  @override
  Future<void> deleteAccessToken() async {
    _access = null;
  }

  @override
  Future<void> deleteRefreshToken() async {
    _refresh = null;
  }

  @override
  Future<void> clear() async {
    _access = null;
    _refresh = null;
  }

  @override
  Future<bool> hasAccessToken() async => (_access ?? '').isNotEmpty;

  @override
  Future<bool> hasRefreshToken() async => (_refresh ?? '').isNotEmpty;
}