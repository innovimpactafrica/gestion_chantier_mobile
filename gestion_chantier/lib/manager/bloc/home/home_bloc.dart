import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/manager/bloc/home/home_event.dart';
import 'package:gestion_chantier/manager/bloc/home/home_state.dart';
import 'package:gestion_chantier/manager/repository/auth_repository.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AuthRepository authRepository;

  HomeBloc({required this.authRepository}) : super(HomeState()) {
    on<LoadCurrentUserEvent>(_onLoadCurrentUser);
    on<ClearUserEvent>(_onClearUser);
  }

  Future<void> _onLoadCurrentUser(
    LoadCurrentUserEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final user = await authRepository.currentUser();
      emit(state.copyWith(isLoading: false, currentUser: user));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onClearUser(
    ClearUserEvent event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(
      currentUser: null,
      isAuthenticated: false,
      errorMessage: null,
    ));
  }
}
