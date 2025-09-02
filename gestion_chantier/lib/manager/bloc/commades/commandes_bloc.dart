import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/manager/bloc/commades/commandes_event.dart';
import 'package:gestion_chantier/manager/bloc/commades/commandes_state.dart';

import 'package:gestion_chantier/manager/models/CommandeModel.dart';
import 'package:gestion_chantier/manager/services/CommandesService.dart';

class CommandeBloc extends Bloc<CommandeEvent, CommandeState> {
  final CommandeService _commandeService;

  CommandeBloc({CommandeService? commandeService})
    : _commandeService = commandeService ?? CommandeService(),
      super(const CommandeInitial()) {
    // Enregistrer les handlers pour chaque événement
    on<GetPendingOrdersEvent>(_onGetPendingOrders);
    on<AddOrderEvent>(_onAddOrder);
    on<RefreshOrdersEvent>(_onRefreshOrders);
    on<ResetCommandeStateEvent>(_onResetCommandeState);
  }

  /// Handler pour récupérer les commandes en attente
  Future<void> _onGetPendingOrders(
    GetPendingOrdersEvent event,
    Emitter<CommandeState> emit,
  ) async {
    emit(const CommandeLoading());

    try {
      final commandes = await _commandeService.getPendingOrders(
        event.propertyId,
      );

      if (commandes.isEmpty) {
        emit(CommandeEmpty(propertyId: event.propertyId));
      } else {
        emit(
          CommandeLoaded(commandes: commandes, propertyId: event.propertyId),
        );
      }
    } catch (e) {
      emit(
        CommandeError(
          message: e.toString(),
          errorType: 'GET_PENDING_ORDERS_ERROR',
        ),
      );
    }
  }

  /// Handler pour ajouter une nouvelle commande
  Future<void> _onAddOrder(
    AddOrderEvent event,
    Emitter<CommandeState> emit,
  ) async {
    List<CommandeModel> currentCommandes = [];
    if (state is CommandeLoaded) {
      currentCommandes = (state as CommandeLoaded).commandes;
    }

    emit(const CommandeAdding());

    try {
      final newCommande = await _commandeService.addOrder(
        supplierId: event.supplierId,
        materials: event.materials,
        propertyId: event.propertyId,
        deliveryDate: event.deliveryDate,
      );

      final updatedCommandes = [...currentCommandes, newCommande];

      emit(
        CommandeAdded(newCommande: newCommande, allCommandes: updatedCommandes),
      );
    } catch (e) {
      emit(
        CommandeAddError(
          message: e.toString(),
          currentCommandes: currentCommandes,
        ),
      );
    }
  }

  /// Handler pour rafraîchir les commandes
  Future<void> _onRefreshOrders(
    RefreshOrdersEvent event,
    Emitter<CommandeState> emit,
  ) async {
    // Ne pas montrer le loading si on a déjà des données
    if (state is! CommandeLoaded) {
      emit(const CommandeLoading());
    }

    try {
      final commandes = await _commandeService.getPendingOrders(
        event.propertyId,
      );

      if (commandes.isEmpty) {
        emit(CommandeEmpty(propertyId: event.propertyId));
      } else {
        emit(
          CommandeLoaded(commandes: commandes, propertyId: event.propertyId),
        );
      }
    } catch (e) {
      // Si on avait déjà des données, on les garde et on montre juste l'erreur
      if (state is CommandeLoaded) {
        final currentState = state as CommandeLoaded;
        emit(
          CommandeError(
            message: 'Erreur lors du rafraîchissement: ${e.toString()}',
            errorType: 'REFRESH_ERROR',
          ),
        );
        // Retourner à l'état précédent après un délai
        await Future.delayed(const Duration(seconds: 2));
        emit(currentState);
      } else {
        emit(CommandeError(message: e.toString(), errorType: 'REFRESH_ERROR'));
      }
    }
  }

  /// Handler pour réinitialiser l'état
  Future<void> _onResetCommandeState(
    ResetCommandeStateEvent event,
    Emitter<CommandeState> emit,
  ) async {
    emit(const CommandeInitial());
  }

  /// Méthode utilitaire pour obtenir les commandes actuelles
  List<CommandeModel> getCurrentCommandes() {
    if (state is CommandeLoaded) {
      return (state as CommandeLoaded).commandes;
    } else if (state is CommandeAdded) {
      return (state as CommandeAdded).allCommandes;
    }
    return [];
  }

  /// Méthode utilitaire pour vérifier si on a des commandes
  bool hasCommandes() {
    return getCurrentCommandes().isNotEmpty;
  }

  /// Méthode utilitaire pour obtenir le propertyId actuel
  int? getCurrentPropertyId() {
    if (state is CommandeLoaded) {
      return (state as CommandeLoaded).propertyId;
    } else if (state is CommandeEmpty) {
      return (state as CommandeEmpty).propertyId;
    }
    return null;
  }
}
