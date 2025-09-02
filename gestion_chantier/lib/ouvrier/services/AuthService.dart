// ignore_for_file: file_names

import 'package:dio/dio.dart';
import 'api_service.dart';

class AuthService {
  final Dio _dio = ApiService().dio;

  // Méthode existante de connexion
  Future<dynamic> signIn(String email, String password) async {
    try {
      Response response = await _dio.post(
        "/v1/auth/signin", // Ajout du "/" au début
        data: {"email": email, "password": password},
      );

      return response.data;
    } on DioException catch (e) {
      _handleError(e, "Échec de la connexion");
    } catch (e) {
      throw Exception("Erreur inattendue lors de la connexion");
    }
  }

  // Nouvelle méthode pour l'inscription complète
  Future<dynamic> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      Response response = await _dio.post(
        "/v1/auth/signup", // Ajout du "/" au début
        data: {
          "firstName": firstName,
          "lastName": lastName,
          "email": email,
          "password": password,
          "role": "USER",
          "activated": true,
          "profil": "USER",
          "phone": phone,
        },
      );

      return response.data;
    } on DioException catch (e) {
      _handleError(e, "Échec de la création de compte");
    }
  }

  // Méthode existante pour récupérer l'utilisateur connecté
  Future<dynamic> connectedUser() async {
    try {
      Response response = await _dio.get(
        "/v1/user/me",
      ); // Ajout du "/" au début

      return response.data;
    } on DioException catch (e) {
      _handleError(e, "Impossible de récupérer les informations utilisateur");
    }
  }

  // Méthode privée de gestion des erreurs améliorée
  dynamic _handleError(DioException e, String defaultMessage) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final responseData = e.response!.data;

      // Vérifier si le serveur a renvoyé un message d'erreur spécifique
      String errorMessage = defaultMessage;
      if (responseData is Map<String, dynamic>) {
        errorMessage =
            responseData['message'] ??
            responseData['error'] ??
            responseData['detail'] ??
            defaultMessage;
      }

      switch (statusCode) {
        case 400:
          throw Exception("Données invalides: $errorMessage");
        case 401:
          throw Exception("Email ou mot de passe incorrect");
        case 403:
          throw Exception("Accès refusé");
        case 404:
          throw Exception("Service non trouvé");
        case 409:
          throw Exception("Un compte avec cet email existe déjà");
        case 422:
          throw Exception("Données invalides: $errorMessage");
        case 500:
          throw Exception("Erreur serveur temporaire");
        case 502:
        case 503:
        case 504:
          throw Exception("Service temporairement indisponible");
        default:
          throw Exception("$defaultMessage (Code: $statusCode)");
      }
    } else {
      // Erreurs de connexion (pas de réponse du serveur)
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          throw Exception(
            "Délai de connexion dépassé. Vérifiez votre connexion internet.",
          );
        case DioExceptionType.sendTimeout:
          throw Exception(
            "Délai d'envoi dépassé. Vérifiez votre connexion internet.",
          );
        case DioExceptionType.receiveTimeout:
          throw Exception(
            "Délai de réception dépassé. Vérifiez votre connexion internet.",
          );
        case DioExceptionType.connectionError:
          throw Exception(
            "Impossible de se connecter au serveur. Vérifiez votre connexion internet.",
          );
        case DioExceptionType.unknown:
          throw Exception(
            "Erreur de connexion inconnue. Vérifiez votre connexion internet.",
          );
        default:
          throw Exception(
            "$defaultMessage. Vérifiez votre connexion internet.",
          );
      }
    }
  }
}
