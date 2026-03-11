// ignore_for_file: file_names

import 'package:dio/dio.dart';
import 'package:gestion_chantier/shared/services/UserCacheService.dart';
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
    String profil = 'SITE_MANAGER',
    String adresse = '',
    String dateNaissance = '',
    String lieuNaissance = '',
  }) async {
    try {
      final map = <String, dynamic>{
        "nom": lastName,
        "prenom": firstName,
        "email": email,
        "password": password,
        "telephone": phone,
        "profil": profil,
      };
      if (adresse.isNotEmpty) map["adress"] = adresse;
      if (dateNaissance.isNotEmpty) map["date"] = dateNaissance;
      if (lieuNaissance.isNotEmpty) map["lieunaissance"] = lieuNaissance;

      final formData = FormData.fromMap(map);
      Response response = await _dio.post("/v1/auth/signup", data: formData);
      return response.data;
    } on DioException catch (e) {
      _handleError(e, "Échec de la création de compte");
    }
  }

  // Méthode existante pour récupérer l'utilisateur connecté
  Future<dynamic> connectedUser() async {
    try {
      return await UserCacheService.instance.get(() async {
        final response = await _dio.get("/v1/user/me");
        return response.data;
      });
    } on DioException catch (e) {
      _handleError(e, "Impossible de récupérer les informations utilisateur");
    }
  }

  Future<dynamic> resetPassword({required String email}) async {
    try {
      Response response = await _dio.post(
        "/v1/auth/password/reset",
        data: {"email": email},
      );

      return response.data;
    } on DioException catch (e) {
      _handleError(e, "Échec de la réinitialisation du mot de passe");
    }
  }

  Future<dynamic> changePassword({
    required String email,
    required String password,
    required String newPassword,
  }) async {
    try {
      Response response = await _dio.put(
        "/v1/auth/cahnge-password", // Assurez-vous que l'URL est correcte
        data: {
          "email": email,
          "password": password,
          "newPassword": newPassword,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        "Erreur lors de la modification du mot de passe : ${e.toString()}",
      );
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
