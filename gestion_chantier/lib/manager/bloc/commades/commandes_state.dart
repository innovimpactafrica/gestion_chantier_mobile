import 'package:equatable/equatable.dart';
import 'package:gestion_chantier/manager/models/CommandeModel.dart';

abstract class CommandeState extends Equatable {
  const CommandeState();

  @override
  List<Object?> get props => [];
}

/// État initial
class CommandeInitial extends CommandeState {
  const CommandeInitial();
}

/// État de chargement pour les commandes
class CommandeLoading extends CommandeState {
  const CommandeLoading();
}

/// État de chargement pour l'ajout d'une commande
class CommandeAdding extends CommandeState {
  const CommandeAdding();
}

/// État de succès avec les commandes chargées
class CommandeLoaded extends CommandeState {
  final List<CommandeModel> commandes;
  final int? propertyId;

  const CommandeLoaded({required this.commandes, this.propertyId});

  @override
  List<Object?> get props => [commandes, propertyId];

  /// Méthode pour copier l'état avec de nouvelles valeurs
  CommandeLoaded copyWith({List<CommandeModel>? commandes, int? propertyId}) {
    return CommandeLoaded(
      commandes: commandes ?? this.commandes,
      propertyId: propertyId ?? this.propertyId,
    );
  }
}

/// État de succès après l'ajout d'une commande
class CommandeAdded extends CommandeState {
  final CommandeModel newCommande;
  final List<CommandeModel> allCommandes;

  const CommandeAdded({required this.newCommande, required this.allCommandes});

  @override
  List<Object?> get props => [newCommande, allCommandes];
}

/// État d'erreur
class CommandeError extends CommandeState {
  final String message;
  final String? errorType;

  const CommandeError({required this.message, this.errorType});

  @override
  List<Object?> get props => [message, errorType];
}

/// État d'erreur lors de l'ajout
class CommandeAddError extends CommandeState {
  final String message;
  final List<CommandeModel>? currentCommandes;

  const CommandeAddError({required this.message, this.currentCommandes});

  @override
  List<Object?> get props => [message, currentCommandes];
}

/// État vide (aucune commande trouvée)
class CommandeEmpty extends CommandeState {
  final int propertyId;

  const CommandeEmpty({required this.propertyId});

  @override
  List<Object?> get props => [propertyId];
}
