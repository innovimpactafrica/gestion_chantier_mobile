import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/manager/repository/auth_repository.dart';
import 'package:gestion_chantier/manager/services/SharedPreferencesService.dart';
import 'package:gestion_chantier/manager/utils/constant.dart';

import 'auth_state.dart';
import 'auth_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository = AuthRepository();
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  AuthBloc() : super(AuthInitialState()) {
    on<AuthLoginEvent>(_onAuthLoginEvent);
    on<AuthSignupEvent>(_onAuthSignupEvent);
    on<AuthLogoutEvent>(_onAuthLogoutEvent);
    on<AuthForgotPasswordEvent>(_onAuthForgotPasswordEvent);
    on<AuthChangePasswordEvent>(_onAuthChangePasswordEvent);
  }

  Future<void> _onAuthLoginEvent(
    AuthLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());

    try {
      final user = await _authRepository.login(event.email, event.password);
      emit(AuthAuthenticatedState(user: user, message: 'Connexion réussie'));
    } catch (e) {
      emit(AuthErrorState(message: 'Erreur de connexion : ${e.toString()}'));
    }
  }

  Future<void> _onAuthSignupEvent(
    AuthSignupEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());

    try {
      final user = await _authRepository.signup(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        password: event.password,
        phone: event.phone,
      );
      emit(AuthAuthenticatedState(user: user, message: 'Inscription réussie'));
    } catch (e) {
      emit(AuthErrorState(message: 'Erreur d\'inscription : ${e.toString()}'));
    }
  }

  Future<void> _onAuthLogoutEvent(
    AuthLogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());

    try {
      // Supprimer le token d'authentification
      await _sharedPreferencesService.removeValue(APIConstants.AUTH_TOKEN);
      // Supprimer le refresh token
      await _sharedPreferencesService.removeValue(APIConstants.REFRESH_TOKEN);

      await _sharedPreferencesService.removeValue("profil");

      emit(AuthUnauthenticatedState());
    } catch (e) {
      emit(AuthErrorState(message: 'Erreur de déconnexion : ${e.toString()}'));
    }
  }

  Future<void> _onAuthForgotPasswordEvent(
    AuthForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());

    try {
      // Appel à la méthode resetPassword du repository
      await _authRepository.resetPassword(email: event.email);

      // Si succès, émet un état indiquant que l'email a été envoyé
      emit(AuthForgotPasswordSentState(email: event.email));

      emit(
        AuthSuccesState(
          message: "Un email de réinitialisation a été envoyé à ${event.email}",
        ),
      );
    } catch (e) {
      // Gestion des erreurs génériques
      emit(
        AuthErrorState(
          message:
              'Erreur inattendue lors de la récupération du mot de passe : ${e.toString()}',
        ),
      );
    }
  }

  // Handler pour changer le mot de passe
  Future<void> _onAuthChangePasswordEvent(
    AuthChangePasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      // Appel au repository pour changer le mot de passe
      final user = await _authRepository.changePassword(
        email: event.email,
        password: event.password,
        newPassword: event.newPassword,
      );
      emit(AuthSuccessState(message: "Mot de passe changé avec succès"));
    } catch (e) {
      emit(
        AuthErrorState(
          message:
              "Erreur lors du changement du mot de passe : ${e.toString()}",
        ),
      );
    }
  }
}
