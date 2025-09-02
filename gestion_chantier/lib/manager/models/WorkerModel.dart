// models/worker_model.dart
import 'package:gestion_chantier/manager/models/AuthorityModel.dart';

class WorkerModel {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String password;
  final String adress;
  final String? technicalSheet;
  final String profil;
  final bool activated;
  final bool notifiable;
  final String telephone;
  final List<dynamic> subscriptions;
  final dynamic company;
  final DateTime createdAt;
  final int funds;
  final int note;
  final String? photo;
  final String? idCard;
  final bool accountNonExpired;
  final bool credentialsNonExpired;
  final bool accountNonLocked;
  final List<AuthorityModel> authorities;
  final String username;
  final bool enabled;

  WorkerModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.password,
    required this.adress,
    this.technicalSheet,
    required this.profil,
    required this.activated,
    required this.notifiable,
    required this.telephone,
    required this.subscriptions,
    required this.company,
    required this.createdAt,
    required this.funds,
    required this.note,
    this.photo,
    this.idCard,
    required this.accountNonExpired,
    required this.credentialsNonExpired,
    required this.accountNonLocked,
    required this.authorities,
    required this.username,
    required this.enabled,
  });

  factory WorkerModel.fromJson(Map<String, dynamic> json) {
    try {
      return WorkerModel(
        id: _parseInt(json['id']) ?? 0,
        nom: json['nom']?.toString() ?? '',
        prenom: json['prenom']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        password: json['password']?.toString() ?? '',
        adress: json['adress']?.toString() ?? '',
        technicalSheet: json['technicalSheet']?.toString(),
        profil: json['profil']?.toString() ?? '',
        activated: json['activated'] == true,
        notifiable: json['notifiable'] == true,
        telephone: json['telephone']?.toString() ?? '',
        subscriptions: _parseSubscriptions(json['subscriptions']),
        company: json['company'],
        createdAt: _parseDateTime(json['createdAt']),
        funds: _parseInt(json['funds']) ?? 0,
        note: _parseInt(json['note']) ?? 0,
        photo: json['photo']?.toString(),
        idCard: json['idCard']?.toString(),
        accountNonExpired: json['accountNonExpired'] == true,
        credentialsNonExpired: json['credentialsNonExpired'] == true,
        accountNonLocked: json['accountNonLocked'] == true,
        authorities: _parseAuthorities(json['authorities']),
        username: json['username']?.toString() ?? '',
        enabled: json['enabled'] == true,
      );
    } catch (e) {
      print('Error parsing WorkerModel: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  static List<dynamic> _parseSubscriptions(dynamic subscriptions) {
    if (subscriptions == null) return [];
    if (subscriptions is List) return subscriptions;
    return [subscriptions]; // If it's a single object, wrap in list
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  static DateTime _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return DateTime.now();

    if (dateTime is List && dateTime.length >= 3) {
      return DateTime.utc(
        dateTime[0] ?? DateTime.now().year,
        dateTime[1] ?? DateTime.now().month,
        dateTime[2] ?? DateTime.now().day,
        dateTime.length > 3 ? dateTime[3] ?? 0 : 0,
        dateTime.length > 4 ? dateTime[4] ?? 0 : 0,
        dateTime.length > 5 ? dateTime[5] ?? 0 : 0,
        dateTime.length > 6 ? (dateTime[6] ~/ 1000000) : 0,
      );
    }

    if (dateTime is String) {
      return DateTime.tryParse(dateTime) ?? DateTime.now();
    }

    return DateTime.now();
  }

  static List<AuthorityModel> _parseAuthorities(dynamic authorities) {
    if (authorities == null) return [];
    if (authorities is! List) return [];

    return authorities
        .where((e) => e != null)
        .map((e) {
          try {
            return AuthorityModel.fromJson(e as Map<String, dynamic>);
          } catch (ex) {
            print('Error parsing AuthorityModel: $ex');
            return null;
          }
        })
        .where((e) => e != null)
        .cast<AuthorityModel>()
        .toList();
  }
}
