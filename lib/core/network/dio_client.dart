import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../utils/constants.dart';

class DioClient {
  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: Constants.BASE_URL,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          Logger().i("➡️ ${options.method} ${options.path}");
          return handler.next(options);
        },
        onResponse: (response, handler) {
          Logger().i("✅ ${response.statusCode} ${response.data}");
          return handler.next(response);
        },
        onError: (e, handler) {
          Logger().e("❌ ${e.message}");
          return handler.next(e);
        },
      ),
    );

    return dio;
  }
}
