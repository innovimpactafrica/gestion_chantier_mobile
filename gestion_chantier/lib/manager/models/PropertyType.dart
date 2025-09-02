class PropertyType {
  final int id;
  final String typeName;
  final bool parent;

  PropertyType({
    required this.id,
    required this.typeName,
    required this.parent,
  });

  factory PropertyType.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing PropertyType from JSON: $json');

      return PropertyType(
        id: _parseIntSafely(json['id']),
        typeName: _parseStringSafely(json['typeName']),
        parent: json['parent'] == true,
      );
    } catch (e, stackTrace) {
      print('Erreur lors du parsing de PropertyType: $e');
      print('StackTrace: $stackTrace');
      print('JSON reçu: $json');

      // Log des valeurs nulles spécifiques
      json.forEach((key, value) {
        if (value == null) {
          print('Valeur null trouvée pour la clé: $key');
        }
      });

      // Créer un PropertyType par défaut en cas d'erreur
      print(
        'Création d\'un PropertyType par défaut due à l\'erreur de parsing',
      );
      return PropertyType(id: 0, typeName: 'Type par défaut', parent: false);
    }
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "typeName": typeName, "parent": parent};
  }

  // Méthodes utilitaires pour parser en sécurité
  static int _parseIntSafely(dynamic value) {
    if (value == null) {
      print('Warning: Parsing null value as int, returning 0');
      return 0;
    }
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed == null) {
        print('Warning: Could not parse string "$value" as int, returning 0');
        return 0;
      }
      return parsed;
    }
    if (value is double) return value.toInt();
    print(
      'Warning: Unexpected type ${value.runtimeType} for int parsing, returning 0',
    );
    return 0;
  }

  static String _parseStringSafely(dynamic value) {
    if (value == null) {
      print('Warning: Parsing null value as string, returning empty string');
      return '';
    }
    return value.toString();
  }

  @override
  String toString() {
    return 'PropertyType(id: $id, typeName: $typeName, parent: $parent)';
  }
}
