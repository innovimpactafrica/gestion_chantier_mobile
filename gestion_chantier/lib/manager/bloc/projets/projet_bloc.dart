// bloc/navigation/navigation_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/manager/bloc/projets/projet_event.dart';
import 'package:gestion_chantier/manager/bloc/projets/projet_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(NavigationState()) {
    on<NavigationIndexChanged>((event, emit) {
      emit(state.copyWith(currentIndex: event.index));
    });
  }
}
