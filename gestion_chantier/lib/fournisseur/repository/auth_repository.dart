import 'package:gestion_chantier/fournisseur/models/UserModel.dart';
import 'package:gestion_chantier/fournisseur/services/AuthService.dart';
import 'package:gestion_chantier/fournisseur/services/SharedPreferencesService.dart';
import 'package:gestion_chantier/fournisseur/utils/constant.dart';

class AuthRepository {
  final AuthService _authService = AuthService();
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _authService.signIn(email, password);
      print('Response from API: $response'); // Debug log
      return _handleLoginResponse(response);
    } catch (e) {
      print('Login error: $e'); // Debug log
      if (e.toString().contains('Données invalides')) {
        throw Exception("Email ou mot de passe incorrect");
      } else if (e.toString().contains('connexion internet')) {
        throw Exception("Vérifiez votre connexion internet");
      } else if (e.toString().contains('Non autorisé')) {
        throw Exception("Email ou mot de passe incorrect");
      } else {
        throw Exception("Erreur de connexion : ${e.toString()}");
      }
    }
  }

  Future<UserModel> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final response = await _authService.signUp(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phone: phone,
      );
      return _handleResponse(response);
    } catch (e) {
      print('Signup error: $e'); // Debug log
      throw Exception("Erreur d'inscription : ${e.toString()}");
    }
  }

  Future<UserModel> _handleLoginResponse(Map<String, dynamic> response) async {
    try {
      print('Handling login response: $response'); // Debug log

      if (response.containsKey("token") &&
          response.containsKey("refreshToken")) {
        // Sauvegarder le token
        await _sharedPreferencesService.saveValue(
          APIConstants.AUTH_TOKEN,
          response["token"],
        );

        // Récupérer les informations utilisateur
        final userMap = await _authService.connectedUser();
        print('User data: $userMap'); // Debug log

        return UserModel.fromJson(userMap);
      } else if (response.containsKey("accessToken")) {
        // Au cas où l'API utilise "accessToken" au lieu de "token"
        await _sharedPreferencesService.saveValue(
          APIConstants.AUTH_TOKEN,
          response["accessToken"],
        );

        final userMap = await _authService.connectedUser();
        return UserModel.fromJson(userMap);
      } else {
        print('Invalid response structure: $response'); // Debug log
        throw Exception("Réponse invalide du serveur");
      }
    } catch (e) {
      print('Error handling login response: $e'); // Debug log
      throw Exception(
        "Erreur lors du traitement de la réponse : ${e.toString()}",
      );
    }
  }

  Future<UserModel> currentUser() async {
    try {
      final userMap = await _authService.connectedUser();
      return UserModel.fromJson(userMap);
    } catch (e) {
      throw Exception("Impossible de récupérer les informations utilisateur");
    }
  }

  UserModel _handleResponse(Map<String, dynamic> response) {
    try {
      if (response['success'] == true && response.containsKey('data')) {
        return UserModel.fromJson(response['data']);
      } else if (response.containsKey('user')) {
        return UserModel.fromJson(response['user']);
      } else {
        throw Exception(response['message'] ?? "Une erreur est survenue");
      }
    } catch (e) {
      print('Error handling response: $e'); // Debug log
      throw Exception("Erreur lors du traitement des données");
    }
  }
}
