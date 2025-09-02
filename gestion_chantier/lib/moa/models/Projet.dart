// models/projet.dart
class Projet {
  final String nom;
  final String lieu;
  final String? dateDebut;
  final String? dateFin;
  final int progression;
  final String? image;
  final bool isMainProject;
  final String? id;

  Projet({
    required this.nom,
    required this.lieu,
    this.dateDebut,
    this.dateFin,
    required this.progression,
    this.image,
    this.isMainProject = false,
    this.id,
  });

  // Factory constructor pour créer un Projet à partir d'une Map
  factory Projet.fromMap(Map<String, dynamic> map) {
    return Projet(
      nom: map['nom'] ?? '',
      lieu: map['lieu'] ?? '',
      dateDebut: map['dateDebut'],
      dateFin: map['dateFin'],
      progression: map['progression'] ?? 0,
      image: map['image'],
      isMainProject: map['isMainProject'] ?? false,
      id: map['id'],
    );
  }

  // Méthode pour convertir un Projet en Map
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'lieu': lieu,
      'dateDebut': dateDebut,
      'dateFin': dateFin,
      'progression': progression,
      'image': image,
      'isMainProject': isMainProject,
      'id': id,
    };
  }

  // Méthode pour créer une copie du projet avec des modifications
  Projet copyWith({
    String? nom,
    String? lieu,
    String? dateDebut,
    String? dateFin,
    int? progression,
    String? image,
    bool? isMainProject,
    String? id,
  }) {
    return Projet(
      nom: nom ?? this.nom,
      lieu: lieu ?? this.lieu,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      progression: progression ?? this.progression,
      image: image ?? this.image,
      isMainProject: isMainProject ?? this.isMainProject,
      id: id ?? this.id,
    );
  }

  @override
  String toString() {
    return 'Projet(nom: $nom, lieu: $lieu, progression: $progression%)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Projet &&
        other.nom == nom &&
        other.lieu == lieu &&
        other.dateDebut == dateDebut &&
        other.dateFin == dateFin &&
        other.progression == progression &&
        other.image == image &&
        other.isMainProject == isMainProject &&
        other.id == id;
  }

  @override
  int get hashCode {
    return nom.hashCode ^
        lieu.hashCode ^
        dateDebut.hashCode ^
        dateFin.hashCode ^
        progression.hashCode ^
        image.hashCode ^
        isMainProject.hashCode ^
        id.hashCode;
  }
}
