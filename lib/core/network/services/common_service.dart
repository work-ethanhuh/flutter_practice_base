import 'package:dio/dio.dart';
import '../api_end_point.dart';
import '../settings/api_response.dart';
import 'package:retrofit/retrofit.dart';

part 'common_service.g.dart';

@RestApi(baseUrl: ApiEndPoint.common)
abstract class CommonService {
  factory CommonService(Dio dio, {String baseUrl}) = _CommonService;

  @GET('/loadUser')
  Future<ApiResponse> test();

  // @GET('/userinfo/{userSeq}')
  // Future<ApiResponse> userInfo(@Path('userSeq') int userSeq);

  // @GET('/dept/{deptSeq}')
  // Future<ApiResponse> department(@Path('deptSeq') int deptSeq);

  // @GET('/dept/{deptSeq}/child')
  // Future<ApiResponse> departmentChild(@Path('deptSeq') int deptSeq);

  // @GET('/dept/{deptSeq}/user')
  // Future<ApiResponse> departmentUser(@Path('deptSeq') int deptSeq);

  // @GET('/dept/{deptSeq}/user/cnc')
  // Future<ApiResponse> departmentUserCnc(@Path('deptSeq') int deptSeq);

  // @GET('/code/common')
  // Future commonCode();

  // @GET('/code/custom')
  // Future customCode();

  // @GET('/menu/{menuSeq}')
  // Future<ApiResponse> menu({@Path('menuSeq') int menuSeq = 0});

  // @GET('/menu/{menuSeq}')
  // Future<ApiResponse> childMenu(@Path('menuSeq') int menuSeq);
}