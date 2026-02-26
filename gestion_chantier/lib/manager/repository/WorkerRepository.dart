import 'dart:io';
import 'package:dio/dio.dart';
import '../../ouvrier/services/api_service.dart';

class WorkerRepository {
  final ApiService _apiService = ApiService();

  Future<void> createWorker({
    required int id,
    required String prenom,
    required String nom,
    required String telephone,
    required String email,
    required String password,
    required String profil, // SITE_MANAGER, WORKER, MOA
    required String adress,
    required String lieunaissance,
    required DateTime date,
    File? photo,
  }) async {
    try {
      final formData = FormData.fromMap({
        'prenom': prenom,
        'nom': nom,
        'telephone': telephone,
        'email': email,
        'password': password,
        'profil': profil,
        'adress': adress,
        'lieunaissance': lieunaissance,
        'date': "${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}-${date.year}",
        if (photo != null)
          'photo': await MultipartFile.fromFile(
            photo.path,
            filename: photo.path.split('/').last,
          ),
      });

      await _apiService.dio.post('/workers/save/$id', data: formData);
    } catch (e) {
      throw Exception("Erreur lors de la création du worker : $e");
    }
  }
}
