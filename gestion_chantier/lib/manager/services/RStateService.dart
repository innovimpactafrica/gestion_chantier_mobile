import 'package:dio/dio.dart';
import 'package:gestion_chantier/bet/utils/constant.dart';

class RStateService {
  static const String _baseUrl =
      APIConstants.API_BASE_URL;

  late final Dio _dio;

  RStateService () {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': '*/*',
        },
      ),
    );

    /// Interceptor (logs – très utile en dev)
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('➡️ ${options.method} ${options.uri}');
          print('Headers: ${options.headers}');
          print('Data: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ Response: ${response.statusCode}');
          print('Data: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          print('❌ Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  // =======================
  // GET
  // =======================
  Future<dynamic> get(String endpoint,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // =======================
  // POST JSON
  // =======================
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // =======================
  // POST MULTIPART (IMAGE / FILE)
  // =======================
  Future<dynamic> postMultipart(
      String endpoint,
      FormData formData,
      ) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // =======================
  // PUT
  // =======================
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // =======================
  // DELETE
  // =======================
  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // =======================
  // ERROR HANDLER
  // =======================
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final status = error.response?.statusCode;
        final message = error.response?.data?.toString() ??
            'Erreur serveur';

        return Exception(
            'Erreur $status : $message');
      } else {
        return Exception(
            'Erreur réseau, vérifiez votre connexion');
      }
    }
    return Exception('Erreur inconnue : $error');
  }
}
