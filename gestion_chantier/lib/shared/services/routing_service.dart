import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Imports pour tous les modules
import 'package:gestion_chantier/manager/widgets/navitems.dart' as manager;
import 'package:gestion_chantier/manager/bloc/auth/auth_bloc.dart'
    as manager_auth;
import 'package:gestion_chantier/manager/bloc/home/home_bloc.dart'
    as manager_home;
import 'package:gestion_chantier/manager/bloc/home/home_event.dart'
    as manager_event;
import 'package:gestion_chantier/manager/repository/auth_repository.dart'
    as manager_repo;

import 'package:gestion_chantier/moa/widgets/navitems.dart' as moa;
import 'package:gestion_chantier/moa/bloc/auth/auth_bloc.dart' as moa_auth;
import 'package:gestion_chantier/moa/bloc/home/home_bloc.dart' as moa_home;
import 'package:gestion_chantier/moa/bloc/home/home_event.dart' as moa_event;
import 'package:gestion_chantier/moa/repository/auth_repository.dart'
    as moa_repo;

import 'package:gestion_chantier/fournisseur/widgets/navitems.dart'
    as fournisseur;
import 'package:gestion_chantier/fournisseur/bloc/auth/auth_bloc.dart'
    as fournisseur_auth;
import 'package:gestion_chantier/fournisseur/bloc/home/home_bloc.dart'
    as fournisseur_home;
import 'package:gestion_chantier/fournisseur/bloc/home/home_event.dart'
    as fournisseur_event;
import 'package:gestion_chantier/fournisseur/repository/auth_repository.dart'
    as fournisseur_repo;

import 'package:gestion_chantier/bet/widgets/navitems.dart' as bet;
import 'package:gestion_chantier/bet/bloc/home/home_bloc.dart' as bet_home;
import 'package:gestion_chantier/bet/bloc/home/home_event.dart' as bet_event;

import 'package:gestion_chantier/ouvrier/pages/ouvrier_main_screen.dart';

class RoutingService {
  static void routeByProfile(BuildContext context, String profile) {
    final profil = profile.toLowerCase();

    if (profil == 'worker' || profil == 'ouvrier') {
      _routeToOuvrier(context);
    } else if (profil == 'moa') {
      _routeToMoa(context);
    } else if (profil == 'fournisseur') {
      _routeToFournisseur(context);
    } else if (profil == 'bet') {
      _routeToBet(context);
    } else {
      _routeToManager(context);
    }
  }

  static void _routeToOuvrier(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OuvrierMainScreen()),
    );
  }

  static void _routeToMoa(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => MultiBlocProvider(
              providers: [
                BlocProvider<moa_auth.AuthBloc>(
                  create: (_) => moa_auth.AuthBloc(),
                ),
                BlocProvider<moa_home.HomeBloc>(
                  create:
                      (_) => moa_home.HomeBloc(
                        authRepository: moa_repo.AuthRepository(),
                      )..add(moa_event.LoadCurrentUserEvent()),
                ),
              ],
              child: const moa.MainScreen(),
            ),
      ),
    );
  }

  static void _routeToFournisseur(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => MultiBlocProvider(
              providers: [
                BlocProvider<fournisseur_auth.AuthBloc>(
                  create: (_) => fournisseur_auth.AuthBloc(),
                ),
                BlocProvider<fournisseur_home.HomeBloc>(
                  create:
                      (_) => fournisseur_home.HomeBloc(
                        authRepository: fournisseur_repo.AuthRepository(),
                      )..add(fournisseur_event.LoadCurrentUserEvent()),
                ),
              ],
              child: const fournisseur.MainScreen(),
            ),
      ),
    );
  }

  static void _routeToBet(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => MultiBlocProvider(
              providers: [
                BlocProvider<bet_home.BetHomeBloc>(
                  create:
                      (_) =>
                          bet_home.BetHomeBloc()
                            ..add(bet_event.LoadCurrentUserEvent()),
                ),
              ],
              child: const bet.BetMainScreen(),
            ),
      ),
    );
  }

  static void _routeToManager(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => MultiBlocProvider(
              providers: [
                BlocProvider<manager_auth.AuthBloc>(
                  create: (_) => manager_auth.AuthBloc(),
                ),
                BlocProvider<manager_home.HomeBloc>(
                  create:
                      (_) => manager_home.HomeBloc(
                        authRepository: manager_repo.AuthRepository(),
                      )..add(manager_event.LoadCurrentUserEvent()),
                ),
              ],
              child: const manager.MainScreen(),
            ),
      ),
    );
  }
}
