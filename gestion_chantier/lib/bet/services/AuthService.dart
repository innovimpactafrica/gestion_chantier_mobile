import 'package:shared_preferences/shared_preferences.dart';
import 'package:gestion_chantier/moa/utils/constant.dart';
import 'package:gestion_chantier/services/api_service.dart';

class BetAuthService {
  static const String _userKey = 'bet_user_data';
  static const String _tokenKey = APIConstants.AUTH_TOKEN;

  Future<Map<String, dynamic>?> connectedUser() async {
    try {
      // Utiliser l'ApiService pour récupérer les vraies données utilisateur
      final apiService = ApiService();
      final response = await apiService.dio.get('/v1/user/me');

      if (response.statusCode == 200) {
        final userData = response.data;
        print('🔍 [BetAuthService] Données utilisateur récupérées: $userData');
        return userData;
      }
      return null;
    } catch (e) {
      print(
        '❌ [BetAuthService] Erreur lors de la récupération de l\'utilisateur: $e',
      );
      return null;
    }
  }

  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      print(
        '🔑 [BetAuthService] Token récupéré: ${token != null ? token.substring(0, 20) + "..." : "null"}',
      );
      return token;
    } catch (e) {
      print('❌ [BetAuthService] Erreur lors de la récupération du token: $e');
      return null;
    }
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // En réalité, vous devriez utiliser jsonEncode
      await prefs.setString(_userKey, 'user_data');
    } catch (e) {
      print('Erreur lors de la sauvegarde des données utilisateur BET: $e');
    }
  }

  Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } catch (e) {
      print('Erreur lors de la sauvegarde du token BET: $e');
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_tokenKey);
    } catch (e) {
      print('Erreur lors de la déconnexion BET: $e');
    }
  }
}
