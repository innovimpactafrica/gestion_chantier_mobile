import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/moa/bloc/Indicator/ConstructionIndicatorEvent.dart';
import 'package:gestion_chantier/moa/bloc/Indicator/ConstructionIndicatorState.dart';
import 'package:gestion_chantier/moa/services/ConstructionPhaseIndicator_service.dart';

class ConstructionIndicatorBloc
    extends Bloc<ConstructionIndicatorEvent, ConstructionIndicatorState> {
  final ConstructionIndicatorService _service;

  ConstructionIndicatorBloc({ConstructionIndicatorService? service})
    : _service = service ?? ConstructionIndicatorService(),
      super(ConstructionIndicatorInitial()) {
    // Enregistrement des handlers d'événements
    on<LoadIndicatorsByProperty>(_onLoadIndicatorsByProperty);
    on<UpdateIndicator>(_onUpdateIndicator);
  }

  /// Handler pour charger les indicateurs d'une propriété
  Future<void> _onLoadIndicatorsByProperty(
    LoadIndicatorsByProperty event,
    Emitter<ConstructionIndicatorState> emit,
  ) async {
    emit(ConstructionIndicatorLoading());

    try {
      final indicators = await _service.getIndicatorsByProperty(
        event.propertyId,
      );
      emit(ConstructionIndicatorLoaded(indicators));
    } catch (e) {
      emit(ConstructionIndicatorError(e.toString()));
    }
  }

  /// Handler pour mettre à jour un indicateur
  Future<void> _onUpdateIndicator(
    UpdateIndicator event,
    Emitter<ConstructionIndicatorState> emit,
  ) async {
    if (state is ConstructionIndicatorLoaded) {
      final currentState = state as ConstructionIndicatorLoaded;

      // Émet l'état de mise à jour
      emit(
        ConstructionIndicatorUpdating(
          indicators: currentState.indicators,
          updatingIndicatorId: event.indicatorId,
        ),
      );

      try {
        // Met à jour l'indicateur via l'API
        final updatedIndicator = await _service.updateIndicator(
          event.indicatorId,
          event.progressPercentage,
        );

        // Met à jour la liste locale
        final updatedIndicators =
            currentState.indicators.map((indicator) {
              if (indicator.id == event.indicatorId) {
                return updatedIndicator;
              }
              return indicator;
            }).toList();

        emit(ConstructionIndicatorLoaded(updatedIndicators));
      } catch (e) {
        // En cas d'erreur, revient à l'état précédent avec un message d'erreur
        emit(
          ConstructionIndicatorError(
            'Erreur lors de la mise à jour: ${e.toString()}',
            previousIndicators: currentState.indicators,
          ),
        );

        // Après un délai, revient à l'état chargé précédent
        await Future.delayed(const Duration(seconds: 3));
        emit(ConstructionIndicatorLoaded(currentState.indicators));
      }
    }
  }
}
