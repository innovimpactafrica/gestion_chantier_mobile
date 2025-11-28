class BetUserModel {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String? telephone;
  final String? adress;
  final String profil;
  final bool activated;

  BetUserModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    this.telephone,
    this.adress,
    required this.profil,
    required this.activated,
  });

  // Getter pour le nom complet
  String get fullName {
    return '$prenom $nom';
  }

  factory BetUserModel.fromJson(Map<String, dynamic> json) {
    return BetUserModel(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      email: json['email'] ?? '',
      telephone: json['telephone'],
      adress: json['adress'],
      profil: json['profil'] ?? 'BET',
      activated: json['activated'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
      'adress': adress,
      'profil': profil,
      'activated': activated,
    };
  }
}
