// ignore_for_file: unused_element

import 'package:gestion_chantier/manager/models/UserModel.dart';
import 'package:gestion_chantier/manager/models/documents.dart';
import 'package:gestion_chantier/manager/services/AuthService.dart';
import 'package:gestion_chantier/manager/services/Materiaux_service.dart';
import 'package:gestion_chantier/manager/services/SharedPreferencesService.dart';
import 'package:gestion_chantier/manager/services/UnitParametreService.dart';
import 'package:gestion_chantier/manager/utils/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gestion_chantier/manager/models/UnitParametre.dart';
import 'dart:io';
import 'package:gestion_chantier/manager/models/MaterialModel.dart';

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
      // Correction de la faute de frappe et amélioration du message d'erreur
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
        // Au cas où la structure serait différente
        return UserModel.fromJson(response['user']);
      } else {
        throw Exception(response['message'] ?? "Une erreur est survenue");
      }
    } catch (e) {
      print('Error handling response: $e'); // Debug log
      throw Exception("Erreur lors du traitement des données");
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }
}

class DocumentRepository {
  final DocumentService _documentService = DocumentService();

  /// Récupère tous les documents pour une propriété
  Future<List<DocumentModel>> getDocumentsByProperty(int propertyId) async {
    return await _documentService.getDocumentsByProperty(propertyId);
  }

  /// Récupère tous les types de documents
  Future<List<UnitParametre>> getDocumentTypes() async {
    return await _documentService.getDocumentTypes();
  }

  /// Ajoute un nouveau document
  Future<DocumentModel> addDocument({
    required String title,
    required File file,
    required String description,
    required int realEstatePropertyId,
    required int typeId,
    required String startDate,
    required String endDate,
  }) async {
    return await _documentService.addDocument(
      title: title,
      file: file,
      description: description,
      realEstatePropertyId: realEstatePropertyId,
      typeId: typeId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}

class InventoryRepository {
  final MaterialsApiService _materialsApiService = MaterialsApiService();

  /// Récupère tous les matériaux pour une propriété
  Future<List<MaterialModel>> getMaterialsByProperty(int propertyId) async {
    return await _materialsApiService.getMaterialsByProperty(propertyId);
  }

  /// Récupère toutes les unités disponibles
  Future<List<Unit>> getUnits() async {
    return await _materialsApiService.getUnits();
  }

  /// Ajoute un nouveau matériau à l'inventaire
  Future<MaterialModel> addMaterialToInventory({
    required String label,
    required int quantity,
    required int criticalThreshold,
    required int unitId,
    required int propertyId,
  }) async {
    return await _materialsApiService.addMaterialToInventory(
      label: label,
      quantity: quantity,
      criticalThreshold: criticalThreshold,
      unitId: unitId,
      propertyId: propertyId,
    );
  }
}
