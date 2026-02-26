class RapportModel {
  final int id;
  final String titre;
  final String description;
  final String pdf;
  final DateTime lastUpdated;

  RapportModel({
    required this.id,
    required this.titre,
    required this.description,
    required this.pdf,
    required this.lastUpdated,
  });

  factory RapportModel.fromJson(Map<String, dynamic> json) {
    return RapportModel(
      id: json['id'],
      titre: json['titre'],
      description: json['description'],
      pdf: json['pdf'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "titre": titre,
      "description": description,
      "pdf": pdf,
      "lastUpdated": lastUpdated.toIso8601String(),
    };
  }
}
