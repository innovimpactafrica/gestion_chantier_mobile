class DocumentModel {
  final int id;
  final String title;
  final String file;
  final String description;
  final String? type;
  final DateTime? startDate;
  final DateTime? endDate;

  DocumentModel({
    required this.id,
    required this.title,
    required this.file,
    required this.description,
    this.type,
    this.startDate,
    this.endDate,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    try {
      // Gestion du champ type qui peut être un objet ou une chaîne
      String? typeValue;
      if (json['type'] != null) {
        if (json['type'] is String) {
          typeValue = json['type'];
        } else if (json['type'] is Map<String, dynamic>) {
          // Si c'est un objet, on prend le code ou le label
          final typeObj = json['type'] as Map<String, dynamic>;
          typeValue = typeObj['code'] ?? typeObj['label'] ?? '';
        }
      }

      return DocumentModel(
        id: json['id'] ?? 0,
        title: json['title'] ?? '',
        file: json['file'] ?? '',
        description: json['description'] ?? '',
        type: typeValue,
        startDate: _parseDate(json['startDate']),
        endDate: _parseDate(json['endDate']),
      );
    } catch (e) {
      print('Erreur de parsing DocumentModel: $e');
      print('Données reçues: $json');
      throw FormatException('Format de données invalide pour DocumentModel');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'file': file,
      'description': description,
      'type': type,
      'startDate': _dateToList(startDate),
      'endDate': _dateToList(endDate),
    };
  }

  static DateTime? _parseDate(List<dynamic>? dateArray) {
    if (dateArray == null || dateArray.length < 3) return null;
    return DateTime(
      dateArray[0],
      dateArray[1],
      dateArray[2],
      dateArray.length > 3 ? dateArray[3] : 0,
      dateArray.length > 4 ? dateArray[4] : 0,
    );
  }

  static List<int>? _dateToList(DateTime? date) {
    if (date == null) return null;
    return [date.year, date.month, date.day, date.hour, date.minute];
  }
}
