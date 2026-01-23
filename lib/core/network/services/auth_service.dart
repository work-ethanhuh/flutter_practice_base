import 'package:dio/dio.dart';
import 'package:flutter_practice_base/core/network/services/refresh_jwt/refresh_jwt_request.dart';
import 'package:flutter_practice_base/core/network/services/refresh_jwt/refresh_jwt_response.dart';
import '../api_end_point.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_service.g.dart';

@RestApi(baseUrl: ApiEndPoint.auth)
abstract class AuthService {
  factory AuthService(Dio dio, {String baseUrl}) = _AuthService;

  // @POST('/login/pwd')
  // Future<ApiResponse> pwdLogin(@Body() ForLoginInfo body);

  @POST('refreshJwt')
  Future<RefreshJwtResponse> refreshJwt(@Body() RefreshJwtRequest body);
}
