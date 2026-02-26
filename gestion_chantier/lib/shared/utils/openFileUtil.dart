import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';

Future<void> openFileFromUrl(String url, String fileName) async {
  try {
    // Récupérer le dossier temporaire
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/$fileName';

    // Télécharger le fichier
    final dio = Dio();
    await dio.download(url, filePath);

    // Ouvrir le fichier avec l'application appropriée
    await OpenFilex.open(filePath);
  } catch (e) {
    print("Erreur ouverture fichier: $e");
  }
}
