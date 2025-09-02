import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/manager/bloc/Indicator/ConstructionIndicatorBloc.dart';
import 'package:gestion_chantier/manager/bloc/Task/task_bloc.dart';
import 'package:gestion_chantier/manager/bloc/auth/auth_bloc.dart';
import 'package:gestion_chantier/manager/bloc/commades/commandes_bloc.dart';
import 'package:gestion_chantier/manager/bloc/home/home_bloc.dart';
import 'package:gestion_chantier/manager/bloc/home/home_event.dart';
import 'package:gestion_chantier/manager/bloc/projet/projet_bloc.dart';
import 'package:gestion_chantier/manager/bloc/projets/projet_bloc.dart';
import 'package:gestion_chantier/manager/pages/auth/login.dart';
import 'package:gestion_chantier/manager/repository/auth_repository.dart';
import 'package:gestion_chantier/manager/services/CommandesService.dart';
import 'package:gestion_chantier/manager/services/ConstructionPhaseIndicator_service.dart';
import 'package:gestion_chantier/manager/services/ProjetService.dart';
import 'package:gestion_chantier/manager/services/TaskService.dart';
import 'package:gestion_chantier/manager/services/api_service.dart';
// import 'package:gestion_chantier/manager/widgets/navitems.dart';
// import 'package:gestion_chantier/ouvrier/pages/ouvrier_main_screen.dart';

// import 'package:gestion_chantier/manager/widgets/navitems.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ApiService apiService = ApiService();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [RepositoryProvider.value(value: apiService)],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthBloc()),
          BlocProvider(
            create:
                (context) =>
                    HomeBloc(authRepository: AuthRepository())
                      ..add(LoadCurrentUserEvent()),
          ),
          BlocProvider<ProjetsBloc>(
            create: (context) {
              final currentUser = context.read<HomeBloc>().state.currentUser;
              return ProjetsBloc(
                promoterId: currentUser?.id ?? 0,
                realEstateService: RealEstateService(),
              );
            },
          ),
          // Ajoutez ceci :
          BlocProvider(create: (_) => NavigationBloc()),
          BlocProvider<TaskBloc>(create: (context) => TaskBloc(TaskService())),
          BlocProvider<ConstructionIndicatorBloc>(
            create:
                (context) => ConstructionIndicatorBloc(
                  service: ConstructionIndicatorService(),
                ),
          ),

          BlocProvider(
            create:
                (context) => CommandeBloc(commandeService: CommandeService()),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: LoginScreen(),
        ),
      ),
    );
  }
}
