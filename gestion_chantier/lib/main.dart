import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
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
import 'package:gestion_chantier/manager/pages/splash/splash1.dart';
import 'package:gestion_chantier/manager/repository/auth_repository.dart';
import 'package:gestion_chantier/manager/services/CommandesService.dart';
import 'package:gestion_chantier/manager/services/ConstructionPhaseIndicator_service.dart';
import 'package:gestion_chantier/manager/services/ProjetService.dart';
import 'package:gestion_chantier/manager/services/TaskService.dart';
import 'package:gestion_chantier/manager/services/api_service.dart';
import 'package:gestion_chantier/services/PushNotificationService.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gestion_chantier/l10n/app_localizations.dart';
import 'package:gestion_chantier/shared/bloc/locale_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'bet/utils/HexColor.dart';
import 'bet/utils/constant.dart';
import 'firebase_options.dart';

// import 'package:gestion_chantier/manager/widgets/navitems.dart';
// import 'package:gestion_chantier/ouvrier/pages/ouvrier_main_screen.dart';

// import 'package:gestion_chantier/manager/widgets/navitems.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
late FirebaseAnalytics analytics;

Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await initializeDateFormatting('fr_FR');

      // Initialisation Firebase
      await _initializeFirebase();

      analytics = FirebaseAnalytics.instance;

      // Initialisation des services
      await _initializeServices();

      // Lancement de l'application
      runApp(MyApp());
    },
    (error, stack) {
      debugPrint('Erreur non capturée: $error');
      debugPrint('Stack trace: $stack');
    },
  );
}

Future<void> _initializeServices() async {
  try {
    await PushNotificationService().initialize();
  } catch (e) {
    debugPrint('Error initializing services: $e');
  }
}

// 🔥 FONCTION D'INITIALISATION FIREBASE CORRIGÉE
Future<void> _initializeFirebase() async {
  try {
    print('🔄 Début initialisation Firebase...');

    // IMPORTANT : Attendre que Firebase soit prêt
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    print('✅ Firebase.initializeApp() terminé avec succès');

    // Vérification supplémentaire
    final app = Firebase.app();
    print('📱 Application Firebase: ${app.name}');
    print('📱 Project ID: ${app.options.projectId}');
    print('📱 API Key: ${app.options.apiKey}');

    // Test immédiat avec Analytics
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'firebase_initialized',
        parameters: {'platform': 'ios', 'time': DateTime.now().toString()},
      );
      print('✅ Test Analytics réussi');
    } catch (e) {
      print('⚠️ Analytics test échoué: $e');
    }
  } catch (e, stack) {
    print('❌ ERREUR CRITIQUE Firebase.initializeApp: $e');
    print('Stack trace: $stack');

    // Essayez avec des options par défaut comme fallback
    try {
      print('🔄 Tentative avec options par défaut...');
      await Firebase.initializeApp();
      print('✅ Firebase initialisé avec options par défaut');
    } catch (e2) {
      print('❌ Échec total Firebase: $e2');
      rethrow;
    }
  }
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
        child: BlocProvider(
          create: (_) => LocaleBloc()..add(LoadLocaleEvent()),
          child: BlocBuilder<LocaleBloc, LocaleState>(
            builder: (context, localeState) {
              return MaterialApp(
                title: 'BTP Cloud',
                theme: _buildAppTheme(),
                debugShowCheckedModeBanner: false,
                locale: localeState.locale,
                supportedLocales: const [Locale('fr'), Locale('en')],
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                home: SplashScreen(),
              );
            },
          ),
        ),
      ),
    );
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
      primaryColor: HexColor(APIConstants.primaryColorValue),
      colorScheme: ColorScheme.fromSeed(
        seedColor: HexColor(APIConstants.secondaryColorValue),
        brightness: Brightness.light,
      ),
      fontFamily: 'Poppins',
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Poppins'),
        displayMedium: TextStyle(fontFamily: 'Poppins'),
        displaySmall: TextStyle(fontFamily: 'Poppins'),
        headlineLarge: TextStyle(fontFamily: 'Poppins'),
        headlineMedium: TextStyle(fontFamily: 'Poppins'),
        headlineSmall: TextStyle(fontFamily: 'Poppins'),
        titleLarge: TextStyle(fontFamily: 'Poppins'),
        titleMedium: TextStyle(fontFamily: 'Poppins'),
        titleSmall: TextStyle(fontFamily: 'Poppins'),
        bodyLarge: TextStyle(fontFamily: 'Poppins'),
        bodyMedium: TextStyle(fontFamily: 'Poppins'),
        bodySmall: TextStyle(fontFamily: 'Poppins'),
        labelLarge: TextStyle(fontFamily: 'Poppins'),
        labelMedium: TextStyle(fontFamily: 'Poppins'),
        labelSmall: TextStyle(fontFamily: 'Poppins'),
      ),
    );
  }
}
