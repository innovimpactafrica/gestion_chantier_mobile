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
    return PropertyType(
      id: json['id']??0,
      typeName: json['typeName']?.toString() ?? '',
      parent: _parseBool(json['parent']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'typeName': typeName,
      'parent': parent,
    };
  }
}
