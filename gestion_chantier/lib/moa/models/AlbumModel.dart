// models/AlbumModel.dart ou models/ProgressAlbumModel.dart

import 'package:gestion_chantier/moa/models/RealEstateModel.dart';

class ProgressAlbum {
  final int id;
  final RealEstateModel realEstateProperty;
  final String name;
  final String description;
  final List<DateTime> lastUpdated;
  final List<String> pictures;
  final bool entrance;

  ProgressAlbum({
    required this.id,
    required this.realEstateProperty,
    required this.name,
    required this.description,
    required this.lastUpdated,
    required this.pictures,
    required this.entrance,
  });

  factory ProgressAlbum.fromJson(Map<String, dynamic> json) {
    return ProgressAlbum(
      id: _parseId(json['id']),
      realEstateProperty: RealEstateModel.fromJson(
        json['realEstateProperty'] ?? {},
      ),
      name: json['name']?.toString() ?? json['phaseName']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      lastUpdated: _parseLastUpdated(json['lastUpdated']),
      pictures: _parsePictures(json['pictures']),
      entrance: json['entrance'] == true,
    );
  }

  // CORRECTION: Méthode pour parser l'ID de façon sûre
  static int _parseId(dynamic id) {
    if (id is int) return id;
    if (id is String) {
      try {
        return int.parse(id);
      } catch (e) {
        return 0;
      }
    }
    return 0;
  }

  // CORRECTION: Méthode pour parser les images de façon sûre
  static List<String> _parsePictures(dynamic pictures) {
    if (pictures is List) {
      return pictures.map((item) => item.toString()).toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'realEstateProperty': realEstateProperty.toJson(),
      'name': name,
      'description': description,
      'lastUpdated': _formatLastUpdated(lastUpdated),
      'pictures': pictures,
      'entrance': entrance,
    };
  }

  static List<DateTime> _parseLastUpdated(dynamic lastUpdatedJson) {
    if (lastUpdatedJson is List) {
      // Format: [2025, 6, 19, 9, 54, 37, 172079000]
      if (lastUpdatedJson.length >= 6) {
        try {
          int year = _parseInt(lastUpdatedJson[0]);
          int month = _parseInt(lastUpdatedJson[1]);
          int day = _parseInt(lastUpdatedJson[2]);
          int hour = _parseInt(lastUpdatedJson[3]);
          int minute = _parseInt(lastUpdatedJson[4]);
          int second = _parseInt(lastUpdatedJson[5]);
          int microsecond =
              lastUpdatedJson.length > 6
                  ? (_parseInt(lastUpdatedJson[6]) / 1000).round()
                  : 0;

          return [
            DateTime(year, month, day, hour, minute, second, 0, microsecond),
          ];
        } catch (e) {
          print('Erreur lors du parsing de lastUpdated: $e');
          return [DateTime.now()];
        }
      }
    }
    return [DateTime.now()];
  }

  // CORRECTION: Méthode helper pour parser les entiers de façon sûre
  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return 0;
      }
    }
    if (value is double) return value.round();
    return 0;
  }

  static List<dynamic> _formatLastUpdated(List<DateTime> dateTime) {
    if (dateTime.isNotEmpty) {
      DateTime date = dateTime.first;
      return [
        date.year,
        date.month,
        date.day,
        date.hour,
        date.minute,
        date.second,
        date.microsecond * 1000,
      ];
    }
    return [];
  }

  DateTime get lastUpdatedDate =>
      lastUpdated.isNotEmpty ? lastUpdated.first : DateTime.now();

  String get formattedDate {
    DateTime date = lastUpdatedDate;
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  String get photoCount {
    int count = pictures.length;
    return "${count.toString().padLeft(2, '0')} photo${count > 1 ? 's' : ''}";
  }

  bool get hasPhotos => pictures.isNotEmpty;
}
