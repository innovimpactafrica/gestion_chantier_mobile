import 'package:gestion_chantier/bet/models/UserModel.dart';
import 'package:gestion_chantier/bet/services/AuthService.dart';

class BetAuthRepository {
  final BetAuthService _authService = BetAuthService();

  Future<BetUserModel> getCurrentUser() async {
    try {
      final userData = await _authService.connectedUser();
      if (userData == null) {
        throw Exception('Utilisateur non connecté');
      }
      return BetUserModel.fromJson(userData);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'utilisateur: $e');
    }
  }
}
