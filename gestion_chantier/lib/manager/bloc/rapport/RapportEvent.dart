import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class RapportEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadRapports extends RapportEvent {
  final int userId;
  final int page;
  final int size;
  final bool reset; // AJOUTER CE PARAMÈTRE

  LoadRapports({
    required this.userId,
    this.page = 0,
    this.size = 10,
    this.reset = false, // Par défaut false
  });

  @override
  List<Object?> get props => [userId, page, size, reset];
}

// AJOUTER CET ÉVÉNEMENT POUR RAFRAÎCHIR
class RefreshRapports extends RapportEvent {
  final int userId;

  RefreshRapports({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class AddRapport extends RapportEvent {
  final String titre;
  final String description;
  final int propertyId;
  final File file;

  AddRapport({required this.titre, required this.description, required this.propertyId, required this.file});

  @override
  List<Object?> get props => [titre, description, propertyId, file];
}

class DeleteRapport extends RapportEvent {
  final int rapportId;

  DeleteRapport({required this.rapportId});

  @override
  List<Object?> get props => [rapportId];
}