import 'package:dio/dio.dart';
import 'package:gestion_chantier/manager/utils/constant.dart';

import 'SharedPreferencesService.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  late Dio dio;

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: APIConstants.API_BASE_URL,
        connectTimeout: Duration(seconds: 30),
        receiveTimeout: Duration(seconds: 60),
        headers: {
          "User-Agent": "curl/7.64.1",
          "Content-Type": "application/json",
          "Accept": "*/*",
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // DEBUG: Afficher tous les headers envoyés
          print('[DEBUG] Headers envoyés: \\n${options.headers}');
          if (_isProtectedApi(options)) {
            String? token = await _getToken();
            if (token != null) {
              // Try different authorization header formats
              options.headers['Authorization'] = 'Bearer $token';
              // Alternative formats that some servers might expect
              options.headers['X-Auth-Token'] = token;
              options.headers['X-API-Key'] = token;

              print(
                '🔐 Token ajouté pour \\${options.uri}: \\${token.substring(0, 20)}...',
              );
            } else {
              print('⚠️ Aucun token trouvé pour \\${options.uri}');
            }
          } else {
            print('🔓 API non protégée: \\${options.uri}');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(
            '✅ Réponse reçue pour ${response.requestOptions.uri}: ${response.statusCode}',
          );
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print(
            '❌ Erreur pour ${e.requestOptions.uri}: ${e.response?.statusCode} - ${e.message}',
          );
          return handler.next(e);
        },
      ),
    );
  }

  bool _isProtectedApi(RequestOptions options) {
    const protectedApis = [
      "/v1/user/me",
      "/budgets",
      "/expenses",
      "/materials",
      "/realestate",
      "/rapports",
      "/tasks",
      "/workers",
      "/orders",
      "/progress-album",
      "/indicators",
      "/documents",
      "/units",
      "/incidents",
    ];
    for (var api in protectedApis) {
      if (options.uri.toString().contains(api)) {
        return true;
      }
    }
    return false;
  }

  Future<String?> _getToken() async {
    String? token = await _sharedPreferencesService.getValue(
      APIConstants.AUTH_TOKEN,
    );
    if (token != null) {
      print('🔑 Token récupéré: ${token.substring(0, 20)}...');
    } else {
      print('🔑 Aucun token trouvé dans le stockage');
    }
    return token;
  }
}
