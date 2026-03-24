import 'package:equatable/equatable.dart';
import 'package:gestion_chantier/manager/models/CommandeModel.dart';
import 'package:gestion_chantier/manager/models/MaterialModel.dart';

abstract class CommandeEvent extends Equatable {
  const CommandeEvent();

  @override
  List<Object?> get props => [];
}

/// Événement pour récupérer les commandes en attente d'une propriété
class GetPendingOrdersEvent extends CommandeEvent {
  final int propertyId;

  const GetPendingOrdersEvent({required this.propertyId});

  @override
  List<Object?> get props => [propertyId];
}

/// Événement pour ajouter une nouvelle commande
class AddOrderEvent extends CommandeEvent {
  final int supplierId;
  final List<MaterialModel> materials;
  final int propertyId;
  final DateTime? deliveryDate;

  const AddOrderEvent({
    required this.supplierId,
    required this.materials,
    required this.propertyId,
    this.deliveryDate,
  });

  @override
  List<Object?> get props => [supplierId, materials, propertyId, deliveryDate];
}

/// Événement pour rafraîchir les commandes
class RefreshOrdersEvent extends CommandeEvent {
  final int propertyId;

  const RefreshOrdersEvent({required this.propertyId});

  @override
  List<Object?> get props => [propertyId];
}

/// Événement pour réinitialiser l'état des commandes
class ResetCommandeStateEvent extends CommandeEvent {
  const ResetCommandeStateEvent();
}

/// Événement pour supprimer une commande
class DeleteOrderEvent extends CommandeEvent {
  final int orderId;
  final int propertyId;
  const DeleteOrderEvent({required this.orderId, required this.propertyId});
  @override
  List<Object?> get props => [orderId, propertyId];
}

/// Événement pour dupliquer une commande
class DuplicateOrderEvent extends CommandeEvent {
  final CommandeModel commande;
  final int propertyId;
  const DuplicateOrderEvent({required this.commande, required this.propertyId});
  @override
  List<Object?> get props => [commande, propertyId];
}

/// Événement pour modifier une commande
class UpdateOrderEvent extends CommandeEvent {
  final int orderId;
  final int supplierId;
  final DateTime deliveryDate;
  final List<Map<String, dynamic>> items;
  final int propertyId;
  const UpdateOrderEvent({
    required this.orderId,
    required this.supplierId,
    required this.deliveryDate,
    required this.items,
    required this.propertyId,
  });
  @override
  List<Object?> get props => [orderId, supplierId, deliveryDate, items, propertyId];
}
