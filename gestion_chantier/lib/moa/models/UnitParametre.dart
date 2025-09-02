// Modèles de données
class UnitParametre {
  final int id;
  final String label;
  final String code;
  final bool hasStartDate;
  final bool hasEndDate;
  final String type;

  UnitParametre({
    required this.id,
    required this.label,
    required this.code,
    required this.hasStartDate,
    required this.hasEndDate,
    required this.type,
  });

  factory UnitParametre.fromJson(Map<String, dynamic> json) {
    return UnitParametre(
      id: json['id'] ?? 0,
      label: json['label'] ?? '',
      code: json['code'] ?? '',
      hasStartDate: json['hasStartDate'] ?? false,
      hasEndDate: json['hasEndDate'] ?? false,
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'code': code,
      'hasStartDate': hasStartDate,
      'hasEndDate': hasEndDate,
      'type': type,
    };
  }
}

class UnitParametreResponse {
  final List<UnitParametre> content;
  final int totalElements;
  final int totalPages;
  final bool last;
  final int numberOfElements;
  final int size;
  final int number;
  final bool first;
  final bool empty;

  UnitParametreResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.last,
    required this.numberOfElements,
    required this.size,
    required this.number,
    required this.first,
    required this.empty,
  });

  factory UnitParametreResponse.fromJson(Map<String, dynamic> json) {
    return UnitParametreResponse(
      content:
          (json['content'] as List?)
              ?.map((item) => UnitParametre.fromJson(item))
              .toList() ??
          [],
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      last: json['last'] ?? false,
      numberOfElements: json['numberOfElements'] ?? 0,
      size: json['size'] ?? 0,
      number: json['number'] ?? 0,
      first: json['first'] ?? false,
      empty: json['empty'] ?? true,
    );
  }
}
